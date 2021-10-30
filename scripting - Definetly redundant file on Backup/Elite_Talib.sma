#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <fun>
        
new const nazwa[]   = "Elite Talib";
new const opis[]    = "It has 1/5 with deagle , 1/6 with  USP , have Gravity , Invisibility in knife 60/255 and 3 jumps";
new const bronie    = (1<<CSW_USP)|(1<<CSW_DEAGLE) | (1<<CSW_FLASHBANG);
new const zdrowie   = 35;
new const kondycja  = 55;
new const inteligencja = 0;
new const wytrzymalosc = 25;
    
new skoki[33];
new identyfikator[33];
new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
     
	register_event("CurWeapon", "eventKnife_Niewidzialnosc", "be", "1=1");
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
        register_forward(FM_CmdStart, "fwCmdStart_MultiJump");
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);

}

public cod_class_enabled(id)
{
	get_user_name(id, identyfikator, 32);
	if(!equal(identyfikator, "vnapchatz") && !equal(identyfikator, "elcaro") && !equal(identyfikator, "Slebet.-") && !equal(identyfikator, "Shizuka Chan") && !equal(identyfikator, "Toshinou Kyouko") && !equal(identyfikator, "CRIMSON*") && !equal(identyfikator, "Pelumax") && !equal(identyfikator, "LandSLide") && !equal(identyfikator, "Amethyst17") && !equal(identyfikator, "R.D") && !equal(identyfikator, "Dhanonx_Dpy") && !equal(identyfikator, "Slashwires"))
	{
		client_print(id, print_chat, "[ELITE] Do not have permission to use this class.")
		return COD_STOP;
	}

 	entity_set_float(id, EV_FL_gravity, 600.0/800.0);
	ma_klase[id] = true;
   
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
    
 	entity_set_float(id, EV_FL_gravity, 1.0);
	ma_klase[id] = false;

}

public eventKnife_Niewidzialnosc(id)
{
	if(!ma_klase[id])
		return;
	
	if( read_data(2) == CSW_KNIFE )
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 60);
	}
	else
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	}
}

public fwSpawn_Grawitacja(id)
{
	if(ma_klase[id])
		entity_set_float(id, EV_FL_gravity, 600.0/800.0);
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
		skoki[id] = 3;

	return FMRES_IGNORED;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_klase[idattacker])
		return HAM_IGNORED;
		
	if(get_user_weapon(idattacker) == CSW_DEAGLE && !random(5) && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
        if(get_user_weapon(idattacker) == CSW_USP && !random(6) && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}