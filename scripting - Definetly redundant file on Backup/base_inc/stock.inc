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


#if defined _BASE_STOCK_INCLUDED
  #endinput
#endif
#define _BASE_STOCK_INCLUDED


#if defined USE_AMXX_MODE
stock set_user_money( nUserID, nMoney )
{
    return cs_set_user_money( nUserID, nMoney )
}
stock get_user_money( nUserID )
{
    return cs_get_user_money( nUserID )
}
#endif


stock PluginEnabled( nSwitch )
{
    if( nSwitch > NULL )
        set_cvar_num( "sv_swearfilter", clamp( nSwitch, 0, 1 ) )
    return get_cvar_num( "sv_swearfilter" )
}

stock WhiteListEnabled( nSwitch )
{
    if( nSwitch > NULL )
        set_cvar_num( "sv_whitelist", clamp( nSwitch, 0, 1 ) )
    return get_cvar_num( "sv_whitelist" )
}

stock HelpEnabled( nSwitch )
{
    if( nSwitch > NULL )
        set_cvar_num( "sv_swearhelp", clamp( nSwitch, 0, 1 ) )
    return get_cvar_num( "sv_swearhelp" )
}

stock NameFilterEnabled( nSwitch )
{
    if( nSwitch > NULL )
        set_cvar_num( "sv_checknames", clamp( nSwitch, 0, 1 ) )
    return get_cvar_num( "sv_checknames" )
}

stock FilterSystem( nSwitch )
{
    if( nSwitch > NULL )
        set_cvar_num( "sv_filtersystem", clamp( nSwitch, 0, 2 ) )

    return get_cvar_num( "sv_filtersystem" )
}

stock PunishSystem( nSwitch )
{
    if( nSwitch > NULL )
        set_cvar_num( "sv_punishsystem", clamp( nSwitch, 0, 2 ) )

    return get_cvar_num( "sv_punishsystem" )
}

stock RenameSystem( nSwitch )
{
    if( nSwitch > NULL )
        set_cvar_num( "sv_renamesystem", clamp( nSwitch, 0, 2 ) )

    return get_cvar_num( "sv_renamesystem" )
}

stock CensorSystem( nSwitch )
{
    if( nSwitch > NULL )
        set_cvar_num( "sv_censorsystem", clamp( nSwitch, 0, 2 ) )

    return get_cvar_num( "sv_censorsystem" )
}

stock bool:InputSwitch( szArg[] )
{
    return ( equali( szArg, "on", 2 ) || equali( szArg, "1", 1 ) ) ? true : false
}

stock bool:IsPlayerImmune( nUserID )
{
    if( get_cvar_num("sv_obeyimmunity") < 1 )
        return false
    return (get_user_flags( nUserID ) & ADMIN_IMMUNITY) ? true : false
}

stock AdminRanks( nUserID )
{
    if( !g_nShowAdmin && access( nUserID, ADMIN_IMMUNITY ) )
    {
        g_nShowAdmin = nUserID
        client_print( nUserID, print_console, "%s The Swear Menu is now attached to you!", PLUGIN_MOD )
    }
    return
}

stock ResetPlayer( nUserID )
{
    g_nOffenseCount[nUserID-1] = 0
    g_bUserGagged[nUserID-1] = false

    if( task_exists( TASK_PLAYER_GAG + nUserID ) )
        remove_task( TASK_PLAYER_GAG + nUserID )

    return
}

stock ResetAdmin( nUserID )
{
    if( g_nShowAdmin == nUserID ) g_nShowAdmin = 0
    return
}

stock ReadPunFlags( szFlags[] )
{
    new i, j = 0
    for( i = 0; i < MAX_PUNISHMENTS; i++ )
        if( containi( szFlags, g_szPunFlags[i] ) > NULL )
            j |= (1<<i)
    return j
}

stock IssuePunishment( nUserID, nPunishment )
{
    switch( nPunishment )
    {
        case 0: ActionGag( nUserID )
        case 1: ActionSlap( nUserID )
        case 2: ActionFire( nUserID )
        case 3: ActionSlay( nUserID )
        case 4: ActionCash( nUserID )
        case 5: ActionKick( nUserID )
        case 6: ActionBan( nUserID )
        default: ActionWarn( nUserID )
    }
    return
}

stock MultiPunishment( nUserID, szPunFlags[] )
{
    new i, nPunBits = ReadPunFlags( szPunFlags )
    for( i = 0; i < MAX_PUNISHMENTS; i++ )
    {
        if( nPunBits & (1<<i) )
        {
            IssuePunishment( nUserID, i )
        }
    }
    return
}

stock PunishPlayer( nUserID )
{
    new nSystem = PunishSystem( NULL )
    new szPunFlags[MAX_PUNISHMENTS+1]

    if( nSystem == PS_PROG && g_bLoadErrPunish )
        nSystem = PS_SINGLE

    if( nSystem == PS_PROG )
    {
        MultiPunishment( nUserID, g_szPunishments[g_nOffenseCount[nUserID-1]++] )
        if( g_nOffenseCount[nUserID-1] >= g_nProgPunCount )
            g_nOffenseCount[nUserID-1] = 0
    }
    else if( nSystem == PS_SINGLE )
    {
        if( g_nShowAdmin > 0 )
        {
            ShowMenuToAdmin( g_nShowAdmin, nUserID )
        }
        else
        {
            get_cvar_string( "sv_punish_single", szPunFlags, MAX_PUNISHMENTS )
            MultiPunishment( nUserID, szPunFlags )
        }
    }
    return
}

