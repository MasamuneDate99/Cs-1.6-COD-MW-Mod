#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <engine>
#include <fakemeta>
#include <codmod>
#include <colorchat>
#include <hamsandwich>

#define TASK_ROCKET 6740100
#define TASK_BOMB 6760200
#define VERSION "1.2.2"

new const nazwa[] = "Special Unit";
new const opis[] = "Say /mount to create Apache, and say /unmount di disasamble, Nightvision for Stealth Mode. You have 2 Apache";
new const bronie = 1<<CSW_FLASHBANG | 1<<CSW_HEGRENADE | 1<<CSW_SMOKEGRENADE;
new const zdrowie = 0;
new const kondycja = 0;
new const inteligencja = 0;
new const wytrzymalosc = 50;

new bool:ma_klase[33];
new ilosc_uzyc[33];

new apaches[33], camera[33], apache_speed[33], grabbed[33]
new smoke, boom, laserbeam
new maxplayers, maxentities
new bool:wait_rocket[33], bool:wait_bomb[33], bool:wait_stealth[33], stealth[33]
new gmsgNVGToggle
new g_apacheactive = 0

new active,health,maxspeed2,stealthamt,stealthspeed,stealthregen,bulletdmg,bulletspeed;
new rocketspeed,distance,height,beams,cost,ff,c_ilosc_uzyc;

public plugin_init()
{
	register_plugin(nazwa, VERSION, "SeeK")
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_clcmd("say /mount", "create_apache")
	register_clcmd("say /unmount", "destroy_apache")
	
	register_clcmd("drop", "stop_apache")
	register_clcmd("nightvision", "stealth_mode")
	
	active =           register_cvar("apache_active", "1")
	health =           register_cvar("apache_health", "300")
	maxspeed2 =         register_cvar("apache_maxspeed", "500")
	stealthamt =       register_cvar("apache_stealth_amount", "100")
	stealthspeed =    register_cvar("apache_stealth_maxspeed", "350")
	stealthregen =    register_cvar("apache_stealth_regen", "10")
	bulletdmg =        register_cvar("apache_bulletdmg", "10")
	bulletspeed =     register_cvar("apache_bulletspeed", "2000")
	rocketspeed =     register_cvar("apache_rocketspeed", "1000")
	distance =         register_cvar("apache_dist", "70")
	height =           register_cvar("apache_height", "20")
	beams =            register_cvar("apache_beams", "0")
	cost =             register_cvar("apache_cost", "0")
	ff =              register_cvar("apache_ff", "0")
	c_ilosc_uzyc = 	register_cvar("apache_max_use", "1")
	
	register_event("DeathMsg", "death_event", "a")
	register_event("ResetHUD", "resethud_event", "be") //bad
	register_event("CurWeapon", "check_weapon", "be", "1=1")
	register_logevent("new_round", 2, "0=World triggered", "1=Round_Start")
	register_event("TextMsg", "game_restart", "a", "1=4", "2&#Game_C", "2&#Game_w")
	register_event("SendAudio", "round_end", "a", "2=%!MRAD_terwin", "2=%!MRAD_ctwin", "2=%!MRAD_rounddraw")
	register_forward(FM_EmitSound,"emitsound",0)
	
	maxplayers = get_maxplayers() + 1
	maxentities = get_global_int(GL_maxEntities)
	
	gmsgNVGToggle = get_user_msgid("NVGToggle")
}

public cod_class_enabled(id)
{
	ma_klase[id] = true
	
	return COD_CONTINUE;
}

public cod_class_disabled(id)
	ma_klase[id] = false
	
public client_connect(id)
{		
	if(task_exists(54545454+id))
	{
		remove_task(54545454+id)
	}
	ilosc_uzyc[id] = c_ilosc_uzyc
	apaches[id] = 0
	camera[id] = 0
	grabbed[id] = 0
	wait_rocket[id] = false
	wait_bomb[id] = false
	wait_stealth[id] = false
	stealth[id] = false
}

