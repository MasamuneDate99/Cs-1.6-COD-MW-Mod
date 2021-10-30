#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <cstrike>
#include <zombieplague>

/////////////////////////////////////////////
#define PLUGIN "[Z47] M3 Black Dragon"	/////
#define VERSION "1.2"			/////
#define AUTHOR "ZinoZack47"		/////
/////////////////////////////////////////////

#define MBD_WEAPONKEY			2346647

#define WEAP_LINUX_XTRA_OFF		4
#define PLAYER_LINUX_XTRA_OFF		5

#define m_pPlayer             		41
#define m_flNextPrimaryAttack 		46
#define m_flNextSecondaryAttack 	47
#define m_flTimeWeaponIdle		48
#define m_iClip				51
#define m_fInReload			54
#define m_fInSpecialReload 		55
#define m_flNextReload			75

#define m_flNextAttack			83
#define m_pActiveItem 			373

#define OFFSET_M3_AMMO               	381

#define MBD_DRAW_TIME     		1.0

#define CSW_MBD 			CSW_M3
#define weapon_mbd			"weapon_m3"

#define  MBD_FIRE_CLASSNAME 		"mbd_fire"
#define  MBD_EGG_CLASSNAME 		"mbd_egg"
#define  MBD_DRAGON_CLASSNAME 		"mbd_dragon"

const i_LastHitGroup = 75
const pev_life = pev_fuser1

enum
{
	MODE_NORMAL,
	MODE_NORMAL2,
	MODE_FIRE
}

enum
{
	MBD_IDLE = 0,
	MBD_SHOOT,
	MBD_SHOOT2,
	MBD_INSERT,
	MBD_AFTER_RELOAD,
	MBD_BEFORE_RELOAD,
	MBD_DRAW,
	MBD_SECONDARY_READY,
	MBD_SECONDARY_SHOOT,
	MBD_SECONDARY_INSERT,
	MBD_SECONDARY_AFTER_RELOAD,
	MBD_SECONDARY_BEFORE_RELOAD,
	MBD_SECONDARY_DRAW
}

new MBD_V_MODEL[64] = "models/z47_m3dragon/v_m3dragon.mdl"
new MBD_P_MODEL[64] = "models/z47_m3dragon/p_m3dragon.mdl"
new MBD_W_MODEL[64] = "models/z47_m3dragon/w_m3dragon.mdl"

new const MBD_Sounds[][] = 
{
	"weapons/z47_m3dragon/m3dragon-1_1.wav",
	"weapons/z47_m3dragon/m3dragon-1_2.wav",
	"weapons/z47_m3dragon/m3dragon-2.wav",
	"weapons/z47_m3dragon/m3dragon_secondary_draw.wav",
	"weapons/z47_m3dragon/m3dragon_reload_insert.wav",
	"weapons/z47_m3dragon/m3dragon_after_reload.wav",
	"weapons/z47_m3dragon/m3dragon_fire_loop.wav",
	"weapons/z47_m3dragon/m3dragon_dragon_fx.wav",
	"weapons/z47_m3dragon/m3dragon_exp.wav"
}

new const MBD_Effects[][] = 
{
	"models/z47_m3dragon/ef_fireball2.mdl",
	"models/z47_m3dragon/m3dragon_effect.mdl"
}

new const MBD_Sprites[][] = 
{
	"sprites/weapon_m3dragon.txt",
	"sprites/640hud18_47.spr",
	"sprites/640hud19_47.spr",
	"sprites/640hud43_47.spr",
	"sprites/m3dragon_flame.spr",
	"sprites/m3dragon_flame2.spr"
}

new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 }

new cvar_dmg_mbd, cvar_recoil_mbd, g_itemid, cvar_clip_mbd, cvar_mbd_ammo, cvar_one_round
new g_maxplayers, g_orig_event_mbd, g_IsInPrimaryAttack, g_iClip, g_clip_counter[33]
new Float:cl_pushangle[33][3], m_iBlood[2]
new bool:g_has_mbd[33], g_clip_ammo[33], g_current_mode[33], g_MBDFire[33][2]
new g_MsgWeaponList, g_MsgCurWeapon

