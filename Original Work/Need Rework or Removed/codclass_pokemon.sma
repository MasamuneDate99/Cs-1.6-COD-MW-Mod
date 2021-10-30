#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>

#define DMG_BULLET (1<<1)
        
new const nazwa[]   = "Pokemon";
new const opis[]    = "Famas +15 DMG , usp/glock, FiveSeven.";
new const bronie    = (1<<CSW_FIVESEVEN)|(1<<CSW_FAMAS)|(1<<CSW_USP)|(1<<CSW_GLOCK18);
new const zdrowie   = 20;
new const kondycja  = 20;
new const inteligencja = 0;
new const wytrzymalosc = 10;

new bool:ma_klase[33];
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "CR4ATOR");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	ma_klase[id] = true;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;

}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if(get_user_weapon(idattacker) == CSW_FAMAS && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, 15.0, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}