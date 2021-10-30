#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fun>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>
        
new const nazwa[]   = "Samuraj";
new const opis[]    = "1 HP na sta³e, niewidka, zmniejszona grawitacja, +2 skoki, 1/1 kosa";
new const bronie    = 0;
new const zdrowie   = -99;
new const kondycja  = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;
    
new skoki[33];

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);   
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);

   
	register_forward(FM_CmdStart, "fwCmdStart_MultiJump");

   
	RegisterHam(Ham_TakeDamage, "player", "fwTakeDamage_JedenCios");
	
	register_event("Health", "Health", "be")

}

public cod_class_enabled(id)
{

	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 1);
	set_user_health(id, 1);
 	entity_set_float(id, EV_FL_gravity, 640.0/800.0);
	ma_klase[id] = true;

}

public cod_class_disabled(id)
{
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
    
 	entity_set_float(id, EV_FL_gravity, 1.0);
	ma_klase[id] = false;

}

public fwSpawn_Grawitacja(id)
{
	if(ma_klase[id])
		entity_set_float(id, EV_FL_gravity, 640.0/800.0);
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
		skoki[id] = 2;

	return FMRES_IGNORED;
}

public fwTakeDamage_JedenCios(id, ent, attacker)
{
	if(is_user_alive(attacker) && ma_klase[attacker] && get_user_weapon(attacker) == CSW_KNIFE)
	{
		cs_set_user_armor(id, 0, CS_ARMOR_NONE);
		SetHamParamFloat(4, float(get_user_health(id) + 1));
		return HAM_HANDLED;
	}
	return HAM_IGNORED;
}

public Health(id)

{

	if(ma_klase[id] && is_user_alive(id) && read_data(1) > 1)

	{

		set_user_health(id, 1);  //Tutaj cyfra 1, tak¿e ustala hp

	}

}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1041\\ f0\\ fs16 \n\\ par }
*/
