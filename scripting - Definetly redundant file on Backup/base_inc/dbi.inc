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


#if defined _BASE_DBI_INCLUDED
  #endinput
#endif
#define _BASE_DBI_INCLUDED



// AMX Mod X 0.20 DBI-SQL Module
#include <dbi>

// Database Connection Objects
new Sql:cnSQL
new Result:rsResultSet



// Initializes a Connection with DB
stock bool:ConnectDB()
{
    new szHost[64], szUser[32], szPass[32], szDatabase[32], szError[128], szLogMsg[STR_L]

    get_cvar_string( "amx_sql_host", szHost, 63 )
    get_cvar_string( "amx_sql_user", szUser, 31 )
    get_cvar_string( "amx_sql_pass", szPass, 31 )
    get_cvar_string( "amx_sql_db",   szDatabase, 31 )

    // Database Connection
    cnSQL = dbi_connect( szHost, szUser, szPass, szDatabase, szError, 127 )
    if( cnSQL <= SQL_FAILED )
    {
        format( szLogMsg, STR_L-1, "%s %s::DBI_CONNECT Error: '%s'", PLUGIN_MOD, PLUGIN_NAME, szError )
        WriteLog( szLogMsg )
        return false
    }
    return true
}

// Closes a Connection with DB
stock DisconnectDB()
{
    dbi_close( cnSQL )
    return
}

// Load BlackList Words From DBI
stock bool:LoadBlackList()
{
    new i = 0, szError[STR_M], szLogMsg[STR_L]

    // Get BlackList Words...
    rsResultSet = dbi_query( cnSQL, "Select Word From SF_BlackList" )
    if( rsResultSet == RESULT_FAILED )
    {
        dbi_error( cnSQL, szError, STR_M-1 )
        dbi_free_result( rsResultSet )
        format( szLogMsg, STR_L-1, "%s %s::DBI_QUERY [BL] Error: '%s'", PLUGIN_MOD, PLUGIN_NAME, szError )
        WriteLog( szLogMsg )
        return false
    }else if( rsResultSet == RESULT_NONE )
    {
        dbi_free_result( rsResultSet )
        format( szLogMsg, STR_L-1, "%s %s::DBI_QUERY [BL] Error: 'No Words Found!'", PLUGIN_MOD, PLUGIN_NAME )
        WriteLog( szLogMsg )
        return false
    }

    // Load All BlackList Words into Array
    while( (dbi_nextrow( rsResultSet ) > 0) && (i < BLACKLIST_WORDS) )
        dbi_result( rsResultSet, "Word", g_szBlackList[i++], MAX_WORD_LENGTH-1 )

    // BlackList Loaded Successfully
    format( szLogMsg, STR_L-1, "%s %s::%d Swear Word%s Loaded From DBI!", PLUGIN_MOD, PLUGIN_NAME, i, (i == 1) ? "" : "s" )
    WriteLogDebug( szLogMsg )

    return true
}

// Load WhiteList Words From DBI
stock bool:LoadWhiteList()
{
    new i = 0, szError[STR_M], szLogMsg[STR_L]

    rsResultSet = dbi_query( cnSQL, "Select Word From SF_WhiteList" )
    if( rsResultSet == RESULT_FAILED )
    {
        dbi_error( cnSQL, szError, STR_M-1 )
        dbi_free_result( rsResultSet )
        format( szLogMsg, STR_L-1, "%s %s::DBI_QUERY [WL] Error: '%s'", PLUGIN_MOD, PLUGIN_NAME, szError )
        WriteLog( szLogMsg )
        return false
    }else if( rsResultSet == RESULT_NONE )
    {
        dbi_free_result( rsResultSet )
        format( szLogMsg, STR_L-1, "%s %s::DBI_QUERY [WL] Error: 'No Words Found!'", PLUGIN_MOD, PLUGIN_NAME )
        WriteLog( szLogMsg )
        return false
    }

    // Load All WhiteList Words into Array
    while( (dbi_nextrow( rsResultSet ) > 0) && (i < WHITELIST_WORDS) )
        dbi_result( rsResultSet, "Word", g_szWhiteList[i++], MAX_WORD_LENGTH-1 )

    // WhiteList Loaded Successfully
    format( szLogMsg, STR_L-1, "%s %s::%d Good Word%s Loaded From DBI!", PLUGIN_MOD, PLUGIN_NAME, i, (i == 1) ? "" : "s" )
    WriteLogDebug( szLogMsg )

    return true
}

