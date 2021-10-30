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


#if defined _BASE_CONST_INCLUDED
  #endinput
#endif
#define _BASE_CONST_INCLUDED


// Plugin Information
#define PLUGIN_NAME         "RS Swear Filter"
#define PLUGIN_VERSION      "2.0"
#define PLUGIN_AUTHOR       "xeroblood"
#if defined USE_AMXX_MODE
    #define PLUGIN_MOD      "[AMXX]"
#else
    #define PLUGIN_MOD      "[AMX]"
#endif

// Swear Filter System
#define FS_FULL             0
#define FS_SLIM             1
#define FS_SIMPLE           2

// Punishment System
#define PS_NONE             0
#define PS_SINGLE           1
#define PS_PROG             2

// Rename System
#define RS_OLDNAME          0
#define RS_STEAMID          1
#define RS_CUSTOM           2

// Censor System
#define CS_NONE             0
#define CS_RANDOM           1
#define CS_CUSTOM           2

// Max Values
#define MAX_PUNISHMENTS     7
#define MAX_CENSORS         7
#define MAX_FILTERS         18
#define MAX_PLAYERS         32
#define MAX_NAME_LEN        32
#define MAX_LINE_LEN        128
#define MAX_CHAT_LEN        256
#define MAX_FILE_LEN        256

// String Sizes
#define STR_T               32
#define STR_S               64
#define STR_M               128
#define STR_L               256
#define STR_X               512

// Menu Specific Settings
#define MENU_SIZE           256
#define MENU_DISPLAY        8

// Task IDs
#define TASK_SAY_FILTER     2600
#define TASK_PLAYER_GAG     2700
#define TASK_PLAYER_SLAP    2800
#define TASK_PLAYER_FIRE    2900

// General Defines
#define NULL                (-1)
#define OFF                 0
#define ON                  1

// Punishment Bits
#define PUN_GAG             (1<<0)
#define PUN_SLAP            (1<<1)
#define PUN_FIRE            (1<<2)
#define PUN_SLAY            (1<<3)
#define PUN_CASH            (1<<4)
#define PUN_KICK            (1<<5)
#define PUN_BAN             (1<<6)

