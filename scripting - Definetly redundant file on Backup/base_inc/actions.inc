/*******************************************************************************************
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
 ******************************************************************************************/


#if defined _BASE_ACTIONS_INCLUDED
  #endinput
#endif
#define _BASE_ACTIONS_INCLUDED


////////////////////////////////////////////////////////////////////////////////////////////
// Punishment Actions
////////////////////////////////////////////////////////////////////////////////////////////


public SlapPlayer( aCmdParm[] )
    user_slap( aCmdParm[0], aCmdParm[1] )



stock ActionWarn( nUserID )
{
    client_print( nUserID, print_chat, "%s %s -- WARNING! Do Not Swear Again! You May Be Punished!", PLUGIN_MOD, PLUGIN_NAME )
    return
}

stock ActionGag( nUserID )
{
    new nGagTime = get_cvar_num( "sv_gag_time" )
    new aCmdParm[2]
    aCmdParm[0] = nUserID

    set_task( float(nGagTime), "ActionUngag", (TASK_PLAYER_GAG + nUserID), aCmdParm, 1 )

    g_bUserGagged[nUserID-1] = true

    // Announce Punishment
    new szUsername[STR_T]
    get_user_name( nUserID, szUsername, STR_T-1 )
    client_print( 0, print_chat, "%s %s Has Been Gagged for Swearing for %d Seconds!", PLUGIN_MOD, szUsername, nGagTime )

    return
}

stock ActionSlap( nUserID )
{
    new nSlapDmg = get_cvar_num( "sv_slap_dmg" )
    new nSlapTimes = get_cvar_num( "sv_slap_times" )

    new aCmdArgs[3]
    aCmdArgs[0] = nUserID
    aCmdArgs[1] = nSlapDmg

    if( nSlapTimes < 2 ) nSlapTimes = 2
    set_task( 0.1, "SlapPlayer", (TASK_PLAYER_SLAP + nUserID), aCmdArgs, 2, "a", nSlapTimes )

    // Announce Punishment
    new szUsername[STR_T]
    get_user_name( nUserID, szUsername, STR_T-1 )
    client_print( 0, print_chat, "%s %s Has Been Slapped %d Times for Swearing!", PLUGIN_MOD, szUsername, nSlapTimes )

    return
}

stock ActionFire( nUserID )
{
    new nFireDmg = get_cvar_num( "sv_fire_dmg" )
    new nFireTime = get_cvar_num( "sv_fire_time" )

    new aCmdArgs[3]
    aCmdArgs[0] = nUserID
    aCmdArgs[1] = nFireDmg

    g_bUserFlame[nUserID-1] = true
    ignite_effects( aCmdArgs )
    ignite_player( aCmdArgs )
    set_task( float( nFireTime ), "ExtinguishPlayer", (TASK_PLAYER_FIRE + nUserID), aCmdArgs, 1 )

    // Announce Punishment
    new szUsername[STR_T]
    get_user_name( nUserID, szUsername, STR_T-1 )
    client_print( 0, print_chat, "%s %s Has Been Set on Fire for Swearing for %d Seconds!", PLUGIN_MOD, szUsername, nFireTime )

    return
}

stock ActionSlay( nUserID )
{
    ThrowLightning( nUserID )

    // Announce Punishment
    new szUsername[STR_T]
    get_user_name( nUserID, szUsername, STR_T-1 )
    client_print( 0, print_chat, "%s %s Has Been Slain for Swearing!", PLUGIN_MOD, szUsername )

    return
}

stock ActionCash( nUserID )
{
    new nCash = get_user_money( nUserID )
    new nCashLoss = get_cvar_num( "sv_cash_loss" )

    if( nCash-nCashLoss > NULL )
        set_user_money( nUserID, nCash-nCashLoss )
    else
        set_user_money( nUserID, 0 )

    // Announce Punishment
    new szUsername[STR_T]
    get_user_name( nUserID, szUsername, STR_T-1 )
    client_print( 0, print_chat, "%s %s Has Lost Cash ($%d) for Swearing!", PLUGIN_MOD, szUsername, nCashLoss )

    return
}

stock ActionKick( nUserID )
{
    server_cmd( "kick #%d ^"No Swearing Allowed.^"", get_user_userid( nUserID ) )

    // Announce Punishment
    new szUsername[STR_T]
    get_user_name( nUserID, szUsername, STR_T-1 )
    client_print( 0, print_chat, "%s %s Has Been Kicked for Swearing!", PLUGIN_MOD, szUsername )

    return
}

stock ActionBan( nUserID )
{
    new Float:fBanTime = float(get_cvar_num( "sv_ban_time" ))
    new szUsername[STR_T], szUserID[STR_T]
    get_user_name( nUserID, szUsername, STR_T-1 )

    if( get_cvar_num( "sv_bantype" ) == 1 )
    {
        get_user_ip( nUserID, szUserID, 31, 1 )
        server_cmd( "addip ^"%d^" ^"%s^";wait;writeip", floatround(fBanTime), szUserID )
    }else
    {
        get_user_authid( nUserID, szUserID, 31 )
        server_cmd( "banid ^"%d^" ^"%s^" kick;wait;writeid", floatround(fBanTime), szUserID )
    }
    server_cmd( "kick #%d ^"No Swearing Allowed.^"", get_user_userid( nUserID ) )


    if( fBanTime > 60.0 )
    {
        fBanTime /= 60.0
        // Announce Punishment
        client_print( 0, print_chat, "%s %s Has Been Banned for Swearing for %3.1f Hours!", PLUGIN_MOD, szUsername, fBanTime )
    }else
    {
        // Announce Punishment
        client_print( 0, print_chat, "%s %s Has Been Banned for Swearing for %3.0f Minutes!", PLUGIN_MOD, szUsername, fBanTime )
    }
    return
}


////////////////////////////////////////////////////////////////////////////////////////////
// Reverse Actions
////////////////////////////////////////////////////////////////////////////////////////////

public ActionUngag( aCmdParm[] )
{
    g_bUserGagged[aCmdParm[0]-1] = false
    remove_task( TASK_PLAYER_GAG + aCmdParm[0] )
    client_print( aCmdParm[0], print_chat, "%s You have been Ungagged! Watch Your Language!", PLUGIN_MOD )
    return
}

public ExtinguishPlayer( aCmdParm[] )
{
    client_print( aCmdParm[0], print_chat, "You Have Been Extinguished!" )
    g_bUserFlame[aCmdParm[0]-1] = false
    return
}