// Load Progressive Punishments From DBI
stock bool:LoadPunishments()
{
    new szError[STR_M], szLogMsg[STR_L]//, szRank[4]

    // Get Stored Punishments by Offense Order...
    rsResultSet = dbi_query( cnSQL, "Select Punish From SF_Punishment Order By Offense" )
    if( rsResultSet == RESULT_FAILED )
    {
        dbi_error( cnSQL, szError, STR_M-1 )
        dbi_free_result( rsResultSet )
        format( szLogMsg, STR_L-1, "%s %s::DBI_QUERY [Punish] Error: '%s'", PLUGIN_MOD, PLUGIN_NAME, szError )
        WriteLog( szLogMsg )
        return false
    }else if( rsResultSet == RESULT_NONE )
    {
        dbi_free_result( rsResultSet )
        format( szLogMsg, STR_L-1, "%s %s::DBI_QUERY [Punish] Error: 'No Progressive Punishments Found!'", PLUGIN_MOD, PLUGIN_NAME )
        WriteLog( szLogMsg )
        return false
    }

    // Load Punishment Data into Arrays
    while( (dbi_nextrow( rsResultSet ) > 0) && (g_nProgPunCount < MAX_PUN_OFFENSE) )
        dbi_result( rsResultSet, "Punish", g_szPunishments[g_nProgPunCount++], MAX_PUNISHMENTS )

    // Check Punishment Count
    if( g_nProgPunCount <= 1 )
    {
        format( szLogMsg, STR_L-1, "%s %s::DBI_QUERY [Punish] Error: 'Not Enough Progressive Punishments Found!'", PLUGIN_MOD, PLUGIN_NAME )
        WriteLog( szLogMsg )
        return false
    }

    // Punishments Loaded Successfully
    format( szLogMsg, STR_L-1, "%s %s::%d Progressive Punishments%s Loaded From DBI!", PLUGIN_MOD, PLUGIN_NAME, g_nProgPunCount, (g_nProgPunCount == 1) ? "" : "s" )
    WriteLogDebug( szLogMsg )
    return true
}































// Read Player DB Data
stock bool:ReadPlayerData( id )
{
    new i, szAuthID[32], szQuery[64], szError[128]

    // User STEAM ID
    get_user_authid( id, szAuthID, 31 )
    format( szQuery, 63, "Select * From MU_Players Where UserSteamID='%s'", szAuthID )

    rsResultSet = dbi_query( cnSQL, szQuery )
    if( rsResultSet == RESULT_FAILED )
    {
        // SQL Search Error
        dbi_error( cnSQL, szError, 127 )
        server_print( "%s %s - DBI-READ Error: '%s'", PLUGIN_MOD, PLUGIN_NAME, szError )
        dbi_free_result( rsResultSet )
        return false
    }
    else if( rsResultSet == RESULT_NONE )
    {
        // New Player

        dbi_free_result( rsResultSet )
        return true
    }

    // Existing Player
    new szTempData[5][5]

    dbi_nextrow( rsResultSet )
    dbi_result( rsResultSet, "UserID", szTempData[0], 4 )
    dbi_result( rsResultSet, "UserExpBit", szTempData[1], 4 )
    dbi_result( rsResultSet, "UserZenBit", szTempData[2], 4 )
    dbi_result( rsResultSet, "UserInvBit", szTempData[3], 4 )
    dbi_result( rsResultSet, "UserLastRace", szTempData[4], 4 )
    dbi_free_result( rsResultSet )

    for( i = 0; i < 5; i++ )
        g_nUserData[i] = str_to_num( szTempData[i] )

    return true
}