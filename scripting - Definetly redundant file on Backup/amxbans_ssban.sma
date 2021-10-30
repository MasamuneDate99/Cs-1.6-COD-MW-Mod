#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#include "include/amxbans/color_chat.inl"

#define PLUGIN "AMXBans: Screens"
#define VERSION	"Gm 1.6"
#define AUTHOR "Larte Team"

#define PREFIX "!y[!tAMXBans!y]"

new victim
new CvarMaxss
new CvarInterval
new CvarTimestamptype
new CvarHUDText
new CvarBanTime
new CvarBanReason

new CountMenu
new CvarCountScreens
new g_max_players
new g_user_ids[33]
new g_player[33]

public plugin_init () 
{ 
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_dictionary("amxbans_ssban.txt")

	register_clcmd("amx_ssban", "cmdScreen", ADMIN_BAN, "<authid, nick or #userid> <count of screens>")
	register_clcmd("amx_ssbanmenu", "cmdScreenMenu", ADMIN_BAN, " - display screens menu")

	CvarMaxss = register_cvar("amx_maxscreens", "10")
	CvarInterval = register_cvar("amx_interval", "1.0")
	CvarTimestamptype = register_cvar("amx_stamptype", "3")
	CvarHUDText = register_cvar("amx_hudtext", "Cheese! :)")
	CvarCountScreens = register_cvar("amx_screenscount", "1 2 3 4 5 6 7 8 9")

	CvarBanTime = register_cvar("amx_ssbantime", "0")
	CvarBanReason = register_cvar("amx_ssbanreason", "Screens, go gm-community.net")

	register_cvar("amxbans_ssversion", VERSION, FCVAR_SERVER | FCVAR_SPONLY)
	g_max_players = get_maxplayers()

	color_chat_init()
	
	new configsDir[64]
	get_configsdir(configsDir, 63)
	
	return server_cmd("exec %s/amxbans-ssban.cfg", configsDir)
}

public plugin_cfg() 
{
	new line[128], token[10]
	get_pcvar_string(CvarCountScreens, line, 127)

	new stemp[128]
	formatex(stemp, 127, "%L", LANG_SERVER, "SS_MENU_COUNT_HEADER")
	
	CountMenu = menu_create(stemp, "CountScreensMenu")
	while(contain (line, " ") != -1) 
	{
		strbreak(line, token, 9, line, 127)
		formatex(stemp, 127, "%L", LANG_SERVER, "SS_MAKE_X_SCREENS", token)
		menu_additem(CountMenu, stemp, token)
	}
	
	formatex(stemp, 127, "%L", LANG_SERVER, "SS_MORE")
	menu_setprop(CountMenu, MPROP_NEXTNAME, stemp)
	
	formatex(stemp, 127, "%L", LANG_SERVER, "SS_BACK")
	menu_setprop(CountMenu, MPROP_BACKNAME, stemp)
	
	formatex(stemp, 127, "%L", LANG_SERVER, "SS_EXIT")
	menu_setprop(CountMenu, MPROP_EXITNAME, stemp)

	return set_task(5.0, "add_menu")
}

public add_menu()
{
	new stemp[128]
	formatex(stemp, 127, "%L", LANG_SERVER, "SS_MENU_NAME")
	
	AddMenuItem(stemp, "amx_ssbanmenu", ADMIN_BAN, "AMXBans: Screens")
	
	return PLUGIN_CONTINUE
}

public cmdScreenMenu(id, level, cid) 
{
	if(!cmd_access(id, level, cid, 1))
	{
		return PLUGIN_HANDLED
	}
	
	new stemp[128]
	formatex(stemp, 127, "%L", LANG_SERVER, "SS_MENU_PLAYER_HEADER")
	
	new menu = menu_create(stemp, "PlayersMenu")
	
	new i, name[32], tempid[10]
	
	for(i = 1; i <= g_max_players; i++) 
	{
		if(is_user_connected(i)) 
		{
			get_user_name(i, name, 31)
			num_to_str(i, tempid, 9)
			g_user_ids[i] = get_user_userid(i)
			menu_additem(menu, name, tempid, 0)
		}
	}
	
	formatex(stemp, 127, "%L", LANG_SERVER, "SS_MORE")
	menu_setprop(menu, MPROP_NEXTNAME, stemp)
	
	formatex(stemp, 127, "%L", LANG_SERVER, "SS_BACK")
	menu_setprop(menu, MPROP_BACKNAME, stemp)
	
	formatex(stemp, 127, "%L", LANG_SERVER, "SS_EXIT")
	menu_setprop(menu, MPROP_EXITNAME, stemp)

	return menu_display (id, menu, 0)
}

