/***************************************************************************************************
* Copyleft (c)2010 Teascu Dorin & Fysiks
* Plugin Support:
* 	- http://forums.alliedmods.net/showthread.php?t=90318
*	or
*	- http://fightersclan.com/forum/f7/amx-ssban-v2-6-%5Bupdate-15-oct-2010%5D-35/
****************************************************************************************************
*  This program is free software; you can redistribute it and/or modify it under the terms
*  of the GNU General Public License as published by the Free Software Foundation; either
*  version 2 of the License, or (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
*  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*  See the GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License along with this program;
*  if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
*  MA 02111-1307 USA
*
*  In addition, as a special exception, the author gives permission to link the code of this
*  program with the Half-Life Game Engine ("HL Engine") and Modified Game Libraries ("MODs")
*  developed by Valve, L.L.C ("Valve"). You must obey the GNU General Public License in all
*  respects for all of the code used other than the HL Engine and MODs from Valve.
*  If you modify this file, you may extend this exception to your version of the file,
*  but you are not obligated to do so. If you do not wish to do so, delete this exception
*  statement from your version.
****************************************************************************************************
* Amx SSBan
* =========
****************************************************************************************************
* Description
* -----------
* - Take snapshots and ban a player (saved on targets PC) or just take snapshots
****************************************************************************************************
* Available CVAR's
* ----------------
* amx_ssdelay "1.0"	- Delay between snapshots (Def.: "1.0") WARNING has to be .0 as is float
* amx_bandelay "10.0" 	- Delay before ban is done (Def.: "10.0") WARNING has to be .0 as is float
* amx_ssnumber "3" 	- Number of snapshots to take (Def.: "3")
* amx_website "" 	- Unban request site (Def.: "www.yoursite.com")
* amx_msg_type "3" 	- Info player/admin messages 1 - chat | 2- hud | 3- chat+hud (Def.: "3")
****************************************************************************************************
* Admin Commands
* --------------
* amx_ss <name or #userid> - Make Snapshots on target !
* amx_ssban <name or #userid> <minutes> [reason] - Ban with snapshots (AMXMODX) !
* 		If #define AMXBANS is setted to 1 the following console command will be used:
* amx_ssban <minutes> <name or #userid> [reason] - Ban with snapshots (AMXBANS) !
* amx_ssmenu - Displays Snapshot Menu
* amx_ssbanmenu - Displays ban menu
****************************************************************************************************
* Credits
* -------
* Fysiks - ADDED BAN, SS & SSBan MENU and support for AmxBans v6.x - !!! Thank you !!!
* Alka - stock color chat print
* hackandmore - used his plugin to learn how to use amx_msg_type cvar
* AMXX Dev Team for using their amxmodx ban script
* uTg | bigpapajiggs using his plugin (Admin Screen 2) to learn how to use delay and tasks
* Any other plugins authors that made this type of plugin
****************************************************************************************************
* Changelog
* ---------
* 
* 	10.Jul.2010 - v2.6 - [ADDED] support for AmxBans v6.x (by Fysiks)
* 			[FIXED] lang file by saving it as Unicode without BOM
* 	20.Aug.2009 - v2.5 - [ADDED] HUD flashing message to ask reason submission from admin
* 	17.Aug.2009 - v2.4 - [FIXED] Amx Mod X banning issue
* 	31.Jul.2009 - v2.3 - [ADDED] reason submission for menu bans
* 	26.Jul.2009 - v2.2 - [ADDED] menu for taking snapshots - by Fysiks
* 			[CHANGED] the plugin name from AMXX SSBan w/ Menu in simple AMX SSBan
* 	24.Jul.2009 - v2.1 - [REMOVED] amx_ban_type cvar
* 			[CHANGED] the script for easy usage of bantype (optimized by Fysiks)
* 	23.Jul.2009 - v2.0 - [ADDED] ban menu - Al the work provided by Fysiks
* 	11.May.2009 - v1.9.5 - [ADDED] tasks controlled by cvar for bans
*			[ADDED] cvar amx_bandelay - Delay before ban is done (Def.: 10.0)
*	07.May.2009 - v1.9.1 - [FIXED] the usage of command on immunity admins.
* 					You can take snapshots of admins with immunity
* 	06.May.2009 - v1.9 - [ADDED] to AMXX Snapshot a task to take the snapshots with time delay
*			[ADDED] cvar amx_ssdelay - Delay between snapshots (Def.: 1)
*			[ADDED] cvar amx_ssnumber - Number of snapshots to take (Def.: 3)
*			[ADDED] possibility of taking snapshots on immunity admins
* 	06.May.2009 - v1.8.1 beta - [REMOVED] NO ACCESS console message as Fysiks said that
* 					'if(!cmd_access...' already does this
* 	06.May.2009 - v1.8 beta - [CLEANED] up the plugin (some script arranging)
*			[REMOVED] amx_chattag - it was irelevant... left [AMXX] by default as tag
*			[ADDED] bans by AMXMODX - THX AMXX Dev Team for ban code
*			[ADDED] cvar amx_ban_type - 0- Disabled | 1- AmxModX Ban | 2- AmaBans Ban
*			[ADDED] possibility of taking snapshots and banning admins with immunity
*			(not working for AMXBANS as is used by server_cmd)
*			[ADDED] the console print to inform a player/admin about no acces for command
*	03.May.2009 - v1.7 beta - [ADDED] command amx_ssban to use bans by AMXBANS
* 	28.Apr.2009 - v1.6 - [CHANGED] from 'if(get_pcvar_num...' to switch Message type with case
*	18.Apr.2009 - v1.5 - [ADDED] cvar amx_msg_type - 1 - chat | 2- hud | 3- chat+hud (Def: "1")
*			[ADDED] hud message for player data (controled by cvar)
*			[ADDED] Polish translation
*	17.Apr.2009 - v1.4 - [ADDED] to cache SteamID also in the snapshots - THX xPaw
* 	17.Apr.2009 - v1.3 - [CHANGED] cvar to pcvar - THX xPaw for pointing that out !
* 	17.Apr.2009 - v1.2 - [ADDED] cvar amx_chattag - Make any tag you like in chat
* 	16.Apr.2009 - v1.1 - [ADDED] Multilingual
* 	15.Apr.2009 - v1.0:- Initial release
***************************************************************************************************/

