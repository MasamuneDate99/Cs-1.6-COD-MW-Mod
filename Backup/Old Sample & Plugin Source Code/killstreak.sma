#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <engine>
#include <fakemeta>
#include <fun>
#include <xs>

#define PLUGIN "KillStreak"
#define VERSION "1.3.4"
#define AUTHOR "cypis"

#define MAX_DIST 8192.0
#define MAX 32

new const maxAmmo[31]={0,52,0,90,1,32,1,100,90,1,120,100,100,90,90,90,100,120,30,120,200,32,90,120,90,2,35,90,90,0,100};

new sprite_blast, cache_trail;

new licznik_zabic[MAX+1], bool:radar[2], bool:nalot[MAX+1], bool:predator[MAX+1], bool:nuke[MAX+1], bool:emp[MAX+1], bool:cuav[MAX+1], bool:uav[MAX+1], bool:pack[MAX+1], bool:sentrys[MAX+1];
new user_controll[MAX+1], emp_czasowe, bool:nuke_player[MAX+1];
new PobraneOrigin[3], ZmienKilla[2];
new nukeuses = 0;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_think("sentry","SentryThink");
	
	register_touch("predator", "*", "touchedpredator");
	register_touch("bomb", "*", "touchedrocket");

	register_forward(FM_ClientKill, "cmdKill");
	
	RegisterHam(Ham_TakeDamage, "func_breakable", "TakeDamage");
	RegisterHam(Ham_Killed, "player", "SmiercGracza", 1);
	
	register_event("CurWeapon","CurWeapon","be", "1=1");
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");
	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
	
	register_cvar("ks_hpsentry", "2500");
	register_cvar("ks_sentry_remove", "1");
	
	register_clcmd("say /ks", "uzyj_nagrody");
	register_clcmd("say /killstreak", "uzyj_nagrody");
	set_task(2.0,"radar_scan",_,_,_,"b");
}

public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	cache_trail = precache_model("sprites/smoke.spr");
	
	precache_model("models/p_hegrenade.mdl");
	precache_model("models/cod_carepackage.mdl");
	precache_model("models/cod_plane.mdl");
	precache_model("models/cod_predator.mdl");
	precache_model("models/sentrygun_mw2.mdl");
	
	precache_sound("mw/nuke_friend.wav");
	precache_sound("mw/nuke_enemy.wav");
	precache_sound("mw/nuke_give.wav");
	
	precache_sound("mw/jet_fly1.wav");
	//precache_sound("mw/jet_fly2.wav");
	
	precache_sound("mw/emp_effect.wav");
	precache_sound("mw/emp_friend.wav");
	precache_sound("mw/emp_enemy.wav");
	precache_sound("mw/emp_give.wav");
	
	precache_sound("mw/counter_friend.wav");
	precache_sound("mw/counter_enemy.wav");
	precache_sound("mw/counter_give.wav");
	
	precache_sound("mw/air_friend.wav");
	precache_sound("mw/air_enemy.wav");
	precache_sound("mw/air_give.wav");
	
	precache_sound("mw/predator_friend.wav");
	precache_sound("mw/predator_enemy.wav");
	precache_sound("mw/predator_give.wav");
	
	precache_sound("mw/uav_friend.wav");
	precache_sound("mw/uav_enemy.wav");
	precache_sound("mw/uav_give.wav");
	
	precache_sound("mw/carepackage_friend.wav");
	precache_sound("mw/carepackage_enemy.wav");
	precache_sound("mw/carepackage_give.wav");
	
	precache_sound("mw/firemw.wav");
	precache_sound("mw/plant.wav");
	precache_sound("mw/sentrygun_starts.wav");
	precache_sound("mw/sentrygun_stops.wav");
	precache_sound("mw/sentrygun_gone.wav");
	precache_sound("mw/sentrygun_friend.wav");
	precache_sound("mw/sentrygun_enemy.wav");
	precache_sound("mw/sentrygun_give.wav");
	
	precache_model("models/computergibs.mdl");
	/*precache_sound("mw/emergairdrop_friend.wav");
	precache_sound("mw/emergairdrop_enemy.wav");
	precache_sound("mw/emergairdrop_give.wav");*/
}

public uzyj_nagrody(id)
{
	new menu = menu_create("KillStreak:", "Nagrody_Handler");
	new cb = menu_makecallback("Nagrody_Callback");
	menu_additem(menu, "UAV", _, _, cb);
	menu_additem(menu, "Care Package", _, _, cb);
	menu_additem(menu, "Counter-UAV", _, _, cb);
	menu_additem(menu, "Sentry Gun", _, _, cb);
	menu_additem(menu, "Predator Missle", _, _, cb);
	menu_additem(menu, "Airstrike", _, _, cb);
	menu_additem(menu, "EMP", _, _, cb);
	menu_additem(menu, "Nuke", _, _, cb);
	menu_setprop(menu, MPROP_EXITNAME, "Exit^n\yCOD KILLSTREAK");
	menu_display(id, menu)
}

