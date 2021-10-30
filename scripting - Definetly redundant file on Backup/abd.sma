/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>

#define PLUGIN "Advanced Bullet Damage"
#define VERSION "1.0"
#define AUTHOR "Sn!ff3r"

new g_type, g_enabled, g_recieved, bool:g_showrecieved, g_hudmsg1, g_hudmsg2

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("Damage", "on_damage", "b", "2!0", "3=0", "4!0")	
	register_event("HLTV", "on_new_round", "a", "1=0", "2=0")
	
	g_type = register_cvar("amx_bulletdamage","1")
	g_recieved = register_cvar("amx_bulletdamage_recieved","1")	
	
	g_hudmsg1 = CreateHudSyncObj()	
	g_hudmsg2 = CreateHudSyncObj()
}

public on_new_round()
{
	g_enabled = get_pcvar_num(g_type)
	if(get_pcvar_num(g_recieved)) g_showrecieved = true	
}

public on_damage(id)
{
	if(g_enabled)
	{		
		static attacker; attacker = get_user_attacker(id)
		static damage; damage = read_data(2)		
		if(g_showrecieved)
		{			
			set_hudmessage(255, 0, 0, 0.45, 0.50, 2, 0.1, 4.0, 0.1, 0.1, -1)
			ShowSyncHudMsg(id, g_hudmsg2, "%i^n", damage)		
		}
		if(is_user_connected(attacker))
		{
			switch(g_enabled)
			{
				case 1: {
					set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
					ShowSyncHudMsg(attacker, g_hudmsg1, "%i^n", damage)				
				}
				case 2: {
					if(fm_is_ent_visible(attacker,id))
					{
						set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
						ShowSyncHudMsg(attacker, g_hudmsg1, "%i^n", damage)				
					}
				}
			}
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
