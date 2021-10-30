#include <amxmodx>
#include <codmod>
#include <fakemeta>
#include <colorchat>

new const nazwa[] = "Admiral";
new const opis[] = "Has Multi jump, 20 hp and full magazine for every kill";
new const bronie = 1<<CSW_FAMAS | 1<<CSW_DEAGLE;
new const zdrowie = 30;
new const kondycja = 28;
new const inteligencja = 0;
new const wytrzymalosc = 20;

new bool:ma_klase[33];

new bool:moze_skoczyc[33];

new const maxClip[31] = { -1, 13, -1, 10,  1,  7,  1,  30, 30,  1,  30,  20,  25, 30, 35, 25,  12,  20, 
10,  30, 100,  8, 30,  30, 20,  2,  7, 30, 30, -1,  50 };

public plugin_init() {
	register_plugin(nazwa, "1.0", "Esnon");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_forward(FM_CmdStart, "CmdStart");
	register_event("DeathMsg", "DeathMsg", "ade");
}

public cod_class_enabled(id)
{
	ma_klase[id] = true;
	return COD_CONTINUE;
}

public cod_class_disabled(id)
	ma_klase[id] = false;

public CmdStart(id, uc_handle)
{
	if(!ma_klase[id])
		return FMRES_IGNORED;
	
	new button = get_uc(uc_handle, UC_Buttons);
	new oldbutton = pev(id, pev_oldbuttons);
	new flags = pev(id, pev_flags);
	if((button & IN_JUMP) && !(flags & FL_ONGROUND) && !(oldbutton & IN_JUMP) && moze_skoczyc[id])
	{
		moze_skoczyc[id] = false;
		new Float:velocity[3];
		pev(id, pev_velocity, velocity);
		velocity[2] = random_float(265.0,285.0);
		set_pev(id, pev_velocity, velocity);
	}
	else if(flags & FL_ONGROUND)	
		moze_skoczyc[id] = true;
		
	return FMRES_IGNORED;
}

public DeathMsg()
{
	new killer = read_data(1);
	new victim = read_data(2);
	
	if(!is_user_connected(killer))
		return PLUGIN_CONTINUE;
	
	if(ma_klase[victim] && !ma_klase[killer])
		cod_set_user_xp(killer, cod_get_user_xp(killer)+10);
	
	if(ma_klase[killer])
	{
		new cur_health = pev(killer, pev_health);
		new Float:max_health = 100.0+cod_get_user_health(killer);
		new Float:new_health = cur_health+20.0<max_health? cur_health+20.0: max_health;
		set_pev(killer, pev_health, new_health);
		
		new weapon = get_user_weapon(killer);
		if(maxClip[weapon] != -1)
			set_user_clip(killer, maxClip[weapon]);
	}
	
	
	return PLUGIN_CONTINUE;
}

stock set_user_clip(id, ammo)
{
	new weaponname[32], weaponid = -1, weapon = get_user_weapon(id, _, _);
	get_weaponname(weapon, weaponname, 31);
	while ((weaponid = engfunc(EngFunc_FindEntityByString, weaponid, "classname", weaponname)) != 0)
		if (pev(weaponid, pev_owner) == id) {
		set_pdata_int(weaponid, 51, ammo, 4);
		return weaponid;
	}
	return 0;
}