const PRIMARY_WEAPONS_BIT_SUM =
(1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|
(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")

	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	RegisterHam(Ham_Killed, "player", "fw_Killed")
	RegisterHam(Ham_Item_Deploy, weapon_mbd, "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_mbd, "fw_M3Dragon_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_mbd, "fw_M3Dragon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Item_PostFrame, weapon_mbd, "fw_M3Dragon_ItemPostFrame")
	RegisterHam(Ham_Weapon_Reload, weapon_mbd, "fw_M3Dragon_Reload")
	RegisterHam(Ham_Item_AddToPlayer, weapon_mbd, "fw_M3Dragon_AddToPlayer")
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_mbd, "fw_M3Dragon_WeaponIdle_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_wall", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_door", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_plat", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_rotating", "fw_TraceAttack", 1)

	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_forward(FM_Think, "fw_Think")
	register_forward(FM_Touch, "fw_Touch")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")

	cvar_clip_mbd = register_cvar("zp_m3blackdragon_clip", "8")
	cvar_mbd_ammo = register_cvar("zp_m3blackdragon_ammo", "12")
	cvar_dmg_mbd = register_cvar("zp_m3blackdragon_dmg", "500")
	cvar_recoil_mbd = register_cvar("zp_m3blackdragon_recoil", "0.6")
	cvar_one_round = register_cvar("zp_m3blackdragon_one_round", "1")

	g_MsgWeaponList = get_user_msgid("WeaponList")
	g_MsgCurWeapon = get_user_msgid("CurWeapon")

	g_itemid = zp_register_extra_item("M3 Black Dragon", 0, ZP_TEAM_HUMAN)

	register_clcmd("weapon_m3dragon", "select_m3dragon")
	g_maxplayers = get_maxplayers()
}

public plugin_precache()
{
	precache_model(MBD_V_MODEL)
	precache_model(MBD_P_MODEL)
	precache_model(MBD_W_MODEL)

	for(new i = 0; i < sizeof(MBD_Sounds); i++)
		precache_sound(MBD_Sounds[i])	
	
	for(new i = 0; i < sizeof(MBD_Sprites); i++)
		0 <= i <= 2 ? precache_generic(MBD_Sprites[i]) : precache_model(MBD_Sprites[i])

	for(new i = 0; i < sizeof(MBD_Effects); i++)
		precache_model(MBD_Effects[i])

	m_iBlood[0] = precache_model("sprites/blood.spr")
	m_iBlood[1] = precache_model("sprites/bloodspray.spr")
	
	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1)

}

public plugin_natives ()
	register_native("give_weapon_mbd", "native_give_weapon_add", 1)

public native_give_weapon_add(id)
	give_m3dragon(id)

public select_m3dragon(id)
{
    engclient_cmd(id, weapon_mbd)
    return PLUGIN_HANDLED
}

public fw_PrecacheEvent_Post(type, const name[])
{
	new weapon[32], event_mbd[64]
	
	copy(weapon, charsmax(weapon), weapon_mbd)
	replace(weapon, charsmax(weapon), "weapon_", "")

	formatex(event_mbd, charsmax(event_mbd), "events/%s.sc", weapon)

	if (equal(event_mbd, name))
	{
		g_orig_event_mbd = get_orig_retval()
		return FMRES_HANDLED
	}

	return FMRES_IGNORED
}

public Event_NewRound()
{
	for(new id = 0; id <= g_maxplayers; id++)
	{
		if(!g_has_mbd[id])

		if(get_pcvar_num(cvar_one_round))
			remove_m3dragon(id)
	}
}

public fw_Killed(id)
	remove_m3dragon(id)

public zp_user_humanized_post(id)
	remove_m3dragon(id)

public client_disconnect(id)
	remove_m3dragon(id)

public zp_user_infected_post(id)
	remove_m3dragon(id)


public fw_SetModel(entity, model[])
{
	if(!pev_valid(entity))
		return FMRES_IGNORED

	static weapon[32], old_mbd[64]

	if(!fm_is_ent_classname(entity, "weaponbox"))
		return FMRES_IGNORED

	copy(weapon, charsmax(weapon), weapon_mbd)
	replace(weapon, charsmax(weapon), "weapon_", "")

	formatex(old_mbd, charsmax(old_mbd), "models/w_%s.mdl", weapon)

	static owner
	owner = pev(entity, pev_owner)

	if(equal(model, old_mbd))
	{
		static StoredWepID
		
		StoredWepID = fm_find_ent_by_owner(-1, weapon_mbd, entity)
	
		if(!pev_valid(StoredWepID))
			return FMRES_IGNORED
	
		if(g_has_mbd[owner])
		{
			set_pev(StoredWepID, pev_impulse, MBD_WEAPONKEY)

			remove_m3dragon(owner)

			engfunc(EngFunc_SetModel, entity, MBD_W_MODEL)
						
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

public give_m3dragon(id)
{
	drop_weapons(id, 1)

	g_has_mbd[id] = true
	g_current_mode[id] = MODE_NORMAL

	fm_give_item(id, weapon_mbd)
	
	static weapon; weapon = fm_get_user_weapon_entity(id, CSW_MBD)

	if(pev_valid(weapon)) cs_set_weapon_ammo(weapon, get_pcvar_num(cvar_clip_mbd))	

	message_begin(MSG_ONE_UNRELIABLE, g_MsgWeaponList, .player = id)
	write_string("weapon_m3dragon")
	write_byte(5)
	write_byte(32)
	write_byte(-1)
	write_byte(-1)
	write_byte(0) 
	write_byte(5)
	write_byte(CSW_MBD)
	write_byte(0)
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, g_MsgCurWeapon, .player = id)
	write_byte(1)
	write_byte(CSW_MBD)
	write_byte(get_pcvar_num(cvar_clip_mbd))
	message_end()

	cs_set_user_bpammo(id, CSW_MBD, get_pcvar_num(cvar_mbd_ammo))

	make_fire(id)
}

public remove_m3dragon(id)
{
	g_has_mbd[id] = false
	g_current_mode[id] = MODE_NORMAL
	g_clip_counter[id] = 0
	
	if (pev_valid(g_MBDFire[id][0]) && pev_valid(g_MBDFire[id][1]))
	{
		engfunc(EngFunc_RemoveEntity, g_MBDFire[id][0])
		g_MBDFire[id][0] = 0
		engfunc(EngFunc_RemoveEntity, g_MBDFire[id][1])
		g_MBDFire[id][1] = 0
	}

}

public fw_TraceAttack(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
	if(!is_user_alive(iAttacker))
		return HAM_IGNORED

	new g_currentweapon = get_user_weapon(iAttacker)

	if(g_currentweapon != CSW_MBD || !g_has_mbd[iAttacker])
		return HAM_IGNORED

	static Float:flEnd[3]
	get_tr2(ptr, TR_vecEndPos, flEnd)

	if(iEnt)
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_DECAL)
		engfunc(EngFunc_WriteCoord, flEnd[0])
		engfunc(EngFunc_WriteCoord, flEnd[1])
		engfunc(EngFunc_WriteCoord, flEnd[2])
		write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
		write_short(iEnt)
		message_end()
	}
	else
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		engfunc(EngFunc_WriteCoord, flEnd[0])
		engfunc(EngFunc_WriteCoord, flEnd[1])
		engfunc(EngFunc_WriteCoord, flEnd[2])
		write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
		message_end()
	}

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_GUNSHOTDECAL)
	engfunc(EngFunc_WriteCoord, flEnd[0])
	engfunc(EngFunc_WriteCoord, flEnd[1])
	engfunc(EngFunc_WriteCoord, flEnd[2])
	write_short(iAttacker)
	write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
	message_end()

	return HAM_IGNORED
}

