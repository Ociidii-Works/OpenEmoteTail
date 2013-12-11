/// The latest version of this script can be found at https://bitbucket.org/tarnix/open-source-tail-script/src ///

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
list list_cute = ["Brush","Carress","Grab","Hug","Play","Stroke","Squeak","Yank"];
list list_adult = ["Fluff","Grope","Hump","Butt Lick","Hot Lick","Smack"];
list choice = ["Cute","Adult"];

// Other variables //
key ownerkey;           // avoid calling llGetOwner so often.
string owner;           // Needed for owner identification
integer lock = FALSE;   // Boolean for locking capability
integer rand;           // Required for random menu channel (you really want this)
integer dChan;          // Required for channel reference.
string touchername;     // Required to re-use the name of who is touching the tail
integer listen_handle;  // Required for the listener.
key toucherkey;         // This will be set to the toucher's key. Used for user detection.
string oname;           //  To keep a name for the object when needed.

// Automagical Ending fixer //
string ending = "'s";
string gender = "him";
string gender2 = "his";

twitch()
{
	llMessageLinked(LINK_THIS, 0, "twitchplz", "");
}

init()
{
	//Message stuff
	oname = llGetObjectName();
	ownerkey = llGetOwner();
	owner = llGetDisplayName(ownerkey);
	string nameEnd = llGetSubString(owner, -1, -1);
	if (nameEnd == "s")
	{
		ending = "'";
		InfoMessage("INIT: This is " + owner + ending + " tail.");
	}
}

default
{
	attach(key id)
	{
		init();
		twitch();
		if(id != NULL_KEY)
		llRequestPermissions(ownerkey, PERMISSION_TAKE_CONTROLS );
	}

	on_rez(integer start_param)
	{
		init();
		twitch();
	}
	state_entry(){
		llSetMemoryLimit(21000);
		// Menu stuff
		init();
		oname = llGetObjectName();
	}

	touch_start(integer total_number)
	{
		llListenRemove(listen_handle);
		llSetTimerEvent(15);
		toucherkey = llDetectedKey(0);
		touchername = llGetDisplayName(toucherkey);
		dChan = 0x80000000 | (integer)("0x"+(string)llDetectedKey(0));
		DebugMessage("Channel = " + (string)dChan);
		listen_handle = llListen(dChan, "", toucherkey, "");
		toucherkey = llDetectedKey(0);
		if(toucherkey == ownerkey)
		{
			if(!lock)
				llDialog(toucherkey,"\nChange Tail option",["Waggle","Rest","Lock","Gender"],dChan);
			else
				llDialog(toucherkey,"\nChange Tail option",["Waggle","Rest","Unlock","Gender"],dChan);
		}
		else if(lock == FALSE)
		{
			llOwnerSay("Your tail is being touched by " + touchername);
			llDialog(toucherkey,"\nWould you like to play cute or hot with "+owner+"'s tail?",choice,dChan);
		}
		else
		{
			llListenRemove(listen_handle);
		}
		twitch();
	}
	listen(integer c, string n, key i, string m)
	{
	   string m2 = llToLower(m);
	   InfoMessage(touchername+" selected "+m2);
		 n = llGetDisplayName(i);
		// tail commands
		if(m2 == "cute")
		{
			llListenRemove(listen_handle);
			state CuteMenu;
		}
		else if(m2 == "adult")
		{
			llListenRemove(listen_handle);
			state Adult;
		}
		else if(m2 == "gender")
		{
			llDialog(toucherkey,"Sausage or Tacos?",["Sausage","Tacos"],dChan);
		}
		else if(m2 == "tacos")
		{
			llListenRemove(listen_handle);
			gender = "her";
			gender2 = "her";
			InfoMessage("gender set to female");
		}
		else if(m2 == "sausage")
		{
			llListenRemove(listen_handle);
			gender = "him";
			gender2 = "his";
			InfoMessage("gender set to male");
		}
		else if(m2 == "rest")
		{
			llDialog(toucherkey,"Would you like to play cute or hot with "+owner+"'s tail?",choice,dChan);
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
		llSetObjectName(oname);
		twitch();
		twitch();
		twitch();
		twitch();
		twitch();
		twitch();
		twitch();
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
state CuteMenu
{
	state_entry()
	{
		llSetTimerEvent(15);
		listen_handle=llListen(dChan,"","","");
		llDialog(toucherkey,"What will you do with " +owner+"'s tail?",list_cute,dChan);
	}
	listen(integer c, string n, key i, string m)
	{
		string m2 = llToLower(m);
		n = llGetDisplayName(i);
		llSetObjectName("");
		// tail commands
		if(m2 == "brush")
		{
			llListenRemove(listen_handle);
			llSay(0,n+" pulls out a soft brush and begins to stroke it against " + owner + ending + " tail. She giggles and blushes profusely.");

		}
		else if(m2 == "carress")
		{
			llListenRemove(listen_handle);
			llSay(0,n+" slides their hands along " + owner + ending + " tail slowly, eliciting a soft sigh from " + owner + ". ");
		}
		else if(m2 == "grab")
		{
			llListenRemove(listen_handle);
			llSay(0,n+" grabs " + owner + ending + " tail and cuddles it softly. She blushes deeply and wiggles, trying to break free.");
		}
		else if(m2 == "hug")
		{
			llListenRemove(listen_handle);
			llSay(0,n+" hugs " + owner + ending + " stubby little doe tail softly. ♥");
		}
		else if(m2 == "play")
		{
			llListenRemove(listen_handle);
			llSay(0,n+" play's with " + owner + ending + " tail, swatting at it. She giggles and flicks it under "+n+"'s nose teasingly. ♥");
		}
		else if(m2 == "stroke")
		{
			llListenRemove(listen_handle);
			llSay(0,n+" reaches over and strokes " + owner + ending + " tail. ♥");
		}
		else if(m2 == "squeak")
		{
			llListenRemove(listen_handle);
			llSay(0,n+" squeezes the tip of " + owner + ending + " tail making " + gender + " squeak in mock displeasure!");
		}
		else if(m2 == "yank")
		{
			llListenRemove(listen_handle);
			llSay(0,n+" yanks " + owner + ending + " tail for attention.");
		}
		llSetObjectName(oname);
		state default;
	}
	timer()
	{
		llListenRemove(listen_handle);
		ErrorMessage("Timed out");
	}
}
state Adult
{
	state_entry()
	{
		llSetTimerEvent(15);
		listen_handle=llListen(dChan,"","","");
		llDialog(toucherkey,"What will you do with " +owner+"'s tail?",list_adult,dChan);
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

			llSay(0,n+" bends down in front of " + owner + ", slowly moving their hands to reach " + owner + ending + " butt, squeezing it softly with one hand as they grab his cock,  slowly licking it up and down while looking at him...");
			}
			else{
			llListenRemove(listen_handle);
			llSay(0,n+" bends down in front of " + owner + ", slowly kissing her lap and then put their mouth on her pussy,\n licking slowly...");
			}
		}
		else if(m2 == "butt lick")
		{
			llListenRemove(listen_handle);
			llSay(0,n+" bends down and licks " + owner + ending + " butt! ♥");
		}
		else if(m2 == "smack")
		{
			llListenRemove(listen_handle);
			llSay(0,n+" smacks " + owner + ending + " butt!");
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
			llSay(0,n+" fluffs " + owner + ending + " tail making it nice and soft. ^^");
		}
		else
		{
			ErrorMessage("Something went wrong. Derp.");
		}
		llSetObjectName(oname);
		state default;
	}
	timer()
	{
		llListenRemove(listen_handle);
		ErrorMessage("Timed out");
	}
}
