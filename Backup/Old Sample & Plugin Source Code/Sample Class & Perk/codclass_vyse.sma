#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fun>
#include <fakemeta>

new const nazwa[]   = "Vyse";
new const opis[]    = "No step and every frag get +500 xp.";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_AWP)|(1<<CSW_M4A1);
new const zdrowie   = 15;
new const kondycja  = 10;
new const inteligencja = 20;
new const wytrzymalosc = 20;

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "Alelluja");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_event("DeathMsg", "DeathMsg", "ade");
}

public cod_class_enabled(id)
{
	set_user_footsteps(id, 1);
	give_item(id, "weapon_hegrenade");
	
}

public cod_class_disabled(id)
{
	set_user_footsteps(id, 0);
	
}

public DeathMsg()
{
	new killer = read_data(1);
	new victim = read_data(2);
	
	if(!is_user_connected(killer))
		return PLUGIN_CONTINUE;
	
	if(ma_klase[victim] && !ma_klase[killer])
		cod_set_user_xp(killer, cod_get_user_xp(killer)+500);
	
	if(ma_klase[killer])
	{
		new cur_health = pev(killer, pev_health);
		new Float:max_health = 100.0+cod_get_user_health(killer);
		new Float:new_health = cur_health+0.0<max_health? cur_health+0.0: max_health;
		set_pev(killer, pev_health, new_health);
	}
	return PLUGIN_CONTINUE;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
