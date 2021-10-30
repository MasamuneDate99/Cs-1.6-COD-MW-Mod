#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
        
#define DMG_BULLET (1<<1)
	
new const perk_name[] = "Diamond cartridges";
new const perk_desc[] = "1/10 Chance to instant kill with ALL WEAPONS";
    
new ma_perk[33];

public plugin_init()
{
	register_plugin(perk_name, "1.0", "Play 4FuN");
	cod_register_perk(perk_name, perk_desc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id)
	ma_perk[id] = true;

public cod_perk_disabled(id)
    	ma_perk[id] = false;

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
        if(!is_user_connected(idattacker))
                return HAM_IGNORED;
        
        if(!ma_perk[idattacker])
                return HAM_IGNORED;
        
        if(!(damagebits & DMG_BULLET))
                return HAM_IGNORED;
                
        if(random_num(1,10) == 1)
                cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
        
        return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
