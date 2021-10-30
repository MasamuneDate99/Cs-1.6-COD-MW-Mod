#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <codmod>
#include <colorchat>
#include <engine>
#include <cstrike>
#include <amxmisc>

#define CZAS 5

new const name[] = "Vampire Claw";
new const desc[] = "Passive : 20% Lifesteal. Active : Increase lifesteal to 200% for 5 Seconds";

new bool:wykorzystal[33];
new bool:ma_perk[33];
new player_b_vampire[33];

new msg_bartime;

public plugin_init() 
{
        register_plugin(name, "1.0", "MasamuneDate");   
        cod_register_perk(name, desc);    
        register_event("ResetHUD", "ResetHUD", "abe");    
        register_event("Damage", "Damage", "b", "2!0")
        msg_bartime = get_user_msgid("BarTime");
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	player_b_vampire[id] = 20;
	ColorChat(id, GREEN, "Created by MasamuneDate", name);
	ResetHUD(id);
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
}

public cod_class_skill_used(id)
{
	if(!is_user_alive(id))
	return;
        
	if(wykorzystal[id])
	{
		ColorChat(id, RED, "Lifesteal boost can only be used once per round !");
	return;
	}
    
	wykorzystal[id] = true;
    
	player_b_vampire[id] = 200;
	set_task(CZAS.0, "Wylacz", id);
    
	message_begin(MSG_ONE, msg_bartime, _, id)
	write_short(CZAS)
	message_end()
}

public Wylacz(id)
{
	if(!is_user_connected(id)) return;
	player_b_vampire[id] = 20;
}

public ResetHUD(id)
{
        if(ma_perk[id])
        wykorzystal[id] = false;
}

public Damage(id){
	if (is_user_connected(id)){
		new damage = read_data(2)
		new weapon
		new bodypart
		new attacker_id = get_user_attacker(id,weapon,bodypart) 
		if (is_user_connected(attacker_id) && attacker_id != id)
		add_vampire_bonus(id,damage,attacker_id)
	}
}

public add_vampire_bonus(id,damage,attacker_id){
	
	if (player_b_vampire[attacker_id] > 0){
		new maxhealth = 100+cod_get_user_health(attacker_id,1,1,1)
		if (get_user_health(attacker_id)+player_b_vampire[attacker_id] <= maxhealth){
			
			set_user_health(attacker_id,get_user_health(attacker_id)+player_b_vampire[attacker_id])
		} 
		else{
			set_user_health(attacker_id,maxhealth)
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1057\\ f0\\ fs16 \n\\ par }
*/
