#include <amxmodx>
#include <hamsandwich>
#include <fun>
#include <codmod>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Rusher Equipment";
new const perk_desc[] = "Have 1/LW (random) to kill with M3";

new bool:ma_perk[33], wartosc_perku[33]

public plugin_init() 
{
	register_plugin(perk_name, "1.1", "DarkyyLove");
	
	cod_register_perk(perk_name, perk_desc, 2, 4);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	cod_give_weapon(id, CSW_M3);
	wartosc_perku[id] = wartosc;
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_take_weapon(id, CSW_M3);
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(!ma_perk[idattacker])
		return HAM_IGNORED;

	if(get_user_weapon(idattacker) == CSW_M3 && get_user_team(this) != get_user_team(idattacker) && random_num(1, wartosc_perku[idattacker]) == 1 && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}