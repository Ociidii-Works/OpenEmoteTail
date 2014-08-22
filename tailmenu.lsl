// The latest version of this script can be found at
// https://raw.github.com/Ociidii-Works/OpenEmoteTail/master/tailmenu.lsl
string ver = "3.7.5";
// Todo: Use StringReplace instead of variables for Him/Her/His
//       Refactor Variables
integer bGender = 0;                // set default gender here.
// 0 for FEMALE
// 1 for MALE
// integer useTwitcher = 0; // Use the twitcher (requires Twitcher script)
/////////////////////////////////////////////////////////////////////////
/// Internal shit, don't touch unless you know what you're doing! //////
///////////////////////////////////////////////////////////////////////
/// Variables //////
integer MessagesLevel = 0;          // 0: none, 1: error , 2: warning, 3: info, 4: debug
integer iShowMemStats = FALSE;             // Show Memory statistics
list lEmoteTypeMenu = ["Soft Emotes","Adult Emotes"];
list list_soft = ["Nom On","Chew On","Bite","Pet","Tug","Grab","Play","Hug","Hold"];
list list_adult = ["Fluff","Grope","Hump","Lick Butt","Lick Genitals","Smack Butt"];
//// Other variables ////
key kOwnerKey;                      // avoid calling llGetOwner so often.
string sOwnerName;                  // Needed for owner identification
integer lock = FALSE;               // Boolean for locking capability
integer iChannel;                   // Required for channel reference.
string sToucherName;                // Required to re-use the name of who is touching the tail
integer iListenHandle;              // Required for the listener.
//key kToucherKey;                  // This will be set to the toucher's key. Used for user detection.
string sObjectName;                 //  To keep a name for the object when needed.
// string sEmoteMessage;               // Used to send the emote to the world
//// Automagical Ending fixer ////
string sOwnerPossessive;
string sToucherPossessive;
string sGenderHim;
string sGenderHis;
string sGenderHeCap;
//// Functions ////
fSetGender(integer iNewGender)
{
    if(!iNewGender)
    {
        sGenderHim = "her";
        sGenderHis = "her";
        sGenderHeCap = "She";
    }
    else
    {
        sGenderHim = "him";
        sGenderHis = "his";
        sGenderHeCap = "He";
    }
    bGender = iNewGender;
}
memstats(string type)
{
    if(iShowMemStats)
    {
        dm(5,type,(string)llGetMemoryLimit()+" kb allocated");
        dm(5,type,(string)llGetUsedMemory()+" kb used");
        dm(5,type,(string)llGetFreeMemory()+" kb free");
    }
}
dm(integer type, string e, string m)
{
    /*  t
            1 = error
            2 = warning
            3 = info
            4 = debug
            5 = memstats
        e
            event the message comes from
        m
            the actual message
    */
    m = " "+llStringTrim(m,0x3);
    if(type == 1 && MessagesLevel >= 1)
        llRegionSayTo(kOwnerKey,0, "E:"+e+" "+ m);

    if(type == 2 && MessagesLevel >= 2)
        llRegionSayTo(kOwnerKey,0, "W:"+e+" "+ m);

    if(type == 3 && MessagesLevel >= 3)
        llRegionSayTo(kOwnerKey,0, "I:"+e+" "+ m);

    if(type == 4 && MessagesLevel >= 4)
        llRegionSayTo(kOwnerKey,0, "D:"+e+" "+ m);
    
     if(type == 5)
         llRegionSayTo(kOwnerKey,0, "D:"+e+" "+ m);
}
// twitch(string times)
// {
//     if(useTwitcher == 1)
//     {
//         llMessageLinked(LINK_THIS, 0, "t "+times, "");
//     }
// }
string Key2Link(key k)
{
    return "[secondlife:///app/agent/"+(string)k
    + "/about "+llGetDisplayName(k)+"]";
}
init()
{
    kOwnerKey = llGetOwner();
    //Message stuff
    string et = "init";
    dm(4,et,"Running OET v"+ver+"...");
    sObjectName = llGetObjectName();
    sOwnerName = llGetDisplayName(kOwnerKey);
    string nameEnd = llGetSubString(sOwnerName, -1, -1);
    if (nameEnd == "s")
    {
        sOwnerPossessive = "'";
        dm(3,et,"This is "+sOwnerName+sOwnerPossessive+ " tail.");
    }
    else
    {
        sOwnerPossessive = "'s";
    }
    fSetGender(bGender);
    memstats(et);
}
//// Menus ////
/* Menu Types:
0: Others Menu
1: Cute
2: Adult
3: Gender Menu
*/
integer bMenuType;
fBuildMenu(integer bInternalMenuSelect, key kToucherKey)
{
    string et = "fBuildMenu";
    memstats(et);
    dm(4,et,"Received Menu Type: "+(string)bInternalMenuSelect);
    dm(4,et,"Received Key: "+(string)kToucherKey);
    sToucherName = llGetDisplayName(kToucherKey);
    iChannel = 0x80000000 | (integer)("0x"+(string)llDetectedKey(0));
    dm(4,et,"Channel = " + (string)iChannel);
    iListenHandle = llListen(iChannel, "", kToucherKey, "");
    //// Owner Menu ////
    if(kToucherKey == kOwnerKey)
    {
        dm(3,et,"Entering Owner Menu");
        if(bInternalMenuSelect == 0)
        { // Owner Menu Root
            dm(3,et,"Checking Lock");
            if(!lock) // if not locked
            {
                 dm(4,et,"Is Unlocked");
                llDialog(kOwnerKey,"\nChange Tail option",["Waggle","Lock","Gender"],iChannel);
            }
            else // if locked
            {
                 dm(4,et,"Is Locked");
                llDialog(kOwnerKey,"\nChange Tail option",["Waggle","Unlock","Gender"],iChannel);
            }
        }
        if(bInternalMenuSelect == 3) // Gender Menu
        {
            dm(3,et,"Entering Gender Menu");
            llDialog(kToucherKey,"Sausage or Tacos?",["Sausage","Tacos"],iChannel);
        }
    }
    //// Others Menu ////
    else if(kToucherKey != kOwnerKey)
    {
        dm(4,et,"Checking Lock for Others");
        if(lock)
        {
            llListenRemove(iListenHandle);
        }
        else // if not locked and not owner
        {
            dm(4,et,"Entering Others Menu");
            llSetObjectName("");
            llOwnerSay(sToucherName + " is touching your tail...");
            llSetObjectName(sObjectName);
            if(bInternalMenuSelect == 0) // Root Menu
            {
                dm(4,et,"Building Choice Menu");
                llDialog(kToucherKey,"Chose an Emote type",lEmoteTypeMenu,iChannel);
            }
            else if(bInternalMenuSelect == 1) // Soft Menu
            {
                dm(4,et,"Building Soft Menu");
                llDialog(kToucherKey,"Okay, what do you want to do?",list_soft,iChannel);
            }
            else if(bInternalMenuSelect == 2) // Adult Menu
            {
                dm(4,et,"Building Adult Menu");
                llDialog(kToucherKey,"Feeling naughty, eh? How much?",list_adult,iChannel);
            }
        }
    }
    else
    {
        dm(4,et,"Something unexpected happened D:");
    }
    // twitch("1");
    memstats(et);
}
fClearListeners()
{
    string et = "fClearListeners";
    // Stop listening. It's wise to do this to reduce lag
    llListenRemove(iListenHandle);
    // Stop the timer now that its job is done
    llSetTimerEvent(0.0);
    //llInstantMessage(kToucherKey,"Timed out. Click the tail again to get a menu");
    dm(3,et,"Listener closed");
}
default
{
    changed(integer iChange)
    {
        if (iChange & CHANGED_OWNER) //note that it's & and not &&... it's bitwise!
        {
            llOwnerSay("The owner of the object has changed. Resetting!");
            llResetScript();
        }
    }
    attach(key kID)
    {
        if(kOwnerKey != llGetOwner()) llResetScript();
        init();
        // twitch("3");
        if(kID != NULL_KEY)
        llRequestPermissions(kOwnerKey, PERMISSION_TAKE_CONTROLS );
        memstats("attach");
    }
    on_rez(integer start_param)
    {
        if(start_param)
        {
            init();
            llSleep(2);
            llDialog(llGetOwner(),"Sausage or Tacos?",["Sausage","Tacos"],iChannel);
            // twitch("2");
        }
    }
    state_entry()
    {
        llSetMemoryLimit(1024*32);
        // Menu stuff
        init();
    }
    touch_end(integer total_number)
    {
        if(total_number>0)
        {
            llListenRemove(iListenHandle);
            llSetTimerEvent(15);
            fBuildMenu(0, llDetectedKey(0));

        }
    }
    listen(integer c, string n, key kToucherKey, string m)
    {
        if(!c) return;
        //string m = llToLower(m);
        n=Key2Link(kToucherKey);
        string et = "listen";
        dm(4,et,n+" selected "+m);
        //         n = llGetDisplayName(i);
        // tail commands
        if(bMenuType == 0)
        {
            if(m == "Soft Emotes")
            {
                llListenRemove(iListenHandle);
                bMenuType = 1;
                fBuildMenu(bMenuType, kToucherKey);
            }
            else if(m == "Adult Emotes")
            {
                llListenRemove(iListenHandle);
                bMenuType = 2;
                fBuildMenu(bMenuType, kToucherKey);
            }
            else if(m == "Gender") // 2
            {
                bMenuType = 3;
                fBuildMenu(bMenuType, kToucherKey);
            }
            else if(m == "Emote")
            {
                llDialog(kToucherKey,"What kind of emotes do you want to do?",lEmoteTypeMenu,iChannel);
            }
            else if(m == "Lock")
            {
                llListenRemove(iListenHandle);
                lock = TRUE;
                llOwnerSay("Locked");
                fClearListeners();
            }
            else if(m == "Unlock")
            {
                llListenRemove(iListenHandle);
                lock = FALSE;
                llOwnerSay("Unlocked");
                fClearListeners();
            }
            else if(m == "Waggle")
            {
                llListenRemove(iListenHandle);
                llSetObjectName("");
                llSay(0,n+" waggles " + sGenderHis + " tail happily!");
                llSetObjectName(sObjectName);
                // twitch("7");
                fClearListeners();
            }
        }
        else if (bMenuType == 3)
        {
            if(m == "Tacos")
            {
                llListenRemove(iListenHandle);
                fSetGender(0);
                dm(3,et,"gender set to female");
            }
            else if(m == "Sausage")
            {
                llListenRemove(iListenHandle);
                fSetGender(1);
                dm(3,et,"gender set to male");
            }
            bMenuType = 0;
            fClearListeners();
        }
        //// Soft Emotes ////
        else if(bMenuType == 1) // 0
        {
            if(m == "Nom On")
            {
                llListenRemove(iListenHandle);
                llSay(0,n+" grabs and noms on "+sOwnerName+sOwnerPossessive+ " tail. "+sOwnerName+" looks back at "+sGenderHis+" tail to make sure "+n+" did not drool all over it.");
            }
            else if(m == "Chew On")
            {
                llListenRemove(iListenHandle);
                llSay(0,n+" starts to chew on " +sOwnerName+sOwnerPossessive+" tail. "+sOwnerName+" is not too sure how to feel about this o.o...");
            }
            else if(m == "Bite")
            {
                llListenRemove(iListenHandle);
                llSay(0,n+" bites down on "+sOwnerName+sOwnerPossessive+" tail! >w<");
            }
            else if(m == "Pet")
            {
                llListenRemove(iListenHandle);
                llSay(0,n+" takes a hold of "+sOwnerName+sOwnerPossessive+" tail and starts petting it! ♥");
            }
            else if(m == "Tug")
            {
                llListenRemove(iListenHandle);
                llSay(0,n+" grabs and tugs hard on "+sOwnerName+sOwnerPossessive+ " tail! "+sOwnerName+" tugs back on "+n+sToucherPossessive+" ear! :3");
            }
            else if(m == "Grab")
            {
                llListenRemove(iListenHandle);
                llSay(0,n+" grabs "+sOwnerName+sOwnerPossessive+ " tail and just holds it. "+sOwnerName+" looks back at "+n+".");
            }
            else if(m == "Play")
            {
                llListenRemove(iListenHandle);
                llSay(0,sOwnerName+" swishes "+sGenderHis+" tail about. "+n+" grabs it and starts tugging it playfully.");
            }
            else if(m == "Hug")
            {
                llListenRemove(iListenHandle);
                llSay(0,n+" grabs "+sOwnerName+sOwnerPossessive+" tail and gives it a big hug! ♥");
            }
            else if(m == "Hold")
            {
                llListenRemove(iListenHandle);
                llSay(0,n+" grabs and holds "+sOwnerName+sOwnerPossessive+" tail, refusing to let "+sGenderHim+" go!");
            }
            bMenuType = 0;
        }
        /// Adult Emotes ////
        else if(bMenuType == 2) // 1
        {
            if(m == "Lick Genitals")
            {
                if(bGender == 1){
                    llListenRemove(iListenHandle);
                    llSay(0,n+" bends down in front of " + sOwnerName + ", slowly moving their hands to reach " + sOwnerName + sOwnerPossessive + " butt, squeezing it softly with one hand as they grab his cock,  slowly licking it up and down while looking at him...");
                }
                else{
                    llListenRemove(iListenHandle);
                    llSay(0,n+" bends down in front of " + sOwnerName + ", slowly kissing her lap and then put their mouth on her pussy,\n licking slowly...");
                }
                // bMenuType = 0;
            }
            else if(m == "Lick Butt")
            {
                llListenRemove(iListenHandle);
                llSay(0,n+" bends down and licks " + sOwnerName + sOwnerPossessive + " butt! ♥");
            }
            else if(m == "Smack Butt")
            {
                llListenRemove(iListenHandle);
                llSay(0,n+" smacks " + sOwnerName + sOwnerPossessive + " butt!");
            }
            else if(m == "Grope")
            {
                llListenRemove(iListenHandle);
                llSay(0,n+" gropes " + sOwnerName + "! ^_~");
            }
            else if(m == "Hump")
            {
                llListenRemove(iListenHandle);
                llSay(0,n+" grabs " + sOwnerName + " from behind and starts humpin!");
            }
            else if(m == "Fluff")
            {
                llListenRemove(iListenHandle);
                llSay(0,n+" fluffs " + sOwnerName + sOwnerPossessive + " tail, making it nice and soft. ^^");
            }
            bMenuType = 0;
            fClearListeners();
        }
        //// Owner Menu ////
        else
        {
            dm(2,et,"Something unexpected happened");
            //dm(4,et,"Message Received: "+m);
        }
    }
    timer()
    {
        fClearListeners();
    }
}