public Nagrody_Callback(id, menu, item)
{
	if(!uav[id] && item == 0 || !pack[id] && item == 1 || !cuav[id] && item == 2 || !sentrys[id] && item == 3 || !predator[id] && item == 4 || !nalot[id] && item == 5 || !emp[id] && item == 6 || !nuke[id] && item == 7)
		return ITEM_DISABLED;
	
	return ITEM_ENABLED;
}

public Nagrody_Handler(id, menu, item)
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	switch(item)
	{
		case 0:{
			if(!emp_czasowe || (emp_czasowe && get_user_team(id) == get_user_team(emp_czasowe)))
				CreateUVA(id);
		}
		case 1:{
			if(!emp_czasowe || (emp_czasowe && get_user_team(id) == get_user_team(emp_czasowe)))
				CreatePack(id);
		} 
		case 2:{
			if(!emp_czasowe || (emp_czasowe && get_user_team(id) == get_user_team(emp_czasowe)))
				CreateCUVA(id);
		} 
		case 3:{
			if(!emp_czasowe || (emp_czasowe && get_user_team(id) == get_user_team(emp_czasowe)))
				CreateSentry(id);
		} 
		case 4:{
			if(!emp_czasowe || (emp_czasowe && get_user_team(id) == get_user_team(emp_czasowe)))
				CreatePredator(id);
		} 
		case 5:{
			if(!emp_czasowe || (emp_czasowe && get_user_team(id) == get_user_team(emp_czasowe)))
				CreateNalot(id);
		} 
		case 6:{
			if(!emp_czasowe)
				CreateEmp(id);
		} 
		case 7:
		{ 
			if(++nukeuses <= 2)
				CreateNuke(id);
		}
	}		
	return PLUGIN_HANDLED;
}

public NowaRunda()
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new i = 0; i < num; i++)
	{
		if(task_exists(players[i]+997))
			remove_task(players[i]+997);
	}
	
	remove_entity_name("predator")
	remove_entity_name("bomb")
	
	if(get_cvar_num("ks_sentry_remove"))
		remove_entity_name("sentry")
}

public client_putinserver(id){
	licznik_zabic[id] = 0;
	user_controll[id] = 0;
	nalot[id] = false;
	predator[id] = false;
	nuke[id] = false;
	cuav[id] = false;
	uav[id] = false;
	emp[id] = false;
	pack[id] = false;
	sentrys[id] = false;
}

public client_disconnect(id)
{
	new ent = -1
	while((ent = find_ent_by_class(ent, "sentry")))
	{
		if(entity_get_int(ent, EV_INT_iuser2) == id)
			remove_entity(ent);
	}
	return PLUGIN_CONTINUE;
}

public SmiercGracza(id, attacker)
{	
	if(!is_user_alive(attacker) || !is_user_connected(attacker))
		return HAM_IGNORED;
		
	if(get_user_team(attacker) != get_user_team(id) && !nuke_player[attacker])
	{
		licznik_zabic[attacker]++;
		switch(licznik_zabic[attacker])
		{
			case 3:
			{
				uav[attacker] = true;
				OdgrajDzwieki(attacker, "UAV^nType /ks and choose to use it", "uav");
			}
			case 4:
			{
				switch(random_num(0,1))
				{
					case 0:
					{
						cuav[attacker] = true;
						OdgrajDzwieki(attacker, "Counter-Uav^nType /ks and choose to use it", "counter");
					}
					case 1:
					{
						pack[attacker] = true;
						OdgrajDzwieki(attacker, "Care Package^nType /ks and choose to use it", "carepackage");
					}
				}
			}
			case 5:
			{
				predator[attacker] = true;
				OdgrajDzwieki(attacker, "Predator Missible^nType /ks and choose to use it", "predator");
			}
			case 6:
			{
				nalot[attacker] = true;
				OdgrajDzwieki(attacker, "Airstreak^nType /ks and choose to use it", "air");
			}
			case 8:
			{
				sentrys[attacker] = true;
				OdgrajDzwieki(attacker, "Sentry Gun^nType /ks and choose to use it", "sentrygun");
			}
			case 15:
			{
				emp[attacker] = true;
				OdgrajDzwieki(attacker, "EMP^nType /ks and choose to use it", "emp");
			}
			case 20:
			{
				nuke[attacker] = true;
				OdgrajDzwieki(attacker, "Nuke^nType /ks and choose to use it", "nuke");
			}
		}
	}
	licznik_zabic[id] = 0;
	user_controll[id] = 0;
			
	new ent = find_drop_pack(id, "pack")
	if(is_valid_ent(ent))
	{
		if(task_exists(2571+ent))
		{
			remove_task(2571+ent);
			bartime(id, 0);
		}
	}
	return HAM_IGNORED;
}

