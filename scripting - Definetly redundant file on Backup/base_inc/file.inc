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


#if defined _BASE_FILE_INCLUDED
  #endinput
#endif
#define _BASE_FILE_INCLUDED



// Swear Filter Files
new szFiles[3][MAX_FILE_LEN]



// Initializes Paths to Swear Filter Files
stock bool:ConnectDB()
{
    new szBase[MAX_FILE_LEN], szPath[MAX_FILE_LEN]

    #if defined USE_AMXX_MODE
        get_configsdir( szBase, MAX_FILE_LEN-1 )
        format( szPath, MAX_FILE_LEN-1, "%s/swearfilter", szBase )
    #else
        get_basedir( szBase, MAX_FILE_LEN-1 )
        format( szPath, MAX_FILE_LEN-1, "%s/config/swearfilter", szBase )
    #endif

    format( szFiles[0], MAX_FILE_LEN-1, "%s/blacklist.ini", szPath )
    format( szFiles[1], MAX_FILE_LEN-1, "%s/whitelist.ini", szPath )
    format( szFiles[2], MAX_FILE_LEN-1, "%s/punishments.ini", szPath )

    return true
}

// Does Nothing..
stock DisconnectDB()
{
    return
}

// Load BlackList Words From File
stock bool:LoadBlackList()
{
    new i = 0, l = 0, pos = 0
    new szWord[MAX_WORD_LENGTH], szLogMsg[STR_L]

    // Check for Blacklist File
    if( !file_exists( szFiles[0] ) )
    {
        format( szLogMsg, STR_L-1, "%s %s::FILE_EXISTS Error: File '%s' Does Not Exist!", PLUGIN_MOD, PLUGIN_NAME, szFiles[0] )
        WriteLog( szLogMsg )
        return false
    }

    while( read_file( szFiles[0], pos++, szWord, MAX_WORD_LENGTH-1, l ) && (i < BLACKLIST_WORDS) )
    {
        if( szWord[0] == ';' || !l ) continue
        parse( szWord, szWord, MAX_WORD_LENGTH-1 )
        copy( g_szBlackList[i++], MAX_WORD_LENGTH-1, szWord )
    }

    // Check Word Count
    if( i == 0 )
    {
        format( szLogMsg, STR_L-1, "%s %s::FILE [BL] Error: 'No Words Found!'", PLUGIN_MOD, PLUGIN_NAME )
        WriteLog( szLogMsg )
        return false
    }

    // BlackList Loaded Successfully
    format( szLogMsg, STR_L-1, "%s %s::%d Swear Word%s Loaded From File!", PLUGIN_MOD, PLUGIN_NAME, i, (i == 1) ? "" : "s" )
    WriteLogDebug( szLogMsg )

    return true
}

// Load WhiteList Words From File
stock bool:LoadWhiteList()
{
    new i = 0, l = 0, pos = 0
    new szWord[MAX_WORD_LENGTH], szLogMsg[STR_L]

    // Check for WhiteList File
    if( !file_exists( szFiles[1] ) )
    {
        format( szLogMsg, STR_L-1, "%s %s::FILE_EXISTS Error: File '%s' Does Not Exist!", PLUGIN_MOD, PLUGIN_NAME, szFiles[1] )
        WriteLog( szLogMsg )
        return false
    }

    while( read_file( szFiles[1], pos++, szWord, MAX_WORD_LENGTH-1, l ) && (i < WHITELIST_WORDS) )
    {
        if( szWord[0] == ';' || !l ) continue
        parse( szWord, szWord, MAX_WORD_LENGTH-1 )
        copy( g_szWhiteList[i++], MAX_WORD_LENGTH-1, szWord )
    }

    // Check Word Count
    if( i == 0 )
    {
        format( szLogMsg, STR_L-1, "%s %s::FILE [WL] Error: 'No Words Found!'", PLUGIN_MOD, PLUGIN_NAME )
        WriteLog( szLogMsg )
        return false
    }

    // WhiteList Loaded Successfully
    format( szLogMsg, STR_L-1, "%s %s::%d Good Word%s Loaded From File!", PLUGIN_MOD, PLUGIN_NAME, i, (i == 1) ? "" : "s" )
    WriteLogDebug( szLogMsg )

    return true
}

// Load Progressive Punishments From File
stock bool:LoadPunishments()
{
    new l = 0, pos = 0, nIdx = 0
    new szLine[MAX_LINE_LEN], szLogMsg[STR_L], szTemp[2][MAX_PUNISHMENTS+1]

    // Check for Punishments File
    if( !file_exists( szFiles[2] ) )
    {
        format( szLogMsg, STR_L-1, "%s %s::FILE_EXISTS Error: File '%s' Does Not Exist!", PLUGIN_MOD, PLUGIN_NAME, szFiles[2] )
        WriteLog( szLogMsg )
        return false
    }

    while( read_file( szFiles[2], pos++, szLine, MAX_LINE_LEN-1, l ) && (g_nProgPunCount < MAX_PUN_OFFENSE) )
    {
        if( szLine[0] == ';' || !l ) continue
        parse( szLine, szTemp[0], MAX_PUNISHMENTS, szTemp[1], MAX_PUNISHMENTS )
        nIdx = clamp( str_to_num( szTemp[0] ), 1, MAX_PUN_OFFENSE )
        copy( g_szPunishments[nIdx-1], MAX_PUNISHMENTS, szTemp[1] )
        g_nProgPunCount++
    }

    // Check Punishments Count
    if( g_nProgPunCount <= 1 )
    {
        format( szLogMsg, STR_L-1, "%s %s::FILE [Punish] Error: 'Not Enough Progressive Punishments Found!'", PLUGIN_MOD, PLUGIN_NAME )
        WriteLog( szLogMsg )
        return false
    }

    // Punishments Loaded Successfully
    format( szLogMsg, STR_L-1, "%s %s::%d Progressive Punishments%s Loaded From File!", PLUGIN_MOD, PLUGIN_NAME, g_nProgPunCount, (g_nProgPunCount == 1) ? "" : "s" )
    WriteLogDebug( szLogMsg )
    return true
}