public client_disconnect(id)
{
	if(task_exists(54545454+id))
	{
		remove_task(54545454+id)
	}
	if(apaches[id] > 0)
	{
		emit_sound(apaches[id], CHAN_VOICE, "vox/_period.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
		remove_entity(apaches[id])
		apaches[id] = 0
	}
	if(camera[id] > 0)
	{
		remove_entity(camera[id])
		camera[id] = 0
	}
	grabbed[id] = 0
	wait_rocket[id] = false
	wait_bomb[id] = false
	wait_stealth[id] = false
	stealth[id] = false
}

public new_round()
{
	for(new i = 1; i < 33; ++i)
		ilosc_uzyc[i] = c_ilosc_uzyc
		
	new ent
	while((ent = find_ent_by_class(ent,"apache_bullet")) != 0)
		remove_entity(ent)
	
	ent = find_ent_by_class(-1, "apache_rocket")
	new tempent
	while(ent > 0)
	{
		tempent = find_ent_by_class(ent, "apache_rocket")
		emit_sound(ent, CHAN_WEAPON, "vox/_period.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
		//emit_sound(ent, CHAN_VOICE, "vox/_period.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
		remove_entity(ent)
		ent = tempent
	}
	set_task(0.1, "set_speed", 875457545)
}

public round_end()
{
	set_task(4.0, "disable_sound", 212454212)
}

public game_restart()
{
	set_task(0.5, "disable_sound", 787454241)
}

public disable_sound()
{
	new players[32], inum, player
	get_players(players, inum, "a")
	for(new i = 0 ; i < inum ; i++)
	{
		player = players[i]
		if(apaches[player] > 0)
		{
			emit_sound(apaches[player], CHAN_VOICE, "vox/_period.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
		}
	}
}

public death_event()
{
	g_apacheactive = get_pcvar_num(active)
	new id = read_data(2)
	
	if(task_exists(54545454+id))
	{
		remove_task(54545454+id)
	}
	if(apaches[id] > 0)
	{
		emit_sound(apaches[id], CHAN_VOICE, "vox/_period.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
		remove_entity(apaches[id])
		apaches[id] = 0
	}
	if(camera[id] > 0)
	{
		attach_view(id, id)
		remove_entity(camera[id])
		camera[id] = 0
	}
	for(new i = 1 ; i < maxplayers ; i++)
	{
		if(grabbed[i] == id)
		{
			grabbed[i] = 0
		}
	}
	grabbed[id] = 0
	wait_rocket[id] = false
	wait_bomb[id] = false
	wait_stealth[id] = false
	stealth[id] = false
	client_cmd(id, "-left")
	client_cmd(id, "-right")
	message_begin(MSG_ONE, gmsgNVGToggle, {0,0,0}, id)
	write_byte(0)
	message_end()
}

public resethud_event(id)
{	
	g_apacheactive = get_pcvar_num(active)
	if(task_exists(54545454+id))
	{
		remove_task(54545454+id)
	}
	if(apaches[id] > 0)
	{
		new Float:apachecost = get_pcvar_float(cost)
		new Float:apachehealth = get_pcvar_float(health)
		new Float:apachecurhealth = entity_get_float(apaches[id], EV_FL_health) - 5000
		new payback = floatround((apachecost * apachecurhealth) / apachehealth)
		cs_set_user_money(id, cs_get_user_money(id) + payback, 1)
		emit_sound(apaches[id], CHAN_VOICE, "vox/_period.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
		remove_entity(apaches[id])
		apaches[id] = 0
	}
	if(camera[id] > 0)
	{
		attach_view(id, id)
		remove_entity(camera[id])
		camera[id] = 0
	}
	grabbed[id] = 0
	wait_rocket[id] = false
	wait_bomb[id] = false
	wait_stealth[id] = false
	stealth[id] = false
	client_cmd(id, "-left")
	client_cmd(id, "-right")
	message_begin(MSG_ONE, gmsgNVGToggle, {0,0,0}, id)
	write_byte(0)
	message_end()
}

public check_weapon(id)
{
		
	if(apaches[id] > 0)
	{
		client_cmd(id, "weapon_knife")
		set_user_maxspeed(id, -1.0)
	}
}

public set_speed(id)
{
		
	new players[32], inum, player
	get_players(players, inum, "a")
	for(new i = 0 ; i < inum ; i++)
	{
		player = players[i]
		if(apaches[player] > 0)
		{
			set_user_maxspeed(player, -1.0)
		}
	}
}


public create_apache(id,level,cid)
{
	if(!ma_klase[id])
		return PLUGIN_CONTINUE;
	
	
	if(ilosc_uzyc[id] == 0)
	{
		console_print(id, "You can create only 2 helicopter per round.")
		client_print(id, print_center, "You can create only 2 helicopter per round.")
		return PLUGIN_HANDLED
	}
		
	if(get_pcvar_num(active) == 0)
	{
		console_print(id, "WARNING! AMX APACHE IS NOT TURN ON!")
		return PLUGIN_HANDLED
	}
	
	if(apaches[id] > 0)
	{
		console_print(id, "You just control the helicopter.")
		client_print(id, print_center, "You just control the helicopter.")
		return PLUGIN_HANDLED
	}
	
	if(!is_user_alive(id))
	{
		console_print(id, "You can not use a helicopter when you are dead.")
		client_print(id, print_center, "You can not use a helicopter when you are dead.")
		return PLUGIN_HANDLED
	}
	
	new apachecost = get_pcvar_num(cost)
	new usermoney = cs_get_user_money(id)
	if(usermoney < apachecost)
	{
		console_print(id, "You do not have enough money (you need $%i )", apachecost)
		client_print(id, print_center, "You do not have enough money (you need $%i )", apachecost)
		return PLUGIN_HANDLED
	}
	cs_set_user_money(id, usermoney - apachecost, 1)
	
	ilosc_uzyc[id]--;
	set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0);
	
	new Float:origin[3]
	new Float:angles[3]
	entity_get_vector(id, EV_VEC_origin, origin)
	entity_get_vector(id, EV_VEC_v_angle, angles)
	
	apaches[id] = create_entity("info_target")
	if(apaches[id] > 0)
	{
		entity_set_string(apaches[id], EV_SZ_classname, "amx_apache")
		entity_set_model(apaches[id], "models/rc_apache_final.mdl")
		
		entity_set_size(apaches[id], Float:{-12.0,-12.0,-6.0}, Float:{12.0,12.0,6.0})
		
		entity_set_origin(apaches[id], origin)
		entity_set_vector(apaches[id], EV_VEC_angles, angles)
		
		entity_set_int(apaches[id], EV_INT_solid, 2)
		entity_set_int(apaches[id], EV_INT_movetype, 5)
		entity_set_edict(apaches[id], EV_ENT_owner, id)
		entity_set_int(apaches[id], EV_INT_sequence, 1)
		entity_set_float(apaches[id], EV_FL_takedamage, DAMAGE_AIM)
		entity_set_float(apaches[id], EV_FL_health, get_pcvar_float(health) + 5000.0)
		
		apache_speed[id] = 50
		
		new Float:velocity[3]
		VelocityByAim(id, apache_speed[id], velocity)
		entity_set_vector(apaches[id], EV_VEC_velocity, velocity)
		
		emit_sound(apaches[id], CHAN_VOICE, "apache/ap_rotor2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
	}
	
	camera[id] = create_entity("info_target")
	if(camera[id] > 0)
	{
		entity_set_string(camera[id], EV_SZ_classname, "camera")
		entity_set_int(camera[id], EV_INT_solid, SOLID_NOT)
		entity_set_int(camera[id], EV_INT_movetype, MOVETYPE_NOCLIP)
		entity_set_size(camera[id], Float:{0,0,0}, Float:{0,0,0})
		entity_set_model(camera[id], "models/rpgrocket.mdl")
		set_rendering(camera[id], kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)
		
		entity_set_origin(camera[id], origin)
		entity_set_vector(camera[id], EV_VEC_angles, angles)
		
		attach_view(id, camera[id])
	}
	
	engclient_cmd(id, "weapon_knife")
	set_user_maxspeed(id, -1.0)
	
	if(task_exists(54545454+id))
	{
		remove_task(54545454+id)
	}
	
	grabbed[id] = 0
	wait_rocket[id] = false
	wait_bomb[id] = false
	wait_stealth[id] = false
	stealth[id] = false
	
	return PLUGIN_HANDLED
}

public destroy_apache(id,level,cid)
{
	if(!ma_klase[id])
		return PLUGIN_CONTINUE;
		
	if (!cmd_access(id,level,cid,1))
	{
		return PLUGIN_HANDLED
	}
	
	if(apaches[id] > 0)
	{
		attach_view(id, id)
		emit_sound(apaches[id], CHAN_VOICE, "vox/_period.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
		remove_entity(apaches[id])
		apaches[id] = 0
		set_user_maxspeed(id, 250.0)
	}
	if(camera[id] > 0)
	{
		attach_view(id, id)
		remove_entity(camera[id])
		camera[id] = 0
	}
	
	if(task_exists(54545454+id))
	{
		remove_task(54545454+id)
	}
	
	grabbed[id] = 0
	wait_rocket[id] = false
	wait_bomb[id] = false
	wait_stealth[id] = false
	stealth[id] = false
	client_cmd(id, "-left")
	client_cmd(id, "-right")
	
	message_begin(MSG_ONE, gmsgNVGToggle, {0,0,0}, id)
	write_byte(0)
	message_end()
	set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	
	return PLUGIN_HANDLED
}

public stop_apache(id)
{	
	if(!ma_klase[id])
		return PLUGIN_CONTINUE;
	if(apaches[id] > 0)
	{
		if(apache_speed[id] <= 30 && apache_speed[id] >= -30)
		{
			apache_speed[id] = 0
		}
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public stealth_mode(id)
{	
	if(!ma_klase[id])
		return PLUGIN_CONTINUE;	
	if(apaches[id] > 0)
	{
		if(!wait_stealth[id])
		{
			if(!stealth[id])
			{
				stealth[id] = true
				emit_sound(apaches[id], CHAN_VOICE, "apache/ap_rotor2.wav", 0.1, ATTN_NORM, 0, PITCH_NORM)
				set_rendering(apaches[id], kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, get_pcvar_num(stealthamt))
				message_begin(MSG_ONE, gmsgNVGToggle, {0,0,0}, id)
				write_byte(1)
				message_end()
			}
			else
			{
				stealth[id] = false
				emit_sound(apaches[id], CHAN_VOICE, "apache/ap_rotor2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
				set_rendering(apaches[id])
				message_begin(MSG_ONE, gmsgNVGToggle, {0,0,0}, id)
				write_byte(0)
				message_end()
				wait_stealth[id] = true
				new ids[1]
				ids[0] = id
				set_task(get_pcvar_float(stealthregen), "reset_stealth", 54545454+id, ids, 1)
			}
		}
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public client_PreThink(id)
{
	if(!ma_klase[id])
		return PLUGIN_CONTINUE;
		
	if(!(apaches[id] > 0))
	{
		set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	}
	if(g_apacheactive == 0)
	{
		return PLUGIN_CONTINUE
	}
	
	if(is_user_alive(id) && apaches[id] > 0 && camera[id] > 0)
	{
		new Float:forigin[3], Float:dist_origin[3], Float:camera_origin[3]
		new button, oldbutton
		new apacheId = apaches[id]
		new maxspeed
		new Float:frame
		new apache_maxspeed = get_pcvar_num(maxspeed2)
		new apache_stealth_maxspeed = get_pcvar_num(stealthspeed)
		new Float:angles[3], Float:velocity[3]
		new Float:apache_height = get_pcvar_float(height)
		new apache_bulletspeed = get_pcvar_num(bulletspeed)
		new apache_rocketspeed = get_pcvar_num(rocketspeed)
		new classname[32]
		new Float:aim_origin[3], Float:end_origin[3]
		new apache_beams = get_pcvar_num(beams)
		if(entity_get_float(apacheId, EV_FL_health) < 5000)
		{
			new Float:explosion[3]
			entity_get_vector(apacheId, EV_VEC_origin, explosion)
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(3)
			write_coord(floatround(explosion[0]))
			write_coord(floatround(explosion[1]))
			write_coord(floatround(explosion[2]))
			write_short(boom)
			write_byte(50)
			write_byte(15)
			write_byte(0)
			message_end()
			
			HL_RadiusDamage(explosion,0,75.0,150.0)
			/*radius_damage(explosion,75,200)*/
			
			attach_view(id, id)
			if(camera[id] > 0)
			{
				remove_entity(camera[id])
				camera[id] = 0
			}
			emit_sound(apacheId, CHAN_VOICE, "vox/_period.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
			remove_entity(apacheId)
			apaches[id] = 0
			set_user_maxspeed(id, 250.0)
			if(task_exists(54545454+id))
			{
				remove_task(54545454+id)
			}
			wait_rocket[id] = false
			wait_stealth[id] = false
			stealth[id] = false
			client_cmd(id, "-left")
			client_cmd(id, "-right")
			message_begin(MSG_ONE, gmsgNVGToggle, {0,0,0}, id)
			write_byte(0)
			message_end()
			return PLUGIN_CONTINUE
		}
		
		frame = entity_get_float(apacheId, EV_FL_frame)
		if(frame < 0.0 || frame > 254.0)
		{
			entity_set_float(apacheId, EV_FL_frame, 0.0)
		}
		else
		{
			entity_set_float(apacheId, EV_FL_frame, frame + 1.0)
		}
		
		entity_get_vector(apacheId, EV_VEC_origin, forigin)
		button = get_user_button(id)
		if(button & IN_FORWARD)
		{
			apache_speed[id] += 5
		}
		if(button & IN_BACK)
		{
			apache_speed[id] -= 5
		}
		if(!stealth[id])
		{
			maxspeed = apache_maxspeed
		}
		else
		{
			maxspeed = apache_stealth_maxspeed
		}
		if(apache_speed[id] > maxspeed)
		{
			apache_speed[id] = maxspeed
		}
		if(apache_speed[id] < - 80)
		{
			apache_speed[id] = - 80
		}
		
		entity_get_vector(apacheId, EV_VEC_origin, forigin)
		entity_get_vector(id, EV_VEC_v_angle, angles)
		angles[0] = - angles[0]
		VelocityByAim(id, apache_speed[id], velocity)
		entity_set_vector(apacheId, EV_VEC_angles, angles)
		entity_set_vector(apacheId, EV_VEC_velocity, velocity)
		
		oldbutton = get_user_oldbutton(id)
		if(button & IN_JUMP)
		{
			forigin[2] += 2.0
			if(PointContents(forigin) != CONTENTS_SOLID)
			{
				entity_set_origin(apacheId, forigin)
			}
		}
		if(button & IN_DUCK)
		{
			forigin[2] -= 2.0
			if(PointContents(forigin) != CONTENTS_SOLID)
			{
				entity_set_origin(apacheId, forigin)
			}
		}
		
		if(PointContents(forigin) == CONTENTS_SOLID)
		{
			forigin[2] += 10.0
			if(PointContents(forigin) == CONTENTS_SOLID)
			{
				forigin[2] -= 60.0
			}
			entity_set_origin(apacheId, forigin)
		}
		
		VelocityByAim(id, get_pcvar_num(distance), dist_origin)
		camera_origin[0] = forigin[0] - dist_origin[0]
		camera_origin[1] = forigin[1] - dist_origin[1]
		camera_origin[2] = forigin[2] + apache_height
		entity_set_origin(camera[id], camera_origin)
		angles[0] = - angles[0]
		entity_set_vector(camera[id], EV_VEC_angles, angles)
		
		if(button & IN_ATTACK && !(oldbutton & IN_ATTACK) && get_num_ents() < (maxentities - 50))
		{
			emit_sound(apacheId, CHAN_WEAPON, "weapons/m249-1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
			
			new ent = create_entity("info_target")
			if(ent > 0)
			{
				entity_set_string(ent, EV_SZ_classname, "apache_bullet")
				entity_set_model(ent, "models/shell.mdl")
				
				entity_set_size(ent, Float:{-1.0,-1.0,-1.0}, Float:{1.0,1.0,1.0})
				
				entity_set_origin(ent, forigin)
				entity_set_vector(ent, EV_VEC_angles, angles)
				
				entity_set_int(ent, EV_INT_solid, 1)
				entity_set_int(ent, EV_INT_movetype, 5)
				entity_set_edict(ent, EV_ENT_owner, id)
				
				VelocityByAim(id, apache_bulletspeed, velocity)
				entity_set_vector(ent, EV_VEC_velocity, velocity)
				
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
				write_byte(22)
				write_short(ent)
				write_short(smoke)
				write_byte(25)
				write_byte(1)
				write_byte(255)
				write_byte(255)
				write_byte(255)
				write_byte(128)
				message_end()
			}
		}
		if(button & IN_ATTACK2 && !wait_rocket[id] && get_num_ents() < (maxentities - 50))
		{
			new ent = create_entity("info_target")
			if(ent > 0)
			{
				entity_set_string(ent, EV_SZ_classname, "apache_rocket")
				entity_set_model(ent, "models/rpgrocket.mdl")
				
				entity_set_size(ent, Float:{-1.0,-1.0,-1.0}, Float:{1.0,1.0,1.0})
				
				entity_set_origin(ent, forigin)
				entity_set_vector(ent, EV_VEC_angles, angles)
				
				entity_set_int(ent, EV_INT_effects, 64)
				entity_set_int(ent, EV_INT_solid, 1)
				entity_set_int(ent, EV_INT_movetype, 5)
				entity_set_edict(ent, EV_ENT_owner, id)
				
				VelocityByAim(id, apache_rocketspeed, velocity)
				entity_set_vector(ent, EV_VEC_velocity, velocity)
				
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
				write_byte(22)
				write_short(ent)
				write_short(smoke)
				write_byte(40)
				write_byte(4)
				write_byte(255)
				write_byte(0)
				write_byte(0)
				write_byte(128)
				message_end()
				
				emit_sound(ent, CHAN_WEAPON, "weapons/rocketfire1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
				//emit_sound(ent, CHAN_VOICE, "weapons/rocket1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
			}
			wait_rocket[id] = true
			set_task(2.0, "reset_rocket", id+TASK_ROCKET)
		}
		if(button & IN_RELOAD && !wait_bomb[id] && grabbed[id] == 0 && get_num_ents() < (maxentities - 50))
		{
			new ent = create_entity("info_target")
			if(ent > 0)
			{
				entity_set_string(ent, EV_SZ_classname, "apache_bomb")
				entity_set_model(ent, "models/rpgrocket.mdl")
				
				entity_set_size(ent, Float:{-1.0,-1.0,-1.0}, Float:{1.0,1.0,1.0})
				
				entity_set_origin(ent, forigin)
				entity_set_vector(ent, EV_VEC_angles, angles)
				
				entity_set_int(ent, EV_INT_solid, 1)
				entity_set_int(ent, EV_INT_movetype, 6)
				entity_set_edict(ent, EV_ENT_owner, id)
			}
			wait_bomb[id] = true
			set_task(4.0, "reset_bomb", id+TASK_BOMB)
		}
		if(button & IN_USE && !(oldbutton & IN_USE))
		{
			if(grabbed[id] == 0)
			{
				new Float:ent_origin[3]
				new ent = find_ent_in_sphere(-1, forigin, 60.0)
				while(ent > 0 && grabbed[id] == 0)
				{
					classname[0] = '^0'
					entity_get_string(ent, EV_SZ_classname, classname, 31)
					if(equal(classname, "player") || equal(classname, "grenade") || equal(classname, "weaponbox") || equal(classname, "armoury_entity") || equal(classname, "hostage_entity"))
					{
						entity_get_vector(ent, EV_VEC_origin, ent_origin)
						if(ent_origin[2] < forigin[2])
						{
							grabbed[id] = ent
							if(equal(classname, "hostage_entity"))
							{
								entity_set_int(apacheId, EV_INT_solid, 3)
							}
						}
					}
					ent = find_ent_in_sphere(ent, forigin, 60.0)
				}
			}
			else
			{
				classname[0] = '^0'
				if(is_valid_ent(grabbed[id])) {
					entity_get_string(grabbed[id], EV_SZ_classname, classname, 31)
					if(!equal(classname, "player"))
					{
						entity_set_vector(grabbed[id], EV_VEC_velocity, Float:{0,0,-20})
					}
				}
				grabbed[id] = 0
				entity_set_int(apacheId, EV_INT_solid, 2)
			}
		}
		if(button & IN_MOVELEFT)
		{
			client_cmd(id, "+left")
		}
		else if(oldbutton & IN_MOVELEFT)
		{
			client_cmd(id, "-left")
		}
		if(button & IN_MOVERIGHT)
		{
			client_cmd(id, "+right")
		}
		else if(oldbutton & IN_MOVERIGHT)
		{
			client_cmd(id, "-right")
		}
		if(apache_beams == 1)
		{
			VelocityByAim(id, 9999, velocity)
			end_origin[0] = forigin[0] + velocity[0]
			end_origin[1] = forigin[1] + velocity[1]
			end_origin[2] = forigin[2] + velocity[2]
			trace_line(0, forigin, end_origin, aim_origin)
			message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0,0,0}, id)
			write_byte(1)
			write_short(apacheId)
			write_coord(floatround(aim_origin[0]))
			write_coord(floatround(aim_origin[1]))
			write_coord(floatround(aim_origin[2]))
			write_short(laserbeam)
			write_byte(1)
			write_byte(1)
			write_byte(1)
			write_byte(8)
			write_byte(0)
			write_byte(255)
			write_byte(0)
			write_byte(0)
			write_byte(128)
			write_byte(0)
			message_end()
		}
		if(grabbed[id] > 0 && is_valid_ent(grabbed[id]))
		{
			new Float:direction[3], Float:moveto[3], Float:grabbedorigin[3], Float:length
			VelocityByAim(id, 9999, velocity)
			end_origin[0] = forigin[0] + velocity[0]
			end_origin[1] = forigin[1] + velocity[1]
			end_origin[2] = forigin[2] + velocity[2]
			trace_line(0, forigin, end_origin, aim_origin)
			
			entity_get_vector(grabbed[id], EV_VEC_origin, grabbedorigin)
			
			direction[0] = aim_origin[0] - forigin[0]
			direction[1] = aim_origin[1] - forigin[1]
			direction[2] = aim_origin[2] - forigin[2]
			
			length = vector_distance(aim_origin,forigin)
			if (!length) length = 1.0
			
			moveto[0] = forigin[0] + direction[0] / length
			moveto[1] = forigin[1] + direction[1] / length
			classname[0] = '^0'
			entity_get_string(grabbed[id], EV_SZ_classname, classname, 31)
			if(equal(classname, "player"))
			{
				moveto[2] = (forigin[2] + direction[2] / length) - 45.0
				velocity[0] = (moveto[0] - grabbedorigin[0]) * 5
				velocity[1] = (moveto[1] - grabbedorigin[1]) * 5
				velocity[2] = (moveto[2] - grabbedorigin[2]) * 5
			}
			else
			{
				moveto[2] = (forigin[2] + direction[2] / length) - 15.0
				velocity[0] = (moveto[0] - grabbedorigin[0]) * 10
				velocity[1] = (moveto[1] - grabbedorigin[1]) * 10
				velocity[2] = (moveto[2] - grabbedorigin[2]) * 10
			}
			
			entity_set_vector(grabbed[id], EV_VEC_velocity, velocity)
		}
		set_hudmessage(255, 255, 255, -2.0, 0.76, 0, 1.0, 0.01, 0.1, 0.2, 4)
		show_hudmessage(id, " [APACHE] Speed: %i, Health: %i", apache_speed[id], floatround(entity_get_float(apaches[id], EV_FL_health) - 5000))
	}
	
	return PLUGIN_CONTINUE
}

public reset_rocket(id)
{	
	wait_rocket[id-TASK_ROCKET] = false
}

public reset_bomb(id)
{	
	wait_bomb[id-TASK_BOMB] = false
}

public reset_stealth(ids[])
{
	wait_stealth[ids[0]] = false
}

public pfn_touch(entity1, entity2)
{
	if(g_apacheactive == 0)
	{
		return PLUGIN_CONTINUE
	}
	
	if(entity1 > 0 && is_valid_ent(entity1))
	{
		new classname[32]
		entity_get_string(entity1, EV_SZ_classname, classname, 31)
		new classname2[32]
		if(entity2 > 0 && is_valid_ent(entity2))
		{
			entity_get_string(entity2, EV_SZ_classname, classname2, 31)
		}
		
		new attacker = entity_get_edict(entity1, EV_ENT_owner)
		
		if(!ma_klase[attacker])
			return PLUGIN_CONTINUE;
		
		if((equal(classname, "apache_rocket") || equal(classname, "apache_bomb")) && (entity2 == 0 || equal(classname2, "player") || equal(classname2, "amx_apache") || equal(classname2, "apache_rocket") || equal(classname2, "func_breakable") || equal(classname2, "func_pushable")))
		{
			if(entity2 > 0)
			{
				if(attacker == entity_get_edict(entity2, EV_ENT_owner))
				{
					return PLUGIN_CONTINUE
				}
			}
			
			new Float:explosion[3]
			entity_get_vector(entity1, EV_VEC_origin, explosion)
			
			if(!stealth[attacker])
			{
				/*radius_damage(explosion,200,300)*/
				HL_RadiusDamage(explosion,0,100.0,120.0)
			}
			else
			{
				/*radius_damage(explosion,120,300)*/
				HL_RadiusDamage(explosion,0,120.0,80.0)
			}
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(3)
			write_coord(floatround(explosion[0]))
			write_coord(floatround(explosion[1]))
			write_coord(floatround(explosion[2]))
			write_short(boom)
			write_byte(50)
			write_byte(15)
			write_byte(0)
			message_end()
			
			emit_sound(entity1, CHAN_WEAPON, "vox/_period.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
			//emit_sound(entity1, CHAN_VOICE, "vox/_period.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
			
			remove_entity(entity1)
		}
		if(equal(classname, "apache_bullet"))
		{
			if(equal(classname2, "player") || equal(classname2, "amx_apache") || equal(classname2, "func_breakable") || equal(classname2, "func_pushable"))
			{
				if(entity2 > 0)
				{
					if(attacker == entity_get_edict(entity2, EV_ENT_owner))
					{
						return PLUGIN_CONTINUE
					}
					if(equal(classname2, "func_breakable") || equal(classname2, "func_pushable"))
					{
						force_use(entity2, attacker)
					}
					else
					{
						new Float:origin[3]
						entity_get_vector(entity2, EV_VEC_origin, origin)
						cod_inflict_damage( attacker, entity2, get_pcvar_float(bulletdmg) + 5.0, 1.0, CSW_KNIFE, (1<<24))
					}
				}
			}
			
			remove_entity(entity1)
		}
		if(equal(classname, "amx_apache"))
		{
			if(equal(classname2, "player") || equal(classname2, "amx_apache") || equal(classname2, "func_breakable") || equal(classname2, "func_pushable"))
			{
				
				if(equal(classname2, "player") || equal(classname2, "amx_apache"))
				{
					new friendlyfire = get_pcvar_num(ff);
					if((friendlyfire == 1 || friendlyfire == 0 && get_user_team(attacker) != get_user_team(entity2)))
					{
						new Float:origin[3]
						entity_get_vector(entity2, EV_VEC_origin, origin)
						if(equal(classname2, "player") && get_user_health(entity2) == 1)
						{
							client_print(entity2, print_center, "NEVER STAND IN THE ROTORS AGAIN!")
						}
						cod_inflict_damage( attacker, entity2, 1.0, 1.0, entity2, (1<<24))
					}
				}
				else if(equal(classname2, "func_breakable") || equal(classname2, "func_pushable"))
				{
					force_use(entity2, attacker)
				}
			}
		}
	}
	
	return PLUGIN_CONTINUE
}

public emitsound(entity, const sample[])
{
	if(equal(sample, "common/wpn_denyselect.wav"))
	{
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public plugin_precache()
{
	laserbeam = precache_model("sprites/laserbeam.spr")
	smoke = precache_model("sprites/smoke.spr")
	boom = precache_model("sprites/zerogxplode.spr")
	
	precache_model("models/rc_apache_final.mdl")
	precache_model("models/rpgrocket.mdl")
	precache_model("models/shell.mdl")
	
	precache_sound("vox/_period.wav")
	precache_sound("weapons/rocketfire1.wav")
	precache_sound("weapons/rocket1.wav")
	precache_sound("weapons/m249-1.wav")
	precache_sound("apache/ap_rotor2.wav")
}

public get_num_ents()
{
	new i, count;
	for(i=1;i<maxentities;i++)
	{
		if(is_valid_ent(i))
			count++
	}
	return count;
}

///////////////// THANKS AVALANCHE!! ///////////////////

public HL_RadiusDamage( Float:vecSrc[3], /*pevAttacker,*/ pevInflictor, Float:flDamage, Float:flRadius/*, iClassIgnore, bitsDamageType*/ )
{
	new pEntity;
	new tr;
	new Float:flAdjustedDamage, Float:falloff;
	new Float:vecSpot[3];
	
	// NEW
	new Float:vecAbsMin[3], Float:vecAbsMax[3], Float:vecAdjust[3],
	Float:vecEndPos[3], Float:flFraction, iWaterLevel, i;
	
	if( flRadius )
		falloff = flDamage / flRadius;
	else
		falloff = 1.0;
	
	new bInWater = (engfunc( EngFunc_PointContents, vecSrc ) == CONTENTS_WATER);
	
	vecSrc[2] += 1;// in case grenade is lying on the ground
	
	// iterate on all entities in the vicinity.
	while ((pEntity = engfunc( EngFunc_FindEntityInSphere, pEntity, vecSrc, flRadius )) != 0)
	{
		if ( pev( pEntity, pev_takedamage ) != DAMAGE_NO )
		{
			iWaterLevel = pev( pEntity, pev_waterlevel ); // NEW
			
			// blasts don't travel into or out of water
			if (bInWater && iWaterLevel == 0)
				continue;
			if (!bInWater && iWaterLevel == 3)
				continue;
			
			// OLD: vecSpot = pEntity->BodyTarget( vecSrc ); -- NEW:
			pev( pEntity, pev_absmin, vecAbsMin );
			pev( pEntity, pev_absmax, vecAbsMax );
			for( i = 0; i < 3; i++ ) vecSpot[i] = ( vecAbsMin[i] + vecAbsMax[i] ) * 0.5;
			
			engfunc( EngFunc_TraceLine, vecSrc, vecSpot, DONT_IGNORE_MONSTERS, pevInflictor, tr );
			
			get_tr2( tr, TR_flFraction, flFraction ); // NEW
			get_tr2( tr, TR_vecEndPos, vecEndPos ); // NEW
			
			if ( flFraction == 1.0 || get_tr2( tr, TR_pHit ) == pEntity )
				{// the explosion can 'see' this entity, so hurt them!
			if ( get_tr2( tr, TraceResult:TR_StartSolid ) )
			{
				// if we're stuck inside them, fixup the position and distance
				vecEndPos =  vecSrc;
				flFraction = 0.0;
			}
			
			// decrease damage for an ent that's farther from the bomb.
			
			// OLD: flAdjustedDamage = ( vecSrc - tr.vecEndPos ).Length() * falloff; -- NEW:
			for( i = 0; i < 3; i++ ) vecAdjust[i] = vecSrc[i] - vecEndPos[i];
			flAdjustedDamage = floatsqroot(vecAdjust[0]*vecAdjust[0] + vecAdjust[1]*vecAdjust[1] + vecAdjust[2]*vecAdjust[2]) * falloff;
			
			flAdjustedDamage = flDamage - flAdjustedDamage;
			
			if ( flAdjustedDamage < 0.0 )
			{
				flAdjustedDamage = 0.0;
			}
			
			// ALERT( at_console, "hit %s\n", STRING( pEntity->pev->classname ) );
			take_damage( pEntity, pevInflictor, flAdjustedDamage ); // NEW
		}
	}
}
}

public take_damage( victim, attacker, Float:damage )
{
	if(!ma_klase[attacker])
		return;
		
	cod_inflict_damage( attacker, victim, damage, 1.0, victim, (1<<24))
}