public OdgrajDzwieki(id, szNazwa[], scieszka[])
{
	set_hudmessage(255, 255, 255, -1.0, 0.25, 0, 6.0, 7.0);
	ShowSyncHudMsg(id, CreateHudSyncObj(), szNazwa);
	client_cmd(id, "spk sound/mw/%s_give.wav", scieszka);
}

//uav
public CreateUVA(id)
{
	static CzasUav[2];
	new team = get_user_team(id) == 1? 0: 1;
	uav[id] = false;
	radar[team] = true;
	
	new num, players[32];
	get_players(players, num, "gh")
	for(new a = 0; a < num; a++)
	{
		new i = players[a]
		if(get_user_team(id) != get_user_team(i))
			client_cmd(i, "spk sound/mw/uav_enemy.wav")
		else
			client_cmd(i, "spk sound/mw/uav_friend.wav")
	}
	print_info(id, "UAV");
	radar_scan()
	
	if(task_exists(7354+team))
	{
		new times = (CzasUav[team]-get_systime())+60
		change_task(7354+team, float(times));
		CzasUav[team] = CzasUav[team]+times;
	}
	else
	{
		new data[1];
		data[0] = team;
		set_task(60.0, "deluav", 7354+team, data, 1);
		CzasUav[team] = get_systime()+60;
	}
}

public deluav(data[1])
{
	radar[data[0]] = false;
}

public radar_scan()
{
	new num, players[32];
	get_players(players, num, "gh")
	for(new i=0; i<num; i++)
	{
		new id = players[i];
		if(!is_user_alive(id) || !radar[get_user_team(id) == 1? 0: 1])
			continue;
		
		if(!emp_czasowe)
			radar_continue(id)
		else if(get_user_team(id) == get_user_team(emp_czasowe))
			radar_continue(id)
	}
}

radar_continue(id)
{
	new num, players[32], PlayerCoords[3]
	get_players(players, num, "gh")
	for(new a=0; a<num; a++)
	{
		new i = players[a]       
		if(!is_user_alive(i) || get_user_team(i) == get_user_team(id)) 
			continue;
		
		get_user_origin(i, PlayerCoords)
		
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostagePos"), {0,0,0}, id)
		write_byte(id)
		write_byte(i)           
		write_coord(PlayerCoords[0])
		write_coord(PlayerCoords[1])
		write_coord(PlayerCoords[2])
		message_end()
		
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostageK"), {0,0,0}, id)
		write_byte(i)
		message_end()
	}	
}

//airpack
public CreatePack(id)
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(id) != get_user_team(i))
			client_cmd(i, "spk sound/mw/carepackage_enemy.wav");
		else
			client_cmd(i, "spk sound/mw/carepackage_friend.wav");
	}
	print_info(id, "Care Package");
	CreatePlane(id)
	pack[id] = false
	set_task(1.0, "CarePack", id+742)
}

public CarePack(taskid)
{
	new id = (taskid - 742)
	
	PobraneOrigin[2] += 150; 
	new Float:LocVecs[3];
	IVecFVec(PobraneOrigin, LocVecs);
	create_ent(id, "pack", "models/cod_carepackage.mdl", 1, 6, LocVecs);
}

public pickup_pack(info[2])
{
	new id = info[0];
	new ent = info[1];
	
	if(!is_user_connected(id) || !is_user_alive(id))
		return;
	
	new weapons[32], weaponsnum;
	get_user_weapons(id, weapons, weaponsnum);
	for(new i=0; i<weaponsnum; i++)
		if(maxAmmo[weapons[i]] > 0)
			cs_set_user_bpammo(id, weapons[i], maxAmmo[weapons[i]]);
		
	give_item(id, "weapon_hegrenade");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_flashbang");			
	give_item(id, "weapon_smokegrenade");
		
	switch(random(5))	
	{
		case 0:
		{
			uav[id] = true;
			client_cmd(id, "spk sound/mw/uav_give.wav");
		}
		case 1:
		{
			cuav[id] = true;
			client_cmd(id, "spk sound/mw/counter_give.wav");
		}
		case 2:
		{
			predator[id] = true;
			client_cmd(id, "spk sound/mw/predator_give.wav");
		}
		case 3:
		{
			nalot[id] = true;
			client_cmd(id, "spk sound/mw/air_give.wav");
		}
		case 4:
		{
			sentrys[id] = true;
			client_cmd(id, "spk sound/mw/sentrygun_give.wav");
		}
		case 5:
		{
			emp[id] = true;
			client_cmd(id, "spk sound/mw/emp_give.wav");
		}
	}		
	remove_entity(ent);
}

