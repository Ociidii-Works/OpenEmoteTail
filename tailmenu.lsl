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

/*
The latest version of this script can always be found at
    https://raw.github.com/Xenhat/OpenEmoteTail/master/tailmenu.lsl
A version checker is included.

Todo: Use StringReplace instead of variables for Him/Her/His
      Add persistent config x.e
*/

//////////////////
/// User config //
//////////////////

// Set default gender here.
integer g_config_isMale_b                   =   FALSE;

// Is it a tail, a nose, a head, etc.?
string g_config_objectType_s                =   "tail";

// Use the twitcher (requires Twitcher script)
integer g_config_useTwitcher_b              = FALSE;

// How long to wait before displaying owner menu
integer g_config_touchDelay_i               = 1;

// Save settings to prim desc. Disable to avoid breaking objects that also use this
// storage method. you will however lose your settings if the script is reset.
integer g_config_saveToDesc_b               = FALSE;

// Display names in emotes using icon-less SLURL
integer g_config_removeIconInNameLinks_b    = TRUE;

// Display owner name in emotes using icon-less SLURL
integer g_config_removeIconInOwnerName_b    = TRUE;

/////////////////////////////////////////////////////////////////////////
/// Internal stuff, don't touch unless you know what you're doing! //////
/////////////////////////////////////////////////////////////////////////
string g_internal_version_s             = "3.8.8";
string g_internal_repo_s                = "XenHat/OpenEmoteTail";
key g_internal_httprid_k                = NULL_KEY;
// 0: none, 1: error , 2: warning, 3: info, 4: debug
integer LOG_NONE = 0;
integer LOG_ERRR = 1;
integer LOG_WARN = 2;
integer LOG_INFO = 3;
integer LOG_VERB = 4;
integer LOG_DEBG = 5;
integer g_internal_verbosity_i          = LOG_WARN;
integer g_internal_touchTime_i          = -1;
integer g_internal_listenTimeout_i      = 7;
integer g_internal_showMemoryStats_b    = 0;
integer g_internal_memoryLimit_i = 3000;
integer g_internal_appID_i = 1415670124; // "Tail" -> Hex -> Integer

/// Menu Buttons ///
list g_menu_Emote_l1Type_l =   [
    "Soft Emotes"
    ,"Adult Emotes"
];
list g_menu_Emote_l2Soft_l = [
    "Nom On"
    ,"Chew On"
    ,"Bite"
    ,"Pet"
    ,"Tug"
    ,"Grab"
    ,"Fluff"
    ,"Play"
    ,"Hug"
    ,"Hold"
];
list g_menu_Emote_l2Adlt_l = [
    "Grope"
    ,"Hump"
    ,"Lick Butt"
    ,"Lick Genitals"
    ,"Smack Butt"
];

/// Cached values ///
integer g_cached_dialogChannel_i = -1;
integer g_cached_listenHandle_i = -1;
key g_cached_lastToucher_k = NULL_KEY;
key g_cached_owner_k = NULL_KEY;
key g_cached_toucher_k = NULL_KEY;
string g_cached_ownerDisplayName_s;

/// String construction cache ///
string g_cached_objectName_s;
string g_cached_toucherName_s;
string g_cached_updateMsg_s = "";

/// Possessive ending logic ///
string g_dyn_he_s; // use llToLower for middle of sentence
string g_dyn_him_s;
string g_dyn_his_s;
string g_dyn_poss_owner_s;
string g_dyn_poss_toucher_s;

/// Status logic ///
integer g_status_inUse_b            = FALSE;
integer g_status_locked_i           = FALSE;
integer g_status_showUpdateBtn_b    = TRUE;

