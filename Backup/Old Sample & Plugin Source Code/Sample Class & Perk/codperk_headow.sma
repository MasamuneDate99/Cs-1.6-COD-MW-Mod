#include <amxmodx>
#include <codmod>
#include <fakemeta>
#include <hamsandwich>
 
new const perk_name[] = "Hunter Headow";
new const perk_desc[] = "Behind Kills get LW EXP";
new bool:ma_perk[33];
new wartosc_perku[33];
 
public plugin_init()
{
        register_plugin(perk_name, "1.0", "RbK");
        
	  cod_register_perk(perk_name, perk_desc, 200, 500);
	  
        RegisterHam(Ham_TraceAttack, "player", "TraceAttack");
                
}
        
public cod_perk_enabled(id, wartosc){
        ma_perk[id] = true;
        wartosc_perku[id] = wartosc;
 }
public cod_perk_disabled(id)
        ma_perk[id] = false;
        
public TraceAttack(id, attacker, Float:damage, Float:direction[3], tracehandle, damagebits)
{
        if(!is_user_connected(id) || !is_user_connected(attacker) || id == attacker)
                return HAM_IGNORED;
                
        if(get_user_team(id) != get_user_team(attacker) && get_tr2(tracehandle, TR_iHitgroup) == HIT_HEAD)
                cod_set_user_xp(attacker, cod_get_user_xp(attacker)+(wartosc_perku[attacker]));
        
        return HAM_HANDLED;
}