public client_PreThink(id)
{	
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;				
	if(user_controll[id])
	{
		new ent2 = user_controll[id];
		if(is_valid_ent(ent2))
		{
			new Float:Velocity[3], Float:Angle[3];
			velocity_by_aim(id, 500, Velocity);
			entity_get_vector(id, EV_VEC_v_angle, Angle);
			
			entity_set_vector(ent2, EV_VEC_velocity, Velocity);
			entity_set_vector(ent2, EV_VEC_angles, Angle);
		}
		else
			attach_view(id, id);
	}
	static ent_id[MAX+1];
	new ent = find_drop_pack(id, "pack");
	if(is_valid_ent(ent))
	{
		if(!task_exists(2571+ent))
		{
			ent_id[id] = ent;
			bartime(id, 3)	
		
			new info[2];
			info[0] = id;
			info[1] = ent;
			set_task(3.0, "pickup_pack", 2571+ent, info, 2);
		}
	}
	else
	{
		if(task_exists(2571+ent_id[id]))
		{
			remove_task(2571+ent_id[id]);
			bartime(id, 0);
			ent_id[id] = 0;
		}
	}
	return PLUGIN_CONTINUE;
}

//counter-uva
public CreateCUVA(id)
{
	cuav[id] = false;
	new num, players[32];
	get_players(players, num, "gh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(id) != get_user_team(i))
			client_cmd(i, "spk sound/mw/counter_enemy.wav");
		else
			client_cmd(i, "spk sound/mw/counter_friend.wav");
	}
	radar[get_user_team(id) == 1? 1: 0] = false;
	print_info(id, "Counter-UAV");
}

//emp
public CreateEmp(id)
{
	client_cmd(0, "spk sound/mw/emp_effect.wav");
	emp[id] = false;
	new num, players[32];
	get_players(players, num, "gh")
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(id) != get_user_team(i))
		{
			if(is_user_alive(i))
			{
				Display_Fade(i,1<<12,1<<12,1<<16,255, 255,0,166);
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HideWeapon"), _, i);
				write_byte((1<<0)|(1<<3)|(1<<5));
				message_end();
			}
			client_cmd(i, "spk sound/mw/emp_enemy.wav");
		}
		else
			client_cmd(i, "spk sound/mw/emp_friend.wav");
	}
	print_info(id, "EMP", "e");
	emp_czasowe = id;
	set_task(90.0,"del_emp");
}

public del_emp()
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(emp_czasowe) != get_user_team(i))
		{
			if(is_user_alive(i))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HideWeapon"), _, i); 
				write_byte(0);
				message_end();
			}
		}
	}
	emp_czasowe = 0;
}

public CurWeapon(id)
{
	if(get_user_team(id) != get_user_team(emp_czasowe) && emp_czasowe)
	{
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HideWeapon"), _, id); 
		write_byte(0x29); //(1<<0)|(1<<3)|(1<<5)
		message_end(); 
	}
}

//nuke
public CreateNuke(id)
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(is_user_alive(i))
			Display_Fade(i,(10<<12),(10<<12),(1<<16),255, 42, 42,171);
		
		if(get_user_team(id) != get_user_team(i))
			client_cmd(i, "spk sound/mw/nuke_enemy.wav");
		else
			client_cmd(i, "spk sound/mw/nuke_friend.wav");
	}
	print_info(id, "Nuke", "e");
	set_task(10.0,"shakehud");
	set_task(13.5,"del_nuke", id);
	nuke[id] = false;
}

public shakehud()
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(is_user_alive(i))
		{
			Display_Fade(i,(3<<12),(3<<12),(1<<16),255, 85, 42,215);
			message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, i);
			write_short(255<<12);
			write_short(4<<12);
			write_short(255<<12);
			message_end();
		}
	}
}

public del_nuke(id)
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(is_user_alive(i))
		{
			if(get_user_team(id) != get_user_team(i))
			{
				cs_set_user_armor(i, 0, CS_ARMOR_NONE);
				UTIL_Kill(id, i, float(get_user_health(i)), DMG_BULLET)
			}
			else
				user_silentkill(i);
		}
	}
	nuke_player[id] = false;
	licznik_zabic[id] = 0;
}

//nalot
public CreateNalot(id)
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(id) != get_user_team(i))
			client_cmd(i, "spk sound/mw/air_enemy.wav");
		else
			client_cmd(i, "spk sound/mw/air_friend.wav");
	}
	print_info(id, "Airstrike");
	set_task(1.0, "CreateBombs", id+997, _, _, "a", 3);
	CreatePlane(id);
	nalot[id] = false;
}

