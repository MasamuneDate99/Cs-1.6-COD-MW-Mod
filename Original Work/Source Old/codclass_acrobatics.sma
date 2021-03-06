#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
#include <colorchat>
        
new const nazwa[]   = "Acrobatics";
new const opis[]    = "Pure Damage, less gravity and 2 multi jump";
new const bronie    = (1<<CSW_P228)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_M4A1)|(1<<CSW_FLASHBANG)|(1<<CSW_DEAGLE);
new const zdrowie   = 5;
new const kondycja  = 50;
new const inteligencja = 0;
new const wytrzymalosc = 5;
    
new skoki[33];

new Float:redukcja_obrazen_gracza[33];

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);   
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);

   
	register_forward(FM_CmdStart, "fwCmdStart_MultiJump");
 
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	ColorChat(id, GREEN, "Created by MasamuneDate", nazwa);
 	entity_set_float(id, EV_FL_gravity, 550.0/800.0);
	ma_klase[id] = true;

}

public cod_class_disabled(id)
{
 	entity_set_float(id, EV_FL_gravity, 1.0);
	ma_klase[id] = false;

}

public fwSpawn_Grawitacja(id)
{
	if(ma_klase[id])
		entity_set_float(id, EV_FL_gravity, 550.0/800.0);
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

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;

	if(!ma_klase[idattacker])
		return HAM_IGNORED;

	if(!cod_get_user_stamina(this))
		return HAM_IGNORED;

	redukcja_obrazen_gracza[this] = 0.7*(1.0-floatpower(1.1, -0.112311341*cod_get_user_stamina(this)));
	SetHamParamFloat(4, damage/(1.0-redukcja_obrazen_gracza[this]))

	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1041\\ f0\\ fs16 \n\\ par }
*/
