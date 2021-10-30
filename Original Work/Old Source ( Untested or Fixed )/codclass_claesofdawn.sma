#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <codmod>
#include <colorchat>

#define CZAS 8 //SEKUND NIEWIDZIALNOSCI

new const nazwa[] = "Claes of Dawn";
new const opis[] = "Passive : 15% damage with all weapons. Active : No recoil, increase dmg output by 100% for 8 Seconds";
new const bronie = 1<<CSW_SG550 | 1<<CSW_SG552 | 1<<CSW_FIVESEVEN;
new const zdrowie = 30;
new const kondycja = 15;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new bool:wykorzystal[33];
new bool:ma_klase[33];

new Float:dmg_multi = 0.15;
new bool:flag[33];

new msg_bartime;

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "MasamuneDate");   
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);    
	register_event("ResetHUD", "ResetHUD", "abe");    
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");    
	msg_bartime = get_user_msgid("BarTime");
	
	register_forward(FM_PlayerPreThink, "PreThink");
	register_forward(FM_UpdateClientData, "UpdateClientData", 1)
}

public cod_class_enabled(id)
{
	ColorChat(id, GREEN, "Created by MasamuneDate", nazwa);
	ma_klase[id] = true;
	ResetHUD(id);
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
}

public cod_class_skill_used(id)
{
	if(!is_user_alive(id))
	return;
        
	if(wykorzystal[id])
	{
	ColorChat(id, RED, "Skill already used this round !");
	return;
	}
    
    
	dmg_multi = 1.0;
	set_task(CZAS.0, "Wylacz", id);
    
	message_begin(MSG_ONE, msg_bartime, _, id)
	write_short(CZAS)
	message_end()
}

public Wylacz(id)
{
	flag[id] = false;
	dmg_multi = 0.15;
}

public ResetHUD(id)
{
	if(ma_klase[id])
	wykorzystal[id] = false;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits, id)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_klase[idattacker])
	
	if(flag[id] != false)
		cod_inflict_damage(idattacker, this, damage*dmg_multi, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}

public PreThink(id)
{
	if(ma_klase[id] && flag[id])
		set_pev(id, pev_punchangle, {0.0,0.0,0.0})
}
		
public UpdateClientData(id, sw, cd_handle)
{
	if(ma_klase[id] && flag[id])
		set_cd(cd_handle, CD_PunchAngle, {0.0,0.0,0.0})   
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1057\\ f0\\ fs16 \n\\ par }
*/
