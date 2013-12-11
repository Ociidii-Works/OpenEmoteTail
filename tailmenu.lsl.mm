/// The latest version of this script can be found at https://bitbucket.org/tarnix/open-source-tail-script/src ///


///#define DEBUG

#ifdef DEBUG
debug(string text)
{
   llSay(DEBUG_CHANNEL,text);
}
#else
#define debug(dummy)
#endif


/// MENUS ////
list list_cute = ["Brush","Carress","Grab","Hug","Play","Stroke","Squeak","Yank"];
list list_adult = ["Feel Up","Fluff","Grope","Hump","Butt Lick","Hot Lick","Smack"];
list list_owner = ["Waggle","Rest","Lock","Unlock","Gender"];
list choice = ["Cute","Adult"];



// Optimization attempts //

// Other variables~
string owner; // Needed for owner identification
integer lock = FALSE; // Boolean for locking capability
integer rand; // Required for random menu channel (you really want this)
integer channelDialog; // Required for channel reference.
string touchername; // Required to re-use the name of who is touching the tail
integer listen_id; // Required for the listener.
key toucherkey; // This will be set to the toucher's key. Used for user detection.
string originalName; // Used to avoid having unnamed objects in the list of attacjed stuff in your viewer

// Automagical Ending fixer //
string ending = "'s";

// Gender Stuff //
string gender = "him";
string gender2 = "his";


twitch()
{
    llMessageLinked(LINK_THIS, 0, "twitchplz", "");
}

//////////////////////////////////////
////// END OF TAIL TWITCH STUF /////
////////////////////////////////////

setEnding()
{
    //Message stuff
    owner = llGetDisplayName(llGetOwner());
    string nameEnd = llGetSubString(owner, -1, -1);
    if (nameEnd == "s")
    {
        ending = "'";
        debug("Posessive ending auto-configured for your name: This is " + owner + ending + " tail.");
    }
}


