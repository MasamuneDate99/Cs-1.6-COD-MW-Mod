#include <amxmodx>
#include <codmod>

new bool:ma_perk[33];

new const nazwa[] = "Sandals pokemon";
new const opis[] = "You get 130 cond";

public plugin_init()
{
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	cod_register_perk(nazwa, opis);
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0) + 130);
}
	
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0) - 130);
}