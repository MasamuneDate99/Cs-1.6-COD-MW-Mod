#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <cstrike>
#include <fakemeta>
        
new const nazwa[]   = "Lee ";
new const opis[]    = "It has a 1/1 Kosa (PPM), less gravity, dimly visible on the well base (55/255)";
new const bronie    = (1<<CSW_MP5NAVY)|(1<<CSW_DEAGLE);
new const zdrowie   = 12;
new const kondycja  = 3;
new const inteligencja = 0;
new const wytrzymalosc = 15;
    
new ostatnio_prawym[33];

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	register_event("CurWeapon", "eventKnife_Niewidzialnosc", "be", "1=1");
   
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);


	RegisterHam(Ham_TakeDamage, "player", "fwTakeDamage_JedenCios");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fwPrimaryAttack_JedenCios");
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fwSecondaryAttack_JedenCios");

}

public cod_class_enabled(id)
{

 	entity_set_float(id, EV_FL_gravity, 550.0/800.0);
	ma_klase[id] = true;

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
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 55);
	}
	else
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	}
}

public fwSpawn_Grawitacja(id)
{
	if(ma_klase[id])
		entity_set_float(id, EV_FL_gravity, 550.0/800.0);
}


public fwTakeDamage_JedenCios(id, ent, attacker)
{
	if(is_user_alive(attacker) && ma_klase[attacker] && get_user_weapon(attacker) == CSW_KNIFE && ostatnio_prawym[id])
	{
		cs_set_user_armor(id, 0, CS_ARMOR_NONE);
		SetHamParamFloat(4, float(get_user_health(id) + 1));
		return HAM_HANDLED;
	}
	return HAM_IGNORED;
}

public fwPrimaryAttack_JedenCios(ent)
{
	new id = pev(ent, pev_owner);
	ostatnio_prawym[id] = 1;
}

public fwSecondaryAttack_JedenCios(ent)
{
	new id = pev(ent, pev_owner);
	ostatnio_prawym[id] = 0;
}