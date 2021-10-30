#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fun>
#include <hamsandwich>
#include <cstrike>

#define DMG_BULLET (1<<1)
#define DMG_HEGRENADE (1<<24)

new const nazwa[]   = "Kapitan";
new const opis[]    = "1/1 z awp 1/1 z he";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_AWP)|(1<<CSW_DEAGLE);
new const zdrowie   = 0;
new const kondycja  = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "Alelluja");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_TakeDamage, "player", "Zabicie");
	register_event("ResetHUD", "ResetHUD", "abe");
}

public cod_class_enabled(id)
{
	ma_klase[id] = true;
	ResetHUD(id);
	
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
}

public Zabicie(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_klase[idattacker])
		return HAM_IGNORED;      
	
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_AWP && damagebits & DMG_BULLET && random_num(1, 1) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_HEGRENADE && damagebits & DMG_HEGRENADE && random_num(1, 1) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}

public ResetHUD(id)
{
	set_task(0.1, "ResetHUDx", id);
}

public ResetHUDx(id)
{
	if(!is_user_connected(id)) return;

	if(!ma_klase[id]) return;

	cs_set_user_bpammo(id, CSW_HEGRENADE, 2);

}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
