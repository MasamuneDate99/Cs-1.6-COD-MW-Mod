/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <hamsandwich>
#include <codmod>
#include <colorchat>

new const perk_name[] = "Right hand rambo";
new const perk_desc[] = "108 Cond, 35 strength and +7 DMG";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "QTM_Peyote");
	
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0, 1)+108);
	cod_set_user_bonus_stamina(id, cod_get_user_stamina(id, 0, 0, 1)+35);
}
	
public cod_perk_disabled(id)
{
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0, 1)-108);
	cod_set_user_bonus_stamina(id, cod_get_user_stamina(id, 0, 0, 1)-35);
	ma_perk[id] = false;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(ma_perk[idattacker])
		cod_inflict_damage(idattacker, this, 7.0, 0.20, idinflictor, damagebits);

	return HAM_IGNORED;
}
