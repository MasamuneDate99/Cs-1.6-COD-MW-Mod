#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
        
new const nazwa[]   = "Axe";
new const opis[]    = "";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_ELITE)|(1<<CSW_SG552);
new const zdrowie   = 50;
new const kondycja  = 10;
new const inteligencja = 10;
new const wytrzymalosc = 50;
    
new Float:redukcja_obrazen_gracza[33];

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	register_forward(FM_PlayerPreThink, "fwPrethink_AutoBH");
 
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage_wytrzymalosc");
}

public cod_class_enabled(id)
{
	give_item(id, "weapon_hegrenade");
	ma_klase[id] = true;

}

public cod_class_disabled(id)
{
	ma_klase[id] = false;

}

public fwPrethink_AutoBH(id)
{
	if(!ma_klase[id])
		return PLUGIN_CONTINUE

	if (pev(id, pev_button) & IN_JUMP) {
		new flags = pev(id, pev_flags)

		if (flags & FL_WATERJUMP)
			return FMRES_IGNORED;
		if ( pev(id, pev_waterlevel) >= 2 )
			return FMRES_IGNORED;
		if ( !(flags & FL_ONGROUND) )
			return FMRES_IGNORED;

		new Float:velocity[3];
		pev(id, pev_velocity, velocity);
		velocity[2] += 250.0;
		set_pev(id, pev_velocity, velocity);

		set_pev(id, pev_gaitsequence, 6);

	}
	return FMRES_IGNORED;
}

public TakeDamage_wytrzymalosc(this, idinflictor, idattacker, Float:damage, damagebits)
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