public zp_extra_item_selected(id, itemid)
{
	if(itemid != g_itemid)
		return

	give_m3dragon(id)
}

public fw_M3Dragon_AddToPlayer(item, id)
{
	if(!pev_valid(item))
		return HAM_IGNORED

	switch(pev(item, pev_impulse))
	{
		case 0:
		{
			message_begin(MSG_ONE, g_MsgWeaponList, .player = id)
			write_string(weapon_mbd)
			write_byte(5)
			write_byte(32)
			write_byte(-1)
			write_byte(-1)
			write_byte(0) 
			write_byte(5)
			write_byte(CSW_MBD)
			write_byte(0)
			message_end()
			
			return HAM_IGNORED
		}
		case MBD_WEAPONKEY:
		{
			g_has_mbd[id] = true
			
			message_begin(MSG_ONE, g_MsgWeaponList, .player = id)
			write_string("weapon_m3dragon")
			write_byte(5)
			write_byte(32)
			write_byte(-1)
			write_byte(-1)
			write_byte(0) 
			write_byte(5)
			write_byte(CSW_MBD)
			write_byte(0)
			message_end()

			set_pev(item, pev_impulse, 0)
			
			return HAM_HANDLED
		}
	}

	return HAM_IGNORED
}

public fw_Item_Deploy_Post(weapon_ent)
{
	if(pev_valid(weapon_ent) != 2)
		return

	static id
	id = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	if(fm_cs_get_current_weapon_ent(id) != weapon_ent)
		return

	if(!g_has_mbd[id])
		return

	set_pev(id, pev_viewmodel2, MBD_V_MODEL)
	set_pev(id, pev_weaponmodel2, MBD_P_MODEL)

	switch(g_current_mode[id])
	{
		case MODE_NORMAL, MODE_NORMAL2: fm_play_weapon_animation(id, MBD_DRAW)
		case MODE_FIRE: fm_play_weapon_animation(id, MBD_SECONDARY_DRAW)
	}

	fm_set_weapon_idle_time(id, weapon_mbd, MBD_DRAW_TIME)
}

public fw_M3Dragon_WeaponIdle_Post(iEnt)
{
	if(pev_valid(iEnt) != 2)
		return HAM_IGNORED

	new id = fm_cs_get_weapon_ent_owner(iEnt)

	if(fm_cs_get_current_weapon_ent(id) != iEnt)
		return HAM_IGNORED

	if (!g_has_mbd[id])
		return HAM_IGNORED;

	if(get_pdata_float(iEnt, m_flTimeWeaponIdle, WEAP_LINUX_XTRA_OFF) > 0.0 )
		return HAM_IGNORED
	
	new iClip = get_pdata_int(iEnt, m_iClip, WEAP_LINUX_XTRA_OFF)
	new iMaxClip = get_pcvar_num(cvar_clip_mbd)
	new fInSpecialReload = get_pdata_int(iEnt, m_fInSpecialReload, WEAP_LINUX_XTRA_OFF)

	if(!iClip && !fInSpecialReload)
		return HAM_IGNORED

	if(fInSpecialReload)
	{
		static iBpAmmo; iBpAmmo = get_pdata_int(id, OFFSET_M3_AMMO, PLAYER_LINUX_XTRA_OFF)

		if(iClip < iMaxClip && iClip == 8 && iBpAmmo)
			Shotgun_Reload(iEnt, iMaxClip, iClip, iBpAmmo, id)

		else if(iClip == iMaxClip && iClip != 8)
		{
			fm_play_weapon_animation(id, g_current_mode[id] == MODE_FIRE ? MBD_SECONDARY_AFTER_RELOAD : MBD_AFTER_RELOAD)
			
			set_pdata_int(iEnt, m_fInSpecialReload, 0, WEAP_LINUX_XTRA_OFF)
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.5, WEAP_LINUX_XTRA_OFF)
		}

	}
	else
	{
		switch(g_current_mode[id])
		{
			case MODE_NORMAL, MODE_NORMAL2: fm_play_weapon_animation(id, MBD_IDLE)
			case MODE_FIRE: fm_play_weapon_animation(id, MBD_SECONDARY_READY)
		}
	}
	return HAM_IGNORED
}

