/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <codmod>
#include <fakemeta>
#include <colorchat>

#define CZAS_NOCLIP 10

new const nazwa[] = "Ghost Suit";
new const opis[] = "15 Seconds of No Clip";

new bool:uzyl[33];

new msg_bartime;

public plugin_init()
 {
	register_plugin(nazwa, "1.0", "Zazdrosny");
	
	cod_register_perk(nazwa, opis);
	
	register_event("ResetHUD", "ResetHUD", "abe");
	msg_bartime = get_user_msgid("BarTime");
}

public cod_perk_enabled(id)
{
	uzyl[id] = false;
}
	
public cod_perk_used(id)
{	
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;
		
	if(uzyl[id])
	{
		ColorChat(id, RED, "Already used up perk!");
		return PLUGIN_CONTINUE;
	}
	
	set_pev(id, pev_movetype, MOVETYPE_NOCLIP);
	set_bartime(id, CZAS_NOCLIP);
	set_task(CZAS_NOCLIP.0, "WylaczNoclip", id);
	uzyl[id] = true;
	
	return PLUGIN_CONTINUE;
}

public ResetHUD(id)
	uzyl[id] = false;
		
public WylaczNoclip(id)
{
	if(!is_user_connected(id))
		return;
		
	set_pev(id, pev_movetype, MOVETYPE_WALK);
	
	new Float:origin[3];
	
	pev(id, pev_origin, origin);
	
	if (!is_hull_vacant(origin, pev(id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, id))
		user_silentkill(id);
}

stock bool:is_hull_vacant(const Float:origin[3], hull,id) 
{
	static tr;
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr)
	if (!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid))
		return true;
	
	return false;
}

public set_bartime(id, czas)
{
	message_begin(MSG_ONE, msg_bartime, _, id);
	write_short(czas);
	message_end();
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