default
{
    attach(key id)
    {
        setEnding();
        twitch();
        if(id != NULL_KEY)
        llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS ); }

    on_rez(integer start_param)
    {
        setEnding();
        twitch();
    }
    state_entry(){
        debug("Debugging with the Firestorm LSL Preprocessor.");
         //llSetMemoryLimit(21504);
        // Menu stuff
        originalName = llGetObjectName();
        setEnding();
    }

    touch_start(integer total_number)
    {
        llListenRemove(listen_id);
        toucherkey = llDetectedKey(0);
        llSetTimerEvent(15);
        touchername = llGetDisplayName(llDetectedKey(0));
        channelDialog = -1 - (integer)("0x" + llGetSubString( (string)toucherkey, -7, -1) );
        debug(string(channelDialog));
        listen_id = llListen(channelDialog, "", toucherkey, "");
        toucherkey = llDetectedKey(0);
        if(toucherkey == llGetOwner())
        {
            llDialog(toucherkey,"\nChange Tail option",list_owner,channelDialog);
        }
        else if(lock == FALSE)
        {
            llOwnerSay("Your tail is being touched by " + touchername);
            llDialog(toucherkey,"\nWould you like to play cute or hot with "+owner+"'s tail?",choice,channelDialog);
        }
        else
        {
            llListenRemove(listen_id);
        }
        twitch();
    }
    listen(integer c, string n, key i, string m)
    {
       string m2 = llToLower(m);
       debug(m2);
         n = llGetDisplayName(i);
        // tail commands
        if(m2 == "gender")
        {
            llDialog(toucherkey,"Sausage or Tacos?",["Sausage","Tacos"],channelDialog);
        }
        if(m2 == "tacos")
        {
            gender = "her";
            gender2 = "her";
            llListenRemove(listen_id);
            debug("gender set to female");
        }
        if(m2 == "sausage")
        {
            gender = "him";
            gender2 = "his";
            llListenRemove(listen_id);
            debug("gender set to male");
        }

        if(m2 == "cute")
        {
            llListenRemove(listen_id);
            state CuteMenu;

        }
        if(m2 == "adult")
        {

            llListenRemove(listen_id);
            state Adult;
        }
        if(m2 == "rest")
        {
            llDialog(toucherkey,"Would you like to play cute or hot with "+owner+"'s tail?",choice,channelDialog);
        }
        if(m2 == "lock")
        {
            llListenRemove(listen_id);
            lock = TRUE;
            llOwnerSay("Locked");

        }
        if(m2 == "unlock")
        {
            llListenRemove(listen_id);
            lock = FALSE;
            llOwnerSay("Unlocked");

        }

        // ------------------------------------------------------------------ //
        if(m2 == "waggle")
        {
        llListenRemove(listen_id);
        llSetObjectName("");
        llSay(0,n+" waggles " + gender2 + " tail happily!");
        llSetObjectName(originalName);
        twitch();
        twitch();
        twitch();
        twitch();
        twitch();
        twitch();
        twitch();
        }
    }
    timer()
    {
        // Stop listening. It's wise to do this to reduce lag
        llListenRemove(listen_id);
        // Stop the timer now that its job is done
        llSetTimerEvent(0.0);
        debug("Timed out");
    }
}
state CuteMenu
{
    state_entry()
    {
        llSetTimerEvent(15);
        listen_id=llListen(channelDialog,"","","");
        llDialog(toucherkey,"What will you do with " +owner+"'s tail?",list_cute,channelDialog);
    }
    listen(integer c, string n, key i, string m)
    {
        string m2 = llToLower(m);
        n = llGetDisplayName(i);
        // tail commands
        if(m2 == "brush")
        {
            llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" pulls out a soft brush and begins to stroke it against " + owner + ending + " tail. She giggles and blushes profusely.");
            llSetObjectName(originalName);

        }
        if(m2 == "carress")
        {
            llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" slides their hands along " + owner + ending + " tail slowly, eliciting a soft sigh from " + owner + ". ");
            llSetObjectName(originalName);

        }
        if(m2 == "grab")
        {
            llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" grabs " + owner + ending + " tail and cuddles it softly. She blushes deeply and wiggles, trying to break free.");
            llSetObjectName(originalName);
        }
        if(m2 == "hug")
        {
            llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" hugs " + owner + ending + " stubby little doe tail softly. ♥");
            llSetObjectName(originalName);
        }
        if(m2 == "play")
        {
            llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" play's with " + owner + ending + " tail, swatting at it. She giggles and flicks it under "+n+"'s nose teasingly. ♥");
            llSetObjectName(originalName);
        }
        if(m2 == "stroke")
        {
            llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" reaches over and strokes " + owner + ending + " tail. ♥");
            llSetObjectName(originalName);
        }
        if(m2 == "squeak")
        {
            llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" squeezes the tip of " + owner + ending + " tail making " + gender + " squeak in mock displeasure!");
            llSetObjectName(originalName);
        }
        if(m2 == "yank")
        {
            llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" yanks " + owner + ending + " tail for attention.");
            llSetObjectName(originalName);
        }
    state default;
    }
    timer()
    {
        llListenRemove(listen_id);
        debug("Timed out");
    }
}
state Adult
{
    state_entry()
    {
        llSetTimerEvent(15);
        listen_id=llListen(channelDialog,"","","");
        llDialog(toucherkey,"What will you do with " +owner+"'s tail?",list_adult,channelDialog);
    }
    listen(integer c, string n, key i, string m)
    {
        string m2 = llToLower(m);
        debug(m2);
        n = llGetDisplayName(i);
        // tail commands
        if(m2 == "feel up")
        {
            llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" puts a claw on " + owner + ending + " chest and feels around. ♥");
            llSetObjectName(originalName);
        }
        else if(m2 == "hot lick")
        {
            if(gender2 == "his"){
                llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" bends down in front of " + owner + ", slowly moving their hands to reach " + owner + ending + " butt, squeezing it softly with one hand as they grab his cock,  slowly licking it up and down while looking at him...");
            }
            else{
            llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" bends down in front of " + owner + ", slowly kissing her lap and then put their mouth on her pussy,\n licking slowly...");
            }
        }
        else if(m2 == "butt lick")
        {
            llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" bends down and licks " + owner + ending + " butt! ♥");
        }
        else if(m2 == "smack")
        {
            llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" smacks " + owner + ending + " butt!");
        }
        else if(m2 == "grope")
        {
            llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" gropes " + owner + "! ^_~");
        }
        else if(m2 == "hump")
        {
            llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" grabs " + owner + " from behind and starts humpin!");
        }
        else if(m2 == "fluff")
        {
            debug(m2);
            llListenRemove(listen_id);
            llSetObjectName("");
            llSay(0,n+" fluffs " + owner + ending + " tail making it nice and soft. ^^");
        }
        else
        {
            debug("Something went wrong. Derp.");
        }
        state default;
    }
    timer()
    {
        llListenRemove(listen_id);
        debug("Timed out");
    }
}