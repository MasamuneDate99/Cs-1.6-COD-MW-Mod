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


#if defined _BASE_MYSQL_INCLUDED
  #endinput
#endif
#define _BASE_MYSQL_INCLUDED



// AMX Mod 0.9.9 MySQL Module
#include <mysql>

// Database Connection Objects
new cnMySql



// Initializes a Connection with DB
stock bool:ConnectDB()
{
    new szHost[64], szUser[32], szPass[32], szDatabase[32], szError[128], szLogMsg[STR_L]

    get_cvar_string( "amx_sql_host", szHost, 63 )
    get_cvar_string( "amx_sql_user", szUser, 31 )
    get_cvar_string( "amx_sql_pass", szPass, 31 )
    get_cvar_string( "amx_sql_db",   szDatabase, 31 )

    cnMySql = mysql_connect( szHost, szUser, szPass, szDatabase, szError, 127 )
    if( cnMySql < 1 )
    {
        format( szLogMsg, STR_L-1, "%s %s::MySQL_CONNECT Error: '%s'", PLUGIN_MOD, PLUGIN_NAME, szError )
        WriteLog( szLogMsg )
        return false
    }
    return true
}

// Closes a Connection with DB
stock DisconnectDB()
{
    mysql_close( cnMySql )
    return
}

// Load BlackList Words From MySQL
stock bool:LoadBlackList()
{
    new i = 0, szError[STR_M], szLogMsg[STR_L]

    if( mysql_query( cnMySql, "Select Word From SF_BlackList" ) < 1 )
    {
        mysql_error( cnMySql, szError, STR_M-1 )
        format( szLogMsg, STR_L-1, "%s %s::MySQL_QUERY [BL] Error: '%s'", PLUGIN_MOD, PLUGIN_NAME, szError )
        WriteLog( szLogMsg )
        return false
    }

    // Load All BlackList Words into Array
    while( (mysql_nextrow( cnMySql ) > 0) && (i < BLACKLIST_WORDS) )
        mysql_getfield( cnMySql, 1, g_szBlackList[i++], MAX_WORD_LENGTH-1 )

    // Check Word Count
    if( i == 0 )
    {
        format( szLogMsg, STR_L-1, "%s %s::MySQL_QUERY [BL] Error: 'No Words Found!'", PLUGIN_MOD, PLUGIN_NAME )
        WriteLog( szLogMsg )
        return false
    }

    // BlackList Loaded Successfully
    format( szLogMsg, STR_L-1, "%s %s::%d Swear Word%s Loaded From MySQL!", PLUGIN_MOD, PLUGIN_NAME, i, (i == 1) ? "" : "s" )
    WriteLogDebug( szLogMsg )

    return true
}

// Load WhiteList Words From MySQL
stock bool:LoadWhiteList()
{
    new i = 0, szError[STR_M], szLogMsg[STR_L]

    if( mysql_query( cnMySql, "Select Word From SF_WhiteList" ) < 1 )
    {
        mysql_error( cnMySql, szError, STR_M-1 )
        format( szLogMsg, STR_L-1, "%s %s::MySQL_QUERY [WL] Error: '%s'", PLUGIN_MOD, PLUGIN_NAME, szError )
        WriteLog( szLogMsg )
        g_bLoadErrWL = true // WhiteList Cannot be Used
        return true // Non-Critical Error
    }

    // Load All WhiteList Words into Array
    while( (mysql_nextrow( cnMySql ) > 0) && (i < WHITELIST_WORDS) )
        mysql_getfield( cnMySql, 1, g_szWhiteList[i++], MAX_WORD_LENGTH-1 )

    // Check Word Count
    if( i == 0 )
    {
        format( szLogMsg, STR_L-1, "%s %s::MySQL_QUERY [WL] Error: 'No Words Found!'", PLUGIN_MOD, PLUGIN_NAME )
        WriteLog( szLogMsg )
        return false
    }

    // WhiteList Loaded Successfully
    format( szLogMsg, STR_L-1, "%s %s::%d Good Word%s Loaded From MySQL!", PLUGIN_MOD, PLUGIN_NAME, i, (i == 1) ? "" : "s" )
    WriteLogDebug( szLogMsg )

    return true
}

// Load Progressive Punishments From MySQL
stock bool:LoadPunishments()
{
    new szError[STR_M], szLogMsg[STR_L], szRank[4]

    // Get Stored Punishments by Offense Order...
    if( mysql_query( cnMySql, "Select Punish From SF_Punishment Order By Offense" ) < 1 )
    {
        mysql_error( cnMySql, szError, STR_M-1 )
        format( szLogMsg, STR_L-1, "%s %s::MySQL_QUERY [Punish] Error: '%s'", PLUGIN_MOD, PLUGIN_NAME, szError )
        WriteLog( szLogMsg )
        return false
    }

    // Load Punishment Data into Arrays
    while( (mysql_nextrow( cnMySql ) > 0) && (g_nProgPunCount < MAX_PUN_OFFENSE) )
        mysql_getfield( cnMySql, 2, g_szPunishments[g_nProgPunCount++], MAX_PUNISHMENTS )

    // Check Punishment Count
    if( g_nProgPunCount <= 1 )
    {
        format( szLogMsg, STR_L-1, "%s %s::MySQL_QUERY [Punish] Error: 'Not Enough Progressive Punishments Found!'", PLUGIN_MOD, PLUGIN_NAME )
        WriteLog( szLogMsg )
        return false
    }

    // Punishments Loaded Successfully
    format( szLogMsg, STR_L-1, "%s %s::%d Progressive Punishments%s Loaded From MySQL!", PLUGIN_MOD, PLUGIN_NAME, g_nProgPunCount, (g_nProgPunCount == 1) ? "" : "s" )
    WriteLogDebug( szLogMsg )
    return true
}


