#include <amxmodx>
#include <codmod>
#include <hamsandwich>

#define DMG_BULLET (1<<1)

new bool:ma_perk[33];

new const perk_name[] = "Point Bullet";
new const perk_desc[] = "20% extra DMG with all weapons.";

public plugin_init()
{
	register_plugin(perk_name, "1.0", "NieWiemMamMac@");
	
	cod_register_perk(perk_name, perk_desc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)	ma_perk[id] = true;      
public cod_class_disabled(id)	 ma_perk[id] = false;


public TakeDamage(id, ent, attacker, Float:damage, damagebits)
{
	if(!is_user_connected(attacker) || !ma_perk[attacker] || ~damagebits & DMG_BULLET || ent != attacker)    return HAM_IGNORED;
	
	SetHamParamFloat(4,damage*1.2)
	return HAM_HANDLED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1250\\ deff0\\ deflang1045{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
