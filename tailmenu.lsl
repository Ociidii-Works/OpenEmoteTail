//////////////////////////////////////////////////////////////////////////////////
//  OPEN EMOTE TAIL INTERACTIVE SCRIPT                                          //
//  Copyright (c) 2016 Xenhat Liamano                                           //
//  THIS MATERIAL IS PROVIDED AS IS, WITH ABSOLUTELY NO WARRANTY EXPRESSED      //
//  OR IMPLIED.  ANY USE IS AT YOUR OWN RISK.                                   //
//                                                                              //
//  Permission is hereby granted to use or copy this program                    //
//  for any purpose,  provided the above notices are retained on all copies.    //
//  Permission to modify the code and to distribute modified code is granted,   //
//  provided the above notices are retained, and a notice that the code was     //
//  modified is included with the above copyright notice.                       //
//////////////////////////////////////////////////////////////////////////////////

// The latest version of this script can always be found at
// https://raw.github.com/Xenhat/OpenEmoteTail/master/tailmenu.lsl
// A version checker is included.

string g_current_version              =   "3.7.39";
integer touchDelay = 1; // How long to wait before displaying owner menu
// Save settings to prim desc. Disable to avoid breaking objects that also use this storage method. you will however lose your settings if the script is reset.
integer g_saveToDesc_b                = FALSE;
// Todo: Use StringReplace instead of variables for Him/Her/His
//       Refactor Variables
string objectType       =   "tail";           // Is it a tail, a nose, a head, etc.?
integer  bHasDick       =   0;                // set default gender here.
// 0 for FEMALE
// 1 for MALE
integer bLinkForNames = 0;           // Display names in emotes using icon-less SLURL
integer bLinkForOwner = 1;           // Display owner name in emotes using icon-less SLURL
integer useTwitcher = 0; // Use the twitcher (requires Twitcher script)

/////////////////////////////////////////////////////////////////////////
/// Internal shit, don't touch unless you know what you're doing! //////
///////////////////////////////////////////////////////////////////////
/// Variables //////
key http_request_id;
string repository = "XenHat/OpenEmoteTail";
integer MessagesLevel = 2;          // 0: none, 1: error , 2: warning, 3: info, 4: debug
integer time;
integer listen_timeout = 60;
integer iShowMemStats = 0;             // Show Memory statistics
list lEmoteTypeMenu =   ["Soft Emotes"
                        ,"Adult Emotes"
                        ];
list list_soft = ["Nom On","Chew On","Bite","Pet","Tug","Grab","Fluff","Play","Hug","Hold"];
list list_adult = ["Grope","Hump","Lick Butt","Lick Genitals","Smack Butt"];
//// Other variables ////
key kOwnerKey;                      // avoid calling llGetOwner so often.
key kToucherKey;
key kLastToucher = NULL_KEY;                    // Store the last person that touched the tail
string sOwnerName;                  // Needed for owner identification
integer lock = FALSE;               // Boolean for locking capability
integer bMenuInUse = FALSE;           // Boolean to store if the key tail is in use
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
integer APP_ID = 83; // kittyface
integer gMemoryLimit_i = 3000;
integer gShowUpdateCheckButton_b = TRUE;
string gUpdateMessage_s = "";
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
    bHasDick = iNewGender;
    saveToDesc();
}
saveToDesc()
{
    if (!g_saveToDesc_b) return;
    llSetObjectDesc("#OET:g=" + (string)bHasDick + ",t=" + objectType);
}
memstats(string type)
{
    if(!iShowMemStats)
    {
        return;
    }
    dm(4,type,(string)llGetMemoryLimit() + " kb allocated");
    dm(4,type,(string)llGetUsedMemory() + " kb used");
    dm(4,type,(string)llGetFreeMemory() + " kb free");
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
    if(type == 5)
    llOwnerSay("D:" + e + " " + m);

    m = " " + llStringTrim(m,0x3);
    if(type == 1 && MessagesLevel >= 1)
    llOwnerSay("E:" + e + " " + m);

    if(type == 2 && MessagesLevel >= 2)
    llOwnerSay("W:" + e + " " + m);

    if(type == 3 && MessagesLevel >= 3)
    llOwnerSay("I:" + e + " " + m);

    if(type == 4 && MessagesLevel >= 4)
    llOwnerSay("D:" + e + " " + m);
}
twitch(string times)
{
    if(useTwitcher)
    {
        llMessageLinked(LINK_THIS, 0, "t " + times, "");
    }
}
string Key2Link(key k)
{
    return "[secondlife:///app/agent/" + (string)k
    + "/about " + llGetDisplayName(k) + "]";
}
init()
{
    kOwnerKey = llGetOwner();
    //Message stuff
    string et = "init";
    dm(4,et,"Running OET v" + g_current_version + "...");
    sObjectName = llGetObjectName();
    sOwnerName = llGetDisplayName(kOwnerKey);
    // simplistic gender auto-detection.
    if (g_saveToDesc_b)
    {
        string desc = llGetObjectDesc();
        if (desc == "")
        {
            bHasDick = (integer)llList2Integer(llGetObjectDetails(kOwnerKey,[OBJECT_BODY_SHAPE_TYPE]),0);
        }
    }
    string nameEnd = llGetSubString(sOwnerName, -1, -1);
    if (nameEnd == "s")
    {
        sOwnerPossessive = "'";
        dm(3,et,"This is " + sOwnerName + sOwnerPossessive + " " + objectType + ".");
    }
    else
    {
        sOwnerPossessive = "'s";
    }
    fSetGender( bHasDick);
    memstats(et);
}
//// Menus ////
/* Menu Types:
0: Others Menu
1: Cute
2: Adult
3: Gender Menu
*/
integer OWNER_MENU = 0;
integer GENDER_MENU = 1;
integer OTHERS_MENU = 2;
integer SOFT_MENU = 3;
integer ADULT_MENU = 4;

