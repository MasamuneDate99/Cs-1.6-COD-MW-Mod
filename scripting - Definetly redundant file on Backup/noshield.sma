/*	Formatright © 2010, ConnorMcLeod

	This plugin is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this plugin; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

#include <amxmodx>
#include <cstrike>
#include <fakemeta>

new const PLUGIN[] = "No Shield"
#define VERSION "0.2.1"
new const AUTHOR[] = "ConnorMcLeod"

new const shield[] = "shield"

new g_iTextMsg

const m_iMenuCode = 205

#define cs_get_user_menu(%0)				get_pdata_int(%0, m_iMenuCode)
#define cs_set_user_menu(%0,%1)				set_pdata_int(%0, m_iMenuCode, %1)
#define Menu_BuyItem 10

public plugin_precache()
{
	if( !CheckGamePlayerEquip() )
	{
		register_plugin(PLUGIN, VERSION, AUTHOR)
		register_forward(FM_PrecacheModel, "PrecacheModel")
	}
	else
	{
		register_plugin("No Shield (Auto-Disabled)", VERSION, AUTHOR)
		pause("a")
	}
}

public plugin_init()
{
	g_iTextMsg = get_user_msgid("TextMsg")

	register_clcmd("menuselect 8", "ClCmd_MenuSelect_8")
}

public plugin_cfg()
{
	server_cmd("amx_pausecfg add %s", PLUGIN)
}

CheckGamePlayerEquip()
{
	new szMapFile[64]
	get_mapname(szMapFile, charsmax(szMapFile))
	format(szMapFile, charsmax(szMapFile), "maps/%s.bsp", szMapFile)

	new szBuffer[64], szKey[16], szValue[32]
	new bool:bInEntityDatas, bool:bIsPlayerEquip, bool:bHasShield
	new fp = fopen(szMapFile, "rb")
	if( !fp )
	{
		return 0 // default map oO
	}

	new iOffset, iLength, iMaxPos
	fseek(fp, 4, SEEK_SET)
	fread(fp, iOffset, BLOCK_INT)
	fread(fp, iLength, BLOCK_INT)
	iMaxPos = iOffset + iLength
	fseek(fp, iOffset, SEEK_SET)

	while( ftell(fp) < iMaxPos )
	{
		fgets(fp, szBuffer, charsmax(szBuffer))
		trim(szBuffer)

		if( bInEntityDatas )
		{
			if( szBuffer[0] == '}' )
			{
				if( bIsPlayerEquip && bHasShield )
				{
					break
				}
			}
			else
			{
				parse(szBuffer, szKey, charsmax(szKey), szValue, charsmax(szValue))
				if( equal(szKey, "classname") )
				{
					bIsPlayerEquip = !!equal(szValue, "game_player_equip")
				}
				else if( equal(szKey, "weapon_shield") )
				{
					bHasShield = !!equal(szValue, "1")
				}
			}
		}
		else if( szBuffer[0] == '{' )
		{
			bInEntityDatas = true
			bIsPlayerEquip = false
			bHasShield = false
		}
	}
	fclose(fp)

	return ( bIsPlayerEquip && bHasShield )
}

public PrecacheModel(const szModel[])
{
	if( containi(szModel, shield) != -1 )
	{
		forward_return(FMV_CELL, 0)
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public ClCmd_MenuSelect_8( id )
{
	if( is_user_alive(id) && cs_get_user_menu(id) == Menu_BuyItem && cs_get_user_team(id) == CS_TEAM_CT )
	{
		new iOldMenu, iNewMenu
		player_menu_info(id, iOldMenu, iNewMenu)
		if( iNewMenu != -1 || iOldMenu > 0 ) // no check against BuyMenus because amxx menu system is too global.
		{
			cs_set_user_menu(id, 0)
		}
		else
		{
			Message_No_Shield(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

public client_command(id)
{
	static szCommand[8] // shield

	if( read_argv(0, szCommand, charsmax(szCommand)) == 6 && equali(szCommand, shield) )
	{
		Message_No_Shield(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public CS_InternalCommand(id, const szCommand[])
{
	if( equali(szCommand, shield) )
	{
		Message_No_Shield(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

Message_No_Shield(id)
{
	message_begin(MSG_ONE_UNRELIABLE, g_iTextMsg, .player=id)
	write_byte( print_center )
	write_string( "#Weapon_Not_Available" )
	write_string( "#TactShield" )
	message_end()
}