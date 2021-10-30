/*******************************************************************************************
 *   rs_swearfilter.sma                    Version 2.0                     Date: JAN/28/2005
 *
 *   RS Advanced Swear Filter + Punishment (MySQL Support)
 *
 *   By:      Rob Secord
 *   Alias:   xeroblood (aka; Achilles)
 *   Email:   xeroblood@gmail.com
 *
 *   Credits: _KaszpiR_, Util, Knocker, poosmith (See Credits Section Below For More Info)
 *
 *   Tested / Developed On:
 *      CS 1.6 - AMX 0.9.9
 *      CS 1.6 - AMXX 1.0
 *      MySQL v4.0.16-nt (Driver: v03.51)
 *
 *******************************************************************************************
 *  Admin Commands:
 *     amx_swearmode <on|off>   - In-game admin command to Turn swearMode
 *                                on or off. (removes any current punishments)
 *     amx_swearmenu            - Toggles Swear Menu To Be Attached to you In-Game
 *                                If Swear Menu is attached to an Admin, only
 *                                that admin will see the Swear Menu when a
 *                                player swears too many times.  If SwearMenu
 *                                is not attached to an admin, then Gag mode
 *                                is the default!
 *     amx_namecheck            - Runs a Swear Filter On All Clients' Username
 *                                Should be called if CVAR sv_checknames is
 *                                changed to 1 In-Game.
 *
 *  Server CVARS:
 *     sv_swearfilter     <0|1>    - Turns the Whole Plugin On/Off
 *                                     (0 = Off) (1 = On)
 *     sv_filtersystem    <0|1|2>  - Swear Filter System to use:
 *                                     (0 = Full Mode) (1 = Slim Mode) (2 = Simple Mode)
 *     sv_punishsystem    <0|1|2>  - Punishment System to use:
 *                                     (0 = None) (1 = Single) (2 = Progressive)
 *     sv_censorsystem    <0|1|2>  - Word Censoring System to use:
 *                                     (0 = None) (1 = Random (@$%#)) (2 = Custom)
 *     sv_renamesystem    <0|1|2>  - Renaming System to use:
 *                                     (0 = Old Name) (1 = Steam ID) (2 = Custom)
 *     sv_whitelist       <0|1>    - Whitelist System for GOOD words
 *                                     (0 = No Whitelist) (1 = Use Whitelist)
 *     sv_checknames      <0|1>    - Player Name Filter
 *                                     (0 = Ignore Names) (1 = Filter Names)
 *     sv_swearhelp       <0|1>    - Player Help System (say /swear)
 *                                     (0 = No Help) (1 = Help)
 *     sv_bantype         <0|1>    - Player Ban Type to use:
 *                                     (0 = Steam ID) (1 = IP Address)
 *     sv_obeyimmunity    <0|1>    - Obey AMX Admin Immunity Rules for Punishments
 *                                     (0 = Disobey) (1 = Obey)
 *
 *     sv_menu_options    "abc"    - The Punishments Allowed in Swear Menu (Possible Flags: "abcdefg")
 *     sv_punish_single   "abc"    - The Default Punishment for Single Mode (Possible Flags: "abcdefg")
 *     sv_rename_custom   "Noob"   - The Custom Name used for Renaming System
 *     sv_censor_custom   "*"      - The Custom Character used for Censoring System
 *     sv_cash_loss       ##       - Amount of Cash player will Lose
 *     sv_gag_time        ##       - Number of Seconds player will be Gagged
 *     sv_ban_time        ##       - Number of Minutes player will be Banned
 *     sv_fire_time       ##       - Number of Seconds. player will be Set on Fire
 *     sv_fire_dmg        ##       - Amount of Damage/Second player will lose from Fire
 *     sv_slap_times      ##       - Number of Times player will be Slapped
 *     sv_slap_dmg        ##       - Amount of Damage of each Slap
 *
 *******************************************************************************************
 *
 *     If longest swear word is > 24 characters, change MAX_WORD_LENGTH
 *     to reflect longest word.
 *     If you have more that 40 words, change BLACKLIST_WORDS to reflect
 *     the number of words in file!
 *
 *     If you use SQL, run the file tables.sql included in ZIP!
 *
 *******************************************************************************************
 *   Credits:
 *      As Always, Much of the credit goes to The People and Tutorials at
 *      http://amxmod.net/forums & http://www.amxmodx.org/forums for lots of
 *      information, and good advice!!
 *
 *   Plugin Topic:
 *     [AMX] http://djeyl.net/forum/index.php?showtopic=27801
 *    [AMXX] http://www.amxmodx.org/forums/viewtopic.php?t=621
 *
 *   Bug Fixes/Updates
 *      _KaszpiR_
 *
 *   Ideas/Suggestions:
 *      Util, Knocker (see Updates below)
 *
 *   Noticed Bugs (Case-Sensitivity):
 *      poosmith
 *
 *******************************************************************************************
 *  Revision History:
 *
 *  Updates To Version 2.0:
 *    - Added support for AMX 0.9.9b & AMXX 1.0
 *    - Added Punishment System: None, Single and Progressive Modes
 *    - Added Filter System: Simple, Slim and Full Modes
 *    - Changed Renaming System: Old Name, STEAM ID or Custom
 *    - Changed Word Censor System: None, Random or Custom
 *    - Added CVAR to turn Punishments ON/OFF in Swear Menu
 *    - Fixed Crash Bugs on Multiple Swear Words in one line
 *
 *  Updates To Version 1.6:
 *    - Fixed support for non-MySql admins (requires recompile)
 *      (Removed CVAR sv_usemysql -- Defined USE_MYSQL instead)
 *    - Compiled on Linux SUSE 9.0 by Knocker!!
 *
 *  Updates To Version 1.5:
 *    - Checks Names for Swear Words if CVAR sv_checknames is set to 1
 *    - Renames Offensive names to WONID, IP or "Potty-Mouth #". Change by
 *      setting CVAR sv_rename_mode to 1, 2 or 3 respectively.
 *
 *    - Uses MySQL or FILE for Swear Word List. To Use MySQL, set CVAR
 *      sv_usemysql to 1, default is 0 (Read From File)
 *
 *    - Added a Whitelist for Good Words (goodwords.ini, or MySQL Table)
 *
 *    - Uses Word Filters (fu.ck) If CVAR sv_usefilters is set to 1
 *    - Added CVAR sv_swearexact to Test against whole words or substrings
 *      (This should help protect ppl who say FUN when FU is a Swear Word)
 *      (Idea: Knocker)
 *
 *    - Added A New Menu Punishment! Remove Cash From Player, Amount of
 *      cash removed is in CVAR sv_cashloss
 *
 *    - Added a CVAR for the Special Character used for Censoring Words!!
 *      (instead of ****, see whatever char you want!!)
 *      (Idea: Knocker)
 *
 *    - Changed: if sv_sweartimes is set to 0, Punishment Is Turned OFF!
 *
 *    - Added a Help MOTD for players who say /swearwords.  Admins may
 *      disable this option with CVAR sv_swearhelp
 *
 *  Updates To Version 1.4: (Credits: Util for the Ideas!)
 *    - Reads Swear Words From File (addons/amx/swearwords.ini)
 *    - Added Ban Option (Ban Perm / # Minutes)
 *       (# Minutes is a CVAR: amx_bantime #)
 *       (Ban By WONID or IP)
 *    - Added Swear Word To Menu
 *
 *  Updates To Version 1.4: (Credits: Knocker for the Ideas!)
 *    - Added Notice to Users When They Swear
 *    - Added CVAR for displaying/censoring Swear Word
 *    - Added Word Filter to catch words like:  fu.ck  or   f*u.C,k   etc...
 *
 *  Versions prior to 1.4 unreleased...
 *
 **************************************************************************/



