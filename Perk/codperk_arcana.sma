#include <amxmodx>
#include <codmod>
#include <fun>
#include <colorchat>

new const perk_name[] = "Arcana";
new const perk_desc[] = "Stats + 50 ";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "TremoR");
	
	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_enabled(id)
{
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0)+50);
	cod_set_user_bonus_intelligence(id, cod_get_user_intelligence(id, 0, 0)+50);
	cod_set_user_bonus_health(id, cod_get_user_health(id, 0, 0)+50);
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0)-50);
	cod_set_user_bonus_intelligence(id, cod_get_user_intelligence(id, 0, 0)-50);
	cod_set_user_bonus_health(id, cod_get_user_health(id, 0, 0)-50);
	ma_perk[id] = false;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
