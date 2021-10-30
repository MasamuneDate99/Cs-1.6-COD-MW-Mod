#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <fakemeta>
#include <codmod>
#include <colorchat>
#include <hamsandwich>

#define PLUGIN 		"Black Ops Commander"
#define VERSION 	"1.0"
#define AUTHOR 		"MasamuneDate"

new const nazwa[]   = "Black Ops Commander";
new const opis[]    = "Restore 30 HP for each headshot";
new const bronie    = 1<<CSW_TMP | 1<<CSW_G3SG1 | 1<<CSW_FIVESEVEN ;
new const zdrowie   = 25;
new const kondycja  = 10;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new bool:ma_klase[33];
new hitbox[33];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	RegisterHam(Ham_TraceAttack,"player","func_TraceAttack");
}

public cod_class_enabled(id)
{
	ColorChat(id, GREEN, "Created by MasamuneDate",  nazwa);
	ma_klase[id] = true;
}

public cod_class_disabled(id)
{	
	ma_klase[id] = false;
}

public func_TraceAttack(id, idattacker, Float:damage, Float:direction[3], traceresult, damagebits)
{
	hitbox[id] = get_tr2(traceresult,TR_iHitgroup);
} 

public TakeDamage(this, idinflictor, idattacker, id)
{
	
	if(!is_user_connected(idattacker)) 
		return HAM_IGNORED; 
	
	if(!ma_klase[idattacker]) 
		return HAM_IGNORED; 
		
	if(hitbox[id] == HIT_HEAD)
	{
		new cur_health = get_user_health(idattacker);
		new max_health = 100+cod_get_user_health(idattacker);
		new new_health = cur_health+50<max_health? cur_health+50: max_health;
		set_user_health(idattacker, new_health);
		
		return HAM_HANDLED;
	}
	
	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1041\\ f0\\ fs16 \n\\ par }
*/
