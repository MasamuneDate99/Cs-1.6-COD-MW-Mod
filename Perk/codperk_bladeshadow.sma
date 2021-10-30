#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
        
new const perk_name[] = "Blade of Shadow";
new const perk_desc[] = "35/255 in the knife, Multi jump, less gravity";
    
new skoki[33];

new ma_perk[33];

public plugin_init()
{
	register_plugin(perk_name, "1.0", "QTM_Peyote")

	cod_register_perk(perk_name, perk_desc);

	register_event("CurWeapon", "eventKnife_Niewidzialnosc", "be", "1=1");
   
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);

   
	register_forward(FM_CmdStart, "fwCmdStart_MultiJump");

}

public cod_perk_enabled(id)
{

 	entity_set_float(id, EV_FL_gravity, 500.0/800.0);
	ma_perk[id] = true;

}

public cod_perk_disabled(id)
{
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
    
 	entity_set_float(id, EV_FL_gravity, 1.0);
	ma_perk[id] = false;

}

public eventKnife_Niewidzialnosc(id)
{
	if(!ma_perk[id])
		return;

	if( read_data(2) == CSW_KNIFE )
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 35);
	}
	else
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	}
}

public fwSpawn_Grawitacja(id)
{
	if(ma_perk[id])
		entity_set_float(id, EV_FL_gravity, 500.0/800.0);
}


public fwCmdStart_MultiJump(id, uc_handle)
{
	if(!is_user_alive(id) || !ma_perk[id])
		return FMRES_IGNORED;

	new flags = pev(id, pev_flags);

	if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(flags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && skoki[id])
	{
		skoki[id]--;
		new Float:velocity[3];
		pev(id, pev_velocity,velocity);
		velocity[2] = random_float(265.0,285.0);
		set_pev(id, pev_velocity,velocity);
	}
	else if(flags & FL_ONGROUND)
		skoki[id] = 10;

	return FMRES_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