public fw_UpdateClientData_Post(id, SendWeapons, CD_Handle)
{
	if(!is_user_alive(id) || get_user_weapon(id) != CSW_MBD || !g_has_mbd[id])
		return FMRES_IGNORED
	
	set_cd(CD_Handle, CD_flNextAttack, get_gametime() + 0.001)
	return FMRES_HANDLED
}

public fw_M3Dragon_PrimaryAttack(Weapon)
{
	new id = fm_cs_get_weapon_ent_owner(Weapon)
	
	if (!g_has_mbd[id])
		return HAM_IGNORED

	g_IsInPrimaryAttack = 1
	pev(id, pev_punchangle, cl_pushangle[id])

	g_clip_ammo[id] = cs_get_weapon_ammo(Weapon)
	g_iClip = cs_get_weapon_ammo(Weapon)

	return HAM_IGNORED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if (eventid != g_orig_event_mbd || !g_IsInPrimaryAttack)
		return FMRES_IGNORED
	
	if (!(1 <= invoker <= g_maxplayers))
    	return FMRES_IGNORED

	engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	return FMRES_SUPERCEDE
}

public fw_M3Dragon_PrimaryAttack_Post(Weapon)
{
	g_IsInPrimaryAttack = 0
	new id = fm_cs_get_weapon_ent_owner(Weapon)
	
	if(!is_user_alive(id))
		return HAM_IGNORED

	new szClip, szAmmo
	get_user_weapon(id, szClip, szAmmo)

	if(g_iClip <= cs_get_weapon_ammo(Weapon))
		return HAM_IGNORED

	if(g_has_mbd[id])
	{
		if (!g_clip_ammo[id])
			return HAM_IGNORED

		new Float:push[3]

		pev(id,pev_punchangle,push)
		xs_vec_sub(push,cl_pushangle[id],push)

		xs_vec_mul_scalar(push, get_pcvar_float(cvar_recoil_mbd), push)
		xs_vec_add(push, cl_pushangle[id], push)
		set_pev(id,pev_punchangle, push)

		switch(g_current_mode[id])
		{
			case MODE_NORMAL:
			{
				fm_play_weapon_animation(id, MBD_SHOOT)
				emit_sound(id, CHAN_WEAPON, MBD_Sounds[MODE_NORMAL], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			}
			case MODE_NORMAL2:
			{
				fm_play_weapon_animation(id, MBD_SHOOT2)
				emit_sound(id, CHAN_WEAPON, MBD_Sounds[MODE_NORMAL2], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			}
			case MODE_FIRE: 
			{
				fm_play_weapon_animation(id, MBD_SECONDARY_SHOOT)
				emit_sound(id, CHAN_WEAPON, MBD_Sounds[MODE_FIRE], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		
	}

	return HAM_IGNORED
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damagetype)
{
	if (victim != attacker && is_user_connected(attacker))
	{
		if(get_user_weapon(attacker) == CSW_MBD)
		{
			if(g_has_mbd[attacker])
			{
				new g_HitGroup = get_pdata_int(victim, i_LastHitGroup)
				switch(g_HitGroup)
				{
					case HIT_HEAD: damage = get_pcvar_num(cvar_dmg_mbd) * 2.0
					case HIT_LEFTARM .. HIT_RIGHTLEG: damage = get_pcvar_num(cvar_dmg_mbd) * 0.75
					case HIT_CHEST, HIT_STOMACH: damage = float(get_pcvar_num(cvar_dmg_mbd))
				}
				if(~damagetype & DMG_SLASH)
					Check_Counter(attacker)
				
				SetHamParamFloat(4, damage)		
			}
		}
	}
}

public message_DeathMsg(msg_id, msg_dest, id)
{
	static TruncatedWeapon[33], iAttacker, iVictim, weapon[32]
	
	copy(weapon, charsmax(weapon), weapon_mbd)
	replace(weapon, charsmax(weapon), "weapon_", "")

	get_msg_arg_string(4, TruncatedWeapon, charsmax(TruncatedWeapon))

	iAttacker = get_msg_arg_int(1)
	iVictim = get_msg_arg_int(2)

	if(!is_user_connected(iAttacker) || iAttacker == iVictim)
		return PLUGIN_CONTINUE

	if(equal(TruncatedWeapon, weapon) && get_user_weapon(iAttacker) == CSW_MBD && g_has_mbd[iAttacker])
			set_msg_arg_string(4, "m3dragon")

	return PLUGIN_CONTINUE
}

public fw_M3Dragon_ItemPostFrame(weapon_entity) 
{
	if(!pev_valid(weapon_entity))
		return HAM_IGNORED
		
	new id = fm_cs_get_weapon_ent_owner(weapon_entity)

	if (!is_user_connected(id))
		return HAM_IGNORED

	if (!g_has_mbd[id])
		return HAM_IGNORED

	new iClipExtra = get_pcvar_num(cvar_clip_mbd)
	new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)

	new iBpAmmo = cs_get_user_bpammo(id, CSW_MBD)
	new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)
	new iButton = pev(id, pev_button)
	new fInReload = get_pdata_int(weapon_entity, m_fInReload, WEAP_LINUX_XTRA_OFF) 

	if(fInReload && flNextAttack <= 0.0)
	{
		new j = min(iClipExtra - iClip, iBpAmmo)
		set_pdata_int(weapon_entity, m_iClip, iClip + j, WEAP_LINUX_XTRA_OFF)
		set_pdata_int(id, OFFSET_M3_AMMO, iBpAmmo-j, PLAYER_LINUX_XTRA_OFF)
		set_pdata_int(weapon_entity, m_fInReload, 0, WEAP_LINUX_XTRA_OFF)

		cs_set_weapon_ammo(weapon_entity, get_pcvar_num(cvar_clip_mbd))
	}

	M3Dragon_Dance(id, weapon_entity, iButton)

	return HAM_IGNORED
}

public fw_PlayerPreThink(id)
{
	if(get_user_weapon(id) != CSW_MBD || !g_has_mbd[id])
		return FMRES_IGNORED

	if(g_current_mode[id] == MODE_FIRE)
	{
		if (pev_valid(g_MBDFire[id][0]) && pev_valid(g_MBDFire[id][1]))
		{
			fm_set_entity_visibility(g_MBDFire[id][0])
			fm_set_entity_visibility(g_MBDFire[id][1])
		}
	}
	else
	{
		if (pev_valid(g_MBDFire[id][0]) && pev_valid(g_MBDFire[id][1]))
		{
			fm_set_entity_visibility(g_MBDFire[id][0], false)
			fm_set_entity_visibility(g_MBDFire[id][1], false)
		}
	}

	return FMRES_IGNORED
}

public M3Dragon_Dance(id, weapon_entity, iButton)
{
	if(get_pdata_float(id, m_flNextAttack) > 0.0)
		return

	if(get_pdata_float(weapon_entity, m_flNextSecondaryAttack, WEAP_LINUX_XTRA_OFF) <= 0.0 && iButton & IN_ATTACK2 && iButton & ~IN_ATTACK)
	{
		switch(g_current_mode[id])
		{
			case MODE_NORMAL:
			{
				if(g_clip_ammo[id])
				{
					g_current_mode[id] = MODE_NORMAL2
					ExecuteHamB(Ham_Weapon_PrimaryAttack, weapon_entity)
					if(g_current_mode[id] != MODE_FIRE) g_current_mode[id] = MODE_NORMAL
				}
			}
			case MODE_FIRE:
			{
				shoot_ball(id)
				g_current_mode[id] = MODE_NORMAL
			}
		}
	}
}

public shoot_ball(id)
{
	new mbd_egg = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	
	if(!pev_valid(mbd_egg))
		return
	
	set_pev(mbd_egg, pev_classname, MBD_EGG_CLASSNAME)
	engfunc(EngFunc_SetModel, mbd_egg, MBD_Effects[0])

	set_pev(mbd_egg, pev_movetype, MOVETYPE_PUSHSTEP)
	set_pev(mbd_egg, pev_solid, SOLID_BBOX)

	static Float:Origin[3], Float:Angles[3]
	
	engfunc(EngFunc_GetAttachment, id, 2, Origin, Angles)
	pev(id, pev_angles, Angles)
	
	set_pev(mbd_egg, pev_origin, Origin)
	set_pev(mbd_egg, pev_angles, Angles)
	set_pev(mbd_egg, pev_owner, id)

	static Float:Velocity[3], Float:TargetOrigin[3]
	
	fm_get_aim_origin(id, TargetOrigin)
	get_speed_vector(Origin, TargetOrigin, 1800.0, Velocity)
	
	set_pev(mbd_egg, pev_velocity, Velocity)
}

public make_fire(id)
{
	g_MBDFire[id][0] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
	
	if(pev_valid(g_MBDFire[id][0]))
	{
		engfunc(EngFunc_SetModel, g_MBDFire[id][0], MBD_Sprites[4])
		set_pev(g_MBDFire[id][0], pev_classname, MBD_FIRE_CLASSNAME)
		set_pev(g_MBDFire[id][0], pev_body, MODE_FIRE + 1)
		set_pev(g_MBDFire[id][0], pev_aiment, id)
		set_pev(g_MBDFire[id][0], pev_movetype, MOVETYPE_FOLLOW)
		set_pev(g_MBDFire[id][0], pev_rendermode, kRenderTransAdd)
		set_pev(g_MBDFire[id][0], pev_renderamt, 200.00)
		set_pev(g_MBDFire[id][0], pev_scale, 0.1)
		set_pev(g_MBDFire[id][0], pev_frame, random_num(0, 2))
		set_pev(g_MBDFire[id][0], pev_framerate, 30.00)
		set_pev(g_MBDFire[id][0], pev_nextthink, get_gametime() + 0.05)
		dllfunc(DLLFunc_Spawn, g_MBDFire[id][0])
	}

	g_MBDFire[id][1] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
	
	if(pev_valid(g_MBDFire[id][1]))
	{
		engfunc(EngFunc_SetModel, g_MBDFire[id][1], MBD_Sprites[5])
		set_pev(g_MBDFire[id][1], pev_classname, MBD_FIRE_CLASSNAME)
		set_pev(g_MBDFire[id][1], pev_body, MODE_FIRE + 2)
		set_pev(g_MBDFire[id][1], pev_aiment, id)
		set_pev(g_MBDFire[id][1], pev_movetype, MOVETYPE_FOLLOW)
		set_pev(g_MBDFire[id][1], pev_rendermode, kRenderTransAdd)
		set_pev(g_MBDFire[id][1], pev_renderamt, 200.00)
		set_pev(g_MBDFire[id][1], pev_scale, 0.1)
		set_pev(g_MBDFire[id][1], pev_frame, random_num(0, 2))
		set_pev(g_MBDFire[id][1], pev_framerate, 30.00)
		set_pev(g_MBDFire[id][1], pev_nextthink, get_gametime() + 0.05)
		dllfunc(DLLFunc_Spawn, g_MBDFire[id][1])
	}
}

public fw_Touch(iEnt, iTouchedEnt)
{
	if (!pev_valid(iEnt))
		return FMRES_IGNORED

	if(fm_is_ent_classname(iEnt, MBD_EGG_CLASSNAME))
	{
		summon_dragon(iEnt)
		engfunc(EngFunc_RemoveEntity, iEnt)
	}

	return FMRES_IGNORED
}

public summon_dragon(mbd_egg)
{
	if(!pev_valid(mbd_egg))
		return

	new id = pev(mbd_egg, pev_owner)

	static Float:flOrigin[3]
	pev(mbd_egg, pev_origin, flOrigin)

	new mbd_dragon = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target")) 

	if(!pev_valid(mbd_dragon))
		return

	set_pev(mbd_dragon, pev_classname, MBD_DRAGON_CLASSNAME)
	
	engfunc(EngFunc_SetModel, mbd_dragon, MBD_Effects[1])

	set_pev(mbd_dragon, pev_rendermode, kRenderTransAdd)

	set_pev(mbd_dragon, pev_renderamt, 255.0)

	engfunc(EngFunc_SetOrigin, mbd_dragon, flOrigin)

	engfunc(EngFunc_DropToFloor, mbd_dragon)
	
	set_pev(mbd_dragon, pev_solid, SOLID_NOT)

	set_pev(mbd_dragon, pev_scale, 0.1)

	set_pev(mbd_dragon, pev_animtime, get_gametime())

	set_pev(mbd_dragon, pev_framerate, 1.0)
	
	set_pev(mbd_dragon, pev_sequence, 1)

	set_pev(mbd_dragon, pev_owner, id)

	set_pev(mbd_dragon, pev_life, get_gametime() + 4.5)

	set_pev(mbd_dragon, pev_nextthink, get_gametime() + 0.1)

	emit_sound(id, CHAN_STATIC, MBD_Sounds[7], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	set_task(0.2, "dragon_vortex", mbd_dragon + MBD_WEAPONKEY, .flags = "b")
}

public dragon_vortex(mbd_dragon)
{
	mbd_dragon -= MBD_WEAPONKEY

	new id = pev(mbd_dragon, pev_owner)
	static Float:flOrigin[3]
	pev(mbd_dragon, pev_origin, flOrigin)

	for(new victim = 0; victim <= g_maxplayers; victim++)
	{
		if(!is_user_connected(victim))
			continue

		if(!is_user_alive(victim) || !zp_get_user_zombie(victim))
			continue

		if(fm_entity_range(mbd_dragon, victim) >= 400.0)
			continue

		Make_Vortex(victim, flOrigin, 300)
		
		new Float:damage = float(get_pcvar_num(cvar_dmg_mbd)) / 2

		ExecuteHamB(Ham_TakeDamage, victim , id, id, damage, DMG_SLASH)		
		make_blood(victim, damage)
	}
}

public fw_Think(iEnt)
{
	if(!pev_valid(iEnt))
		return FMRES_HANDLED

	if(fm_is_ent_classname(iEnt, MBD_FIRE_CLASSNAME))
	{
		new id = pev(iEnt, pev_aiment)
		
		if(get_user_weapon(id) != CSW_MBD || g_current_mode[id] != MODE_FIRE)
		{
			if (pev_valid(g_MBDFire[id][0]) && pev_valid(g_MBDFire[id][1]))
			{
				fm_set_entity_visibility(g_MBDFire[id][0], 0)
				fm_set_entity_visibility(g_MBDFire[id][1], 0)
			}
		}

		static Float:flRenderAmt
		pev(iEnt, pev_renderamt, flRenderAmt)
		flRenderAmt = flRenderAmt + 20.00
		
		if(flRenderAmt > 200.00)
			flRenderAmt = 200.00

		set_pev(iEnt, pev_renderamt, flRenderAmt)
	}
	else if(fm_is_ent_classname(iEnt, MBD_DRAGON_CLASSNAME))
	{
		if(pev(iEnt, pev_life) - get_gametime() <= 0)
		{
			new id = pev(iEnt, pev_owner)
			set_pev(iEnt, pev_flags, FL_KILLME)
			g_clip_counter[id] = 0
			remove_task(iEnt+MBD_WEAPONKEY)
			engfunc(EngFunc_RemoveEntity, iEnt)
			return FMRES_IGNORED
		}
	}

	set_pev(iEnt, pev_nextthink, get_gametime() + 0.05)

	return FMRES_IGNORED
}

public fw_M3Dragon_Reload(mbd)
{
	if(pev_valid(mbd) != 2)
		return HAM_IGNORED

	new id = fm_cs_get_weapon_ent_owner(mbd)

	if(fm_cs_get_current_weapon_ent(id) != mbd)
		return HAM_IGNORED

	if(!g_has_mbd[id])
		return HAM_IGNORED

	new iBpAmmo = get_pdata_int(id, OFFSET_M3_AMMO, PLAYER_LINUX_XTRA_OFF) 
	new iClip = get_pdata_int(mbd, m_iClip, WEAP_LINUX_XTRA_OFF) 
	new iMaxClip = get_pcvar_num(cvar_clip_mbd)

	Shotgun_Reload(mbd, iMaxClip, iClip, iBpAmmo, id)

	return HAM_SUPERCEDE 
}

stock Shotgun_Reload(iEnt, iMaxClip, iClip, iBpAmmo, id)
{ 
	if(iBpAmmo <= 0 || iClip == iMaxClip) 
		return 

	if(get_pdata_int(iEnt, m_flNextPrimaryAttack, WEAP_LINUX_XTRA_OFF) > 0.0) 
		return

	switch(get_pdata_int(iEnt, m_fInSpecialReload, WEAP_LINUX_XTRA_OFF)) 
	{ 
		case 0: 
		{ 
			fm_play_weapon_animation(id, g_current_mode[id] == MODE_FIRE ? MBD_SECONDARY_BEFORE_RELOAD : MBD_BEFORE_RELOAD) 
			set_pdata_int(iEnt, m_fInSpecialReload, 1, WEAP_LINUX_XTRA_OFF) 
			set_pdata_float(id, m_flNextAttack, 0.2, PLAYER_LINUX_XTRA_OFF)
			fm_set_weapon_idle_time(id, weapon_mbd, 0.2)
		} 
		case 1:
		{	
			if(get_pdata_float(iEnt, m_flTimeWeaponIdle) > 0.0) 
				return 

			fm_play_weapon_animation(id, g_current_mode[id] == MODE_FIRE ? MBD_SECONDARY_INSERT : MBD_INSERT)
			set_pdata_int(iEnt, m_fInSpecialReload, 2, WEAP_LINUX_XTRA_OFF)
			set_pdata_float(iEnt, m_flNextReload, 0.2, WEAP_LINUX_XTRA_OFF)
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.5, WEAP_LINUX_XTRA_OFF) 
		} 
		case 2: 
		{
			set_pdata_int(iEnt, m_iClip, iClip+1, WEAP_LINUX_XTRA_OFF) 
			set_pdata_int(id, OFFSET_M3_AMMO, iBpAmmo-1, PLAYER_LINUX_XTRA_OFF) 
			set_pdata_int(iEnt, m_fInSpecialReload, 1, WEAP_LINUX_XTRA_OFF) 
		} 
	}
}  

stock Make_Vortex(id, Float:flOrigin[3], offset)
{
	new Float:flPlayer[3], Float:flTarget[3], Float:flVelocity[3], Float:flDistance
	
	pev(id, pev_origin, flPlayer)
	
	flPlayer[2] = 0.0
	
	flTarget[0] = flOrigin[0]
	flTarget[1] = flOrigin[1]
	flTarget[2] = 0.0

	flDistance = vector_distance(flPlayer, flTarget)
	
	flVelocity[0] = (flTarget[0] -  flPlayer[0]) / flDistance	
	flVelocity[1] = (flTarget[1] -  flPlayer[1]) / flDistance

	flTarget[0] += flVelocity[1] * offset
	flTarget[1] -= flVelocity[0] * offset
	
	flDistance = vector_distance(flPlayer, flTarget)
	
	flVelocity[0] = (flTarget[0] -  flPlayer[0]) / flDistance	
	flVelocity[1] = (flTarget[1] -  flPlayer[1]) / flDistance
	
	flVelocity[0] = flVelocity[0] * 1500
	flVelocity[1] = flVelocity[1] * 1500
	flVelocity[2] = 0.4 * 1500
	
	set_pev(id, pev_velocity, flVelocity)
}

stock make_blood(id, Float:Damage)
{
	new bloodColor = ExecuteHam(Ham_BloodColor, id)
	new Float:origin[3]
	pev(id, pev_origin, origin)

	if (bloodColor == -1)
		return

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2]))
	write_short(m_iBlood[1])
	write_short(m_iBlood[0])
	write_byte(bloodColor)
	write_byte(min(max(3, floatround(Damage)/5), 16))
	message_end()
}