#include "base_inc/config.cfg"     // Pre-compilation Configurations

#if defined USE_AMXX_MODE
    #include <amxmodx>             // AMX Mod X 1.0 Base
    #include <cstrike>             // AMX Mod X 1.0 CS Module
    #include <fun>                 // AMX Mod X 1.0 Fun Module
#else
    #include <amxmod>              // AMX Mod 0.9.9b Base
    #include <fun>                 // AMX Mod 0.9.9b Fun Module
#endif
#include <amxmisc>                 // AMX/AMXX Misc

#include "base_inc/const.inc"      // Constants
#include "base_inc/global.inc"     // Globals
#include "base_inc/stock.inc"      // Stock Functions
#include "base_inc/actions.inc"    // Punishment Actions
#include "base_inc/effects.inc"    // Punishment Effects

#if defined USE_SQL_MODE
    #if defined USE_AMXX_MODE
        #include "base_inc/dbi.inc"    // AMXX DBI Interface
    #else
        #include "base_inc/mysql.inc"  // AMX MySQL Interface
    #endif
#else
    #include "base_inc/file.inc"       // File Interface
#endif


#if defined USE_AMXX_MODE && defined USE_SQL_MODE
public plugin_modules()
{
    require_module("DBI")
}
#endif


public plugin_init()
{
    register_plugin( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR )

                                                      // Defaults:
    register_cvar( "sv_swearfilter",   "1" )          // 1 = On
    register_cvar( "sv_filtersystem",  "0" )          // 0 = Full Mode
    register_cvar( "sv_punishsystem",  "2" )          // 2 = Progressive
    register_cvar( "sv_censorsystem",  "1" )          // 2 = Random
    register_cvar( "sv_renamesystem",  "2" )          // 2 = Custom Name (Defined in CVAR)
    register_cvar( "sv_whitelist",     "1" )          // 1 = Whitelisted Words Enabled
    register_cvar( "sv_checknames",    "1" )          // 1 = Check Names for Swear Words
    register_cvar( "sv_swearhelp",     "1" )          // 1 = Client Help Enabled
    register_cvar( "sv_bantype",       "0" )          // 0 = Ban Steam ID
    register_cvar( "sv_obeyimmunity",  "1" )          // 1 = Obey Admin Immunity
    register_cvar( "sv_menu_options",  "abcdefg" )    // = All Punishments Enabled in Menu
    register_cvar( "sv_punish_single", "ae" )         // = Gag & CashLoss in Single Mode
    register_cvar( "sv_rename_custom", "PottyMouth" ) // = Custom Name for Renaming
    register_cvar( "sv_censor_custom", "*" )          // = Custom Character for Overwriting Swear Words
    register_cvar( "sv_cash_loss",     "1000" )       // = Amount of Cash Lost as Punishment
    register_cvar( "sv_gag_time",      "120" )        // = Time in Seconds Gag Lasts
    register_cvar( "sv_ban_time",      "1440" )       // = Time in Minutes Ban Lasts
    register_cvar( "sv_fire_time",     "15" )         // = Time in Intervals Fire Lasts
    register_cvar( "sv_fire_dmg",      "5" )          // = Amount of HP Damage/Interval
    register_cvar( "sv_slap_times",    "15" )         // = Amount of Slaps for Punishment
    register_cvar( "sv_slap_dmg",      "5" )          // = Amount of HP Damage/Slap

    register_menucmd( register_menuid("Swear Menu"), 1023, "SwearMenuCommand" )

    register_clcmd( "amx_swearmode", "ToggleSwearFilter", REQD_LEVEL, "<on|off> -- Toggles Swear Mod On or Off" )
    register_clcmd( "amx_swearmenu", "AttachMenuToAdmin", REQD_LEVEL, "Toggle Switch For Admins To See Menu" )
    register_clcmd( "amx_namecheck", "RunNameCheck",      REQD_LEVEL, "Runs A Name Check On All Clients" )
    register_clcmd( "amx_sf_ungag",  "UngagPlayer",       REQD_LEVEL, "Ungags a Player Gagged by Swear Punishment" )

    register_clcmd( "say",        "CheckSay" )
    register_clcmd( "say_team",   "CheckSay" )

    // Client Message Indexes
    g_nMsgDamage = get_user_msgid( "Damage" )
}

