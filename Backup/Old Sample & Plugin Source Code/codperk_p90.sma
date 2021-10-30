#include <amxmodx>
#include <hamsandwich>
#include <codmod>
#define DMG_BULLET (1<<1)
new const perk_name[] = "P90 Custom Stock";
new const perk_desc[] = "Got P90 and +15 Dmg with P90";
new bool:ma_perk[33];
public plugin_init()
{
		register_plugin(perk_name, "0.1", "Pastel");
	  
		cod_register_perk(perk_name, perk_desc);
		RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}
public cod_perk_enabled(id)
{
		cod_give_weapon(id, CSW_P90);
		ma_perk[id] = true;
		return COD_CONTINUE;
}
public cod_perk_disabled(id)
{
		cod_take_weapon(id, CSW_P90);
		ma_perk[id] = false;
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
		if(!is_user_connected(idattacker))
				return HAM_IGNORED;
	  
		if(!ma_perk[idattacker])
				return HAM_IGNORED;
	  
		if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_P90 && damagebits & DMG_BULLET)
				cod_inflict_damage(idattacker, this, 15.0, 0.0, idinflictor, damagebits);
	  
		return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