stock fm_get_aim_origin(index, Float:origin[3])
{
	new Float:start[3], Float:view_ofs[3];
	pev(index, pev_origin, start);
	pev(index, pev_view_ofs, view_ofs);
	xs_vec_add(start, view_ofs, start);

	new Float:dest[3];
	pev(index, pev_v_angle, dest);
	engfunc(EngFunc_MakeVectors, dest);
	global_get(glb_v_forward, dest);
	xs_vec_mul_scalar(dest, 9999.0, dest);
	xs_vec_add(start, dest, dest);

	engfunc(EngFunc_TraceLine, start, dest, 0, index, 0);
	get_tr2(0, TR_vecEndPos, origin);

	return 1;
}

stock fm_cs_get_current_weapon_ent(id)
	return get_pdata_cbase(id, m_pActiveItem, PLAYER_LINUX_XTRA_OFF)

stock fm_cs_get_weapon_ent_owner(ent)
	return get_pdata_cbase(ent, m_pPlayer, WEAP_LINUX_XTRA_OFF)

stock fm_set_weapon_idle_time(id, const class[], Float:IdleTime)
{
	static weapon_ent
	weapon_ent = fm_find_ent_by_owner(-1, class, id)

	if(!pev_valid(weapon_ent))
		return

	set_pdata_float(weapon_ent, m_flNextPrimaryAttack, IdleTime, WEAP_LINUX_XTRA_OFF)
	set_pdata_float(weapon_ent, m_flNextSecondaryAttack, IdleTime, WEAP_LINUX_XTRA_OFF)
	set_pdata_float(weapon_ent, m_flTimeWeaponIdle, IdleTime + 0.50, WEAP_LINUX_XTRA_OFF)
}

