#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta_util>
#include <engine>
#include <hamsandwich>
#include <codmod>

/* 	
This perk was created on needs for Call Of Duty Mod by QTM_Peyote

Perk: Fragmentation Nade
Perk creator: Hleb
Description: You have a special grenade, which after the explosion shatters into 5 fragments.
Rate of damage and factor of intelligence can be set by cvar (Default 40.0 dmg and 0.2 dmg by 1 int points) 
	
Thanks for:
DarkGL - for help in setting angle vectors for fragments
QTM_Peyote - for help in setting simpler angle vectors for fragments
*/
	

#define ILE_ODLAMKOW 5

new pCvarFragmentDMG
new pCvarFragmentInt

new const perk_name[] = "Militaty Granade";
new const perk_desc[] = "You have a granade";

new sprite_blast;
new bool: ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.1", "Hleb")
	
	cod_register_perk(perk_name, perk_desc)
	
	register_event("CurWeapon", "CurWeapon", "be", "1=1")
	register_forward(FM_SetModel, "fw_SetModel");
	
	RegisterHam(Ham_Think,"grenade","ham_grenade_think",0);
	
	register_touch("fragmentation nade", "*", "fragmentation_nade_touch")
	
	pCvarFragmentDMG = register_cvar("cod_fragment_damage", "170.0")
	pCvarFragmentInt = register_cvar("cod_fragment_int", "0.2")
}
public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	cod_give_weapon(id, CSW_HEGRENADE);
}
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_take_weapon(id, CSW_HEGRENADE);
}
public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	precache_model("models/QTM_CodMod/v_hegrenade.mdl");
	precache_model("models/QTM_CodMod/w_hegrenade.mdl");
	precache_model("models/QTM_CodMod/p_hegrenade.mdl");
	precache_model("models/QTM_CodMod/fragment.mdl");
}
public CurWeapon(id)
{
        new weapon = read_data(2);

        if(ma_perk[id])
        {
                if(weapon == CSW_HEGRENADE)
                {
                        set_pev(id, pev_viewmodel2, "models/QTM_CodMod/v_hegrenade.mdl")
                        set_pev(id, pev_weaponmodel2, "models/QTM_CodMod/p_hegrenade.mdl")
                }
        }
}
public ham_grenade_think(ent)
{
	new models[34]
	if(!pev_valid(ent)) 
		return HAM_IGNORED;	
	
	entity_get_string(ent, EV_SZ_model, models, 33)
	if(!equali(models, "models/QTM_CodMod/w_hegrenade.mdl")) 
		return HAM_IGNORED
	
	new Float:damagetime;
	pev(ent,pev_dmgtime,damagetime);
	damagetime+=0.1
	if(damagetime > get_gametime()) 
		return HAM_IGNORED;
		
	fragmentation_explode(ent);
	
	return HAM_IGNORED
}
public fragmentation_explode(ent)
{
	new id = pev(ent,pev_owner);
	
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	if(!ma_perk[id])
		return PLUGIN_CONTINUE;
	
	new Float:origin[3];
		
	pev(ent, pev_origin, origin);
	
	for(new i=1; i <= ILE_ODLAMKOW; i++)
	{	
		new ent = fm_create_entity("info_target");
		set_pev(ent, pev_classname, "fragmentation nade");
		set_pev(ent, pev_owner, id);
		set_pev(ent, pev_movetype, MOVETYPE_TOSS);
		set_pev(ent, pev_origin, origin);
		set_pev(ent, pev_solid, SOLID_BBOX);
		engfunc(EngFunc_SetModel, ent, "models/QTM_CodMod/fragment.mdl");
		
		new Float:fVelocity[3];
		
		fVelocity[0] = floatsin(360.0/ILE_ODLAMKOW*i, degrees)*200.0;
		fVelocity[1] = floatcos(360.0/ILE_ODLAMKOW*i, degrees)*200.0;
		fVelocity[2] = 100.0
		
		set_pev(ent, pev_velocity, fVelocity);
		set_pev(ent, pev_gravity,  1.0);
	}
	
	return PLUGIN_CONTINUE
}	
public fragmentation_nade_touch(ent)
{
	if (!is_valid_ent(ent))
		return;

	new attacker = entity_get_edict(ent, EV_ENT_owner);
	

	new Float:fOrigin[3];
	pev(ent, pev_origin, fOrigin);	
	
	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(sprite_blast);
	write_byte(32); 
	write_byte(20); 
	write_byte(0);
	message_end();

	new entlist[33];
	new numfound = find_sphere_class(ent, "player", 120.0, entlist, 32);
	
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		
		if(!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid))
			continue;
			
		cod_inflict_damage(attacker, pid, get_pcvar_float(pCvarFragmentDMG), get_pcvar_float(pCvarFragmentInt), ent, (1<<24));
	}
	remove_entity(ent);
}		
public fw_SetModel(entity, model[])
{
        if(!pev_valid(entity)) 
                return FMRES_IGNORED

        if(!equali(model, "models/w_hegrenade.mdl"))
                return FMRES_IGNORED;

        new entityowner = pev(entity, pev_owner);
        
        if(!ma_perk[entityowner])
                return FMRES_IGNORED;

        engfunc(EngFunc_SetModel, entity, "models/QTM_CodMod/w_hegrenade.mdl") 
	
        return FMRES_SUPERCEDE
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
