#define DEBUG

#ifdef DEBUG
debug(string text)
{
    llOwnerSay(text);
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
integer chan; // Required for channel reference.
string toucher; // Required to re-use the name of who is touching the tail
integer listener; // Required for the listener.
key dk; // a key, obviously. Stands for DetectedKey. used with the touch function.
string originalName; // Used to avoid having unnamed objects in the list of attacjed stuff in your viewer

// Automagical Ending fixer //
string ending = "'s";

// Gender Stuff //
string gender = "him";
string gender2 = "his";


/////////////////////////////////
////// TAIL TWITCH  STUFF //////
///////////////////////////////

rotation t1 = <0.00000, 0.00000, 0.09587, 0.99539>;
rotation t2;
float j;
twitch()
{
    rotation rot = llGetLocalRot();
    integer i;
    j = llGetTime() + 0.08;
    while(j > llGetTime());
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_ROTATION, rot/t1]);
    j = llGetTime() + 0.08;
    while(j > llGetTime());
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_ROTATION, rot]);
    j = llGetTime() + 0.08;
    while(j > llGetTime());
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_ROTATION, rot/t2]);
    j = llGetTime() + 0.08;
    while(j > llGetTime());
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_ROTATION, rot]);
}
rotation flipRotT(rotation oldRot)
{
    vector up = llRot2Up(oldRot);
    vector fwd = llRot2Fwd(oldRot);
    up.y*=-1;
    fwd.y*=-1;
    return llAxes2Rot(fwd,up%fwd,up);
}