stock fm_play_weapon_animation(const id, const Sequence)
{
	set_pev(id, pev_weaponanim, Sequence)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = id)
	write_byte(Sequence)
	write_byte(pev(id, pev_body))
	message_end()
}

stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0)
{
	new strtype[11] = "classname", ent = index;

	switch (jghgtype)
	{
		case 1: strtype = "target";
		case 2: strtype = "targetname";
	}

	while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}

	return ent;
}

stock fm_give_item(index, const item[])
{
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0;

	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item));
	
	if (!pev_valid(ent))
		return 0;

	new Float:origin[3];
	pev(index, pev_origin, origin);
	set_pev(ent, pev_origin, origin);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);

	new save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, index);
	if (pev(ent, pev_solid) != save)
		return ent;

	engfunc(EngFunc_RemoveEntity, ent);

	return -1;
}

stock Check_Counter(id)
{
	if(get_user_weapon(id) != CSW_MBD || !g_has_mbd[id])
		return

	if(g_current_mode[id] == MODE_FIRE)
		return

	if(g_clip_counter[id] >= 7)
	{
		g_current_mode[id] = MODE_FIRE
		g_clip_counter[id] = 0
		make_fire(id)
		return
	}

	g_clip_counter[id]++
}

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]

	new Float:num = floatsqroot(speed * speed / (new_velocity[0] * new_velocity[0] + new_velocity[1] * new_velocity[1] + new_velocity[2] * new_velocity[2]))
	
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}