xlGenerateDialogText(string sHelpText, list lButtons)
{
    sHelpText = "Based on [https://github.com/XenHat/OpenEmoteTail OpenEmoteTail] "
    + g_current_version + " by secondlife:///app/agent/f1a73716-4ad2-4548-9f0e-634c7a98fe86/inspect.";
    if(bMenuType == OWNER_MENU)
    {
        sHelpText += gUpdateMessage_s;
    }
    llSetTimerEvent(0.0);
    llSetTimerEvent(listen_timeout);
    llDialog(kToucherKey,sHelpText,lButtons,iChannel);
}
integer bMenuType;
fBuildMenu(integer newMenuType_i)
{
    bMenuType = newMenuType_i;
    string et = "fBuildMenu";
    if(MessagesLevel>2) memstats(et);
    dm(4,et,"Received Menu Type: " + (string)bMenuType);
    dm(4,et,"Received Key: " + (string)kToucherKey);
    iChannel = 0x80000000 | ((integer)("0x"+(string)kToucherKey) ^ APP_ID);
    dm(4,et,"Channel = " + (string)iChannel);
    fClearListeners();
    iListenHandle = llListen(iChannel, "", kToucherKey, "");
    dm(4,et,"Now listening on = " + (string)iChannel + " for secondlife:///app/agent/"+(string)kToucherKey+"/displayname");

    
    if(bMenuType == OWNER_MENU)
    {
        //// Owner Menu ////
        if (kToucherKey != NULL_KEY && kToucherKey != kOwnerKey)
        {
            return;
        }
        dm(3,et,"Entering Owner Menu");
        { // Owner Menu Root
            list menu_buttons = ["Waggle", "Gender"];
            dm(3,et,"Checking Lock");
            if(!lock) // if not locked
            {
                dm(4,et,"Is Unlocked");
                menu_buttons += ["Lock"];
            }
            else // if locked
            {
                dm(4,et,"Is Locked");
                menu_buttons += ["Unlock"];
            }
            if (gShowUpdateCheckButton_b)
            {
                menu_buttons += ["Check Update"];
            }
            xlGenerateDialogText("\nChange " + objectType + " option",menu_buttons);
        }
    }
    else if(bMenuType == GENDER_MENU) // Gender Menu
    {
        dm(3,et,"Entering Gender Menu");
        xlGenerateDialogText("Sausage or Tacos?",["Sausage","Tacos"]);
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
            if(bMenuType == OTHERS_MENU)
            {
                dm(4,et,"Building Choice Menu");
                xlGenerateDialogText("Chose an Emote type",lEmoteTypeMenu);
            }
            else if(bMenuType == SOFT_MENU)
            {
                dm(4,et,"Building Soft Menu");
                xlGenerateDialogText("Okay, what do you want to do?",list_soft);
            }
            else if(bMenuType == ADULT_MENU)
            {
                dm(4,et,"Building Adult Menu");
                xlGenerateDialogText("Feeling naughty, eh? How much?",list_adult);
            }
        }
    }
    else
    {
        dm(4,et,"Something unexpected happened D:");
    }
    twitch("1");
    if(MessagesLevel>2) memstats(et);
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
getLatestUpdate()
{
    llSetMemoryLimit(64000);
    if(MessagesLevel>=4) llOwnerSay("Looking for update...");
    http_request_id = llHTTPRequest("https://api.github.com/repos/"+repository+"/releases/latest?access_token=603ee815cda6fb45fcc16876effbda017f158bef",[], "");
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
        twitch("3");
        if(kID != NULL_KEY)
        llRequestPermissions(kOwnerKey, PERMISSION_TAKE_CONTROLS );
        if(MessagesLevel>2) memstats("attach");
        getLatestUpdate();
    }
    on_rez(integer start_param)
    {
        // Do nothing if attached (login?)
        if(llGetAttached())
        {
            return;
        }
        kToucherKey = llGetOwner();
        fBuildMenu(GENDER_MENU);
        twitch("2");
    }
    state_entry()
    {
        if(MessagesLevel>=4)
        {
            gMemoryLimit_i = 64000;
        }
        // Menu stuff
        init();
        llSleep(0.1); // let GC do its thing
        if (!~(""!="x")){
            llOwnerSay(llGetScriptName() + " cannot breathe! Please recompile it as Mono!");
        }
        llSetMemoryLimit(llGetUsedMemory()+gMemoryLimit_i); // fat. I know.
        if (llGetScriptName() == "New Script")
        {
            string oname = llGetObjectName();
            llSetObjectName("");
            llOwnerSay("/me secondlife:///app/agent/f1a73716-4ad2-4548-9f0e-634c7a98fe86/inspect stares at you from far away... \"'New Script', really?\"");
            llSetObjectName(oname);
        }
        if (llGetObjectName() == "Object")
        {
            string oname = llGetObjectName();
            llSetObjectName("");
            llOwnerSay("/me secondlife:///app/agent/f1a73716-4ad2-4548-9f0e-634c7a98fe86/inspect stares at you from far away... \"'OH COME ON! Name that poor prim!\"");
            llSetObjectName(oname);
        }
        getLatestUpdate();
    }
    touch_start(integer num_detected)
    {
        time = llGetUnixTime();
    }
    touch_end(integer total_number)
    {
        kToucherKey = llDetectedKey(0);
        string et = "touch_end";
        dm(4,"touch_end",(string)kToucherKey);
        //llOwnerSay("Level 1");
        if ((bMenuInUse) /* is the tail already in use? */
            || ((kLastToucher != NULL_KEY) // Not a null key (default value)
            && (kLastToucher != kToucherKey))) // Different person, in this dimension
        {
            //llOwnerSay("Level 2");
            kLastToucher = kToucherKey; // Store the new key
            dm(4,et,"Clearing listener because toucher changed");
            fClearListeners();
        }
        dm(4,et,"Checking user and generating new menus");
        if(kToucherKey == kOwnerKey)
        {
            dm(4,et,"Toucher is owner");
            if (llGetUnixTime() >= (time + touchDelay))
            {
                fBuildMenu(OWNER_MENU);
            }
        }
        if (kToucherKey != kOwnerKey)
        {
            dm(4,et,"Toucher is other");
            fBuildMenu(OTHERS_MENU);
            sToucherName = llGetDisplayName(kToucherKey);
            llOwnerSay(sToucherName + " is touching your " + objectType + "...");
            string nameEnd = llGetSubString(sToucherName, -1, -1);
            if (nameEnd == "s")
            {
                sToucherPossessive = "'";
            }
            else
            {
                sToucherPossessive = "'s";
            }
        }
        llSetTimerEvent(listen_timeout);
        time = 0;
    }
    listen(integer c, string n, key kToucherKey, string m)
    {
        if(!c) return; // Don't listen on channel 0
        string et = "listen";
        dm(4,et,"Channel received: " + (string)c);
        dm(4,et,"Listening for menu type = " + (string)bMenuType);
        dm(4,et,n + " selected " + m);
        if (bLinkForNames)
        {
            n=Key2Link(kToucherKey);
        }
        else
        {
            n = llGetDisplayName(kToucherKey);
        }
        // tail commands
        // if(bMenuType == OTHERS_MENU)
        {
            if(m == "Soft Emotes")
            {
                llListenRemove(iListenHandle);
                fBuildMenu(SOFT_MENU);
            }
            else if(m == "Adult Emotes")
            {
                llListenRemove(iListenHandle);
                fBuildMenu(ADULT_MENU);
            }
            else if(m == "Gender") // 2
            {
                fBuildMenu(GENDER_MENU);
            }
            else if(m == "Emote")
            {
                xlGenerateDialogText("What kind of emotes do you want to do?",lEmoteTypeMenu);
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
                llSetObjectName(" ");
                llSay(0,"/me " + n + " waggles " + sGenderHis + " " + objectType + " happily!");
                llSetObjectName(sObjectName);
                twitch("7");
            }
            else if(m == "Check Update")
            {
                llListenRemove(iListenHandle);
                getLatestUpdate();
            }
        }
        if (bMenuType == GENDER_MENU)
        {
            dm(4,et,"Processing Gender Response");
            if(m == "Tacos")
            {
                fSetGender(0);
                dm(3,et,"gender set to female");
            }
            else if(m == "Sausage")
            {
                fSetGender(1);
                dm(3,et,"gender set to male");
            }
            fClearListeners();
        }
        //// Soft Emotes ////
        // else if(bMenuType == SOFT_MENU)
        {
            llSetObjectName(" ");
            string sOwnerNameInEmote;
            if (bLinkForNames && bLinkForOwner)
            {
                sOwnerNameInEmote = Key2Link(kOwnerKey);
            }
            else
            {
                sOwnerNameInEmote = sOwnerName;
            }
            if(bMenuType == SOFT_MENU)
            {
                if(m == "Nom On")
                {
                    llSay(0,"/me " + n + " grabs and noms on " + sOwnerNameInEmote + sOwnerPossessive + " " + objectType + ". " + sOwnerNameInEmote + " looks back at " + sGenderHis + " " + objectType + " to make sure " + n + " did not drool all over it.");
                }
                else if(m == "Chew On")
                {
                    llSay(0,"/me " + n + " starts to chew on " + sOwnerNameInEmote + sOwnerPossessive + " " + objectType + ". " + sOwnerNameInEmote + " is not too sure how to feel about this o.o...");
                }
                else if(m == "Bite")
                {
                    llSay(0,"/me " + n + " bites down on " + sOwnerNameInEmote + sOwnerPossessive + " " + objectType + "! >w<");
                }
                else if(m == "Pet")
                {
                    llSay(0,"/me " + n + " takes a hold of " + sOwnerNameInEmote + sOwnerPossessive + " " + objectType + " and starts petting it! ♥");
                }
                else if(m == "Tug")
                {
                    llSay(0,"/me " + n + " grabs and tugs hard on " + sOwnerNameInEmote + sOwnerPossessive + " " + objectType + "! " + sOwnerNameInEmote + " tugs back on " + n + sToucherPossessive + " ear! :3");
                }
                else if(m == "Grab")
                {
                    llSay(0,"/me " + n + " grabs " + sOwnerNameInEmote + sOwnerPossessive + " " + objectType + " and just holds it. " + sOwnerNameInEmote + " looks back at " + n + ".");
                }
                else if(m == "Play")
                {
                    llSay(0,sOwnerName + " swishes " + sGenderHis + " " + objectType + " about. " + n + " grabs it and starts tugging it playfully.");
                }
                else if(m == "Hug")
                {
                    llSay(0,"/me " + n + " grabs " + sOwnerNameInEmote + sOwnerPossessive + " " + objectType + " and gives it a big hug! ♥");
                }
                else if(m == "Hold")
                {
                    llSay(0,"/me " + n + " grabs and holds " + sOwnerNameInEmote + sOwnerPossessive + " " + objectType + ", refusing to let " + sGenderHim + " go!");
                }
                else if(m == "Fluff")
                {
                    llSay(0,"/me " + n + " fluffs " + sOwnerNameInEmote + sOwnerPossessive + " " + objectType + ", making it nice and soft. ^^");
                }
                llSetObjectName(sObjectName);
            }
            /// Adult Emotes ////
            else if(bMenuType == ADULT_MENU) // 1
            {
                llSetObjectName(" ");
                if(m == "Lick Genitals")
                {
                    if( bHasDick == 1){
                        llSay(0,"/me " + n + " bends down in front of " + sOwnerNameInEmote + ", slowly moving their hands to reach " + sOwnerNameInEmote + sOwnerPossessive + " butt, squeezing it softly with one hand as they grab his cock, slowly licking it up and down while looking at him...");
                    }
                    else{
                        llSay(0,"/me " + n + " bends down in front of " + sOwnerNameInEmote + ", slowly kissing her lap and then put their mouth on her pussy, licking slowly...");
                    }
                }
                else if(m == "Lick Butt")
                {
                    llSay(0,"/me " + n + " bends down and licks " + sOwnerNameInEmote + sOwnerPossessive + " butt! ♥");
                }
                else if(m == "Smack Butt")
                {
                    llSay(0,"/me " + n + " smacks " + sOwnerNameInEmote + sOwnerPossessive + " butt!");
                }
                else if(m == "Grope")
                {
                    llSay(0,"/me " + n + " gropes " + sOwnerNameInEmote + "! ^_~");
                }
                else if(m == "Hump")
                {
                    llSay(0,"/me " + n + " grabs " + sOwnerNameInEmote + " from behind and starts humpin!");
                }
                llSetObjectName(sObjectName);
            }
            // fClearListeners();
        }
        //// Owner Menu ////
        // else
        // {
            // dm(2,et,"Something unexpected happened");
            //dm(4,et,"Message Received: " + m);
        // }
    }
    http_response(key request_id, integer status, list metadata, string body)
    {
        if (request_id != http_request_id) return;// exit if unknown
        string new_version_s = llJsonGetValue(body,["tag_name"]);
        if (new_version_s == g_current_version) return;
        list cur_version_l = llParseString2List(g_current_version, ["."], [""]);
        list new_version_l = llParseString2List(new_version_s, ["."], [""]);
        string update_type = "version";
        if (llList2Integer(new_version_l, 0) > llList2Integer(cur_version_l, 0)){
            update_type = "major version"; jump update;
        }
        else if (llList2Integer(new_version_l, 1) > llList2Integer(cur_version_l, 1)){
            update_type = "minor version"; jump update;
        }
        else if (llList2Integer(cur_version_l, 2) < llList2Integer(new_version_l, 2)){
            update_type = "patch"; jump update;
        }
        jump end;
        @update;
        gUpdateMessage_s = "\nA new " + update_type + " is available:"
            +"\n"
            +"\n[https://github.com/"
                +repository+"/tree/"+new_version_s+"/ "+new_version_s
                +"] \""+llJsonGetValue(body,["name"])+"\"";
            string update_description_s = llJsonGetValue(body,["body"]);
            if(llStringLength(update_description_s) > 256)
            {
                update_description_s = "Too many changes, see [https://github.com/"
                +repository+"/tree/"+new_version_s+"/ online]";
            }
            gUpdateMessage_s +="\n"+update_description_s
            +"\nYou can view the changelog ["+"https://github.com/"+repository+"/compare/"
                +g_current_version+"..."+new_version_s+" on GitHub].\n\n"

            +"Raw scripts to copy-paste:\n[https://raw.githubusercontent.com/"+repository
                +"/"+new_version_s+"/tailmenu.lsl OpenEmoteTail.lsl]";
            ;
            gShowUpdateCheckButton_b = FALSE;
        llOwnerSay("["+llGetScriptName()+".lsl] "+g_current_version + "\n"+gUpdateMessage_s);
        @end;
        llSetMemoryLimit(llGetUsedMemory()+gMemoryLimit_i);
    }
    timer()
    {
        fClearListeners();
    }
}
