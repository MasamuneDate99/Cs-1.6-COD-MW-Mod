/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <codmod>

#define DMG_HEGRENADE (1<<24)

new const perk_name[] = "Mystery General";
new const perk_desc[] = "You ask 100 (+ intelligence) damage with HE";

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
	cod_give_weapon(id, CSW_HEGRENADE);
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_take_weapon(id, CSW_HEGRENADE);
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(!ma_perk[idattacker])
		return HAM_IGNORED;

	if(damagebits & DMG_HEGRENADE && get_user_team(this) != get_user_team(idattacker))
		cod_inflict_damage(idattacker, this, 101.0-damage, 1.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}
