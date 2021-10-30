#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>

#define DMG_BULLET (1<<1)
        
new const nazwa[]   = "Paradox";
new const opis[]    = "Invisible on knife ,less gravity and +4 DMG MAC10";
new const bronie    = (1<<CSW_MAC10)|(1<<CSW_GLOCK18);
new const zdrowie   = 20;
new const kondycja  = 15;
new const inteligencja = 10;
new const wytrzymalosc = 20;
    
new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "`izcoN");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	register_event("CurWeapon", "eventKnife_Niewidzialnosc", "be", "1=1");
   
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);

      RegisterHam(Ham_TakeDamage, "player", "TakeDamage");

}

public cod_class_enabled(id)
{

 	entity_set_float(id, EV_FL_gravity, 600.0/800.0); // zmieniasz grawitacje
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
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 25);  // tu zmieniasz widzialnosc klasy 
	}
	else
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	}
}

public fwSpawn_Grawitacja(id)
{
	if(ma_klase[id])
		entity_set_float(id, EV_FL_gravity, 600.0/800.0); // zmieniasz grawitacje
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
 if(!is_user_connected(idattacker))
 return HAM_IGNORED;

 if(!ma_klase[idattacker])
 return HAM_IGNORED;

 if(damagebits & DMG_BULLET)
 {
 new weapon = get_user_weapon(idattacker);

 if(weapon == CSW_MAC10)
 cod_inflict_damage(idattacker, this, 4.0, 0.0, idinflictor, damagebits);
 }

 return HAM_IGNORED;
}