stock RenamePlayer( nUserID )
{
    new nSystem = RenameSystem( NULL )
    new szNewName[MAX_NAME_LEN], szOldName[MAX_NAME_LEN]
    get_user_info( nUserID, "name", szOldName, MAX_NAME_LEN-1 )

    if( nSystem == RS_OLDNAME )
    {
        format( szNewName, MAX_NAME_LEN-1, "%s", szOldName )
    }
    else if( nSystem == RS_STEAMID )
    {
        get_user_authid( nUserID, szNewName, MAX_NAME_LEN-1 )
    }
    else // RS_CUSTOM
    {
        get_cvar_string( "sv_rename_custom", szNewName, MAX_NAME_LEN-1 )
    }
    set_user_info( nUserID, "name", szNewName )
    client_print( nUserID, print_console, "%s %s :: Your Name Was Auto-Changed To: %s", PLUGIN_MOD, PLUGIN_NAME, szNewName )

    return
}

stock SwearWordsHelp( nUserID )
{
    if( !PluginEnabled( NULL ) || !HelpEnabled( NULL ) ) return

    const nSize = STR_L + (MAX_WORD_LENGTH * BLACKLIST_WORDS)
    new szMsg[nSize], nLen, i

    nLen = format( szMsg, (nSize-1), "<html><body bgcolor=#3E4637 text=#C4B550><center><b><u>Swear Words List</u>:</b></center><br><ul>" )
    for( i = 0; i < BLACKLIST_WORDS; i++ )
    {
        if( !g_szBlackList[i][0] ) break
        nLen += format( szMsg[nLen], ((nSize-1)-nLen), "<li>%s", g_szBlackList[i] )
    }
    format( szMsg[nLen], ((nSize-1)-nLen), "</ul></body></html>" )
    show_motd( nUserID, szMsg, PLUGIN_NAME )
    return
}

stock CensorText( szText[], nPos, nLen )
{
    new i = 0, j = 0, nSystem = CensorSystem( NULL )
    new szCensorChar[2]

    if( nSystem == CS_CUSTOM )
    {
        get_cvar_string( "sv_censor_custom", szCensorChar, 1 )
        while( --nLen >= 0 )
            szText[nPos+nLen] = szCensorChar[0]
    }
    else if( nSystem == CS_RANDOM )
    {
        while( --nLen >= 0 )
        {
            while( i == j ) i = random_num(0, MAX_CENSORS-1)
            szText[nPos+nLen] = g_szCensors[i][0]
            j = i
        }
    }
    return
}

stock RS_Char_Filter( szText[] )
{
    for( new i = 0; i < MAX_FILTERS; i++ )
        while( containi( szText, g_szFilter[i] ) > NULL )
            replace( szText, MAX_CHAT_LEN-1, g_szFilter[i], "" )
    return
}

// 1337 Word Filter
// Originally Written By KrezerJ
stock KJ_1337_Filter( szText[] )
{
    for( new i = 0; szText[i]; i++ )
    {
        switch( szText[i] )
        {
            case '@': szText[i] = 'a'
            case '4': szText[i] = 'a'
            case '(': szText[i] = 'c'
            case '3': szText[i] = 'e'
            case '#': szText[i] = 'h'
            case '!': szText[i] = 'i'
            case '|': szText[i] = 'i'
            case '1': szText[i] = 'i'
            case '0': szText[i] = 'o'
            case '$': szText[i] = 's'
            case '5': szText[i] = 's'
            case '+': szText[i] = 't'
            case '7': szText[i] = 't'
        }
    }
    return
}


stock FilterText( id, szText[] )
{
    new i, j, nBLPos = 0, nWLPos = 0, nLen = 0
    new bool:bUseWL = true, bool:bSkip = false
    new nFound = 0

    if( g_bLoadErrWL || !WhiteListEnabled( NULL ) )
        bUseWL = false

    // Apply Text Filters According to Filter System
    if( FilterSystem( NULL ) == FS_FULL )
    {
        KJ_1337_Filter( szText )
        RS_Char_Filter( szText )
    }
    else if( FilterSystem( NULL ) == FS_SLIM )
    {
        RS_Char_Filter( szText )
    }

    for( i = 0; i < BLACKLIST_WORDS; i++ )
    {
        if( !g_szBlackList[i][0] ) break

        nBLPos = containi( szText, g_szBlackList[i] )
        while( nBLPos > NULL )
        {
            bSkip = false
            nLen = strlen( g_szBlackList[i] )
            if( bUseWL && !g_bLoadErrWL )
            {
                for( j = 0; j < WHITELIST_WORDS; j++ )
                {
                    if( !g_szWhiteList[j][0] ) break

                    nWLPos = containi( szText, g_szWhiteList[j] )
                    if( nWLPos == nBLPos )
                    {
                        bSkip = true
                        break
                    }
                }
            }
            if( !bSkip )
            {
                nFound++
                copy( g_szBadWord[id-1], MAX_WORD_LENGTH-1, g_szBlackList[i] )
                CensorText( szText, nBLPos, nLen )
            }
            nBLPos = containi( szText, g_szBlackList[i] )
        }
    }
    return nFound
}

stock WriteLog( const szMessage[] )
{
    // Log Message to File
#if defined USE_AMXX_MODE
    log_amx( szMessage )
#else
    log_message( szMessage )
#endif
    return
}

stock WriteLogDebug( const szMessage[] )
{
#if defined USE_DEBUG_MODE
    WriteLog( szMessage )
#endif
    return
}