public plugin_cfg()
{
    if( !ConnectDB() )
    {
        PluginEnabled( OFF )
        return PLUGIN_CONTINUE
    }

    if( !LoadBlackList() )
    {
        DisconnectDB()
        PluginEnabled( OFF )
        return PLUGIN_CONTINUE
    }

    g_bLoadErrWL     = !LoadWhiteList()
    g_bLoadErrPunish = !LoadPunishments()

    DisconnectDB()
    return PLUGIN_CONTINUE
}

public plugin_precache()
{
    g_sprSmoke  = precache_model( "sprites/steam1.spr" )
    g_sprMFlash = precache_model( "sprites/muzzleflash.spr" )
    g_sprLight  = precache_model( "sprites/lgtning.spr" )

    precache_sound( g_szSndScream )
    precache_sound( g_szSndFlames )
    precache_sound( g_szSndThunder )

    return PLUGIN_CONTINUE
}

public client_authorized( id )
{
    if( PluginEnabled( NULL ) )
    {
        AdminRanks( id )
        CheckName( id )
    }
    return PLUGIN_CONTINUE
}

public client_putinserver( id )
{
    if( PluginEnabled( NULL ) )
    {
        client_print( id, print_chat, "%s %s Plugin Enabled! Do Not Swear!", PLUGIN_MOD, PLUGIN_NAME )
        if( HelpEnabled( NULL ) )
            client_print( id, print_chat, "%s To See the List of Swear Words, Say /swear", PLUGIN_MOD )
    }
    return PLUGIN_CONTINUE
}

