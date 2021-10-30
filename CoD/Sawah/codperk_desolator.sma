#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
#include <fun>
#include <engine>
#include <colorchat>

new const perk_name[] = "Desolator";
new const perk_desc[] = "Pierce defense, deal pure damage";

new bool:ma_perk[33];
new Float:redukcja_obrazen_gracza[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "MasamuneDate");
	cod_register_perk(perk_name, perk_desc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage_wytrzymalosc")
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	ColorChat(id, GREEN, "Created by MasamuneDate", perk_name);
}

public cod_perk_disabled(id)
{	
	ma_perk[id] = false;
}

public TakeDamage_wytrzymalosc(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;

	if(!ma_perk[idattacker])
		return HAM_IGNORED;

	if(!cod_get_user_stamina(this))
		return HAM_IGNORED;

	redukcja_obrazen_gracza[this] = 0.7*(1.0-floatpower(1.1, -0.112311341*cod_get_user_stamina(this)));
	SetHamParamFloat(4, damage/(1.0-redukcja_obrazen_gracza[this]))

	return HAM_IGNORED;
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