//////////////////////////////////////
////// END OF TAIL TWITCH STUF /////
////////////////////////////////////
default
{
    attach(key id)
    {
        twitch();
        if(id != NULL_KEY)
        llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS ); }
    
    on_rez(integer start_param)
    {
        twitch();
    }
    state_entry(){
        debug("Debugging with the Firestorm LSL Preprocessor.");
         //llSetMemoryLimit(21504);
        // Menu stuff
        originalName = llGetObjectName();
        chan = 100 + (integer)llFrand(20000);
        //Message stuff
        owner = llGetDisplayName(llGetOwner());
        string nameEnd = llGetSubString(owner, -1, -1);
        if (nameEnd == "s"){
            ending = "'";
            llOwnerSay("Posessive ending auto-configured for your name: This is " + owner + ending + " tail.");
            }
        // Twitch stuff
        llSetTimerEvent(1);
        t2 = flipRotT(t1);
    }

    touch_start(integer total_number)
    {   twitch();
        toucher = llGetDisplayName(llDetectedKey(0));
        listener=llListen(chan,"","","");
        toucher = llGetDisplayName(llDetectedKey(0));
        dk = llDetectedKey(0);
        if(dk == llGetOwner())
        {
            llDialog(dk,"Change Tail option,",list_owner,chan);
        } else if(lock == FALSE){

            llOwnerSay("Your tail is being touched by " + toucher);
            llDialog(dk,"Would you like to play cute or hot with "+owner+"'s tail?",choice,chan);}
        else{
            llListenRemove(listener);
        }
    }
    listen(integer c, string n, key i, string m)
    {
       string m2 = llToLower(m);
       debug(m2);
         n = llGetDisplayName(i);
        // tail commands
        if(m2 == "gender")
        {
            llDialog(dk,"Sausage or Tacos?",["Sausage","Tacos"],chan);
        }
        if(m2 == "tacos")
        {
            gender = "her";
            gender2 = "her";
            llListenRemove(listener);
            debug("gender set to female");
        }
        if(m2 == "sausage")
        {
            gender = "him";
            gender2 = "his";
            llListenRemove(listener);
            debug("gender set to male");
        }
    
        if(m2 == "cute")
        {
            llListenRemove(listener);
            state CuteMenu;

        }
        if(m2 == "adult")
        {
            
            llListenRemove(listener);
            state Adult;
        }
        if(m2 == "rest")
        {
            llDialog(dk,"Would you like to play cute or hot with "+owner+"'s tail?",choice,chan);
        }
        if(m2 == "lock")
        {
            llListenRemove(listener);
            lock = TRUE;
            llOwnerSay("Locked");
            
        }
        if(m2 == "unlock")
        {
            llListenRemove(listener);
            lock = FALSE;
            llOwnerSay("Unlocked");
            
        }

        // ------------------------------------------------------------------ //
        if(m2 == "waggle")
        {
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
        twitch();
        llSetTimerEvent(5.f+llFrand(10.f));
    }
    run_time_permissions(integer perm)
    {
        if(perm == PERMISSION_TAKE_CONTROLS)
            llTakeControls( CONTROL_BACK|CONTROL_FWD, TRUE, TRUE );
    }
}
state CuteMenu
{
    state_entry()
    {
        listener=llListen(chan,"","","");
        llDialog(dk,"What will you do with " +owner+"'s tail?",list_cute,chan);
    }
    listen(integer c, string n, key i, string m)
    {
        string m2 = llToLower(m);
        n = llGetDisplayName(i);
        // tail commands
        if(m2 == "brush")
        {
            llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " pulls out a soft brush and begins to stroke it against " + owner + "'s tail. She giggles and blushes profusely.");
            llSetObjectName(originalName);
            
        }
        if(m2 == "carress")
        {
            llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " slides their hands along " + owner + "'s tail slowly, eliciting a soft sigh from " + owner + ". ");
            llSetObjectName(originalName);
            
        }
        if(m2 == "grab")
        {
            llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " grabs " + owner + "'s tail and cuddles it softly. She blushes deeply and wiggles, trying to break free.");
            llSetObjectName(originalName);
        }
        if(m2 == "hug")
        {
            llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " hugs " + owner + "'s stubby little doe tail softly. ♥");
            llSetObjectName(originalName);
            llListenRemove(listener);
        }
        if(m2 == "play")
        {
            llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " play's with " + owner + "'s tail, swatting at it. She giggles and flicks it under "+n + "'s nose teasingly. ♥");
            llSetObjectName(originalName);
            llListenRemove(listener);
        }
        if(m2 == "stroke")
        {
            llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " reaches over and strokes " + owner + "'s tail. ♥");
            llSetObjectName(originalName);
            llListenRemove(listener);
        }
        if(m2 == "squeak")
        {
            llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " squeezes the tip of " + owner + "'s tail making " + gender + " squeak in mock displeasure!");
            llSetObjectName(originalName);
            llListenRemove(listener);
        }
        if(m2 == "yank")
        {
            llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " yanks " + owner + "'s tail for attention.");
            llSetObjectName(originalName);
            llSetObjectName(originalName);
            llListenRemove(listener);
        }
    state default;
    }
}
state Adult
{
    state_entry()
    {
        listener=llListen(chan,"","","");
        llDialog(dk,"What will you do with " +owner+"'s tail?",list_adult,chan);
    }
    listen(integer c, string n, key i, string m)
    {
        string m2 = llToLower(m);
        debug(m2);
        n = llGetDisplayName(i);
        // tail commands
        if(m2 == "feel up")
        {
            llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " puts a claw on " + owner + "'s chest and feels around. ♥");
            llSetObjectName(originalName);
            llListenRemove(listener);
        }
        else if(m2 == "hot lick")
        {
            if(gender2 == "his"){
                llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " bends down in front of " + owner + ", slowly moving their hands to reach " + owner + ending + " butt, squeezing it softly with one hand as they grab his cock,  slowly licking it up and down while looking at him...");
            llSetObjectName(originalName);
            llListenRemove(listener);}
            else{
            llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " bends down in front of " + owner + ", slowly kissing her lap and then put their mouth on her pussy,\n licking slowly...");
            llSetObjectName(originalName);
            llListenRemove(listener);}
        }
        else if(m2 == "butt lick")
        {
            llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " bends down and licks " + owner + ending + " butt! ♥");
            llSetObjectName(originalName);
            llListenRemove(listener);
        }
        else if(m2 == "smack")
        {
            llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " smacks " + owner + ending + " butt!");
            llSetObjectName(originalName);
            llListenRemove(listener);
        }
        else if(m2 == "grope")
        {
            llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " gropes " + owner + "! ^_~");
            llSetObjectName(originalName);
            llListenRemove(listener);
        }
        else if(m2 == "hump")
        {
            llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " grabs " + owner + " from behind and starts humpin!");
            llSetObjectName(originalName);
            llListenRemove(listener);
        }
        else if(m2 == "fluff")
        {
            debug(m2);
            llListenRemove(listener);
            llSetObjectName("");
            llSay(0," "+n + " fluffs " + owner + "'s tail making it nice and soft. ^^");
            llSetObjectName(originalName);
            llListenRemove(listener);
        }
        else
        {
            debug("Something went wrong. Derp.");
        }
        state default;
    }
}