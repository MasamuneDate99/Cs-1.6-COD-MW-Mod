#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
#include <cstrike>

#define DMG_BULLET (1<<1)

new const nazwa[]   = "Comandos";
new const opis[]    = "Instant kill with a knife";
new const bronie = 1<<CSW_DEAGLE;
new const zdrowie = 40;
new const kondycja = 60;
new const inteligencja = 5;
new const wytrzymalosc = 0;
new bool: ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "kubkos");
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}

public cod_class_enabled(id)
{
	ma_klase[id] = true;
	return COD_CONTINUE;
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
	
	if(get_user_weapon(idattacker) == CSW_KNIFE && damagebits & DMG_BULLET && damage > 20.0 && random_num(1,1) == 1)
		
	cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
	
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
