#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
#include <colorchat>

new const nazwa[] = "Claes of Dawn";
new const opis[] = "Passive : 15% damage with all weapons. Active : No recoil, increase dmg output by 100% for 10 Seconds";
new const bronie = 1<<CSW_SG550 | 1<<CSW_SG552 | 1<<CSW_FIVESEVEN;
new const zdrowie = 30;
new const kondycja = 15;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new bool:ma_klase[33];
new bool:wykorzystal[33];
new uzycia_skilla[33];
new czas;

new Float:dmg_multi = 0.15;

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "MasamuneDate");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");

	register_event("ResetHUD", "ResetHUD", "abe");

	register_forward(FM_PlayerPreThink, "PreThink");
	register_forward(FM_UpdateClientData, "UpdateClientData", 1)
}

public cod_class_enabled(id)
{
	ColorChat(id, GREEN, "Created by MasamuneDate", nazwa);
	ma_klase[id] = true;
	wykorzystal[id] = false
	uzycia_skilla[id] = 1;
}

public cod_clas_disabled(id)
{
	ma_klase[id] = false;
	remove_task(id+43)
}

public client_disconnect(id)
{
	remove_task(id+43)
}

public cod_class_skill_used(id)
{
	if(task_exists(id+43))
	{
		return PLUGIN_CONTINUE
	}
	
	if(!uzycia_skilla[id])
	{
		ColorChat(id, RED, "Active skill can only be used once per round !");
		return PLUGIN_CONTINUE
		
	}
	uzycia_skilla[id]--
	
	czas = 10;	// Duration
	dmg_multi = 1.0;
	
	set_task(1.0, "QuadDamage", id+43, _, _, "a",czas);
	set_task(10.0, "Wylacz");
	message_begin(MSG_ONE,108,{0,0,0},id)
	write_short(czas)
	message_end()
	
	
	return PLUGIN_CONTINUE
}
public QuadDamage(id)
{
	id-=43
	czas--
}

public Wylacz()
{
	dmg_multi = 0.15;
}

public client_PreThink(id)
{
	if(!ma_klase[id])
		return;
	
	if(!is_user_alive(id))
		return;
	
	if(task_exists(id+43))
		set_pev(id, pev_punchangle, {0.0,0.0,0.0});	
}

public UpdateClientData(id, sw, cd_handle)
{
	if(!is_user_alive(id))
		return;
	
	if(ma_klase[id] && task_exists(id+43))
		set_cd(cd_handle, CD_PunchAngle, {0.0,0.0,0.0})
}

public ResetHUD(id) 
{
	wykorzystal[id] = false;
	uzycia_skilla[id] = 1;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits, id)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_klase[idattacker])
		cod_inflict_damage(idattacker, this, damage*dmg_multi, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
