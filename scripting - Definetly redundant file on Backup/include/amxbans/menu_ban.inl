/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * AMX Bans - http://www.amxbans.net
 *  Include - menu_ban
 * 
 * Copyright (C) 2014  Ryan "YamiKaitou" LeBlanc
 * Copyright (C) 2009, 2010  Thomas Kurz
 * Copyright (C) 2003, 2004  Ronald Renes / Jeroen de Rover
 * 
 * 
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the
 *  Free Software Foundation; either version 2 of the License, or (at
 *  your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software Foundation,
 *  Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 *
 *  In addition, as a special exception, the author gives permission to
 *  link the code of this program with the Half-Life Game Engine ("HL
 *  Engine") and Modified Game Libraries ("MODs") developed by Valve,
 *  L.L.C ("Valve"). You must obey the GNU General Public License in all
 *  respects for all of the code used other than the HL Engine and MODs
 *  from Valve. If you modify this file, you may extend this exception
 *  to your version of the file, but you are not obligated to do so. If
 *  you do not wish to do so, delete this exception statement from your
 *  version.
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


#if defined _menu_ban_included
    #endinput
#endif
#define _menu_ban_included

#include <amxmodx>
#include <amxmisc>

public cmdBanMenu(id,level,cid) {
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	cmdBanMenu2(id)
	return PLUGIN_HANDLED
}
	
public cmdBanMenu2(id) {
	new menu = menu_create("menu_player","actionBanMenu")
	
	MenuSetProps(id,menu,"BAN_MENU")
	
	new typecallback=menu_makecallback("callback_MenuBanType")
	new szID[3]
	formatex(szID,charsmax(szID),"t%d",g_menuban_type[id])
	menu_additem(menu,"Ban and Kick",szID,0,typecallback)
	menu_addblank(menu,0)
	
	new callback=menu_makecallback("callback_MenuGetPlayers")
	MenuGetPlayers(menu,callback)
	
	menu_display(id,menu,0)
	
	return PLUGIN_HANDLED
}
public actionBanMenu(id,menu,item) {
	if(item < 0) {
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new acc,szInfo[3],szText[128],callb
	menu_item_getinfo(menu,item,acc,szInfo,charsmax(szInfo),szText,charsmax(szText),callb)
	
	if(szInfo[0]=='t') {
		g_menuban_type[id]=str_to_num(szInfo[1])
		g_menuban_type[id]++
		menu_destroy(menu)
		cmdBanMenu2(id)
		return PLUGIN_HANDLED
	}
		
	new pid=str_to_num(szInfo)
	
	if(!is_user_connected(pid)) {
		client_print(id,print_chat,"%L",id,"PLAYER_LEAVED",g_PlayerName[pid])
		//ColorChat(id, RED, "[AMXBans]^x01 %L",id,"PLAYER_LEAVED",g_PlayerName[pid])
		client_cmd(id,"amx_bandisconnectedmenu")
		return PLUGIN_HANDLED
	}
	
	copy(g_choicePlayerName[id],charsmax(g_choicePlayerName[]),g_PlayerName[pid])
	get_user_authid(pid,g_choicePlayerAuthid[id],charsmax(g_choicePlayerAuthid[]))
	get_user_ip(pid,g_choicePlayerIp[id],charsmax(g_choicePlayerIp[]),1)
	g_choicePlayerId[id]=pid
	
	if(get_pcvar_num(pcvar_debug) >= 2)
		log_amx("[AMXBans PlayerMenu %d] %d choice: %d | %s | %s | %d",menu,id,g_choicePlayerName[id],g_choicePlayerAuthid[id],g_choicePlayerIp[id],g_choicePlayerId[id])
	
	//see if the admin can choose the bantime
	if(amxbans_get_static_bantime(id)) {
		set_task(0.2,"cmdReasonMenu",id)
	} else {
		set_task(0.2,"cmdBantimeMenu",id)
	}
	
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public cmdBantimeMenu(id) {
	
	new menu = menu_create("menu_bantime","actionBantimeMenu")
	
	MenuSetProps(id,menu,"BANTIME_MENU")
	MenuGetBantime(id,menu)
	
	menu_display(id,menu,0)
	
	return PLUGIN_HANDLED
}
public actionBantimeMenu(id,menu,item) {
	if(item < 0) {
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new acc,szInfo[11],szText[128],callb
	menu_item_getinfo(menu,item,acc,szInfo,10,szText,127,callb)
	
	g_choiceTime[id]=str_to_num(szInfo)
	
	if(get_pcvar_num(pcvar_debug) >= 2)
		log_amx("[AMXBans BantimeMenu %d] %d choice: %d min",menu,id,g_choiceTime[id])
	
	set_task(0.2,"cmdReasonMenu",id)
	
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public cmdReasonMenu(id) {
	
	new menu = menu_create("menu_banreason","actionReasonMenu")
	
	MenuSetProps(id,menu,"REASON_MENU")
	MenuGetReason(id,menu,amxbans_get_static_bantime(id))
	
	menu_display(id,menu,0)
	
	return PLUGIN_HANDLED
}
public actionReasonMenu(id,menu,item) {
	if(item < 0) {
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new acc,szInfo[3],szText[128],callb
	menu_item_getinfo(menu,item,acc,szInfo,charsmax(szInfo),szText,charsmax(szText),callb)
	
	new aid=str_to_num(szInfo)
	
	if(aid == 99) {
		if(amxbans_get_static_bantime(id)) g_choiceTime[id]=get_pcvar_num(pcvar_custom_statictime)
		set_custom_reason[id]=true
		client_cmd(id,"messagemode amxbans_custombanreason")
		menu_destroy(menu)
		return PLUGIN_HANDLED
	} else {
		ArrayGetString(g_banReasons,aid,g_choiceReason[id],charsmax(g_choiceReason[]))
		if(amxbans_get_static_bantime(id)) g_choiceTime[id]=ArrayGetCell(g_banReasons_Bantime,aid)
	}
	
	if(get_pcvar_num(pcvar_debug) >= 2)
		log_amx("[AMXBans ReasonMenu %d] %d choice: %s (%d min)",menu,id,g_choiceReason[id],g_choiceTime[id])
	
	if(g_choicePlayerId[id] == -1) {
		//disconnected ban
		cmdMenuBanDisc(id)
	} else {
		cmdMenuBan(id)
	}
	
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
