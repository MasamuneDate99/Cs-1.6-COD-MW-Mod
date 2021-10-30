#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <fakemeta>

new const nazwa[] = "Jet Pack Shoes";
new const opis[] = "Gravity Reduce, also 10 Multi Jump";

new skoki[33];
new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "Play 4FuN");
	cod_register_perk(nazwa, opis);
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);
	register_forward(FM_CmdStart, "fwCmdStart_MultiJump");
}

public cod_perk_enabled(id)
{
	entity_set_float(id, EV_FL_gravity, 500.0/800.0);
	ma_klase[id] = true;
}

public cod_perk_disabled(id)
{
	entity_set_float(id, EV_FL_gravity, 1.0);
	ma_klase[id] = false;
}

public fwSpawn_Grawitacja(id)
{
	if(ma_klase[id])
		entity_set_float(id, EV_FL_gravity, 500.0/800.0);
}

public fwCmdStart_MultiJump(id, uc_handle)
{
	if(!is_user_alive(id) || !ma_klase[id])
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
