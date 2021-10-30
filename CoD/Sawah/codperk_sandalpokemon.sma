#include <amxmodx>
#include <codmod>

new bool:ma_perk[33];

new const nazwa[] = "Sandals pokemon";
new const opis[] = "You get 150 cond";

public plugin_init()
{
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	cod_register_perk(nazwa, opis);
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0) + 150);
}
	
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0) - 150);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
