#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
#include <fun>
#include <engine>
#include <colorchat>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Bomberman";
new const perk_desc[] = "150+ damage with HE Grenade, Increase damage with each inteligence stats";


new bool:ma_perk[33];
    

public plugin_init(){
	register_plugin(perk_name, "1.0", "MasamuneDate");
	cod_register_perk(perk_name, perk_desc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}


public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	give_item(id, "weapon_hegrenade");
	ColorChat(id, GREEN, "Created by MasamuneDate", perk_name);
	give_item(id, "weapon_hegrenade");
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;

}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
	
	if(get_user_weapon(idattacker) == CSW_HEGRENADE && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, 150.0, 1.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