public client_disconnect( id )
{
    if( PluginEnabled( NULL ) )
    {
        ResetPlayer( id )
        ResetAdmin( id )
    }
    return PLUGIN_CONTINUE
}

public client_infochanged( id )
{
    if ( !PluginEnabled( NULL ) || !is_user_connected( id ) || IsPlayerImmune( id ) )
        return PLUGIN_CONTINUE

    new szNewName[MAX_NAME_LEN]
    new szOldName[MAX_NAME_LEN]

    get_user_info( id, "name", szNewName, MAX_NAME_LEN-1 )
    get_user_name( id, szOldName, MAX_NAME_LEN-1 )

    if( !equal( szNewName, szOldName ) )
        return CheckName( id )

    return PLUGIN_CONTINUE
}


////////////////////////////////////////////////////////////////////////////////////////////
// Client Commands Section
////////////////////////////////////////////////////////////////////////////////////////////

public ToggleSwearFilter( id, lvl, cid )
{
    if( !cmd_access( id, lvl, cid, 1 ) )
        return PLUGIN_HANDLED

    new i, szArg[32]
    read_argv( 1, szArg, 31 )
    new bool:nOnOff = InputSwitch( szArg )

    PluginEnabled( (nOnOff)?ON:OFF )
    console_print( id, "%s %s %s!", PLUGIN_MOD, PLUGIN_NAME, (nOnOff)?"Enabled":"Disabled" )

    for( i = 1; i < MAX_PLAYERS+1; i++ )
    {
        ResetPlayer( i )
        ResetAdmin( i )
    }
    if( nOnOff ) AdminRanks( id )

    return PLUGIN_HANDLED
}

public AttachMenuToAdmin( id, lvl, cid )
{
    if( !cmd_access( id, lvl, cid, 1 ) )
        return PLUGIN_HANDLED

    if( g_nShowAdmin > OFF )
    {
        if( g_nShowAdmin != id )
        {
            new szAdminName[32]
            get_user_name( g_nShowAdmin, szAdminName, 31 )
            client_print( id, print_chat, "%s ADMIN: %s Already has the Swear Menu attached!", PLUGIN_MOD, szAdminName )
        }else
        {
            g_nShowAdmin = OFF
            client_print( id, print_chat, "%s You Have Unattached The Swear Menu!", PLUGIN_MOD )
        }
    }else
    {
        g_nShowAdmin = id
        client_print( id, print_chat, "%s The Swear Menu is now attached to you!", PLUGIN_MOD )
    }
    return PLUGIN_HANDLED
}

public RunNameCheck( id, lvl, cid )
{
    if( !cmd_access( id, lvl, cid, 1 ) )
        return PLUGIN_HANDLED

    for( new i = 1; i < MAX_PLAYERS+1; i++ )
        CheckName( i )

    return PLUGIN_HANDLED
}

public UngagPlayer( id, lvl, cid )
{
    if( !cmd_access( id, lvl, cid, 1 ) )
        return PLUGIN_HANDLED

    new szTarget[STR_T]
    read_args( szTarget, STR_T-1 )
    new nUserID = cmd_target( id, szTarget, 2 )

    if( nUserID > 0 && nUserID < 33 )
    {
        g_bUserGagged[nUserID-1] = false
        remove_task( TASK_PLAYER_GAG + nUserID )
        client_print( nUserID, print_chat, "%s You have been Ungagged by an Admin! Watch Your Language!", PLUGIN_MOD )
    }
    return PLUGIN_HANDLED
}

////////////////////////////////////////////////////////////////////////////////////////////
// Swear Menu Section
////////////////////////////////////////////////////////////////////////////////////////////

