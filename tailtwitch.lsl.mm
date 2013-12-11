list list_one = ["Smack","Grope","Hug","Play","Feel Up","XXX","Lick","MINE!!!","Fluff","Hump","Poke"];
string owner;
string dn;
key dk;
key ok;
integer lock = FALSE;
integer listn;
integer rand;
integer chan;
default
{
    attach(key n)
    {
        llResetScript();
    }
    
    on_rez(integer n)
    {
        llResetScript();
    }
    state_entry()
    {
        ok = llGetOwner();
        chan = 100 + (integer)llFrand(20000);
        owner = llGetDisplayName(ok);
        llListen(chan,"","","");
    }

    touch_start(integer total_number)
    {   
        dk = llDetectedKey(0);
        if (dk != ok)
        {
        dn = llGetDisplayName(llDetectedKey(0));
        llSetObjectName(dn);
        llSay(0,"/me slides their fingers on "+owner+"'s tail...");
        llDialog(dk,"What u want to do with "+owner+"'s Tail",list_one,chan);}
    }
    
    listen(integer c, string n, key i, string m)
    {
        // tail commands
        if(m == "lock")
        {
            lock = TRUE;
            llOwnerSay("Locked");
        }
        if(m == "unlock")
        {
            lock = FALSE;
            llOwnerSay("Unlocked");
        }
        // fun events
        if(m == "Pet")
        {
            llSay(0, "/me pets " + owner + "'s tail sending shivers up her spine");
        }
         if(m == "Poke")
        {
            llSay(0, "/me pokes " + owner + ".");
        }
        if(m == "Hump")
        {
            llSay(0, "/me grabs " + owner + " from behind and starts humpin!");
        }
        if(m == "MINE!!!")
        {
            llSay(0,"/me pounces " + owner + " ,sits on them and glares at everyone else in the room. ''MINE!!!''");
        }
        if(m == "Lick")
        {
            llSay(0,"/me bends down and licks " + owner + "'s butt! <3");
        }
        if(m == "Smack")
        {
            llSay(0,"/me smacks " + owner + "'s butt!");
        }
        if(m == "Grope")
        {
            llSay(0,"/me gropes " + owner + "! ^_~");
        }
        if(m == "Hug")
        {
            llSay(0,"/me Hugs " + owner + "'s tail firmly and doesnt want to let go! ^,..,^");
        }
        if(m == "Play")
        {
            llSay(0,"/me plays with " + owner + "'s tail like a little kitty! :3");
        }
        if(m == "Feel Up")
        {
            llSay(0,"/me puts a claw on " + owner + "'s chest and feels around. <3");
        }
        if(m == "XXX")
        {
            llSay(0,"/me bends down in front of " + owner + ", slowly kissing her lap and then put their mouth on her pussy,\n licking slowly...Gently... Giving her great shivers and pleasure as she grabs their head and presses it against her,\n moaning and whining a bit...");
        }
    }
}
