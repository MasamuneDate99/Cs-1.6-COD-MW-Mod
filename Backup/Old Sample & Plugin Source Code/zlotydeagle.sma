/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <codmod>
#include <hamsandwich>
 
new const perk_name[] = "Gold Deagle";
new const perk_desc[] = "You get +35 dmg Deagle";
 
 new bool:ma_perk[33];

public plugin_init()
{
register_plugin("Zloty deagle", "1.0", "Dr@goN");

cod_register_perk(perk_name, perk_desc);
RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id)
{
cod_give_weapon(id, CSW_DEAGLE);
ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
cod_take_weapon(id, CSW_DEAGLE);
ma_perk[id] = false;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
if(!is_user_connected(idattacker))
return HAM_IGNORED;

if(!ma_perk[idattacker])
return HAM_IGNORED;


if(get_user_weapon(idattacker) == CSW_DEAGLE && damagebits & (1<<1))
cod_inflict_damage(idattacker, this, 35.0, 0.0, idinflictor, damagebits);

return HAM_IGNORED;




}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
