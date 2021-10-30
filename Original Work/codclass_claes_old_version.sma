#include <amxmodx>
#include <engine>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <codmod>
#include <fun>
#include <ColorChat>
#include <dhudmessage>

#define DMG_BULLET (1<<1)

#define CZAS_GODMOD 5  // Rage Mode, Define how long

new const nazwa[] = "Claes Of Dawn";
new const opis[] = "5 Seconds of rage, While rage you have no recoil, +5 dmg with all weapon";
new const bronie = 1<<CSW_M4A1 | 1<<CSW_XM1014 | 1<<CSW_GLOCK18 ;
new const zdrowie = 10;
new const kondycja = 30;
new const inteligencja = 10;
new const wytrzymalosc = 15;

new msg_bartime;
new bool:wykorzystal[33];
new bool:bonus[33];
new bool:ma_klase[33];

public plugin_init() 
{
		register_plugin(nazwa, "1.0", "MasamuneDate");
		cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
		RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
		register_event("ResetHUD", "ResetHUD", "abe");  
		msg_bartime = get_user_msgid("BarTime");
		register_forward(FM_UpdateClientData, "UpdateClientData", 1);
		register_forward(FM_PlayerPreThink, "PreThink");	
}

public cod_class_enabled(id)
{
	bonus[id] = false;
	ResetHUD(id);
	ma_klase[id] = true;
	ColorChat(id, GREEN, "Create by MasamuneDate, facebook.com/davin.widjaya, natdavin@gmail.com", nazwa);
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
	bonus[id] = false;
}

public cod_class_skill_used(id)
{
	if(!is_user_alive(id))
	return;
	if(wykorzystal[id])
     {
	ColorChat(id, RED, "Skill Has been Used.");
	return;
     }
	wykorzystal[id] = true;
	bonus[id] = true;
	set_task(CZAS_GODMOD.0, "WylaczGod", id);
	message_begin(MSG_ONE, msg_bartime, _, id)
	write_short(CZAS_GODMOD)
	message_end()

}

public WylaczGod(id)
{
	if(!is_user_connected(id) || !ma_klase[id]) return;
	bonus[id]=false;
}

public ResetHUD(id)
{
        if(ma_klase[id])
        wykorzystal[id] = false;
}

public PreThink(id)
{
	if(!is_user_connected(id))
		return;	
	if(!ma_klase[id])
		return;
	if(!bonus[id])
		return;
	set_pev(id, pev_punchangle, {0.0,0.0,0.0})
}
        
public UpdateClientData(id, sw, cd_handle)
{
	if(!is_user_connected(id))
		return;	
	if(!ma_klase[id])
		return;
	if(!bonus[id])
		return;
	set_cd(cd_handle, CD_PunchAngle, {0.0,0.0,0.0})   
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(ma_klase[idattacker])
		cod_inflict_damage(idattacker, this, 5.0, 0.0, idinflictor, damagebits); //lepiej uzyc sethamparamfloat

	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
