#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>
#include <fun>
#include <colorchat>

#define GOD_TIME 2 //second

new bool:this_perk[33];
new bool:perk_used[33];

new msg_bartime;

public plugin_init()
{
	register_plugin("God's Crystal", "1.0", "Siveroo");
	cod_register_perk("God's Crystal", "Grants immortality for 2 seconds. [Immune to all type of damage]");
	register_event("ResetHUD", "ResetHUD", "abe");
	msg_bartime = get_user_msgid("BarTime");
}

public cod_perk_enabled(id)
{
	this_perk[id] = true;
	ColorChat(id, GREEN, "Created by Sivero", "God's Crystal");
	ResetHUD(id);
}

public cod_perk_disabled(id)
{
	this_perk[id] = false;
}

public cod_perk_used(id)
{
	if(!perk_used[id] == false){
		ColorChat(id, RED, "You already used your ability!");
		return COD_STOP;
	}
	if(!is_user_alive(id) == true){
		return COD_STOP;
	}
	
	set_user_godmode(id, 1)
	set_user_rendering(id,kRenderFxGlowShell,192,192,192,kRenderNormal,1)
	set_task(3.0, "disablegod", id);
	perk_used[id] = true
	
	
	message_begin(MSG_ONE, msg_bartime, _, id)
	write_short(GOD_TIME)
	message_end()
	
	return COD_CONTINUE;
}

public disablegod(id)
{
	set_user_godmode(id, 0);
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,1);
}

public ResetHUD(id)
{
	perk_used[id] = false;
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