public ShowMenuToAdmin( aID, vID )
{
    new szUser[STR_T], szMenuBody[STR_X], szPunFlags[MAX_PUNISHMENTS+1]
    new i, j = 0, nLen, nPunBits, nKeys = (1<<9)

    // Get CVAR of Enabled Punishments
    get_cvar_string( "sv_menu_options", szPunFlags, MAX_PUNISHMENTS )
    nPunBits = ReadPunFlags( szPunFlags )

    // Current Offender
    g_nCurrClientID = vID
    get_user_name( vID, szUser, STR_T-1 )

    // Build Menu String
    nLen = format( szMenuBody, (STR_X-1), "\rSwear Menu^n\w%s (%s)\w^n^n", szUser, g_szBadWord[vID-1] )
    for( i = 0; i < MAX_PUNISHMENTS; i++ )
    {
        if( nPunBits & (1<<i) )
        {
            nLen += format( szMenuBody[nLen], (STR_X-1)-nLen, "\w%d. \y%s^n", (j+1), g_szPunTitle[i] )
            nKeys |= (1<<j++)
        }
    }
    format( szMenuBody[nLen], (STR_X-1)-nLen, "^n\w0. Take No Action" )

    // Show Menu to Admin
    show_menu( aID, nKeys, szMenuBody )
}

public SwearMenuCommand( id, key )
{
    IssuePunishment( g_nCurrClientID, key )
    return PLUGIN_HANDLED
}

////////////////////////////////////////////////////////////////////////////////////////////
// Name & Chat Text Filter Section
////////////////////////////////////////////////////////////////////////////////////////////

public CheckSay( id )
{
    if ( !PluginEnabled( NULL ) || is_user_bot( id ) || IsPlayerImmune( id ) )
        return PLUGIN_CONTINUE

    // Commented to test against self
    //if( g_nShowAdmin == id ) return PLUGIN_CONTINUE

    // Prevent Double-Checking
    if( g_bUserSwore[id-1] )
    {
        g_bUserSwore[id-1] = false
        return PLUGIN_CONTINUE
    }

    // Get User Chat Text/Command (say/say_team)
    read_argv( 0, g_szUserCmd[id-1], 31 )
    read_args( g_szUserSpeech[id-1], MAX_CHAT_LEN-1 )
    remove_quotes( g_szUserSpeech[id-1] )

    if( containi( g_szUserSpeech[id-1], "/swear" ) > NULL )
    {
        SwearWordsHelp( id )
        return PLUGIN_HANDLED
    }

    if( g_bUserGagged[id-1] )
    {
        client_print( id, print_chat, "%s You Have Been Gagged for Swearing...You Must Wait!", PLUGIN_MOD )
        if( HelpEnabled( NULL ) )
            client_print( id, print_chat, "%s Say /swear  for a list of Offensive Words!", PLUGIN_MOD )
        return PLUGIN_HANDLED
    }

    if( FilterText( id, g_szUserSpeech[id-1] ) > 0 )
    {
        g_bUserSwore[id-1] = true

        new aID[2], Float:fDelay = get_cvar_float("amx_flood_time") + 0.05
        aID[0] = id
        set_task( fDelay, "RunSayFilter", (TASK_SAY_FILTER + id), aID, 1 )

        PunishPlayer( id )

        new szUsername[STR_T], szMsg[STR_M]
        get_user_name( id, szUsername, 31 )
        format( szMsg, STR_M-1, "%s User '%s' has been Punished for Swearing (%s)!!", PLUGIN_MOD, szUsername, g_szBadWord[id-1] )
        WriteLog( szMsg )

        return PLUGIN_HANDLED
    }
    return PLUGIN_CONTINUE
}

public CheckName( id )
{
    if ( !PluginEnabled( NULL ) || !NameFilterEnabled( NULL ) || is_user_bot( id ) || IsPlayerImmune( id ) )
        return PLUGIN_CONTINUE

    new szUserName[MAX_NAME_LEN]
    get_user_info( id, "name", szUserName, MAX_NAME_LEN-1 )

    if( FilterText( id, szUserName ) > 0 )
    {
        PunishPlayer( id )
        RenamePlayer( id )

        new szUsername[STR_T], szMsg[STR_M]
        get_user_name( id, szUsername, 31 )
        format( szMsg, STR_M-1, "%s User '%s' has been Punished for Name-Swearing (%s)!!", PLUGIN_MOD, szUsername, g_szBadWord[id-1] )
        WriteLog( szMsg )

        return PLUGIN_HANDLED
    }
    return PLUGIN_CONTINUE
}

public RunSayFilter( nArgs[] )
{
    new nID = nArgs[0]
    client_cmd( nID, "%s ^"%s^"", g_szUserCmd[nID-1], g_szUserSpeech[nID-1] )
    if( task_exists( TASK_SAY_FILTER + nID ) )
        remove_task( TASK_SAY_FILTER + nID )
    return
}