stock fm_get_user_weapon_entity(id, wid = 0)
{
	new weap = wid, clip, ammo;
	if (!weap && !(weap = get_user_weapon(id, clip, ammo)))
		return 0;

	if(!pev_valid(weap))
		return 0

	new class[32];
	get_weaponname(weap, class, sizeof class - 1);

	return fm_find_ent_by_owner(-1, class, id);
}

stock Float:fm_entity_range(ent1, ent2)
{
	new Float:origin1[3], Float:origin2[3]
	
	pev(ent1, pev_origin, origin1)
	pev(ent2, pev_origin, origin2)

	return get_distance_f(origin1, origin2)
}

stock bool:fm_is_ent_classname(index, const classname[])
{
	if (!pev_valid(index))
		return false;

	new class[32];
	pev(index, pev_classname, class, sizeof class - 1);

	if (equal(class, classname))
		return true;

	return false;
}

stock fm_set_entity_visibility(index, visible = true)
{
	set_pev(index, pev_effects, visible ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects) | EF_NODRAW);
	return 1;
}

stock drop_weapons(id, dropwhat)
{
     static weapons[32], num, i, weaponid
     num = 0
     get_user_weapons(id, weapons, num)
     
     for (i = 0; i < num; i++)
     {
          weaponid = weapons[i]
          
          if (dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
          {
               static wname[32]
               get_weaponname(weaponid, wname, sizeof wname - 1)
               engclient_cmd(id, "drop", wname)
          }
     }
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
