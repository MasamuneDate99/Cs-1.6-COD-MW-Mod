#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>

new const perk_name[] = "Daedalus";
new const perk_desc[] = "+10 Damage, 25% chance to 2x damage";

new ma_perk[33];

public plugin_init()
{
	register_plugin(perk_name, "1.0", "glut");
	
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_take_weapon(id,CSW_MP5NAVY)
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits) 
{ 
	if(!is_user_connected(idattacker)) 
		return HAM_IGNORED; 
	
	if(!ma_perk[idattacker]) 
		return HAM_IGNORED; 
	
	if(!(damagebits & (1<<1))) 
		return HAM_IGNORED; 
	
	damage+=10;
	
	if(random_num(1,4) == 1)
	{
		damage*=2
	}
	
	return HAM_IGNORED; 
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
