#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <cstrike>
 
#define DMG_BULLET (1<<1)
        
new const nazwa[]   = "Zolnierz";
new const opis[]    = "damage 3 DMG(+int) with Famas";
new const bronie    =(1<<CSW_FAMAS)|(1<<CSW_FIVESEVEN) | 1<<CSW_FLASHBANG;
new const zdrowie   = 15;
new const kondycja  = 35;
new const inteligencja = 2;
new const wytrzymalosc = 20;
    
new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "shajba");

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
        
        if(damagebits & DMG_BULLET)
	{
                new weapon = get_user_weapon(idattacker);
                        
                if(weapon == CSW_FAMAS)
                        cod_inflict_damage(idattacker, this, 3.0, 0.1, idinflictor, damagebits);
        }
        
        return HAM_IGNORED;
}