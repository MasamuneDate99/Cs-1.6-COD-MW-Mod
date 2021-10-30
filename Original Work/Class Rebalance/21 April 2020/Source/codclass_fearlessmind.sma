#include <amxmodx>
#include <engine>
#include <fakemeta> 
#include <fun>
#include <cstrike>
#include <amxmisc>
#include <codmod>
#include <colorchat>
#include <hamsandwich>

new const nazwa[]	= "Fearless Mind";
new const opis[]	= "Heal you 15% of damage dealt, additional 20% dmg";
new const bronie	= 1<<CSW_AK47 | 1<<CSW_FIVESEVEN | 1<<CSW_M4A1 ;
new const zdrowie	= 20;
new const kondycja	= 10;
new const inteligencja	= 0;
new const wytrzymalosc	= 30;

new bool: ma_klase [33];
new player_b_vampire[33] = 0;

public plugin_init() {
	register_plugin(nazwa, "1.0", "MasamuneDate");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);	
	register_event("Damage", "Damage", "b", "2!0")
}

public cod_class_enabled(id){
	ma_klase[id] = true;
	ColorChat(id, GREEN, "Created by MasamuneDate", nazwa);
	player_b_vampire[id] = 20;   // Lifesteal amount
}

public cod_class_disabled(id){
	player_b_vampire[id] = 0;
	ma_klase[id] = false;
}	

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_klase[idattacker])
		cod_inflict_damage(idattacker, this, damage*0.2, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
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
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1041\\ f0\\ fs16 \n\\ par }
*/
