#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <cstrike>
#include <xs>
#include <fun>

// CODMOD
#include <codmod>

#define PLUGIN "[COD:MW] ELITE CLASS: ARJUNA"
#define VERSION "1.0"
#define AUTHOR "RG"

/* KONFIGURASI NICK PEMAKAI ELITE ARJUNA DISINI !!!
------------------------------------------------ */
new const DAFTAR_NICK_ELITE_ARJUNA[][] =
{
	"Hengky.-",
	"-RequiemID-"
}
/* --------------------------------------------- */
// CONFIGURATION WEAPON
#define system_name		"galil"
#define system_base		"galil"

#define DRAW_TIME		1.0

#define CSW_BASE		CSW_GALIL
#define WEAPON_KEY 		1499211021

#define OLD_MODEL		"models/w_galil.mdl"
#define ANIMEXT			"rifle"

// ALL MACRO
#define ENG_NULLENT		-1
#define EV_INT_WEAPONKEY	EV_INT_impulse
#define write_coord_f(%1)	engfunc(EngFunc_WriteCoord,%1)

// ALL ANIM
#define ANIM_DRAW		4
#define ANIM_SHOOT1		1
#define ANIM_SHOOT2		2

new const NAMA_CLASS[]		= "Arjuna";
new const INFO_CLASS[]		= "Get Arjuna Bow With Unlimited Ammo , Inflict Damage 0.5 INT, 1 KILL HS, Less Gravity";
new const SENJATA_CLASS		= 1<<CSW_DEAGLE | 1<<CSW_GALIL;
new const HEALTH_CLASS		= 65;
new const CONDITION_CLASS	= 40;
new const INTELEGENT_CLASS	= 30;
new const ENDURANCE_CLASS	= 30;

// All Models Of The Weapon
new V_MODEL[64] = "models/v_arjuna_bow.mdl"
new W_MODEL[64] = "models/w_arjuna_bow.mdl"
new P_MODEL[64] = "models/p_arjuna_bow.mdl"
new S_MODEL[64] = "models/s_arjuna_bow.mdl"

// You Can Add Fire Sound Here
new const Fire_Sounds[][] = { "weapons/arjuna_bow-1.wav" }

// All Vars Here
new g_attack_type[33], oldweap[33], sTrail, g_orig_event
new g_has_weapon[33], g_weapon_TmpClip[33]

new weapon_name_buffer[512]
new weapon_base_buffer[512]
new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
			"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
			"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
			"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
			"weapon_ak47", "weapon_knife", "weapon_p90" }

// START TO CREATE PLUGINS || AMXMODX FORWARD
public plugin_init()
{
	formatex(weapon_name_buffer, sizeof(weapon_name_buffer), "weapon_%s_asep", system_name)
	formatex(weapon_base_buffer, sizeof(weapon_base_buffer), "weapon_%s", system_base)
	
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	// Event And Message
	register_event("CurWeapon", "Event_CurrentWeapon", "be", "1=1")
	register_event("HLTV", "Event_RoundStart", "a", "1=0", "2=0")
	register_message(get_user_msgid("DeathMsg"), "Forward_DeathMsg")

	// Ham Forward (Entity) || Ham_Use
	RegisterHam(Ham_Use, "func_tank", "Forward_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankmortar", "Forward_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankrocket", "Forward_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tanklaser", "Forward_UseStationary_Post", 1)
	
	// Ham Forward (Entity) || Ham_TraceAttack
	RegisterHam(Ham_TraceAttack, "player", "Forward_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "worldspawn", "Forward_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_wall", "Forward_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_breakable", "Forward_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_door", "Forward_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "Forward_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_rotating", "Forward_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_plat", "Forward_TraceAttack", 1)
	
	// Ham Forward (Weapon)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_base_buffer, "Weapon_PrimaryAttack")
	RegisterHam(Ham_Item_PostFrame, weapon_base_buffer, "Weapon_ItemPostFrame")
	RegisterHam(Ham_Weapon_Reload, weapon_base_buffer, "Weapon_Reload")
	RegisterHam(Ham_Weapon_Reload, weapon_base_buffer, "Weapon_Reload_Post", 1)
	RegisterHam(Ham_Item_AddToPlayer, weapon_base_buffer, "Weapon_AddToPlayer")
	
	for(new i = 1; i < sizeof WEAPONENTNAMES; i++)
		if(WEAPONENTNAMES[i][0]) RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "Weapon_Deploy_Post", 1)
	
	// Fakemeta Forward
	register_forward(FM_SetModel, "Forward_SetModel")
	register_forward(FM_UpdateClientData, "Forward_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "Forward_PlaybackEvent")
	
	// Touch And Think
	register_touch("arjuna_bow", "*", "Forward_Bow_Touch")
	
	// Register Class
	cod_register_class(NAMA_CLASS, INFO_CLASS, SENJATA_CLASS, HEALTH_CLASS, CONDITION_CLASS, INTELEGENT_CLASS, ENDURANCE_CLASS)
}

