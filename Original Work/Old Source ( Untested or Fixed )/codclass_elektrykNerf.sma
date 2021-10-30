#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <codmod>
#include <engine>
#include <hamsandwich>

new sprite;
new ilosc_blyskawic[33],poprzednia_blyskawica[33];
new const gszSound[] = "ambience/thunder_clap.wav";

new const nazwa[] = "Elektryk";
new const opis[] = "3 Lightning charge, 8s CD. Deal 0.4 * Total Inteligence ( E to use )";
new const bronie = 1<<CSW_M4A1 | 1<<CSW_USP;
new const zdrowie = 14;
new const kondycja = 25;
new const inteligencja = 0;
new const wytrzymalosc = 35;

new ma_klase[33]

public plugin_init() {
	register_plugin(nazwa, "1.0", "piterka");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	register_event("ResetHUD", "ResetHUD", "abe");
}

public plugin_precache()
{
	sprite = precache_model("sprites/lgtning.spr");
	precache_sound(gszSound);
}

public cod_class_enabled(id)
{
	ilosc_blyskawic[id] = 3;
	ma_klase[id] = 1;

	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	ma_klase[id] = 0;
	ilosc_blyskawic[id] = 0;
}

public cod_class_skill_used(id) {

	if(!is_user_alive(id)) return PLUGIN_HANDLED;

	if(!ilosc_blyskawic[id]) {
		return PLUGIN_HANDLED;
	}
	new ofiara, body;
	get_user_aiming(id, ofiara, body);
	
	if(is_user_alive(ofiara)){
		if(get_user_team(ofiara) == get_user_team(id)) {
			return PLUGIN_HANDLED;
		}
		
		if(poprzednia_blyskawica[id]+8.0>get_gametime()) {
			client_print(id,print_chat,"Can be used after 8 Seconds");
			return PLUGIN_HANDLED;
		}
		poprzednia_blyskawica[id] = floatround(get_gametime());
		ilosc_blyskawic[id]--;

		puscBlyskawice(id, ofiara, 20.0, 0.5);
	}
	return PLUGIN_HANDLED;
}

stock Create_TE_BEAMENTS(startEntity, endEntity, iSprite, startFrame, frameRate, life, width, noise, red, green, blue, alpha, speed) {
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( TE_BEAMENTS )
	write_short( startEntity )        // start entity
	write_short( endEntity )        // end entity
	write_short( iSprite )            // model
	write_byte( startFrame )        // starting frame
	write_byte( frameRate )            // frame rate
	write_byte( life )                // life
	write_byte( width )                // line width
	write_byte( noise )                // noise amplitude
	write_byte( red )                // red
	write_byte( green )                // green
	write_byte( blue )                // blue
	write_byte( alpha )                // brightness
	write_byte( speed )                // scroll speed
	message_end()
}
puscBlyskawice(id, ofiara, Float:fObrazenia = 55.0, Float:fCzas = 1.0){
	//Obrazenia
	new ent = create_entity("info_target");
	entity_set_string(ent, EV_SZ_classname, "blyskawica");
	cod_inflict_damage(id, ofiara, fObrazenia, 0.4, ent, DMG_SHOCK);		// Damage / Inteligence ( 0.5 )
	
	remove_entity(ent);
	
	//Piorun
	Create_TE_BEAMENTS(id, ofiara, sprite, 0, 10, floatround(fCzas*10), 150, 5, 200, 200, 200, 200, 10);
	
	//Dzwiek
	emit_sound(id, CHAN_WEAPON, gszSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	emit_sound(ofiara, CHAN_WEAPON, gszSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}


public ResetHUD(id) {
	if(ma_klase[id] == 1) {	
		ilosc_blyskawic[id] = 3;
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
