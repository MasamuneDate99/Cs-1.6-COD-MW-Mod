// Plugin oparty na kodzie "No Walls" w wersji 0.13 autorstwa Avalanche

#include <amxmodx>
#include <fakemeta>
#include <codmod>

new normalTrace[33], lastTrace[33], skan[33];
new cvar_skan_xp_typ, cvar_skan_xp_hs, cvar_skan_xp_zabojstwo;

public plugin_init()
{
	register_plugin("Exp Walls","0.1","Window");
	cvar_skan_xp_typ = register_cvar("cod_skan_typ", "1");  // 1-Xp za normalne zabojstwo i w hs; 2-Xp tylko za zabojstwo w hs; 3-Xp tylko za normalne zabojstwo;
	cvar_skan_xp_hs = register_cvar("cod_skan_hs", "1000"); // doswiadczenie za zabojstwo strzalem w glowe
	cvar_skan_xp_zabojstwo = register_cvar("cod_skan_zabojstwo", "500"); // doswiadczenie za normalne zabojstwo

	register_event("DeathMsg", "death", "a", "1>0");
	register_clcmd("fullupdate","cmd_fullupdate");

	register_forward(FM_TraceLine,"fw_traceline");
	register_forward(FM_PlayerPostThink,"fw_playerpostthink");
}
public client_connect(id)
{
	normalTrace[id] = 0;
}
public cmd_fullupdate(id)
{
	return PLUGIN_HANDLED;
}
public fw_traceline(Float:vecStart[3],Float:vecEnd[3],ignoreM,id,ptr) // pentToSkip == id, for clarity
{
	if(!is_user_connected(id))
		return FMRES_IGNORED;

	if(!normalTrace[id])
	{
		normalTrace[id] = ptr;
		return FMRES_IGNORED;
	}

	else if(ptr == normalTrace[id])
		return FMRES_IGNORED;

	if(!is_user_alive(id))
		return FMRES_IGNORED;

	if(!(pev(id,pev_button) & IN_ATTACK))
		return FMRES_IGNORED;

	if(ptr == lastTrace[id])
	{		
		skan[id] = 1;
		return FMRES_SUPERCEDE;
	}

	lastTrace[id] = ptr;

	return FMRES_IGNORED;
}

public fw_playerpostthink(id)
{
	lastTrace[id] = 0;
	skan[id] = 0;
}
 
public death(id)
{
	new killer = read_data(1);
	new victim = read_data(2);
	new hs = read_data(3);
	new typ_xp = get_pcvar_num(cvar_skan_xp_typ);
	new doswiadczenie_za_hs = get_pcvar_num(cvar_skan_xp_hs);
	new doswiadczenie_za_zabojstwo = get_pcvar_num(cvar_skan_xp_zabojstwo);

	if(killer != victim && skan[killer] == 1)
	{
		switch(typ_xp)
		{
			case 1:
			{
				if(hs)
				{
					cod_set_user_xp(killer, cod_get_user_xp(killer) + doswiadczenie_za_hs);
					client_print(killer, print_chat, "[RAJAGAME] You get an additional +%i exp for killing shot in the head by a wall!", doswiadczenie_za_hs);
				}
				else
				{
					cod_set_user_xp(killer, cod_get_user_xp(killer) + doswiadczenie_za_zabojstwo);
					client_print(killer, print_chat, "[RAJAGAME] You get an additional +%i exp for killing by a wall!", doswiadczenie_za_zabojstwo);
				}
			}
			case 2:
			{
				if(hs)
				{
					cod_set_user_xp(killer, cod_get_user_xp(killer) + doswiadczenie_za_hs);
					client_print(killer, print_chat, "[RAJAGAME] You get an additional +%i exp for killing shot in the head by a wall!", doswiadczenie_za_hs);
				}
			}
			case 3:
			{
				cod_set_user_xp(killer, cod_get_user_xp(killer) + doswiadczenie_za_zabojstwo);
				client_print(killer, print_chat, "[RAJAGAME] You get an additional +%i exp for killing by a wall!", doswiadczenie_za_zabojstwo);
			}
		}
	}
}