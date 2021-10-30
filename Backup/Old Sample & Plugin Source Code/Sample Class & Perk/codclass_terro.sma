#include <amxmodx>
#include <fakemeta>
#include <codmod>
#include <hamsandwich> 

#define DMG_BULLET (1<<1)

new const nazwa[] = "Veil Terro";
new const opis[] = "AutoBH, 6 dmg with Galil";
new const bronie = 1<<CSW_GALIL;
new const zdrowie = 10;
new const kondycja = 20;
new const inteligencja = 10;
new const wytrzymalosc = 5;

new bool:ma_klase[33];
new identyfikator[33];

public plugin_init() 
{
    cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
    register_forward(FM_PlayerPreThink, "fwPrethink_AutoBH");
    RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	get_user_name(id, identyfikator, 32);
	if(!equal(identyfikator, "kira") && !equal(identyfikator, "shu."))
	{
		client_print(id, print_chat, "[PRO] Do not have permission to use this class.")
		return COD_STOP;
	}
	ma_klase[id] = true;
	return COD_CONTINUE;

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

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
        if(!is_user_connected(idattacker))
                return HAM_IGNORED;

        if(!ma_klase[idattacker])
                return HAM_IGNORED;

        if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_GALIL && damagebits & DMG_BULLET)

                cod_inflict_damage(idattacker, this, 6.0, 0.0, idinflictor, damagebits);



        return HAM_IGNORED;

}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
