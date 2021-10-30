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


#if defined _BASE_GLOBAL_INCLUDED
  #endinput
#endif
#define _BASE_GLOBAL_INCLUDED


// Boolean
new bool:g_bUserGagged[MAX_PLAYERS] = false     // Keeps Track of Gagged Players
new bool:g_bUserFlame[MAX_PLAYERS]  = false     // Keeps Track of Burning Players
new bool:g_bUserSwore[MAX_PLAYERS]  = false     // Prevents Double-Checking Chat on Offense
new bool:g_bLoadErrWL = false                   // Keeps Track of Non-Critical Whitelist Load Error
new bool:g_bLoadErrPunish = false               // Keeps Track of Non-Critical Punishments Load Error

// Integers
new g_nProgPunCount = 0                         // Stores Number of Progressive Punishments Loaded
new g_nOffenseCount[MAX_PLAYERS] = 0            // Individual Player Offense Count (Chat & Name)
new g_nShowAdmin = 0                            // Highest Currently Connected Admin ID (See Menu)
new g_nCurrClientID = 0                         // Player ID of Offender for use in Menu

// Strings
new g_szBlackList[BLACKLIST_WORDS][MAX_WORD_LENGTH]     // Array of Swear Words
new g_szWhiteList[WHITELIST_WORDS][MAX_WORD_LENGTH]     // Array of Good Words
new g_szBadWord[MAX_PLAYERS][MAX_WORD_LENGTH]           // Current Offensive Word for use in Menu
new g_szUserSpeech[MAX_PLAYERS][MAX_CHAT_LEN]           // Current Player Speech for Checking
new g_szUserCmd[MAX_PLAYERS][STR_T]                     // Current Player Command (say or say_team)
new g_szPunishments[MAX_PUN_OFFENSE][MAX_PUNISHMENTS+1] // Progressive Punishments (In Order)

// Client HL Messages
new g_nMsgDamage

// Sprites
new g_sprMFlash, g_sprSmoke, g_sprLight

// Sounds
new g_szSndScream[]  = "scientist/scream21.wav"
new g_szSndFlames[]  = "ambience/flameburst1.wav"
new g_szSndThunder[] = "ambience/thunder_clap.wav"

// Punishment Flags
new g_szPunFlags[MAX_PUNISHMENTS][] = { "a", "b", "c", "d", "e", "f", "g" }

// Punishment Titles
new g_szPunTitle[MAX_PUNISHMENTS][] = { "Gag", "Slap", "Fire", "Slay", "Cash Loss", "Kick", "Ban" }

// Filter Characters used for Chat Filtering
new g_szFilter[MAX_FILTERS][] = { "!", "@", "#", "$", "%", "&", "*", ",", ".", ":", ";", "~", "`", "'", "/", "-", "+", "_" }

// Censor Characters used for Random Censor Mode
new g_szCensors[MAX_CENSORS][] = { "!", "+", "#", "$", ".", "-", "*" }