public CreateBombs(taskid)
{	
	new id = (taskid-997);
	
	new radlocation[3];
	PobraneOrigin[0] += random_num(-300,300);
	PobraneOrigin[1] += random_num(-300,300);
	PobraneOrigin[2] += 50;
	
	for(new i=0; i<15; i++) 
	{
		radlocation[0] = PobraneOrigin[0]+1*random_num(-150,150); 
		radlocation[1] = PobraneOrigin[1]+1*random_num(-150,150); 
		radlocation[2] = PobraneOrigin[2]; 
		
		new Float:LocVec[3]; 
		IVecFVec(radlocation, LocVec); 
		create_ent(id, "bomb", "models/p_hegrenade.mdl", 2, 10, LocVec);
	}
}  

public CreatePlane(id)
{
	new Float:Origin[3], Float:Angle[3], Float:Velocity[3], ent;
	
	get_user_origin(id, PobraneOrigin, 3);
	
	velocity_by_aim(id, 1000, Velocity);
	entity_get_vector(id, EV_VEC_origin, Origin);
	entity_get_vector(id, EV_VEC_v_angle, Angle);
	
	Angle[0] = Velocity[2] = 0.0;
	Origin[2] += 200.0;
	
	create_ent(id, "samolot", "models/cod_plane.mdl", 2, 8, Origin, ent);
	
	entity_set_vector(ent, EV_VEC_velocity, Velocity);
	entity_set_vector(ent, EV_VEC_angles, Angle);
	
	emit_sound(ent, CHAN_ITEM, "mw/jet_fly1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
	set_task(4.5, "del_plane", ent+5731);
}

public del_plane(taskid)
	remove_entity(taskid-5731);

public touchedrocket(ent, id)
{
	if(!is_valid_ent(ent))
		return PLUGIN_CONTINUE;
	
	bombs_explode(ent, 100.0, 150.0);
	return PLUGIN_CONTINUE;
}

//predator
public CreatePredator(id)
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(id) != get_user_team(i))
			client_cmd(i, "spk sound/mw/predator_enemy.wav");
		else
			client_cmd(i, "spk sound/mw/predator_friend.wav");
	}
	print_info(id, "Predator Missle");

	new Float:Origin[3], Float:Angle[3], Float:Velocity[3], ent;
	
	velocity_by_aim(id, 700, Velocity);
	entity_get_vector(id, EV_VEC_origin, Origin);
	entity_get_vector(id, EV_VEC_v_angle, Angle);
	
	Angle[0] *= -1.0;
	
	create_ent(id, "predator", "models/cod_predator.mdl", 2, 5, Origin, ent);
	
	entity_set_vector(ent, EV_VEC_velocity, Velocity);
	entity_set_vector(ent, EV_VEC_angles, Angle);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(ent);
	write_short(cache_trail);
	write_byte(10);
	write_byte(5);
	write_byte(205);
	write_byte(237);
	write_byte(163);
	write_byte(200);
	message_end();
	
	predator[id] = false;
	
	attach_view(id, ent);
	user_controll[id] = ent;
} 

public touchedpredator(ent, id)
{
	if(!is_valid_ent(ent))
		return PLUGIN_CONTINUE;
	
	new owner = entity_get_edict(ent, EV_ENT_owner);
	bombs_explode(ent, 220.0, 400.0);
	attach_view(owner, owner);
	user_controll[owner] = 0;
	return PLUGIN_CONTINUE;
}