public PlayersMenu(id, menu, item) 
{
	if(item == MENU_EXIT) 
	{
		return PLUGIN_HANDLED
	}
	
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
	
	g_player[id] = str_to_num (data)
	menu_display(id, CountMenu, 0)
	
	return PLUGIN_HANDLED
}

public CountScreensMenu(id, menu, item) 
{
	if(item == MENU_EXIT) 
	{
		return PLUGIN_HANDLED
	}
	
	new data[6], iName[64]
	new access, callback
	new player = g_player[id]
	
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
	
	if(g_user_ids[player] == get_user_userid(player)) 
	{
		client_cmd(id, "amx_ssban #%d %s", g_user_ids[player], data)
	}
	
	return PLUGIN_HANDLED
}

public cmdScreen(id, level, cid) 
{ 
	if(!cmd_access(id, level, cid, 3)) 
	{
		return PLUGIN_HANDLED
	}

	new arg1[24], arg2[4]

	read_argv(1, arg1, 23)
	read_argv(2, arg2, 3)
	
	new screens = str_to_num(arg2)
	victim = cmd_target(id, arg1, 1)
	
	if(!victim) 
	{
		return PLUGIN_HANDLED
	}
	
	if(screens > get_pcvar_num(CvarMaxss)) 
	{
		console_print(id, "%L", id, "SS_COUNT_NO")
		
		return PLUGIN_HANDLED
	}
	
	new Float:interval = get_pcvar_float(CvarInterval)
	new array[2]

	array[0] = id
	array[1] = victim

	set_task(interval, "takeScreen", 0, array, 2, "a", screens)
	set_task(interval * float(screens) + 1.0, "victimBan", _, array, 2)

	return PLUGIN_HANDLED
}
 
public takeScreen(array[2]) 
{
	new victim = array[1]
	new id = array[0]
	
	new timestamp[32], HUDText[32], name[32], adminname[32]
	get_time("%d.%m.%Y - %H:%M:%S", timestamp, 31)
	get_user_name(victim, name, 31)
	get_user_name(id, adminname, 31)
	get_pcvar_string(CvarHUDText, HUDText, 31)

	switch(get_pcvar_num(CvarTimestamptype)) 
	{
		case 0: 
		{
			ColorChat(id, RED, "%s %L", PREFIX, id, "SS_CHAT_INFO", name, adminname)
			client_cmd(victim, "snapshot")
		}

		case 1: 
		{
			ColorChat(id, RED, "%s %L", PREFIX, id, "SS_CHAT_INFO2", name, adminname, timestamp)
		 	client_cmd(victim, "snapshot")
		}

		case 2: 
		{
			set_hudmessage(225, 225, 225, 0.02, 0.90, 0, 1.0, 2.0)
			show_hudmessage(victim, HUDText)
			client_cmd(victim, "snapshot")
		}

		case 3: 
		{
			set_hudmessage(225, 225, 225, 0.02, 0.90, 0, 1.0, 2.0)
			show_hudmessage(victim, HUDText)
			ColorChat(id, RED, "%s %L", PREFIX, id, "SS_CHAT_INFO2", name, adminname, timestamp)
			client_cmd(victim, "snapshot")
		}
	}

	return PLUGIN_CONTINUE
}

public victimBan(array[2])
{
	new Reason[50]

	new victimId = get_user_userid(array[1])
	get_pcvar_string(CvarBanReason, Reason, 31)

	return client_cmd(array[0], "amx_ban %d #%d %s", get_pcvar_num(CvarBanTime), victimId, Reason)
}
