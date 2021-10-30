#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
        
#define DMG_BULLET (1<<1)
	
new const perk_name[] = "Diamond cartridges";
new const perk_desc[] = "you have a 1/10 of each weapon";
    
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
