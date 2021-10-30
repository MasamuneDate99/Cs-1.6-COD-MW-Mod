#include <amxmodx>
#include <codmod>
#include <csx>

#define PLUGIN "Cod Exp HS"
#define VERSION "1.0"
#define AUTHOR "Cypis"

new cod_cvar;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	cod_cvar = register_cvar("cod_hsxp", "250");
}

public client_death(killer, victim, wpnindex, hitplace, TK)
{	
	if(!is_user_alive(killer) || !is_user_connected(killer))
		return PLUGIN_CONTINUE;
	
	if(get_user_team(victim) != get_user_team(killer))
	{
		new cod_hs = get_pcvar_num(cod_cvar);
		if(hitplace == HIT_HEAD)
		{
			cod_set_user_xp(killer, cod_get_user_xp(killer) + cod_hs);
			set_hudmessage(38, 218, 116, 0.50, 0.33, 1, 6.0, 4.0)
			show_hudmessage(killer, "HEADSHOT^n   +%i", cod_hs)
		}
	}
	return PLUGIN_CONTINUE;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
