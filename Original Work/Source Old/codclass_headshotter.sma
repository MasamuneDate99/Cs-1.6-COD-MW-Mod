#include <amxmodx>
#include <codmod>
#include <colorchat>

#define PLUGIN "CoD Class Miastowy"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Black Ops Commander"
#define DESCRIPTION  "Restore 50 HP With each headshots"
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_AK47)|(1<<CSW_USP) | (1<<CSW_GALIL)
#define HEALTH       10
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      10
#define CONDITION    10

new classActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
{
	ColorChat(id, GREEN, "Rework by MasamuneDate",  name);
	set_bit(id, classActive);
}

public cod_class_disabled(id, promotion)
{	
	rem_bit(id, classActive);
}
public cod_damage_post(attacker, victim, weapon, Float:damage, damageBits, hitPlace)
{
	if (!get_bit(attacker, classActive) || hitPlace != HIT_HEAD) return;
	cod_add_user_health(attacker, 50);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1041\\ f0\\ fs16 \n\\ par }
*/
