/// The latest version of this script can be found at https://bitbucket.org/voaxeyr/open-source-tail-script/src ///

integer MessagesLevel = 0; // 0: none, 1: error , 2: info, 3: debug
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

/// MENUS ////
//list cute = [Nom","Chew","Bite","Pet","Tug","Grab","Play","Hug","Hold","Adult Emotes"];
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

// Automagical Ending fixer //
string oEnding = "'s";
string tEnding = "'s";
string gender = "her";
string gender2 = "her";
string gender3 = "She";
string oE;

// viewer 3 prettyfication //
integer viewer3 = 1;
twitch(string times)
{
    llMessageLinked(LINK_THIS, 0, "t "+times, "");
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
    // Script cpu usage control //
    oE = owner+oEnding; // Owner Ending
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
                llDialog(toucherkey,"\nChange Tail option",["Waggle","Emote","Lock","Gender"],chan);
            else // if locked
                llDialog(toucherkey,"\nChange Tail option",["Waggle","Emote","Unlock","Gender"],chan);
        }
        else if(lock == FALSE)  // if not locked and not owner
        {
            llSetObjectName("");
            llOwnerSay(touchername + " is touching your tail...");
            llSetObjectName(oName);
            state cute;
        }
        else
        {
            llListenRemove(listen_handle);
        }
        twitch("1");
    }
    listen(integer c, string n, key i, string m)
    {
        string m2 = llToLower(m);
        InfoMessage(touchername+" selected "+m2);
        if(viewer3)
        {
            n="secondlife:///app/agent/"+(string)i+"/about";
        }
        else
        {
            string n=llGetDisplayName(i);
        }
//         n = llGetDisplayName(i);
        // tail commands
        if(m2 == "cute")
        {
            llListenRemove(listen_handle);
            state cute;
        }
        else if(m2 == "adult emotes")
        {
            llListenRemove(listen_handle);
            state adult;
        }
        else if(m2 == "gender")
        {
                llDialog(toucherkey,"Sausage or Tacos?",["Sausage","Tacos"],chan);
        }
        else if(m2 == "tacos")
        {
            llListenRemove(listen_handle);
            gender = "her";
            gender2 = "her";
            gender3 = "She";
            InfoMessage("gender set to female");
        }
        else if(m2 == "sausage")
        {
            llListenRemove(listen_handle);
            gender = "him";
            gender2 = "his";
            gender3 = "He";
            InfoMessage("gender set to male");
        }
        else if(m2 == "emote")
        {
            state cute;
        }
        else if(m2 == "lock")
        {
            llListenRemove(listen_handle);
            lock = TRUE;
            llOwnerSay("Locked");
        }
        else if(m2 == "unlock")
        {
            llListenRemove(listen_handle);
            lock = FALSE;
            llOwnerSay("Unlocked");
        }
        else if(m2 == "waggle")
        {
        llListenRemove(listen_handle);
        llSetObjectName("");
        llSay(0,n+" waggles " + gender2 + " tail happily!");
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
        string m2 = llToLower(m);
        n = llGetDisplayName(i);
        string nameEnd = llGetSubString(n, -1, -1);
        if (nameEnd == "s")
        {
            tEnding = "'";
        }
        nameEnd = "";
        llSetObjectName("");
        // tail commands
        if(m2 == "nom")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" grabs and noms on "+oE+ " tail. "+owner+" looks back at "+gender2+" tail to make sure "+n+" did not drool all over it.");

        }
        else if(m2 == "chew")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" starts to chew on " +oE+" tail. "+owner+" is not too sure how to feel about this o.o...");
        }
        else if(m2 == "bite")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" bites down on "+oE+" tail... Though it looks like "+n+" might have hurt their teeth on the scales...");
        }
        else if(m2 == "pet")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" takes a hold of "+oE+" tail and starts petting on the scales ♥");
        }
        else if(m2 == "tug")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" grabs and tugs hard on "+oE+ " tail! "+owner+" tugs back on "+n+tEnding+" ear! :3");
        }
        else if(m2 == "grab")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" reaches over and strokes "+oE+ " tail ♥");
        }
        else if(m2 == "play")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" squeezes the tip of "+oE+ " tail making " + gender + " squeak in mock displeasure!");
        }
        else if(m2 == "hug")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" yanks "+oE+ " tail for attention.");
        }
        else if(m2 == "hold")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" yanks " + owner + oEnding + " tail for attention.");
        }
        else if(m2 == "adult emotes")
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
        string m2 = llToLower(m);
        DebugMessage(m2);
        n = llGetDisplayName(i);
        llSetObjectName("");
        // tail commands
        if(m2 == "hot lick")
        {
            if(gender2 == "his"){
                llListenRemove(listen_handle);

            llSay(0,n+" bends down in front of " + owner + ", slowly moving their hands to reach " + owner + oEnding + " butt, squeezing it softly with one hand as they grab his cock,  slowly licking it up and down while looking at him...");
            }
            else{
            llListenRemove(listen_handle);
            llSay(0,n+" bends down in front of " + owner + ", slowly kissing her lap and then put their mouth on her pussy,\n licking slowly...");
            }
        }
        else if(m2 == "butt lick")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" bends down and licks " + owner + oEnding + " butt! Ã¢â¢Â¥");
        }
        else if(m2 == "smack")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" smacks " + owner + oEnding + " butt!");
        }
        else if(m2 == "grope")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" gropes " + owner + "! ^_~");
        }
        else if(m2 == "hump")
        {
            llListenRemove(listen_handle);
            llSay(0,n+" grabs " + owner + " from behind and starts humpin!");
        }
        else if(m2 == "fluff")
        {
            DebugMessage(m2);
            llListenRemove(listen_handle);
            llSay(0,n+" fluffs " + owner + oEnding + " tail making it nice and soft. ^^");
        }
        else
        {
            ErrorMessage("Something went wrong. Derp.");
            ErrorMessage("Message was: "+m2+".");
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