//sentry gun
public CreateSentry(id) 
{
	if(!(entity_get_int(id, EV_INT_flags) & FL_ONGROUND)) 
		return;

	new entlist[3];
	if(find_sphere_class(id, "func_bomb_target", 650.0, entlist, 2))
	{
		client_print(id, print_chat, "[KillStrike] Jestes zbyt blisko BS'A.");
		return;
	}
	if(find_sphere_class(id, "func_buyzone", 650.0, entlist, 2))
	{
		client_print(id, print_chat, "[KillStrike] Jestes zbyt blisko Respa.");
		return;
	}
	new num, players[32], Float:Origin[3];
	get_players(players, num, "gh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(id) != get_user_team(i))
			client_cmd(i, "spk sound/mw/sentrygun_enemy.wav");
		else
			client_cmd(i, "spk sound/mw/sentrygun_friend.wav");
	}
	print_info(id, "Sentry Gun");
	
	entity_get_vector(id, EV_VEC_origin, Origin);
	Origin[2] += 45.0;
	
	new health[12], ent = create_entity("func_breakable");
	get_cvar_string("ks_hpsentry",health, charsmax(health));
	
	DispatchKeyValue(ent, "health", health);
	DispatchKeyValue(ent, "material", "6");
	
	entity_set_string(ent, EV_SZ_classname, "sentry");
	entity_set_model(ent, "models/sentrygun_mw2.mdl");
	
	entity_set_float(ent, EV_FL_takedamage, DAMAGE_YES);
	
	entity_set_size(ent, Float:{-16.0, -16.0, 0.0}, Float:{16.0, 16.0, 48.0});
	
	entity_set_origin(ent, Origin);
	entity_set_int(ent, EV_INT_solid, SOLID_SLIDEBOX);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_int(ent, EV_INT_iuser2, id);
	entity_set_vector(ent, EV_VEC_angles, Float:{0.0, 0.0, 0.0});
	entity_set_byte(ent, EV_BYTE_controller2, 127);

	entity_set_float(ent, EV_FL_nextthink, get_gametime()+1.0);
	
	sentrys[id] = false;
	emit_sound(ent, CHAN_ITEM, "mw/plant.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
}

public SentryThink(ent)
{
	if(!is_valid_ent(ent)) 
		return PLUGIN_CONTINUE;
	
	new Float:SentryOrigin[3], Float:closestOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, SentryOrigin);

	new id = entity_get_int(ent, EV_INT_iuser2);
	new target = entity_get_edict(ent, EV_ENT_euser1);
	new firemods = entity_get_int(ent, EV_INT_iuser1);
	
	if(firemods)
	{ 
		if(/*ExecuteHam(Ham_FVisible, target, ent)*/fm_is_ent_visible(target, ent) && is_user_alive(target)) 
		{
			if(UTIL_In_FOV(target,ent))
			{
				goto fireoff;
			}
			
			new Float:TargetOrigin[3];
			entity_get_vector(target, EV_VEC_origin, TargetOrigin);
				
			emit_sound(ent, CHAN_AUTO, "mw/firemw.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			sentry_turntotarget(ent, SentryOrigin, TargetOrigin);
				
			new Float:hitRatio = random_float(0.0, 1.0) - 0.2;
			if(hitRatio <= 0.0)
			{
				UTIL_Kill(id, target, random_float(5.0, 35.0), DMG_BULLET, 1);
				
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_TRACER);
				write_coord(floatround(SentryOrigin[0]));
				write_coord(floatround(SentryOrigin[1]));
				write_coord(floatround(SentryOrigin[2]));
				write_coord(floatround(TargetOrigin[0]));
				write_coord(floatround(TargetOrigin[1]));
				write_coord(floatround(TargetOrigin[2]));
				message_end();
			}
			entity_set_float(ent, EV_FL_nextthink, get_gametime()+0.1);
			return PLUGIN_CONTINUE;
		}
		else
		{
fireoff:
			firemods = 0;
			entity_set_int(ent, EV_INT_iuser1, 0);
			entity_set_edict(ent, EV_ENT_euser1, 0);
			emit_sound(ent, CHAN_AUTO, "mw/sentrygun_stops.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			
			entity_set_float(ent, EV_FL_nextthink, get_gametime()+1.0);
			return PLUGIN_CONTINUE;
		}
	}

	new closestTarget = getClosestPlayer(ent)
	if(closestTarget)
	{
		emit_sound(ent, CHAN_AUTO, "mw/sentrygun_starts.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
		entity_get_vector(closestTarget, EV_VEC_origin, closestOrigin);
		sentry_turntotarget(ent, SentryOrigin, closestOrigin);
		
		entity_set_int(ent, EV_INT_iuser1, 1);
		entity_set_edict(ent, EV_ENT_euser1, closestTarget);
		
		entity_set_float(ent, EV_FL_nextthink, get_gametime()+1.0);
		return PLUGIN_CONTINUE;
	}

	if(!firemods)
	{
		new controler1 = entity_get_byte(ent, EV_BYTE_controller1)+1;
		if(controler1 > 255)
			controler1 = 0;
		entity_set_byte(ent, EV_BYTE_controller1, controler1);
		
		new controler2 = entity_get_byte(ent, EV_BYTE_controller2);
		if(controler2 > 127 || controler2 < 127)
			entity_set_byte(ent, EV_BYTE_controller2, 127);
			
		entity_set_float(ent, EV_FL_nextthink, get_gametime()+0.05);
	}
	return PLUGIN_CONTINUE
}

public sentry_turntotarget(ent, Float:sentryOrigin[3], Float:closestOrigin[3]) 
{
	new newTrip, Float:newAngle = floatatan(((closestOrigin[1]-sentryOrigin[1])/(closestOrigin[0]-sentryOrigin[0])), radian) * 57.2957795;

	if(closestOrigin[0] < sentryOrigin[0])
		newAngle += 180.0;
	if(newAngle < 0.0)
		newAngle += 360.0;
	
	sentryOrigin[2] += 35.0
	if(closestOrigin[2] > sentryOrigin[2])
		newTrip = 0;
	if(closestOrigin[2] < sentryOrigin[2])
		newTrip = 255;
	if(closestOrigin[2] == sentryOrigin[2])
		newTrip = 127;
		
	entity_set_byte(ent, EV_BYTE_controller1,floatround(newAngle*0.70833));
	entity_set_byte(ent, EV_BYTE_controller2, newTrip);
	entity_set_byte(ent, EV_BYTE_controller3, entity_get_byte(ent, EV_BYTE_controller3)+20>255? 0: entity_get_byte(ent, EV_BYTE_controller3)+20);
}

public TakeDamage(ent, idinflictor, attacker, Float:damage, damagebits)
{
	if(!is_user_alive(attacker))
		return HAM_IGNORED;
	
	new classname[32];
	entity_get_string(ent, EV_SZ_classname, classname, 31);
	
	if(equal(classname, "sentry")) 
	{
		new id = entity_get_int(ent, EV_INT_iuser2);
		if(get_user_team(attacker) == get_user_team(id))
			return HAM_SUPERCEDE;

		if(damage >= entity_get_float(ent, EV_FL_health))
		{
			new Float:Origin[3];
			entity_get_vector(ent, EV_VEC_origin, Origin);	
			new entlist[33];
			new numfound = find_sphere_class(ent, "player", 190.0, entlist, 32);
			
			for(new i=0; i < numfound; i++)
			{		
				new pid = entlist[i];
				
				if(!is_user_alive(pid) || get_user_team(id) == get_user_team(pid))
					continue;
				UTIL_Kill(id, pid, 70.0, (1<<24));
			}
			client_cmd(id, "spk sound/mw/sentrygun_gone.wav");
			//Sprite_Blast(Origin);
			//remove_entity(ent); //jak to dam to cresh serwer bo odrazu usuwa sentry guna :O
			set_task(1.0, "del_sentry", ent); //jak tego nie dam to sentry jest jako byt i strzela
		}
	}
	return HAM_IGNORED;
}

public del_sentry(ent)
	remove_entity(ent);

//wybuch
bombs_explode(ent, Float:zadaje, Float:promien)
{
	if(!is_valid_ent(ent)) 
		return;
	
	new attacker = entity_get_edict(ent, EV_ENT_owner);
	
	new Float:entOrigin[3], Float:fDamage, Float:Origin[3];
	entity_get_vector(ent, EV_VEC_origin, entOrigin);
	entOrigin[2] += 1.0;
	
	new entlist[33];
	new numfound = find_sphere_class(ent, "player", promien, entlist, 32);	
	for(new i=0; i < numfound; i++)
	{		
		new victim = entlist[i];		
		if(!is_user_alive(victim) || get_user_team(attacker) == get_user_team(victim))
			continue;
			
		entity_get_vector(victim, EV_VEC_origin, Origin);
		fDamage = zadaje - floatmul(zadaje, floatdiv(get_distance_f(Origin, entOrigin), promien));
		fDamage *= estimate_take_hurt(entOrigin, victim, 0);
		if(fDamage>0.0)
			UTIL_Kill(attacker, victim, fDamage, DMG_BULLET);
	}
	Sprite_Blast(entOrigin);
	remove_entity(ent);
}

public cmdKill()
	return FMRES_SUPERCEDE;

public message_DeathMsg()
{
	new killer = get_msg_arg_int(1);
	if(ZmienKilla[0] & (1<<killer))
	{
		set_msg_arg_string(4, "grenade");
		return PLUGIN_CONTINUE;
	}
	if(ZmienKilla[1] & (1<<killer))
	{
		set_msg_arg_string(4, "m249");
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}

stock create_ent(id, szName[], szModel[], iSolid, iMovetype, Float:fOrigin[3], &ent=-1)
{
	new ent1 = create_entity("info_target");
	entity_set_string(ent1, EV_SZ_classname, szName);
	entity_set_model(ent1, szModel);
	entity_set_int(ent1, EV_INT_solid, iSolid);
	entity_set_int(ent1, EV_INT_movetype, iMovetype);
	entity_set_edict(ent1, EV_ENT_owner, id);
	entity_set_origin(ent1, fOrigin);
	
	if(ent != -1)
		ent = ent1;
}

stock Sprite_Blast(Float:iOrigin[3])
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_EXPLOSION);
	write_coord(floatround(iOrigin[0]));
	write_coord(floatround(iOrigin[1])); 
	write_coord(floatround(iOrigin[2]));
	write_short(sprite_blast);
	write_byte(32);
	write_byte(20); 
	write_byte(0);
	message_end();
}

stock Float:estimate_take_hurt(Float:fPoint[3], ent, ignored) 
{
	new Float:fFraction, Float:fOrigin[3], tr;
	entity_get_vector(ent, EV_VEC_origin, fOrigin);
	engfunc(EngFunc_TraceLine, fPoint, fOrigin, DONT_IGNORE_MONSTERS, ignored, tr);
	get_tr2(tr, TR_flFraction, fFraction);
	if(fFraction == 1.0 || get_tr2(tr, TR_pHit) == ent)
		return 1.0;
	return 0.6;
}

stock bartime(id, number)
{
	message_begin(MSG_ONE, get_user_msgid("BarTime"), _, id);
	write_short(number);
	message_end();	
}

stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha)
{
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"),{0,0,0},id);
	write_short(duration);
	write_short(holdtime);
	write_short(fadetype);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(alpha);
	message_end();
}

