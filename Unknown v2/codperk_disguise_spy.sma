#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <cstrike>
        
new const nazwa[]   = "Disguise Spy";
new const opis[]    = "1/LW Chance to spawn at enemy base, got Opponent skin";
    
new wartosc_perku[33];
new bool: ma_perk[33];
new CT_Skins[4][] = {"sas","gsg9","urban","gign"};
new Terro_Skins[4][] = {"arctic","leet","guerilla","terror"};

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");
	cod_register_perk(nazwa, opis, 2, 4);
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}

public cod_perk_enabled(id, wartosc)

{
	ZmienUbranie(id, 0);
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	ZmienUbranie(id, 1);
	ma_perk[id] = false;
}

public Spawn(id, this)

{
        if(!is_user_alive(id))
                return;
                
        if(!ma_perk[id])
                return;
                
        if(random_num(1,wartosc_perku[this]) == 1)
        {
                new CsTeams:team = cs_get_user_team(id);
                
                cs_set_user_team(id, (team == CS_TEAM_CT)? CS_TEAM_T: CS_TEAM_CT);
                ExecuteHam(Ham_CS_RoundRespawn, id);
                
                cs_set_user_team(id, team);
        }
}

public ZmienUbranie(id,reset)

{
	if (!is_user_connected(id))
		return PLUGIN_CONTINUE; 

	if (reset)
		cs_reset_user_model(id);
	else
	{
		new num = random_num(0,3);
		cs_set_user_model(id, (get_user_team(id) == 1)? CT_Skins[num]: Terro_Skins[num]);
	}
	return PLUGIN_CONTINUE;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
