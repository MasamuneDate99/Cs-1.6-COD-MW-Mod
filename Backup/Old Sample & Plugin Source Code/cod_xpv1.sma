#include <amxmodx>
#include <codmod>

#define MIN_PLAYERS 5

new const msg[][] = { "bomb", "bomb", "Save the host" }

new cod_cvars[3];

public plugin_init() {
	register_plugin("cod_bombxp", "1.1", "byQQ");
	
	register_logevent("logevent_przydziel", 3, "1=triggered");
	
	cod_cvars[0] = register_cvar("cod_plantxp", "445");
	cod_cvars[1] = register_cvar("cod_defusxp", "455");
	cod_cvars[2] = register_cvar("cod_rescuxp", "430");
}

public logevent_przydziel()
{
	new loguser[80], akcja[64], name[32];
	read_logargv(0, loguser, 79);
	read_logargv(2, akcja, 63);
	parse_loguser(loguser, name, 31);
	
	new id = get_user_index(name);
	
	if(equal(akcja, "Planted_The_Bomb")) { PrzydzielExp(id, 0); }
	else if(equal(akcja, "Defused_The_Bomb")) { PrzydzielExp(id, 1); }
	else if(equal(akcja, "Rescued_A_Hostage")) { PrzydzielExp(id, 2); }
}

public PrzydzielExp(id, typ)
{
	new exp = get_pcvar_num(cod_cvars[typ]); 
	
	if(get_playersnum() >= MIN_PLAYERS)
	{
		cod_set_user_xp(id, cod_get_user_xp(id) + exp);
		client_print(id, print_chat, "[COD:MW] You get %d experience for %s.", exp, msg[typ]);
	}
}