stock find_drop_pack(id, const class[])
{
	new Float:origin[3], classname[32], ent;
	entity_get_vector(id, EV_VEC_origin, origin);
	
	while((ent = find_ent_in_sphere(ent, origin, 75.0)) != 0) 
	{
		entity_get_string(ent, EV_SZ_classname, classname, 31);
		if(equali(classname, class))
			return ent;
	}
	return 0;
}

stock print_info(id, const nagroda[], const nazwa[] = "y")
{
	new nick[64];
	get_user_name(id, nick, 63);
	client_print(0, print_chat, "%s be called%s by %s", nagroda, nazwa, nick);
}
	
stock UTIL_Kill(atakujacy, obrywajacy, Float:damage, damagebits, ile=0)
{
	ZmienKilla[ile] |= (1<<atakujacy);
	ExecuteHam(Ham_TakeDamage, obrywajacy, atakujacy, atakujacy, damage, damagebits);
	ZmienKilla[ile] &= ~(1<<atakujacy);
}
	
stock getClosestPlayer(ent)
{
	new iClosestPlayer = 0, Float:flClosestDist = MAX_DIST, Float:flDistanse, Float:fOrigin[2][3];
	new num, players[32];
	get_players(players, num, "gh")
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(!is_user_connected(i) || !is_user_alive(i) || /*!ExecuteHam(Ham_FVisible, i, ent)*/!fm_is_ent_visible(i, ent) || get_user_team(i) == get_user_team(entity_get_int(ent, EV_INT_iuser2)))
			continue;
		
		if(UTIL_In_FOV(i, ent))
			continue;
		
		entity_get_vector(i, EV_VEC_origin, fOrigin[0]);
		entity_get_vector(ent, EV_VEC_origin, fOrigin[1]);
		
		flDistanse = get_distance_f(fOrigin[0], fOrigin[1]);
		
		if(flDistanse <= flClosestDist)
		{
			iClosestPlayer = i;
			flClosestDist = flDistanse;
		}
	}
	return iClosestPlayer;
}

