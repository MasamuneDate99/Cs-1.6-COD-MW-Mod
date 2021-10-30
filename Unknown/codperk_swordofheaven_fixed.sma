#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
#include <cstrike>
#include <colorchat>
#include <engine>
#include <fakemeta>

new const perk_name[] = "Sword of Heaven";
new const perk_desc[] = "Instant kill enemy with a knife";
    
new bool:ma_perk[33];

public plugin_init()
{
	register_plugin(perk_name, "1.0", "MasamuneDate");
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	ColorChat(id, GREEN, "Created by MasamuneDate", perk_name);
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
	
	if(get_user_weapon(idattacker) == CSW_KNIFE && damagebits & DMG_BULLET && damage > 20.0 && random_num(1,1) == 1)
	cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	return HAM_IGNORED;
	
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
