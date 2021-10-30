#include <amxmodx>
#include <fun>
#include <hamsandwich>
#include <codmod>

#define DMG_BULLET (1<<1)

new const perk_name[] = "SS Skill";
new const perk_desc[] = "You get an AK47 and 1/4 of HE, there can hear your step.";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "Hajto");
	
	cod_register_perk(perk_name, perk_desc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id)
{
        set_user_footsteps(id, 1);
	cod_give_weapon(id, CSW_AK47);
        cod_give_weapon(id, CSW_HEGRENADE);
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
        set_user_footsteps(id, 0);
	cod_take_weapon(id, CSW_AK47);
        cod_take_weapon(id, CSW_HEGRENADE);
	ma_perk[id] = false;
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
		
	if(random(4))
		return HAM_IGNORED;
	
	if(get_user_team(this) == get_user_team(idattacker))
		return HAM_IGNORED;
	
	if(get_user_weapon(idattacker) != CSW_HEGRENADE)
		return HAM_IGNORED;
	
	if(!(damagebits & DMG_BULLET))
		return HAM_IGNORED;
		
	cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