stock bool:UTIL_In_FOV(id,ent)
{
	if((get_pdata_int(id, 510) & (1<<16)) && (Find_Angle(id, ent) > 0.0))
		return true;
	return false;
}

stock Float:Find_Angle(id, target)
{
	new Float:Origin[3], Float:TargetOrigin[3];
	pev(id,pev_origin, Origin);
	pev(target,pev_origin,TargetOrigin);
	
	new Float:Angles[3], Float:vec2LOS[3];
	pev(id,pev_angles, Angles);
	
	xs_vec_sub(TargetOrigin, Origin, vec2LOS);
	vec2LOS[2] = 0.0;
	
	new Float:veclength = vector_length(vec2LOS);
	if (veclength <= 0.0)
		vec2LOS[0] = vec2LOS[1] = 0.0;
	else
	{
		new Float:flLen = 1.0 / veclength;
		vec2LOS[0] = vec2LOS[0]*flLen;
		vec2LOS[1] = vec2LOS[1]*flLen;
	}
	engfunc(EngFunc_MakeVectors, Angles);
	
	new Float:v_forward[3];
	get_global_vector(GL_v_forward, v_forward);
	
	new Float:flDot = vec2LOS[0]*v_forward[0]+vec2LOS[1]*v_forward[1];
	if(flDot > 0.5)
		return flDot;
	
	return 0.0;
}

stock bool:fm_is_ent_visible(index, entity, ignoremonsters = 0) {
	new Float:start[3], Float:dest[3];
	pev(index, pev_origin, start);
	pev(index, pev_view_ofs, dest);
	xs_vec_add(start, dest, start);

	pev(entity, pev_origin, dest);
	engfunc(EngFunc_TraceLine, start, dest, ignoremonsters, index, 0);

	new Float:fraction;
	get_tr2(0, TR_flFraction, fraction);
	if (fraction == 1.0 || get_tr2(0, TR_pHit) == entity)
		return true;

	return false;
}
