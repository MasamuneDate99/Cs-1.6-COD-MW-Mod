#include <amxmodx>
#include <codmod>

new bool:ma_perk[33];

new const nazwa[] = "Vest pokemon";
new const opis[] = "50 Cond + 50 Str";

public plugin_init()
{
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	cod_register_perk(nazwa, opis);
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0) + 50);
        cod_set_user_bonus_stamina(id, cod_get_user_stamina(id, 0, 0)+50);
}
	
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0) - 50);
        cod_set_user_bonus_stamina(id, cod_get_user_stamina(id, 0, 0)-50);
}