// Includes
#include <amxmodx>
#include <amxmisc>
#include <geoip>

// Defines
#define VERSION "2.6"


//********** EDIT HERE if you use AMXBANS ***********//
#define AMXBANS 1 // Set this to 1 to enable AmxBans support. (Uses amx_ban <minutes> <userid> [reason])
//***************************************************//


#define MAX_PLAYERS 33 // Maximum number of players (plus 1)

new g_Activity, g_Hostname, g_DelaySS, g_DelayBan, g_SnapShot, g_UnbanURL, g_MsgType, g_SayText
new g_szBanTime[MAX_PLAYERS][8], g_szBanReason[MAX_PLAYERS][32]
new Array:g_bantimes

new g_menuPosition[MAX_PLAYERS]
new g_menuPlayers[MAX_PLAYERS][32]
new g_menuPlayersNum[MAX_PLAYERS]
new g_menuOption[MAX_PLAYERS]
new g_menuSettings[MAX_PLAYERS]

public plugin_init()
{
	/* Register plugin name and author */
	register_plugin("AMX SSBan", VERSION, "God@Dorin\Fysiks");

	/* Register plugin version */
	register_cvar("screen_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY);

	/* Register language file */
	register_dictionary("screen_message.txt")	// Language file for snapshot messages
	register_dictionary("admincmd.txt")		// Language file for amxmodx bans

	/* Register cvars */
	g_Activity = get_cvar_pointer("amx_show_activity")
	g_Hostname = get_cvar_pointer("hostname")
	g_DelaySS = register_cvar("amx_ssdelay", "1.0")			// Delay between snapshots (Def.: 1.0)
	g_DelayBan = register_cvar("amx_bandelay", "1.0")		// Delay before ban is done (Def.: 10.0)
	g_SnapShot = register_cvar("amx_ssnumber", "1")			// Number of snapshots to take (Def.: 3)
	g_UnbanURL = register_cvar("amx_website", "cszone.rajagame.com")	// Unban request site (Def.: "www.yoursite.com")
	g_MsgType = register_cvar("amx_msg_type", "3")			// 1- chat | 2- hud | 3- chat+hud (Def.: 3)

	/* Register console admin commands */
	register_concmd("amx_ss", "cmdSS",ADMIN_KICK, "<name or #userid> - Make snapshots on user !")
#if AMXBANS
	if( get_cvar_num("amxbans_use_newbancmd") )
		register_concmd("amx_ssban", "cmdBanSS", ADMIN_BAN, "<name or #userid> <minutes> [reason] -  - Ban with snapshots! (AmxBans)")
	else
		register_concmd("amx_ssban", "cmdBanSS", ADMIN_BAN, "<minutes> <name or #userid> [reason] - Ban with snapshots! (AmxBans)")
#else
	register_concmd("amx_ssban", "cmdBanSS", ADMIN_BAN, "<name or #userid> <minutes> [reason] - Ban with snapshots! (AMX Mod X)")
#endif
	register_clcmd("_BanReason", "cmdBanReason")

	g_SayText = get_user_msgid("SayText")

	/* Register the menu for banning */
	register_clcmd("amx_ssmenu", "cmdSSMenu", ADMIN_KICK, " - Displays ScreenShot Menu")
	register_clcmd("amx_ssbanmenu", "cmdBanMenu", ADMIN_BAN, " - Displays ScreenShot Ban Menu")
	register_menucmd(register_menuid("SS Menu"), 1023, "actionMenu")

	/* Set bantimes for the menu */
	g_bantimes = ArrayCreate()

	ArrayPushCell(g_bantimes, 0)
	ArrayPushCell(g_bantimes, 5)
	ArrayPushCell(g_bantimes, 10)
	ArrayPushCell(g_bantimes, 30)
	ArrayPushCell(g_bantimes, 60)
	ArrayPushCell(g_bantimes, 240)
	ArrayPushCell(g_bantimes, 1440)

	register_srvcmd("amx_ssbantimes", "ssbanmenu_setbantimes")
}

public cmdSS(id,level,cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	new target[32]
	read_argv(1, target, 31)
	new player = cmd_target(id, target, CMDTARGET_OBEY_IMMUNITY)

	if(!player)
		return PLUGIN_HANDLED

	new name[32], name2[32]
	get_user_name(id, name, 31)
	get_user_name(player, name2, 31)
	/* show message in chat to all players by amx_show_activity */
	switch( get_pcvar_num(g_Activity) )
	{
		case 2: client_printc(0,"%L", LANG_PLAYER, "SS_CASE2", name, name2)
		case 1: client_printc(0,"%L", LANG_PLAYER, "SS_CASE1", name2)
	}

	new Param[2]
	Param[0] = id
	Param[1] = player
	/* Set the task to take snapshots */
	set_task(Float:get_pcvar_float(g_DelaySS), "SS_Task", 0, Param,2, "a", get_pcvar_num(g_SnapShot))
	return PLUGIN_HANDLED

}

public cmdBanSS(id,level,cid)
{
	if(!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED

	new target[32]

#if AMXBANS
	if( get_cvar_num("amxbans_use_newbancmd") )
	{
		read_argv(1, target, 31)
		read_argv(2, g_szBanTime[id], 7)
	}
	else
	{
		read_argv(1, g_szBanTime[id], 7)
		read_argv(2, target, 31)
	}
#else
	read_argv(1, target, 31)
	read_argv(2, g_szBanTime[id], 7)
#endif
	read_argv(3, g_szBanReason[id], 63)

	new player = cmd_target(id, target, CMDTARGET_OBEY_IMMUNITY)

	if(!player)
		return PLUGIN_HANDLED

	new Param[2]
	Param[0] = id
	Param[1] = player

	/* Set tasks to take snapshots and ban target */
	set_task(Float:get_pcvar_float(g_DelaySS), "SS_Task", 0, Param,2, "a", get_pcvar_num(g_SnapShot))
	set_task(Float:get_pcvar_float(g_DelayBan), "BanSS_Task", 0, Param, 2)

	return PLUGIN_HANDLED
}

public SS_Task(Param[2])
{
	new player = Param[1]
	new id = Param[0]
	new name[32], timer[32], hostname[64], name2[32], ip[32], authid2[32], country[33], site[64]

	get_user_name(id, name, 31)
	get_user_name(player, name2, 31)
	get_user_authid(player, authid2, 31)
	get_user_ip(player, ip, 31, 1)

	geoip_country(ip, country)
	get_time("%d/%m/%Y - %H:%M:%S", timer, 63)
	get_pcvar_string(g_Hostname, hostname, charsmax(hostname))
	get_pcvar_string(g_UnbanURL, site, charsmax(site))

	switch( get_pcvar_num(g_MsgType) )
	{
		case 1:
		{
			/* Show screen messages in chat */
			client_printc(player,"%L", player, "SS_MSG1", name)
			client_printc(player,"%L", player, "SS_MSG2", timer, hostname)
			client_printc(player,"%L", player, "SS_MSG3", name2, ip, authid2, country)
			client_printc(player,"%L", player, "SS_MSG4", site)
		}
		case 2:
		{
			/* Show screen messages in hud */
			set_hudmessage(150, 0, 255, -1.0, 0.1, 0, 0.25, 1.0, 0.0, 0.0, 4)
			show_hudmessage(player, "%L", player, "SS_MSG_HUD", timer, hostname, name2, ip, authid2, country, site)
		}
		case 3:
		{
			/* Show screen messages in chat */
			client_printc(player,"%L", player, "SS_MSG1", name)
			client_printc(player,"%L", player, "SS_MSG2", timer, hostname)
			client_printc(player,"%L", player, "SS_MSG3", name2, ip, authid2, country)
			client_printc(player,"%L", player, "SS_MSG4", site)

			/* Show screen messages in hud */
			set_hudmessage(150, 0, 255, -1.0, 0.1, 0, 0.25, 1.0, 0.0, 0.0, 4)
			show_hudmessage(player, "%L", player, "SS_MSG_HUD", timer, hostname, name2, ip, authid2, country, site)
		}
	}
	/* Take the snapshots ! */
	client_cmd(player,"snapshot")
	/* Confirm for the admin in console that the command was commited */
	console_print(id,"%L", id, "SS_CONSOLE", name2)

	return PLUGIN_HANDLED
}

public BanSS_Task(Param[])
{
	new id = Param[0]
	new player = Param[1]
	new minutes[8], reason[32]
	new userid2 = get_user_userid(player)

	copy(minutes, 7, g_szBanTime[id])
	copy(reason, 31, g_szBanReason[id])

#if AMXBANS // Ban "player" using AmxBans
	if( get_cvar_num("amxbans_use_newbancmd") )
		client_cmd(id, "amx_ban #%d %s ^"%s^"", userid2, minutes, reason)
	else
		client_cmd(id, "amx_ban %s #%d ^"%s^"", minutes, userid2, reason)
#else
	// Ban "player" using HL Ban Method

	new authid[32], name2[32], authid2[32], name[32]

	get_user_authid(player, authid2, 31)
	get_user_authid(id, authid, 31)
	get_user_name(player, name2, 31)
	get_user_name(id, name, 31)

	log_amx("Ban: ^"%s<%d><%s><>^" ban and kick ^"%s<%d><%s><>^" (minutes ^"%s^") (reason ^"%s^")", name, get_user_userid(id), authid, name2, userid2, authid2, minutes, reason)

	new temp[64], banned[16], nNum = str_to_num(minutes)
	if(nNum)
	{
		formatex(temp, 63, "%L", player, "FOR_MIN", minutes)
	}
	else
	{
		formatex(temp, 63, "%L", player, "PERM")
	}

	formatex(banned, 15, "%L", player, "BANNED")

	if (reason[0])
		server_cmd("kick #%d ^"%s (%s %s)^"", userid2, reason, banned, temp)
	else
		server_cmd("kick #%d ^"%s %s^"", userid2, banned, temp)
 
	server_cmd("banid %s %s", minutes, authid2)
	server_cmd("writeid")

	// Display the message to all clients
	new msg[256]
	new len
	new maxpl = get_maxplayers()
	for(new i = 1; i <= maxpl; i++)
	{
		if(is_user_connected(i) && !is_user_bot(i))
		{
			len = formatex(msg, charsmax(msg), "%L", i, "BAN")
			len += formatex(msg[len], charsmax(msg) - len, " %s ", name2)
			if(nNum)
			{
				len += formatex(msg[len], charsmax(msg) - len, "%L", i, "FOR_MIN", minutes)
			}
			else
			{
				len += formatex(msg[len], charsmax(msg) - len, "%L", i, "PERM")
			}
			if(strlen(reason) > 0)
			{
				formatex(msg[len], charsmax(msg) - len, " (%L: %s)", i, "REASON", reason)
			}
			show_activity_id(i, id, name, msg)
		}
	}
	console_print(id, "[AMXX] %L", id, "CLIENT_BANNED", name2)
#endif
	return PLUGIN_HANDLED
}

public cmdBanMenu(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	g_menuOption[id] = 0

	if (ArraySize(g_bantimes) > 0)
	{
		g_menuSettings[id] = ArrayGetCell(g_bantimes, g_menuOption[id])
	}
	else
	{
		// should never happen, but failsafe
		g_menuSettings[id] = 0
	}
	displayMenu(id, g_menuPosition[id] = 0)

	return PLUGIN_HANDLED
}

public cmdSSMenu(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	g_menuOption[id] = 0

	g_menuSettings[id] = -1
	displayMenu(id, g_menuPosition[id] = 0)

	return PLUGIN_HANDLED
}

displayMenu(id, pos)
{
	if (pos < 0)
		return

	get_players(g_menuPlayers[id], g_menuPlayersNum[id])

	new menuBody[512]
	new b = 0
	new i
	new name[32]
	new start = pos * 7, len

	if (start >= g_menuPlayersNum[id])
		start = pos = g_menuPosition[id] = 0

	len = format(menuBody, 511, "\y%L\R%d/%d^n\w^n", id, g_menuSettings[id] == -1 ? "SS_MENU" : "SSBAN_MENU", pos + 1, (g_menuPlayersNum[id] / 7 + ((g_menuPlayersNum[id] % 7) ? 1 : 0)))

	new end = start + 7
	new keys = MENU_KEY_0

	if (end > g_menuPlayersNum[id])
		end = g_menuPlayersNum[id]

	for (new a = start; a < end; ++a)
	{
		i = g_menuPlayers[id][a]
		get_user_name(i, name, 31)

		if (is_user_bot(i) || (access(i, ADMIN_IMMUNITY) && i != id))
		{
			++b

			len += format(menuBody[len], 511-len, "\d%d. %s^n\w", b, name)
		} else {
			keys |= (1<<b)

			if (is_user_admin(i))
				len += format(menuBody[len], 511-len, "%d. %s \r*^n\w", ++b, name)
			else
				len += format(menuBody[len], 511-len, "%d. %s^n", ++b, name)
		}
	}

	if(g_menuSettings[id] != -1)
	{
		if (g_menuSettings[id])
			len += format(menuBody[len], 511-len, "^n8. %L^n", id, "BAN_FOR_MIN", g_menuSettings[id])
		else
			len += format(menuBody[len], 511-len, "^n8. %L^n", id, "BAN_PERM")
		keys |= MENU_KEY_8
	}

	if (end != g_menuPlayersNum[id])
	{
		format(menuBody[len], 511-len, "^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
		keys |= MENU_KEY_9
	}
	else
		format(menuBody[len], 511-len, "^n0. %L", id, pos ? "BACK" : "EXIT")

	show_menu(id, keys, menuBody, -1, "SS Menu")
}

public actionMenu(id, key)
{
	switch (key)
	{
		case 7:
		{
			++g_menuOption[id]
			g_menuOption[id] %= ArraySize(g_bantimes)

			g_menuSettings[id] = ArrayGetCell(g_bantimes, g_menuOption[id])

			displayMenu(id, g_menuPosition[id])
		}
		case 8: displayMenu(id, ++g_menuPosition[id])
		case 9: displayMenu(id, --g_menuPosition[id])
		default:
		{
			new player = g_menuPlayers[id][g_menuPosition[id] * 7 + key]

			new minutes[8]
			num_to_str(g_menuSettings[id], minutes, 7)

			copy(g_szBanTime[id], 7, minutes)
			copy(g_szBanReason[id], 31, "_BanReason")

			new Param[2]
			Param[0] = id
			Param[1] = player

			set_task(Float:get_pcvar_float(g_DelaySS), "SS_Task", 0, Param,2, "a", get_pcvar_num(g_SnapShot))
			if(g_menuSettings[id] != -1)
			{
				messagemode_reason(id)
				set_task(Float:get_pcvar_float(g_DelayBan), "BanSS_Task", 0, Param, 2)
			}

			// displayMenu(id, g_menuPosition[id]) // Uncomment this line to make menu remain open after banning
		}
	}

	return PLUGIN_HANDLED
}

messagemode_reason(id)
{
	formatex(g_szBanReason[id], charsmax(g_szBanReason[]), "%L", id, "NO_REASON_MENU")
	
	new name[32]
	get_user_name(id, name, 31)
	
	set_hudmessage(255, 0, 0, 0.0, 0.24, 1, 6.0, 12.0)
	show_hudmessage(id, "%L", id, "REASON_HUDASK", name)
	
	client_cmd(id, "messagemode _BanReason")
}

public cmdBanReason(id)
{
	// Client has submitted reason.
	new szArg[sizeof(g_szBanReason[])]
	read_args(szArg, charsmax(szArg))
	remove_quotes(szArg)

	if(szArg[0])
	{
		formatex(g_szBanReason[id], charsmax(g_szBanReason[]), szArg)
	}
	return PLUGIN_HANDLED
}

public ssbanmenu_setbantimes()
{
	new buff[32]
	new args = read_argc()

	if (args <= 1)
	{
		server_print("usage: amx_ssbantimes <time1> [time2] [time3] ...")
		server_print("   use time of 0 for permanent.")

		return
	}

	ArrayClear(g_bantimes)

	for (new i = 1; i < args; i++)
	{
		read_argv(i, buff, charsmax(buff))

		ArrayPushCell(g_bantimes, str_to_num(buff))

	}

}

/* Stock colors for chat messages */
stock client_printc(const id, const string[], {Float, Sql, Resul,_}:...) {

	new msg[191], players[32], count = 1
	vformat(msg, sizeof msg - 1, string, 3)

	replace_all(msg,190,"!g","^4")
	replace_all(msg,190,"!y","^1")
	replace_all(msg,190,"!t","^3")

	if(id)
		players[0] = id
	else
		get_players(players,count,"ch")

	for (new i = 0 ; i < count ; i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_SayText,_, players[i])
			write_byte(players[i])
			write_string(msg)
			message_end()
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1048\\ f0\\ fs16 \n\\ par }
*/