public plugin_precache()
{
	formatex(weapon_name_buffer, sizeof(weapon_name_buffer), "weapon_%s_asep", system_name)
	formatex(weapon_base_buffer, sizeof(weapon_base_buffer), "weapon_%s", system_base)
	
	precache_model(V_MODEL)
	precache_model(P_MODEL)
	precache_model(W_MODEL)
	precache_model(S_MODEL)
	
	for(new i = 0; i < sizeof Fire_Sounds; i++)
		precache_sound(Fire_Sounds[i])
	
	sTrail = precache_model("sprites/laserbeam.spr")
	
	precache_viewmodel_sound(V_MODEL)
	register_forward(FM_PrecacheEvent, "Forward_PrecacheEvent_Post", 1)
}

/* ========= START OF REGISTER HAM TO SUPPORT BOTS FUNC ========= */
new g_HamBot
public client_putinserver(id)
{
	if(!g_HamBot && is_user_bot(id))
	{
		g_HamBot = 1
		set_task(0.1, "Do_RegisterHam", id)
	}
}

public Do_RegisterHam(id)
{
	RegisterHamFromEntity(Ham_TraceAttack, id, "Forward_TraceAttack", 1)
}

/* ======== END OF REGISTER HAM TO SUPPORT BOTS FUNC ============= */
/* ============ START OF ALL FORWARD (FAKEMETA) ================== */
public Forward_SetModel(entity, model[])
{
	if(!is_valid_ent(entity))
		return FMRES_IGNORED
	
	static szClassName[33]
	entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName))
		
	if(!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED
	
	static iOwner
	iOwner = entity_get_edict(entity, EV_ENT_owner)
	
	if(equal(model, OLD_MODEL))
	{
		static iStoredAugID
		iStoredAugID = find_ent_by_owner(ENG_NULLENT, weapon_base_buffer, entity)
			
		if(!is_valid_ent(iStoredAugID))
			return FMRES_IGNORED

		if(g_has_weapon[iOwner])
		{
			entity_set_int(iStoredAugID, EV_INT_WEAPONKEY, WEAPON_KEY)
			entity_set_model(entity, W_MODEL)
			
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

public Forward_PrecacheEvent_Post(type, const name[])
{
	new Buffer[512]
	formatex(Buffer, sizeof(Buffer), "events/%s.sc", system_base)
	if(equal(Buffer, name, 0))
	{
		g_orig_event = get_orig_retval()
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}

public Forward_UseStationary_Post(entity, caller, activator, use_type)
{
	if(!use_type && is_user_connected(caller))
		replace_weapon_models(caller, get_user_weapon(caller))
}

public Forward_UpdateClientData_Post(Player, SendWeapons, CD_Handle)
{
	if(!is_user_alive(Player) || (get_user_weapon(Player) != CSW_BASE || !g_has_weapon[Player]))
		return FMRES_IGNORED
	
	set_cd(CD_Handle, CD_flNextAttack, halflife_time () + 0.001)
	return FMRES_HANDLED
}

public Forward_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if((eventid != g_orig_event))
		return FMRES_IGNORED
	if(!(1 <= invoker <= get_maxplayers()))
		return FMRES_IGNORED
	if(!g_has_weapon[invoker])
		return FMRES_IGNORED
		
	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	return FMRES_SUPERCEDE
}

/* ================= END OF ALL FAKEMETA FORWARD ================= */
/* ================= START OF ALL ENGINE FORWARD ================ */
public Forward_Bow_Touch(bow, touched)
{
	if(!pev_valid(bow))
		return
		
	static classnameptd[32]
	pev(touched, pev_classname, classnameptd, 31)
	
	new team
	team = pev(bow, pev_iuser1)
		
	if(is_user_alive(touched))
	{
		set_pev(bow, pev_movetype, MOVETYPE_FOLLOW)
		set_pev(bow, pev_solid, SOLID_NOT)
		set_pev(bow, pev_aiment, touched)
		
		if(get_user_team(touched) != team)
		{
			new owner = pev(bow, pev_owner)
			
			if(Get_MissileWeaponHitGroup(bow) == HIT_HEAD) cod_inflict_damage(owner, touched, float(get_user_health(touched))+2.0, 0.0, bow, (1<<24))
			else
			{
				new Float:flAdjustedDamage
				switch(Get_MissileWeaponHitGroup(bow)) 
				{
					case HIT_GENERIC: flAdjustedDamage = 0.65
					case HIT_STOMACH: flAdjustedDamage = 0.75
					case HIT_LEFTLEG, HIT_RIGHTLEG: flAdjustedDamage = 0.4
					case HIT_LEFTARM, HIT_RIGHTARM: flAdjustedDamage = 0.4
					case HIT_CHEST: flAdjustedDamage = 0.8
				}
				cod_inflict_damage(owner, touched, 10.0, flAdjustedDamage, bow, (1<<24))
			}
		}
	}
	else
	{
		set_pev(bow, pev_movetype, MOVETYPE_NONE)
		set_pev(bow, pev_solid, SOLID_NOT)
	}
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
	write_byte(TE_KILLBEAM) 
	write_short(bow) 
	message_end()
	
	set_task(1.0, "Remove_Bow_Ent", bow)
}

public Remove_Bow_Ent(bow)
{
	if(!pev_valid(bow))
		return
	
	remove_entity(bow)
}

public Forward_Bow_Think(bow)
{
	if(!pev_valid(bow))
		return
	
	new Float:fTimeRemove
	pev(bow, pev_fuser1, fTimeRemove)
	
	if(get_gametime() >= fTimeRemove - 0.25)
	{
		new Float:fade_out
		pev(bow, pev_renderamt, fade_out)
		fade_out -= 30.0
		fade_out = floatmax(fade_out, 0.0)
		set_pev(bow, pev_rendermode, kRenderTransAdd)
		set_pev(bow, pev_renderamt, fade_out)
		set_pev(bow, pev_nextthink, get_gametime() + 0.05)
		return;
	}
	else if(get_gametime() >= fTimeRemove)
	{
		engfunc(EngFunc_RemoveEntity, bow)
		return;
	}
}

/* ================= END OF ALL ENGINE FORWARD ================= */
/* ================= START OF ALL MESSAGE FORWARD ================ */
public Forward_DeathMsg(msg_id, msg_dest, id)
{
	static szTruncatedWeapon[33], iAttacker, iVictim
	
	get_msg_arg_string(4, szTruncatedWeapon, charsmax(szTruncatedWeapon))
	
	iAttacker = get_msg_arg_int(1)
	iVictim = get_msg_arg_int(2)
	
	if(!is_user_connected(iAttacker) || iAttacker == iVictim)
		return PLUGIN_CONTINUE
	
	if(equal(szTruncatedWeapon, system_base) && get_user_weapon(iAttacker) == CSW_BASE)
	{
		if(g_has_weapon[iAttacker])
			set_msg_arg_string(4, system_name)
	}
	return PLUGIN_CONTINUE
}
/* ================== END OF ALL MESSAGE FORWARD ================ */
/* ================== START OF ALL EVENT FORWARD ================ */
public Event_CurrentWeapon(id)
{
	replace_weapon_models(id, read_data(2))
}

public Event_RoundStart()
{
	// Remove All Bow
	remove_entity_name("arjuna_bow")
}

/* ================== END OF ALL EVENT FORWARD =================== */
/* ================== START OF ALL HAM FORWARD ============== */
public Forward_TraceAttack(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
	if(!is_user_alive(iAttacker) || !is_user_connected(iAttacker))
		return FMRES_IGNORED
	if(get_user_weapon(iAttacker) == CSW_BASE && g_has_weapon[iAttacker])
	{
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public Weapon_PrimaryAttack(weapon_entity)
{
	if(!pev_valid(weapon_entity))
		return HAM_IGNORED
		
	new Player = get_pdata_cbase(weapon_entity, 41, 4)
	
	if(g_has_weapon[Player] && get_user_weapon(Player) == CSW_BASE)
	{
		return HAM_SUPERCEDE
	}
	
	return HAM_IGNORED
}

public Weapon_Deploy_Post(weapon_entity)
{
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_entity)
	
	static weaponid
	weaponid = cs_get_weapon_id(weapon_entity)
	
	replace_weapon_models(owner, weaponid)
}

public Weapon_AddToPlayer(weapon_entity, id)
{
	if(!is_valid_ent(weapon_entity) || !is_user_connected(id) || !g_has_weapon[id])
		return HAM_IGNORED
	
	if(entity_get_int(weapon_entity, EV_INT_WEAPONKEY) == WEAPON_KEY)
	{
		entity_set_int(weapon_entity, EV_INT_WEAPONKEY, 0)
		return HAM_HANDLED
	}
	
	return HAM_IGNORED
}

public Weapon_ItemPostFrame(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)
	
	if(!is_user_connected(id))
		return HAM_IGNORED
	if(!g_has_weapon[id])
		return HAM_IGNORED

	if(!get_pdata_int(weapon_entity, 74, 4))
	{		
		if(get_pdata_float(id, 83, 5) <= 0.0 && get_pdata_float(weapon_entity, 46, 4) <= 0.0 ||
		get_pdata_float(weapon_entity, 47, 4) <= 0.0 || get_pdata_float(weapon_entity, 48, 4) <= 0.0)
		{
			if(pev(id, pev_button) & IN_ATTACK)
			{
				shoot_bow(id)
			}
		}
	}
	
	return HAM_IGNORED
}

public Weapon_Reload(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)
	if(!is_user_connected(id))
		return HAM_IGNORED
	if(!g_has_weapon[id])
		return HAM_IGNORED

	return HAM_SUPERCEDE
}

public Weapon_Reload_Post(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)
	if(!is_user_connected(id))
		return HAM_IGNORED
	if(!g_has_weapon[id])
		return HAM_IGNORED
	if(g_weapon_TmpClip[id] == -1)
		return HAM_IGNORED
	
	return HAM_SUPERCEDE
}

/* ===================== END OF ALL HAM FORWARD ====================== */
/* ================= START OF OTHER PUBLIC FUNCTION  ================= */
public cod_class_enabled(id)
{
	if(!cod_get_user_elite_arjuna(id))
	{
		client_print(id, print_chat, "[ELITE] You Don't Have Permission To Use The Class")
		return COD_STOP
	}
	
	new weapon_entity = fm_give_item(id, weapon_base_buffer)
	if(weapon_entity > 0)
	{
		cs_set_weapon_ammo(weapon_entity, 10)
		cs_set_user_bpammo(id, CSW_BASE, 0)
		
		emit_sound(id, CHAN_ITEM, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		
		set_weapon_anim(id, ANIM_DRAW)
		set_pdata_float(id, 83, DRAW_TIME, 5)
	}
	
	g_has_weapon[id] = true
	
	return COD_CONTINUE
}

public cod_class_disabled(id)
{
	g_has_weapon[id] = false
}

public weapon_hook(id)
{
	engclient_cmd(id, weapon_base_buffer)
	return PLUGIN_HANDLED
}

public replace_weapon_models(id, weaponid)
{
	switch(weaponid)
	{
		case CSW_BASE:
		{
			if(g_has_weapon[id])
			{
				new weapon_entity = fm_cs_get_current_weapon_ent(id)
				cs_set_weapon_ammo(weapon_entity, 10)
				cs_set_user_bpammo(id, CSW_BASE, 0)
				
				set_pev(id, pev_viewmodel2, V_MODEL)
				set_pev(id, pev_weaponmodel2, P_MODEL)
				
				if(oldweap[id] != CSW_BASE) 
				{
					set_weapon_anim(id, ANIM_DRAW)
					set_player_nextattackx(id, DRAW_TIME)
					set_weapons_timeidle(id, CSW_BASE, DRAW_TIME)
					set_pdata_string(id, (492) * 4, ANIMEXT, -1 , 20)
				}
			}
		}
	}
	
	oldweap[id] = weaponid
}

public shoot_bow(id)
{
	if(!is_user_alive(id))
		return
	
	new weapon_entity = fm_cs_get_current_weapon_ent(id)
	
	if(!pev_valid(weapon_entity) || get_user_weapon(id) != CSW_BASE)
		return
	
	static iAnimDesired,  szAnimation[64]

	set_player_nextattackx(id, 0.8)
	set_weapons_timeidle(id, CSW_BASE, 0.8)
	
	ExecuteHamB(Ham_Weapon_PrimaryAttack, weapon_entity)
	
	formatex(szAnimation, charsmax(szAnimation), (pev(id, pev_flags) & FL_DUCKING) ? "crouch_shoot_%s" : "ref_shoot_%s", ANIMEXT)
	if((iAnimDesired = lookup_sequence(id, szAnimation)) == -1)
		iAnimDesired = 0
	
	set_pev(id, pev_sequence, iAnimDesired)
	
	set_weapon_anim(id, !g_attack_type[id] ? ANIM_SHOOT1 : ANIM_SHOOT2)
	g_attack_type[id] = !g_attack_type[id] ? 1 : 0
	
	static Float:StartOrigin[3], Float:TargetOrigin[3], Float:angles[3], Float:angles_fixed[3]
	get_position(id, 2.0, 4.0, -1.0, StartOrigin)
	
	pev(id, pev_v_angle, angles)
	new bow = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	
	if(!pev_valid(bow))
		return
	
	angles_fixed[0] = 180.0 - angles[0]
	angles_fixed[1] = angles[1]
	angles_fixed[2] = angles[2]

	set_pev(bow, pev_movetype, MOVETYPE_FLY)
	set_pev(bow, pev_owner, id)
	
	entity_set_string(bow, EV_SZ_classname, "arjuna_bow")
	engfunc(EngFunc_SetModel, bow, S_MODEL)
	set_pev(bow, pev_mins,{ -0.1, -0.1, -0.1 })
	set_pev(bow, pev_maxs,{ 0.1, 0.1, 0.1 })
	set_pev(bow, pev_origin, StartOrigin)
	set_pev(bow, pev_angles, angles_fixed)
	set_pev(bow, pev_gravity, 0.01)
	set_pev(bow, pev_solid, SOLID_BBOX)
	set_pev(bow, pev_iuser1, get_user_team(id))
	set_pev(bow, pev_iuser2, 0)
	set_pev(bow, pev_fuser1, get_gametime() + 1.0)
	
	set_pev(bow, pev_rendermode, kRenderNormal)
	set_pev(bow, pev_renderamt, 255.0)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(bow)
	write_short(sTrail)
	write_byte(5)
	write_byte(1)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(200)
	message_end()
	
	static Float:Velocity[3]
	fm_get_aim_origin(id, TargetOrigin)
	get_speed_vector(StartOrigin, TargetOrigin, 2000.0, Velocity)
	set_pev(bow, pev_velocity, Velocity)
	
	static Float:PunchAngles[3]
	PunchAngles[0] = random_float(-3.5, -7.0)
	PunchAngles[1] = random_float(3.0, -3.0)
	set_pev(id, pev_punchangle, PunchAngles)
	
	emit_sound(id, CHAN_WEAPON, Fire_Sounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	cs_set_weapon_ammo(weapon_entity, 10)
}

/* ============= END OF OTHER PUBLIC FUNCTION (Weapon) ============= */
/* ================= START OF ALL STOCK TO MACROS ================== */
stock get_position(id,Float:forw, Float:right, Float:up, Float:vStart[])
{
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_view_ofs, vUp) //for player
	xs_vec_add(vOrigin, vUp, vOrigin)
	pev(id, pev_v_angle, vAngle) // if normal entity ,use pev_angles
	
	angle_vector(vAngle, ANGLEVECTOR_FORWARD, vForward) //or use EngFunc_AngleVectors
	angle_vector(vAngle, ANGLEVECTOR_RIGHT, vRight)
	angle_vector(vAngle, ANGLEVECTOR_UP, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}

stock set_player_nextattackx(id, Float:nexttime)
{
	if(!is_user_alive(id))
		return
		
	set_pdata_float(id, 83, nexttime, 5)
}

stock set_weapons_timeidle(id, WeaponId ,Float:TimeIdle)
{
	if(!is_user_alive(id))
		return
		
	static entwpn; entwpn = fm_get_user_weapon_entity(id, WeaponId)
	if(!pev_valid(entwpn)) 
		return
		
	set_pdata_float(entwpn, 46, TimeIdle, 4)
	set_pdata_float(entwpn, 47, TimeIdle, 4)
	set_pdata_float(entwpn, 48, TimeIdle + 1.0, 4)
}

stock set_weapon_anim(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player)
	write_byte(Sequence)
	write_byte(0)
	message_end()
}

stock precache_viewmodel_sound(const model[])
{
	new file, i, k
	if((file = fopen(model, "rt")))
	{
		new szsoundpath[64], NumSeq, SeqID, Event, NumEvents, EventID
		fseek(file, 164, SEEK_SET)
		fread(file, NumSeq, BLOCK_INT)
		fread(file, SeqID, BLOCK_INT)
		
		for(i = 0; i < NumSeq; i++)
		{
			fseek(file, SeqID + 48 + 176 * i, SEEK_SET)
			fread(file, NumEvents, BLOCK_INT)
			fread(file, EventID, BLOCK_INT)
			fseek(file, EventID + 176 * i, SEEK_SET)
			
			// The Output Is All Sound To Precache In ViewModels (GREAT :V)
			for(k = 0; k < NumEvents; k++)
			{
				fseek(file, EventID + 4 + 76 * k, SEEK_SET)
				fread(file, Event, BLOCK_INT)
				fseek(file, 4, SEEK_CUR)
				
				if(Event != 5004)
					continue
				
				fread_blocks(file, szsoundpath, 64, BLOCK_CHAR)
				
				if(strlen(szsoundpath))
				{
					strtolower(szsoundpath)
					engfunc(EngFunc_PrecacheSound, szsoundpath)
				}
			}
		}
	}
	fclose(file)
}

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	static Float:num; num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}

stock fm_cs_get_weapon_ent_owner(ent)
{
	return get_pdata_cbase(ent, 41, 4)
}

stock fm_cs_get_current_weapon_ent(id)
{
	return get_pdata_cbase(id, 373, 5)
}

stock Get_MissileWeaponHitGroup(iEnt)
{
	new Float:flStart[ 3 ], Float:flEnd[ 3 ];
	pev( iEnt, pev_origin, flStart );
	pev( iEnt, pev_velocity, flEnd );
	xs_vec_add( flStart, flEnd, flEnd );
	
	new ptr = create_tr2();
	engfunc( EngFunc_TraceLine, flStart, flEnd, 0, iEnt, ptr );
	
	free_tr2( ptr );
	
	return get_tr2( ptr, TR_iHitgroup );
}

stock cod_get_user_elite_arjuna(id)
{
	static nickname[33]
	get_user_name(id, nickname, 32)
	
	for(new nick_law = 0; nick_law < sizeof(DAFTAR_NICK_ELITE_ARJUNA); nick_law++)
	{
		if(equal(nickname, DAFTAR_NICK_ELITE_ARJUNA[nick_law]))
			return 1;
	}
	
	return 0;
}

/* ================= END OF ALL STOCK AND PLUGINS CREATED ================== */
