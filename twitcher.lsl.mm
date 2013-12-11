//#define DEBUG

#ifdef DEBUG
debug(string text)
{
   llSay(DEBUG_CHANNEL,text);
}
#else
#define debug(dummy)
#endif


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
    run_time_permissions(integer perm)
    {
        if(perm == PERMISSION_TAKE_CONTROLS)
            llTakeControls( CONTROL_BACK|CONTROL_FWD, TRUE, TRUE );
    }
    state_entry()
    {        llSetTimerEvent(1);
    }
    timer()
    {
        debug(llGetScriptName() + ": Timer-based twitch");
        twitch();
        llSetTimerEvent(5.f+llFrand(10.f));
    }
    // Quick and dirty debugging link_messages
    link_message(integer sender_num, integer num, string msg, key id) 
    {
        if(msg == "twitchplz")
        {
            debug(llGetScriptName() + ": I'M SUPPOSED TO TWITCH, RIGHT HERE!");
            twitch();
        }
    }
}