/*
********************************************************************************
*  AMX Mod X script.
*
*   Hobo AFK Manager (hobo_AFK_manager.sma)
*   Copyright (C) 2008-2009 hoboman
*
*   This program is free software; you can redistribute it and/or
*   modify it under the terms of the GNU General Public License
*   as published by the Free Software Foundation; either version 2
*   of the License, or (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   when you downloaded AMX Mod X; if not, write to the Free Software
*   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*
*   In addition, as a special exception, the author gives permission to
*   link the code of this program with the Half-Life Game Engine ("HL
*   Engine") and Modified Game Libraries ("MODs") developed by Valve,
*   L.L.C ("Valve"). You must obey the GNU General Public License in all
*   respects for all of the code used other than the HL Engine and MODs
*   from Valve. If you modify this file, you may extend this exception
*   to your version of the file, but you are not obligated to do so. If
*   you do not wish to do so, delete this exception statement from your
*   version.
*
*********************************************************************************
*/

/*
* For a full plugin description read: http://forums.alliedmods.net/showthread.php?t=69622
*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN	"Hobo AFK Manager"
#define AUTHOR	"hoboman313"
#define VERSION	"1.2a"

#define MAX_PLAYERS 32
//Admins with this flag cannot be kicked
#define AFK_IMMUNITY ADMIN_IMMUNITY
#define AFK_MOVE_DIST 15

#define OFFSET_TEAM 114
#define OFFSET_INTERNALMODEL 126

#define PUNISH_UNASSIGNED 0
#define PUNISH_SPECTATOR 1
#define PUNISH_AFK_SPECTATOR 2
#define PUNISH_AFK_KICK 3
#define PUNISH_NOMODEL 4


enum CsInternalModel
{
    CS_DONTCHANGE = 0,
    CS_CT_URBAN = 1,
    CS_T_TERROR = 2,
    CS_T_LEET = 3,
    CS_T_ARCTIC = 4,
    CS_CT_GSG9 = 5,
    CS_CT_GIGN = 6,
    CS_CT_SAS = 7,
    CS_T_GUERILLA = 8,
    CS_CT_VIP = 9,
    CZ_T_MILITIA = 10,
    CZ_CT_SPETSNAZ = 11
}

enum CsTeams 
{
    CS_TEAM_UNASSIGNED = 0,
    CS_TEAM_T = 1,
    CS_TEAM_CT = 2,
    CS_TEAM_SPECTATOR = 3
}

new g_oldangles[MAX_PLAYERS+1][3], g_afktime[MAX_PLAYERS+1], saved_freq, bool:freezetimeOver
new bool:player_spawned[MAX_PLAYERS+1],  msgSync, maxplayers, bool:selectedNoModel[MAX_PLAYERS+1]
//cvars
new maxAfkTime, aImmunity, kick, kickPlayers, unassignedTime, warning_time, check_frequency
	
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	check_frequency= register_cvar("hobo_afk_frequency", "1.0")
	maxAfkTime = register_cvar("hobo_afk_time", "60")
	aImmunity = register_cvar("hobo_afk_immunity", "1")
	kick = register_cvar("hobo_afk_kick", "1")
	kickPlayers = register_cvar("hobo_afk_spectator_kick", "32")
	unassignedTime = register_cvar("hobo_afk_unassigned_time", "60")
	warning_time = register_cvar("hobo_afk_warning_time", "10" )
 
	msgSync = CreateHudSyncObj()
	maxplayers = get_maxplayers()
	
	register_logevent("round_start_event", 2, "1=Round_Start")

	RegisterHam(Ham_Spawn, "player", "player_spawn", 1)
	
	if( get_cvar_num("mp_freezetime") > 0 )
		register_event("HLTV", "event_new_round", "a", "1=0", "2=0") 
	
	saved_freq=get_pcvar_num(check_frequency)
	set_task(get_pcvar_float(check_frequency), "checkPlayers", 31337, _, _, "b")
}


public player_spawn(id)
{
	if( is_user_alive(id) && !is_user_bot(id) ) 
	{
		new arrId[1]
		arrId[0]=id
		//player isn't considered spawned until he drops to the ground
		set_task( 0.5, "playerSpawned", id, arrId, 1  )
	}
}


public event_new_round()
	freezetimeOver=false


public round_start_event()
{
	for( new i = 1; i <= maxplayers; i++ )
	{
		player_spawned[i] = false
		
		if( is_user_connected(i) && ( fm_get_user_team(i) == CS_TEAM_CT || fm_get_user_team(i) == CS_TEAM_T ) && !is_user_alive(i) && checkImmunity(i) )
		{
			if( selectedNoModel[i] == true )
				punish_player( i, PUNISH_NOMODEL )
				
			selectedNoModel[i]=true
		}
		else
			selectedNoModel[i]=false
	}
	
	if( saved_freq != get_pcvar_num(check_frequency) )
	{
		change_task( 31337, get_pcvar_float(check_frequency) ) 
		saved_freq = get_pcvar_num(check_frequency)	
	}
	
	freezetimeOver=true
}


public checkPlayers() 
{
	static newangle[3]
	
	if(freezetimeOver)
	{
		for ( new i = 1; i <= maxplayers; i++ ) 
		{
			if ( is_user_alive(i) && player_spawned[i] )
			{
				get_user_origin( i, newangle )

				if ( abs(newangle[0]-g_oldangles[i][0]) < AFK_MOVE_DIST && abs(newangle[1]-g_oldangles[i][1]) < AFK_MOVE_DIST && abs(newangle[2]-g_oldangles[i][2]) < AFK_MOVE_DIST ) 
				{
					g_afktime[i] += get_pcvar_num(check_frequency)
					
					check_afktime(i)
				} 
				else 
				{
					g_oldangles[i][0] = newangle[0]
					g_oldangles[i][1] = newangle[1]
					g_oldangles[i][2] = newangle[2]
					g_afktime[i] = 0
				}
			}
		}
	}
}


public check_afktime(id) 
{
	new afkTimeTmp = get_pcvar_num( maxAfkTime ), afkTimeLeft, kickOrSpect
	
	static punishName[17]
	
	afkTimeLeft = afkTimeTmp - g_afktime[id]
	
	if ( afkTimeLeft <= get_pcvar_num(warning_time) ) 
	{	
		if( ( get_pcvar_num(kick) || get_playersnum() > get_pcvar_num(kickPlayers) ) && checkImmunity(id) )
		{
			kickOrSpect=1
			punishName="kicked"
		}
		else
		{
			kickOrSpect=0
			punishName="put to Spectator"
		}
		
		if(afkTimeLeft>0)
		{
			set_hudmessage(0, 100, 200, -1.0, 0.25, 1, 0.1, 3.0, 0.05, 0.05, -1)
			ShowSyncHudMsg( id, msgSync, "You have %d seconds to move or you will be %s for being AFK", afkTimeLeft, punishName )
		}
	} 
	
	if( g_afktime[id] >= afkTimeTmp ) 
	{
		if( kickOrSpect==1 )
			punish_player(id, PUNISH_AFK_KICK )	
		else
			punish_player(id, PUNISH_AFK_SPECTATOR )
		
		g_afktime[id]=0
	}
}


public client_disconnect(id)
{	
	g_afktime[id] = 0
	selectedNoModel[id]= false	
}


//a player connected so we must find and kick a spectator if there are any
public client_putinserver(id) 
{
	if( is_user_bot(id) || is_user_hltv(id) )
		return
	
	if( checkImmunity(id) )
	{
		new arrId[1]
		arrId[0] = id
		set_task( get_pcvar_float( unassignedTime ), "check_unassigned", id+40, arrId, 1 )
	}
	
	if( get_playersnum() > get_pcvar_num(kickPlayers) )
	{
		for( new i=1; i<=maxplayers; i++ )
		{
			if( is_user_connected(i) && fm_get_user_team(i) == CS_TEAM_SPECTATOR && checkImmunity(i) )
			{
				punish_player( i, PUNISH_SPECTATOR )
				break
			}
		}
	}
}


public check_unassigned( arrId[] )
{
	new id=arrId[0]
	
	//if the player is unassigned after x seconds then kick him
	if( is_user_connected(id) && fm_get_user_team( id ) == CS_TEAM_UNASSIGNED )
		punish_player( id, PUNISH_UNASSIGNED )
}


public playerSpawned(arrId[]) 
{
	new id=arrId[0]
	get_user_origin( id, g_oldangles[id] )
	player_spawned[id] = true
}


stock punish_player( id, punishType )
{
	static name[32]
	get_user_name(id, name, 31)
	
	switch(punishType)
	{
		case PUNISH_UNASSIGNED: 
		{
			client_print( 0, print_chat, "%s was kicked for being unnassigned longer than %d seconds", name, get_pcvar_num(unassignedTime) )
			server_cmd("kick #%d ^"You were kicked for being unassigned for more than %d seconds^"", get_user_userid(id ), get_pcvar_num(unassignedTime) )	
		}
		case PUNISH_SPECTATOR: 
		{
			client_print( 0, print_chat, "%s was kicked for spectating on a server with more than %d players", name, get_pcvar_num(kickPlayers) )
			server_cmd( "kick #%d ^"The server is getting too full to allow spectators^"", get_user_userid(id) )
		}
		case PUNISH_AFK_KICK:
		{
			client_print(0, print_chat, "%s was kicked for being AFK longer than %d seconds", name, get_pcvar_num(maxAfkTime) )
			server_cmd("kick #%d ^"You were kicked for being AFK longer than %d seconds^"", get_user_userid(id), get_pcvar_num(maxAfkTime) )
		}
		case PUNISH_AFK_SPECTATOR:
		{
			client_print(0, print_chat, "%s was put to Spectator for being AFK longer than %d seconds", name, get_pcvar_num(maxAfkTime) )
			user_silentkill(id)
			fm_set_user_team( id, CS_TEAM_SPECTATOR )
		}
		case PUNISH_NOMODEL:
		{
			client_print(0, print_chat, "%s was kicked for joining a team and idling without choosing a model.", name )
			server_cmd("kick #%d ^"You were kicked for joining a team and idling without choosing a model.^"", get_user_userid(id) )
		}
	}
}


public checkImmunity(id)
{
	//if immunity is disabled
	if( get_pcvar_num(aImmunity)==0 )
		return true
	//admin has AFK_IMMUNITY flag
	else if( get_user_flags(id) & AFK_IMMUNITY )
		return false
	
	return true	
}


stock fm_set_user_team(id, CsTeams:team)
{
    set_pdata_int(id, OFFSET_TEAM, _:team)

    dllfunc(DLLFunc_ClientUserInfoChanged, id)

    static teaminfo[12], iMsgid_TeamInfo
    switch(team)
    {
        case CS_TEAM_UNASSIGNED: 
			teaminfo="UNASSIGNED"
        case CS_TEAM_T: 
			teaminfo="TERRORIST"
        case CS_TEAM_CT: 
			teaminfo="CT"
        case CS_TEAM_SPECTATOR: 
			teaminfo="SPECTATOR"
    }

    if(!iMsgid_TeamInfo)
        iMsgid_TeamInfo = get_user_msgid("TeamInfo")
	
    message_begin(MSG_ALL, iMsgid_TeamInfo)
    write_byte(id)
    write_string(teaminfo)
    message_end()
}


stock CsTeams:fm_get_user_team(id)
    return CsTeams:get_pdata_int(id, OFFSET_TEAM)