//// Functions ////
fSetGender(integer iNewGender)
{
    if(!iNewGender)
    {
        g_dyn_him_s = "her";
        g_dyn_his_s = "her";
        g_dyn_he_s = "She";
    }
    else
    {
        g_dyn_him_s = "him";
        g_dyn_his_s = "his";
        g_dyn_he_s = "He";
    }
    g_config_isMale_b = iNewGender;
    saveToDesc();
}
saveToDesc()
{
    if (!g_config_saveToDesc_b) return;
    llSetObjectDesc("#OET:g=" + (string)g_config_isMale_b + ",t=" + g_config_objectType_s);
}
memstats(string type)
{
    if(!g_internal_showMemoryStats_b || g_internal_verbosity_i < LOG_INFO)
    {
        return;
    }
    dm(LOG_DEBG,type,(string)llGetMemoryLimit() + " kb allocated");
    dm(LOG_DEBG,type,(string)llGetUsedMemory() + " kb used");
    dm(LOG_DEBG,type,(string)llGetFreeMemory() + " kb free");
}
dm(integer level, string function_s, string message_s)
{
    /*  t
            see LOG_* definitions
        e
            event the message comes from
        m
            the actual message
    */
    if(level == LOG_NONE)
    jump end;
    // Reminder: LSL is not a short-circuiting language
    // using || or && will always evaluate both before taking action.
    // This is a speed hack. I hope.
    if(g_internal_verbosity_i < level)
    {
        jump end;
    }
    string prefix_s;
    if(g_internal_verbosity_i >= LOG_DEBG)
    {
        prefix_s = function_s+"()";
        if(level == LOG_ERRR)
        {
            prefix_s += " [E] ";
        }
        else if(level == LOG_WARN)
        {
            prefix_s += " [W] ";
        }
        else if(level == LOG_INFO)
        {
            prefix_s += " [I] ";
        }
        else if(level == LOG_VERB)
        {
            prefix_s += " [V] ";
        }
        else if(level == LOG_DEBG)
        {
            prefix_s += " [D] ";
        }
    }
    llOwnerSay(prefix_s+llStringTrim(message_s,0x3));
    @end;
}
twitch(string times)
{
    if(g_config_useTwitcher_b)
    {
        llMessageLinked(LINK_THIS, 0, "t " + times, "");
    }
}
string Key2Link(key k)
{
    return "[secondlife:///app/agent/" + (string)k
    + "/about " + llGetDisplayName(k) + "]";
}
getDynamicEnding(string nameEnd)
{
    if(nameEnd == "")
    {
        nameEnd = llGetSubString(g_cached_ownerDisplayName_s, -1, -1);
    }
    if (nameEnd == "s")
    {
        g_dyn_poss_owner_s = "'";
        dm(LOG_INFO,"getDynamicEnding","This is " + g_cached_ownerDisplayName_s + g_dyn_poss_owner_s + " " + g_config_objectType_s + ".");
    }
    else
    {
        g_dyn_poss_owner_s = "'s";
    }
}
init()
{
    string et = "init";
    dm(LOG_DEBG,et,"Running OET v" + g_internal_version_s + "...");
    g_cached_owner_k = llGetOwner();
    //Message stuff
    g_cached_ownerDisplayName_s = llGetDisplayName(g_cached_owner_k);
    if (llGetObjectName() == " ") // when shit goes left
    {
        dm(LOG_DEBG,"xlCreateMenu","Object name is empty!");
        list name_list = llParseString2List(llKey2Name(g_cached_owner_k), [" "],[]);
        string first_name = llList2String(name_list,0);
        getDynamicEnding(first_name);
        llSetObjectName(first_name + g_dyn_poss_owner_s + " " + g_config_objectType_s);
        g_cached_objectName_s = llGetObjectName();
        dm(LOG_DEBG,"xlCreateMenu","Fixing empty item name with '"+g_cached_objectName_s+"'");
    }
    else
    {
        g_cached_objectName_s = llGetObjectName();
        getDynamicEnding("");
    }
    // simplistic gender auto-detection.
    if (g_config_saveToDesc_b)
    {
        string desc = llGetObjectDesc();
        if (desc == "")
        {
            g_config_isMale_b = (integer)llList2Integer(llGetObjectDetails(g_cached_owner_k,[OBJECT_BODY_SHAPE_TYPE]),0);
        }
    }
    fSetGender( g_config_isMale_b);
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

xlCreateMenu(string sHelpText, list lButtons)
{
    sHelpText = "[https://github.com/XenHat/OpenEmoteTail OpenEmoteTail] "
    + g_internal_version_s + " by secondlife:///app/agent/f1a73716-4ad2-4548-9f0e-634c7a98fe86/inspect.";
    if(bMenuType == OWNER_MENU)
    {
        sHelpText += g_cached_updateMsg_s;
    }
    llSetTimerEvent(0.0);
    llSetTimerEvent(g_internal_listenTimeout_i);

    llDialog(g_cached_toucher_k,sHelpText,lButtons,g_cached_dialogChannel_i);
}
integer bMenuType;
xlGenerateMenuData(integer newMenuType_i)
{
    bMenuType = newMenuType_i;
    string et = "xlGenerateMenuData";
    memstats(et);
    dm(LOG_DEBG,et,"Received Menu Type: " + (string)bMenuType);
    dm(LOG_DEBG,et,"Received Key: " + (string)g_cached_toucher_k);
    fClearListeners();
    g_cached_listenHandle_i = llListen(g_cached_dialogChannel_i, "", g_cached_toucher_k, "");
    dm(LOG_DEBG,et,"Now listening on = " + (string)g_cached_dialogChannel_i + " for secondlife:///app/agent/"+(string)g_cached_toucher_k+"/displayname");

    if(bMenuType == OWNER_MENU)
    {
        //// Owner Menu ////
        if (g_cached_toucher_k != NULL_KEY && g_cached_toucher_k != g_cached_owner_k)
        {
            return;
        }
        dm(LOG_DEBG,et,"Entering Owner Menu");
        { // Owner Menu Root
            list menu_buttons = ["Waggle", "Gender"];
            dm(LOG_INFO,et,"Checking Lock");
            if(!g_status_locked_i) // if not locked
            {
                dm(LOG_INFO,et,"Is Unlocked");
                menu_buttons += ["Lock"];
            }
            else // if locked
            {
                dm(LOG_INFO,et,"Is Locked");
                menu_buttons += ["Unlock"];
            }
            if (g_status_showUpdateBtn_b)
            {
                menu_buttons += ["Check Update"];
            }
            xlCreateMenu("\nChange " + g_config_objectType_s + " option",menu_buttons);
        }
    }
    else if(bMenuType == GENDER_MENU) // Gender Menu
    {
        dm(LOG_DEBG,et,"Entering Gender Menu");
        xlCreateMenu("Sausage or Tacos?",["Sausage","Tacos"]);
    }
    //// Others Menu ////
    else if(g_cached_toucher_k != g_cached_owner_k)
    {
        dm(LOG_DEBG,et,"Checking Lock for Others");
        if(g_status_locked_i)
        {
            fClearListeners();
        }
        else // if not locked and not owner
        {
            dm(LOG_DEBG,et,"Entering Others Menu");
            if(bMenuType == OTHERS_MENU)
            {
                dm(LOG_DEBG,et,"Building Choice Menu");
                xlCreateMenu("Chose an Emote type",g_menu_Emote_l1Type_l);
            }
            else if(bMenuType == SOFT_MENU)
            {
                dm(LOG_DEBG,et,"Building Soft Menu");
                xlCreateMenu("Okay, what do you want to do?",g_menu_Emote_l2Soft_l);
            }
            else if(bMenuType == ADULT_MENU)
            {
                dm(LOG_DEBG,et,"Building Adult Menu");
                xlCreateMenu("Feeling naughty, eh? How much?",g_menu_Emote_l2Adlt_l);
            }
        }
    }
    else
    {
        dm(LOG_ERRR,et,"Something unexpected happened D:");
    }
    twitch("1");
    memstats(et);
}
fClearListeners()
{
    string et = "fClearListeners";
    // Stop listening. It's wise to do this to reduce lag
    if(g_cached_listenHandle_i == -1)
    {
        dm(LOG_DEBG,et,"There is no listener to close");
        return;
    }
    dm(LOG_VERB,et,"Listener handle "+(string)g_cached_listenHandle_i+" for " + (string)g_cached_dialogChannel_i + " closed");
    llListenRemove(g_cached_listenHandle_i);
    g_cached_listenHandle_i = -1;
    llSetTimerEvent(0);
}
getLatestUpdate()
{
    llSetMemoryLimit(64000);
    dm(LOG_VERB,"getLatestUpdate","Looking for update...");
    g_internal_httprid_k = llHTTPRequest("https://api.github.com/repos/"+g_internal_repo_s+"/releases/latest?access_token=603ee815cda6fb45fcc16876effbda017f158bef",[], "");
}
sendEmote(string message_s)
{
    llSetObjectName("");
    llSay(0,"/me " +message_s);
    llSetObjectName(g_cached_objectName_s);
}
default
{
    changed(integer iChange)
    {
        if (iChange & CHANGED_OWNER) //note that it's & and not &&... it's bitwise!
        {
            dm(LOG_INFO,"changed","The owner of the object has changed. Resetting!");
            llResetScript();
        }
    }
    attach(key kID)
    {
        if(g_cached_owner_k != llGetOwner()) llResetScript();
        init();
        twitch("3");
        if(kID != NULL_KEY)
        llRequestPermissions(g_cached_owner_k, PERMISSION_TAKE_CONTROLS );
        memstats("attach");
        getLatestUpdate();
    }
    on_rez(integer start_param)
    {
        // Do nothing if attached (login?)
        if(llGetAttached())
        {
            return;
        }
        g_cached_toucher_k = llGetOwner();
        xlGenerateMenuData(GENDER_MENU);
        twitch("2");
    }
    state_entry()
    {
        if(g_internal_verbosity_i>=4)
        {
            g_internal_memoryLimit_i = 64000;
        }
        // Menu stuff
        init();
        llSleep(0.1); // let GC do its thing
        if (!~(""!="x")){
            llOwnerSay(llGetScriptName() + " cannot breathe! Please recompile it as Mono!");
        }
        llSetMemoryLimit(llGetUsedMemory()+g_internal_memoryLimit_i); // fat. I know.
        if (llGetScriptName() == "New Script")
        {
            llOwnerSay("/me secondlife:///app/agent/f1a73716-4ad2-4548-9f0e-634c7a98fe86/inspect stares at you from far away... \"'New Script', really?\"");
        }
        if (llGetObjectName() == "Object")
        {
            llOwnerSay("/me secondlife:///app/agent/f1a73716-4ad2-4548-9f0e-634c7a98fe86/inspect stares at you from far away... \"'OH COME ON! Name that poor prim!\"");
        }
        getLatestUpdate();
    }
    touch_start(integer num_detected)
    {
        fClearListeners();
        g_internal_touchTime_i = llGetUnixTime();
    }
    touch_end(integer total_number)
    {
        g_cached_toucher_k = llDetectedKey(0);
        g_cached_dialogChannel_i = llRound(llFrand(-200000));
        string et = "touch_end";
        dm(LOG_DEBG,et,"Channel = " + (string)g_cached_dialogChannel_i);
        dm(LOG_DEBG,"touch_end",(string)g_cached_toucher_k);
        //llOwnerSay("Level 1");
        if ((g_status_inUse_b) /* is the tail already in use? */
            || ((g_cached_lastToucher_k != NULL_KEY) // Not a null key (default value)
            && (g_cached_lastToucher_k != g_cached_toucher_k))) // Different person, in this dimension
        {
            //llOwnerSay("Level 2");
            g_cached_lastToucher_k = g_cached_toucher_k; // Store the new key
            dm(LOG_DEBG,et,"Clearing listener because toucher changed");
            fClearListeners();
        }
        dm(LOG_DEBG,et,"Checking user and generating new menus");
        if(g_cached_toucher_k == g_cached_owner_k)
        {
            dm(LOG_DEBG,et,"Toucher is owner");
            if (llGetUnixTime() >= (g_internal_touchTime_i + g_config_touchDelay_i))
            {
                xlGenerateMenuData(OWNER_MENU);
            }
        }
        if (g_cached_toucher_k != g_cached_owner_k)
        {
            dm(LOG_DEBG,et,"Toucher is other");
            xlGenerateMenuData(OTHERS_MENU);
            g_cached_toucherName_s = llGetDisplayName(g_cached_toucher_k);
            llOwnerSay(g_cached_toucherName_s + " is touching your " + g_config_objectType_s + "...");
            string nameEnd = llGetSubString(g_cached_toucherName_s, -1, -1);
            if (nameEnd == "s")
            {
                g_dyn_poss_toucher_s = "'";
            }
            else
            {
                g_dyn_poss_toucher_s = "'s";
            }
        }
        dm(LOG_DEBG,et,"Running listener timout loop");
        llSetTimerEvent(g_internal_listenTimeout_i);
        g_internal_touchTime_i = 0;
    }
    listen(integer c, string n, key g_cached_toucher_k, string m)
    {
        if(!c) return; // Don't listen on channel 0
        string et = "listen";
        dm(LOG_DEBG,et,"Channel received: " + (string)c);
        dm(LOG_DEBG,et,"Listening for menu type = " + (string)bMenuType);
        dm(LOG_VERB,et,n + " selected " + m);
        if (g_config_removeIconInNameLinks_b)
        {
            n=Key2Link(g_cached_toucher_k);
        }
        else
        {
            n = llGetDisplayName(g_cached_toucher_k);
        }
        // tail commands
        // if(bMenuType == OTHERS_MENU)
        {
            if(m == "Emote")
            {
                xlCreateMenu("What kind of emotes do you want to do?",g_menu_Emote_l1Type_l);
            }
            else if(m == "Soft Emotes")
            {
                xlGenerateMenuData(SOFT_MENU);
            }
            else if(m == "Adult Emotes")
            {
                xlGenerateMenuData(ADULT_MENU);
            }
            else if(m == "Gender") // 2
            {
                xlGenerateMenuData(GENDER_MENU);
            }
            else
            {
                if(m == "Lock")
                {
                    g_status_locked_i = TRUE;
                    llOwnerSay("Locked");
                }
                else if(m == "Unlock")
                {
                    g_status_locked_i = FALSE;
                    llOwnerSay("Unlocked");
                }
                else if(m == "Waggle")
                {
                    sendEmote( n + " waggles " + g_dyn_his_s + " " + g_config_objectType_s + " happily!");
                    twitch("7");
                }
                else if(m == "Check Update")
                {
                    getLatestUpdate();
                }
                fClearListeners();
            }
        }
        if (bMenuType == GENDER_MENU)
        {
            dm(LOG_DEBG,et,"Processing Gender Response");
            if(m == "Tacos")
            {
                fSetGender(0);
                dm(LOG_VERB,et,"gender set to female");
            }
            else if(m == "Sausage")
            {
                fSetGender(1);
                dm(LOG_VERB,et,"gender set to male");
            }
            fClearListeners();
        }
        //// Soft Emotes ////
        // else if(bMenuType == SOFT_MENU)
        // Scope hack.
        {
            string sOwnerNameInEmote;
            if (g_config_removeIconInNameLinks_b && g_config_removeIconInOwnerName_b)
            {
                sOwnerNameInEmote = Key2Link(g_cached_owner_k);
            }
            else
            {
                sOwnerNameInEmote = g_cached_ownerDisplayName_s;
            }
            if(bMenuType == SOFT_MENU)
            {
                if(m == "Nom On")
                {
                    sendEmote( n + " grabs and noms on " + sOwnerNameInEmote + g_dyn_poss_owner_s + " " + g_config_objectType_s + ". " + sOwnerNameInEmote + " looks back at " + g_dyn_his_s + " " + g_config_objectType_s + " to make sure " + n + " did not drool all over it.");
                }
                else if(m == "Chew On")
                {
                    sendEmote( n + " starts to chew on " + sOwnerNameInEmote + g_dyn_poss_owner_s + " " + g_config_objectType_s + ". " + sOwnerNameInEmote + " is not too sure how to feel about this o.o...");
                }
                else if(m == "Bite")
                {
                    sendEmote( n + " bites down on " + sOwnerNameInEmote + g_dyn_poss_owner_s + " " + g_config_objectType_s + "! >w<");
                }
                else if(m == "Pet")
                {
                    sendEmote( n + " takes a hold of " + sOwnerNameInEmote + g_dyn_poss_owner_s + " " + g_config_objectType_s + " and starts petting it! ♥");
                }
                else if(m == "Tug")
                {
                    sendEmote( n + " grabs and tugs hard on " + sOwnerNameInEmote + g_dyn_poss_owner_s + " " + g_config_objectType_s + "! " + sOwnerNameInEmote + " tugs back on " + n + g_dyn_poss_toucher_s + " ear! :3");
                }
                else if(m == "Grab")
                {
                    sendEmote( n + " grabs " + sOwnerNameInEmote + g_dyn_poss_owner_s + " " + g_config_objectType_s + " and just holds it. " + sOwnerNameInEmote + " looks back at " + n + ".");
                }
                else if(m == "Play")
                {
                    llSay(0,g_cached_ownerDisplayName_s + " swishes " + g_dyn_his_s + " " + g_config_objectType_s + " about. " + n + " grabs it and starts tugging it playfully.");
                }
                else if(m == "Hug")
                {
                    sendEmote( n + " grabs " + sOwnerNameInEmote + g_dyn_poss_owner_s + " " + g_config_objectType_s + " and gives it a big hug! ♥");
                }
                else if(m == "Hold")
                {
                    sendEmote( n + " grabs and holds " + sOwnerNameInEmote + g_dyn_poss_owner_s + " " + g_config_objectType_s + ", refusing to let " + g_dyn_him_s + " go!");
                }
                else if(m == "Fluff")
                {
                    sendEmote( n + " fluffs " + sOwnerNameInEmote + g_dyn_poss_owner_s + " " + g_config_objectType_s + ", making it nice and soft. ^^");
                }
            }
            /// Adult Emotes ////
            else if(bMenuType == ADULT_MENU) // 1
            {
                if(m == "Lick Genitals")
                {
                    if( g_config_isMale_b == 1){
                        sendEmote( n + " bends down in front of " + sOwnerNameInEmote + ", slowly moving their hands to reach " + sOwnerNameInEmote + g_dyn_poss_owner_s + " butt, squeezing it softly with one hand as they grab his cock, slowly licking it up and down while looking at him...");
                    }
                    else{
                        sendEmote( n + " bends down in front of " + sOwnerNameInEmote + ", slowly kissing her lap and then put their mouth on her pussy, licking slowly...");
                    }
                }
                else if(m == "Lick Butt")
                {
                    sendEmote( n + " bends down and licks " + sOwnerNameInEmote + g_dyn_poss_owner_s + " butt! ♥");
                }
                else if(m == "Smack Butt")
                {
                    sendEmote( n + " smacks " + sOwnerNameInEmote + g_dyn_poss_owner_s + " butt!");
                }
                else if(m == "Grope")
                {
                    sendEmote( n + " gropes " + sOwnerNameInEmote + "! ^_~");
                }
                else if(m == "Hump")
                {
                    sendEmote( n + " grabs " + sOwnerNameInEmote + " from behind and starts humpin!");
                }
            }
            // fClearListeners();
        }
    }
    http_response(key request_id, integer status, list metadata, string body)
    {
        if (request_id != g_internal_httprid_k) return;// exit if unknown
        string new_version_s = llJsonGetValue(body,["tag_name"]);
        if (new_version_s == g_internal_version_s) return;
        list cur_version_l = llParseString2List(g_internal_version_s, ["."], [""]);
        list new_version_l = llParseString2List(new_version_s, ["."], [""]);
        string update_type = "version";
        if (llList2Integer(new_version_l, 0) > llList2Integer(cur_version_l, 0)){
            update_type = "major version"; jump update;
        }
        else if (llList2Integer(new_version_l, 1) > llList2Integer(cur_version_l, 1)){
            update_type = "version"; jump update;
        }
        else if (llList2Integer(cur_version_l, 2) < llList2Integer(new_version_l, 2)){
            update_type = "patch"; jump update;
        }
        jump end;
        @update;
        g_cached_updateMsg_s = "\nA new " + update_type + " is available!\n"
            +"[" + new_version_s+ "] \""+llJsonGetValue(body,["name"])+"\"";
            string update_description_s = llJsonGetValue(body,["body"]);
            if(llStringLength(update_description_s) >= 128)
            {
                update_description_s = "Too many changes, see link below.";
            }
            g_cached_updateMsg_s +="\n"+update_description_s
            +"\n["+"https://github.com/"+g_internal_repo_s+"/compare/"
                +g_internal_version_s+"..."+new_version_s+" What's new?]\n\n"

            +"Your new script(s):\n[https://raw.githubusercontent.com/"+g_internal_repo_s
                +"/"+new_version_s+"/tailmenu.lsl OpenEmoteTail.lsl]";
            ;
            g_status_showUpdateBtn_b = FALSE;
        llOwnerSay("["+llGetScriptName()+".lsl] ("+g_internal_version_s + "):\n"+g_cached_updateMsg_s);
        @end;
        llSetMemoryLimit(llGetUsedMemory()+g_internal_memoryLimit_i);
    }
    timer()
    {
        llInstantMessage(g_cached_toucher_k,"Timed out. Click the tail again to get a menu");
        fClearListeners();
        llSetTimerEvent(0);
    }
}
