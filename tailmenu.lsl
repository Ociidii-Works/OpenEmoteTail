// The latest version of this script can be found at
// https://raw.github.com/Ociidii-Works/OpenEmoteTail/master/tailmenu.lsl
integer bGender = 0; // set default gender here.
// 0 for FEMALE
// 1 for MALE
integer useTwitcher = 0; // Use the twitcher (requires Twitcher script)
/////////////////////////////////////////////////////////////////////////
/// Internal shit, don't touch unless you know what you're doing! //////
///////////////////////////////////////////////////////////////////////
/// Variables //////
integer MessagesLevel = 0; // 0: none, 1: error , 2: info, 3: debug
list emoteType = ["Soft Emotes","Adult Emotes"];
list list_cute = ["Nom","Chew","Bite","Pet","Tug","Grab","Play","Hug","Hold"];
list list_adult = ["Fluff","Grope","Hump","Butt Lick","Genitals Lick","Smack"];
// Other variables //
key ownerkey;           // avoid calling llGetOwner so often.
string owner;           // Needed for owner identification
integer lock = FALSE;   // Boolean for locking capability
integer rand;           // Required for random menu channel (you really want this)
integer chan;          // Required for channel reference.
string touchername;     // Required to re-use the name of who is touching the tail
integer listen_handle;  // Required for the listener.
key toucherkey;         // This will be set to the toucher's key. Used for user detection.
string oName;           //  To keep a name for the object when needed.
// viewer 3 prettyfication //
integer viewer3 = 1;
// Automagical Ending fixer //
string oEnding;
string tEnding;
string sGenderHim;
string sGenderHis;
string sGenderHeCap;
/// Functions //////
changeGender(integer male)
{
    //if (male == 0)
    if(!bGender)
    {
        sGenderHim = "her";
        sGenderHis = "her";
        sGenderHeCap = "She";
    }
    else
    //else if (male == 1)
    {
        sGenderHim = "him";
        sGenderHis = "his";
        sGenderHeCap = "He";
    }
}
ErrorMessage(string message)
{
    if(MessagesLevel >= 1)
        llSay(DEBUG_CHANNEL, "E: " + message);
}
InfoMessage(string message)
{
    if(MessagesLevel >= 2)
        llSay(DEBUG_CHANNEL, "I: " + message);
}
DebugMessage(string message)
{
    if(MessagesLevel >= 3)
        llSay(DEBUG_CHANNEL, "D: " + message);
}
twitch(string times)
{
    if(useTwitcher == 1)
    {
        llMessageLinked(LINK_THIS, 0, "t "+times, "");
    }
}
string Key2Link(key k)
{
    string l = "[secondlife:///app/agent/"+(string)k + "/about "+llList2String(llParseString2List(llGetDisplayName(k)
        +"("+llKey2Name(k)+")", [" "], []), 0) +"]";
    return (string)l;
}
init()
{
    //Message stuff
    oName = llGetObjectName();
    ownerkey = llGetOwner();
    owner = llGetDisplayName(ownerkey);
    string nameEnd = llGetSubString(owner, -1, -1);
    if (nameEnd == "s")
    {
        oEnding = "'";
        InfoMessage("INIT: This is "+owner+oEnding+ " tail.");
    }
}
menu(string type){
    if (type == "cute"){
        state cute;}
    if (type == "adult"){
        state adult;}
    if (type == "owner"){
        state cute;}
    if (type == "0"){
        state cute;}
}
default
{
    changed(integer change)
    {
        if (change & CHANGED_OWNER) //note that it's & and not &&... it's bitwise!
        {
            llOwnerSay("The owner of the object has changed. Resetting!");
            llResetScript();
        }
    }
    attach(key id)
    {
        init();
        twitch("3");
        if(id != NULL_KEY)
        llRequestPermissions(ownerkey, PERMISSION_TAKE_CONTROLS );
    }
    on_rez(integer start_param)
    {
        init();
        llSleep(2);
        llDialog(toucherkey,"Sausage or Tacos?",["Sausage","Tacos"],chan);
        twitch("2");
    }
    state_entry(){
        llSetMemoryLimit(21000);
        // Menu stuff
        init();
    }
    touch_end(integer total_number)
    {
        llListenRemove(listen_handle);
        llSetTimerEvent(15);
        toucherkey = llDetectedKey(0);
        touchername = llGetDisplayName(toucherkey);
        chan = 0x80000000 | (integer)("0x"+(string)llDetectedKey(0));
        DebugMessage("Channel = " + (string)chan);
        listen_handle = llListen(chan, "", toucherkey, "");
        toucherkey = llDetectedKey(0);
        if(toucherkey == ownerkey)
        {
            if(!lock) // if not locked
                //llDialog(ownerkey,"\nChange Tail option",["Waggle","Emote","Lock","Gender"],chan);
                llDialog(ownerkey,"\nChange Tail option",["Waggle","Lock","Gender"],chan);
            else // if locked
                //llDialog(ownerkey,"\nChange Tail option",["Waggle","Emote","Unlock","Gender"],chan);
                llDialog(ownerkey,"\nChange Tail option",["Waggle","Unlock","Gender"],chan);
        }
        else if(lock == FALSE)  // if not locked and not owner
        {
            llSetObjectName("");
            llOwnerSay(touchername + " is touching your tail...");
            llSetObjectName(oName);
            llDialog(toucherkey,"What kind of emotes do you want to do?",emoteType,chan);
        }
        else
        {
            llListenRemove(listen_handle);
        }
        twitch("1");
    }
    listen(integer c, string n, key i, string m)
    {
        //string m = llToLower(m);
        InfoMessage(touchername+" selected "+m);
        if(viewer3)
        {
            n=Key2Link(i);
        }
        else
        {
            string n=llGetDisplayName(i);
        }
//         n = llGetDisplayName(i);
        // tail commands
        if(m == "Soft Emotes")
        {
            llListenRemove(listen_handle);
            state cute;
        }
        else if(m == "Adult Emotes")
        {
            llListenRemove(listen_handle);
            state adult;
        }
        else if(m == "Gender")
        {
                llDialog(toucherkey,"Sausage or Tacos?",["Sausage","Tacos"],chan);
        }
        else if(m == "Tacos")
        {
            llListenRemove(listen_handle);
            changeGender(0);
            InfoMessage("gender set to female");
        }
        else if(m == "Sausage")
        {
            llListenRemove(listen_handle);
            changeGender(1);
            InfoMessage("gender set to male");
        }
        else if(m == "Emote")
        {
            llDialog(toucherkey,"What kind of emotes do you want to do?",emoteType,chan);
        }
        else if(m == "Lock")
        {
            llListenRemove(listen_handle);
            lock = TRUE;
            llOwnerSay("Locked");
        }
        else if(m == "Unlock")
        {
            llListenRemove(listen_handle);
            lock = FALSE;
            llOwnerSay("Unlocked");
        }
        else if(m == "Waggle")
        {
        llListenRemove(listen_handle);
        llSetObjectName("");
        llSay(0,n+" waggles " + sGenderHis + " tail happily!");
        llSetObjectName(oName);
        twitch("7");
        }
        else
        {
            ErrorMessage("Something unexpected happened");
        }
    }
    timer()
    {
        // Stop listening. It's wise to do this to reduce lag
        llListenRemove(listen_handle);
        // Stop the timer now that its job is done
        llSetTimerEvent(0.0);
        llInstantMessage(toucherkey,"Timed out. Click the tail again to get a menu");
        ErrorMessage("Timed out");
    }
}
state cute
{
    state_entry()
    {
        llSetTimerEvent(15);
        listen_handle=llListen(chan,"","","");
        llDialog(toucherkey,"What will you do with " +owner+"'s tail?",list_cute,chan);
    }
    listen(integer c, string n, key i, string m)
    {
        string m = llToLower(m);
        n = llGetDisplayName(i);
        string nameEnd = llGetSubString(n, -1, -1);
        if (nameEnd == "s")
        {
            tEnding = "'";
        }
        nameEnd = "";
        llSetObjectName("");
        // tail commands
        if(m == "nom")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" grabs and noms on "+owner+oEnding+ " tail. "+owner+" looks back at "+sGenderHis+" tail to make sure "+n+" did not drool all over it.");
        }
        else if(m == "chew")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" starts to chew on " +owner+oEnding+" tail. "+owner+" is not too sure how to feel about this o.o...");
        }
        else if(m == "bite")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" bites down on "+owner+oEnding+" tail... Though it looks like "+n+" might have hurt their teeth on the scales...");
        }
        else if(m == "pet")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" takes a hold of "+owner+oEnding+" tail and starts petting on the scales ♥");
        }
        else if(m == "tug")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" grabs and tugs hard on "+owner+oEnding+ " tail! "+owner+" tugs back on "+n+tEnding+" ear! :3");
        }
        else if(m == "grab")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" grabs "+owner+oEnding+ " tail and just holds it. "+owner+" looks back at "+n+".");
        }
        else if(m == "play")
        {
            llListenRemove(listen_handle);
            llSay(0,owner+" swishes their tail about."+n+" grabs it and starts tugging it playfully.");
        }
        else if(m == "hug")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" grabs "+owner+oEnding+" tail and gives it a big hug! ♥");
        }
        else if(m == "hold")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" grabs and holds "+owner+oEnding+" tail, refusing to let "+sGenderHim+" go!");
        }
        else if(m == "adult emotes")
        {
            llListenRemove(listen_handle);
            state adult;
        }
        llSetObjectName(oName);
        state default;
    }
    timer()
    {
        // Put listener back.
        listen_handle=llListen(chan,"","","");
        // Stop the timer now that its job is done
        llSetTimerEvent(0.0);
        ErrorMessage("Timed out");
        state default;
    }
}
state adult
{
    state_entry()
    {
        llSetTimerEvent(15);
        listen_handle=llListen(chan,"","","");
        llDialog(toucherkey,"What will you do with " +owner+"'s tail?",list_adult,chan);
    }
    listen(integer c, string n, key i, string m)
    {
        string m = llToLower(m);
        DebugMessage(m);
        n = llGetDisplayName(i);
        llSetObjectName("");
        // tail commands
        if(m == "hot lick")
        {
            if(bGender == 1){
                llListenRemove(listen_handle);
            llSay(0,n+" bends down in front of " + owner + ", slowly moving their hands to reach " + owner + oEnding + " butt, squeezing it softly with one hand as they grab his cock,  slowly licking it up and down while looking at him...");
            }
            else{
            llListenRemove(listen_handle);
            llSay(0,n+" bends down in front of " + owner + ", slowly kissing her lap and then put their mouth on her pussy,\n licking slowly...");
            }
        }
        else if(m == "butt lick")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" bends down and licks " + owner + oEnding + " butt! ♥");
        }
        else if(m == "smack")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" smacks " + owner + oEnding + " butt!");
        }
        else if(m == "grope")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" gropes " + owner + "! ^_~");
        }
        else if(m == "hump")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" grabs " + owner + " from behind and starts humpin!");
        }
        else if(m == "fluff")
        {
            DebugMessage(m);
            llListenRemove(listen_handle);
            llSay(0,n+" fluffs " + owner + oEnding + " tail making it nice and soft. ^^");
        }
        else
        {
            ErrorMessage("Something went wrong. Derp.");
            ErrorMessage("Message was: "+m+".");
        }
        llSetObjectName(oName);
        state default;
    }
    timer()
    {
        // Put listener back.
        listen_handle=llListen(chan,"","","");
        // Stop the timer now that its job is done
        llSetTimerEvent(0.0);
        ErrorMessage("Timed out");
        state default;
    }
}
