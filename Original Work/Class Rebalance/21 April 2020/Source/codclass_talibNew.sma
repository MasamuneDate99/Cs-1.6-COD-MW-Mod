/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <engine>
#include <hamsandwich>
#include <codmod>

new bool:ma_klase[33];

new const nazwa[] = "Talib";
new const opis[] = "1/5 chance to instantly kill with deagle, AutoBH";
new const bronie = 1<<CSW_DEAGLE | 1<<CSW_HEGRENADE | 1<<CSW_FLASHBANG | 1<<CSW_SMOKEGRENADE;
new const zdrowie = 70;
new const kondycja = 50;
new const inteligencja = -1;
new const wytrzymalosc = 5;

public plugin_init() {
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	ma_klase[id] = true;
}

public cod_class_disabled(id)
	ma_klase[id] = false;

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_klase[idattacker])
		return HAM_IGNORED;
		
	if(get_user_weapon(idattacker) == CSW_DEAGLE && !random(5) && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}

public client_PreThink(id)
{
	if(!ma_klase[id])
		return PLUGIN_CONTINUE;
		
	if(!(get_user_button(id) & IN_JUMP))
		return PLUGIN_CONTINUE;
		
	new flags = get_entity_flags(id);
	
	if (flags & FL_WATERJUMP)
		return PLUGIN_CONTINUE;
		
	if (entity_get_int(id, EV_INT_waterlevel) >= 2)
		return PLUGIN_CONTINUE;
		
	if (!(flags & FL_ONGROUND))
		return PLUGIN_CONTINUE;
	
	new Float:velocity[3];
	entity_get_vector(id, EV_VEC_velocity, velocity);
	velocity[2] += 250.0
	entity_set_vector(id, EV_VEC_velocity, velocity);
	
	entity_set_int(id, EV_INT_gaitsequence, 6);
	
	return PLUGIN_CONTINUE;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
