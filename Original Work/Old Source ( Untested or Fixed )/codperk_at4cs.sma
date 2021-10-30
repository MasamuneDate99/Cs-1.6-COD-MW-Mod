#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <cstrike>
#include <codmod>

#define PLUGIN "[Perk] AT4CS"
#define VERSION "1.0"
#define AUTHOR "Dias edited by Fili:P"

#define weapon_at4cs "weapon_m249"
#define CSW_AT4CS CSW_M249

#define TASK_CHECKRELOAD 111112
#define TASK_RELOAD 111113

new g_at4cs
new g_had_at4cs[33], Float:g_lastfire[33], Float:g_lastaim[33], g_aiming[33],
g_smoke_id, g_spr_trail, g_spr_exp, is_reloading[33],
cvar_radius, cvar_maxdamage

new const v_model[] = "models/SawahCod/v_at4ex.mdl"
new const p_model[] = "models/SawahCod/p_at4ex.mdl"
new const w_model[] = "models/SawahCod/w_at4ex.mdl"
new const s_model[] = "models/SawahCod/s_rocket.mdl"

new const at4cs_sound[5][] = {
	"weapons/at4-1.wav", // Fire Sound
	"weapons/at4_clipin1.wav", // Clip in 1
	"weapons/at4_clipin2.wav", // Clip in 2
	"weapons/at4_clipin3.wav", // Clip in 3
	"weapons/at4_draw.wav"  // Draw
}

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("CurWeapon", "event_curweapon", "be", "1=1")
	register_event("HLTV", "event_newround", "a", "1=0", "2=0")
	
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_SetModel, "fw_SetModel")
	
	register_think("at4ex_rocket", "fw_rocket_think")
	register_touch("at4ex_rocket", "*", "fw_rocket_touch")
	
	RegisterHam(Ham_Weapon_Reload, weapon_at4cs, "fw_WeaponReload")
	RegisterHam(Ham_Item_AddToPlayer, weapon_at4cs, "fw_AddToPlayer", 1)
	
	cvar_radius = register_cvar("cod_at4cs_radius", "1500.0")
	cvar_maxdamage = register_cvar("cod_at4cs_maxdamage", "150.0")
	
	g_at4cs = cod_register_perk("AT4CS", "You get AT4CS")
	
	register_clcmd("weapon_at4cs", "hook_weapon")
}

public hook_weapon(id)
{
	engclient_cmd(id, weapon_at4cs)
	return PLUGIN_HANDLED
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, v_model)
	engfunc(EngFunc_PrecacheModel, p_model)
	engfunc(EngFunc_PrecacheModel, w_model)
	engfunc(EngFunc_PrecacheModel, s_model)
	
	engfunc(EngFunc_PrecacheGeneric, "sprites/weapon_at4cs.txt")
	engfunc(EngFunc_PrecacheGeneric, "sprites/at4cs.spr")	
	
	g_smoke_id = engfunc(EngFunc_PrecacheModel, "sprites/effects/rainsplash.spr")
	g_spr_trail = engfunc(EngFunc_PrecacheModel,"sprites/xbeam3.spr")
	g_spr_exp = engfunc(EngFunc_PrecacheModel,"sprites/zerogxplode.spr")
	
	for(new i = 0; i < sizeof(at4cs_sound); i++)
		engfunc(EngFunc_PrecacheSound, at4cs_sound[i])
}

public cod_perk_enabled(id, wartosc, perk)
{
	if(perk != g_at4cs)
		return PLUGIN_HANDLED
		
	g_had_at4cs[id] = 1
	is_reloading[id] = 0
	g_aiming[id] = 0
	
	cod_give_weapon(id, CSW_AT4CS)
	
	static at4cs
	at4cs = fm_get_user_weapon_entity(id, CSW_AT4CS)

	cs_set_weapon_ammo(at4cs, 1)
	cs_set_user_bpammo(id, CSW_AT4CS, 3)
	
	return PLUGIN_CONTINUE
}

public cod_perk_disabled(id)
{
	g_had_at4cs[id] = 0
	is_reloading[id] = 0
	g_aiming[id] = 0
	
	cod_take_weapon(id, CSW_AT4CS);
	
	remove_task(id+TASK_CHECKRELOAD)
	remove_task(id+TASK_RELOAD)	
}
public event_newround(id)
{
	remove_entity_name("at4ex_rocket")
	
	for(new i = 0; i < get_maxplayers(); i++)
	{
		if(is_user_alive(i) && is_user_connected(i))
		{
			remove_task(i+TASK_CHECKRELOAD)
			remove_task(i+TASK_RELOAD)	
			g_had_at4cs[id] = 1
			is_reloading[id] = 0
			g_aiming[id] = 0
			
		}
	}
}

public event_curweapon(id)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return PLUGIN_HANDLED
		
	if(get_user_weapon(id) != CSW_AT4CS || !g_had_at4cs[id])
		return PLUGIN_HANDLED
		
	set_pev(id, pev_viewmodel2, v_model)
	set_pev(id, pev_weaponmodel2, p_model)
	
	return PLUGIN_CONTINUE
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return FMRES_IGNORED
		
	if(get_user_weapon(id) != CSW_AT4CS || !g_had_at4cs[id])
		return FMRES_IGNORED
		
	set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001)  

	return FMRES_HANDLED
}

public fw_AddToPlayer(ent, id)
{
	if(!is_valid_ent(ent) || !is_user_alive(id))
		return HAM_IGNORED
		
	if(entity_get_int(ent, EV_INT_impulse) == 61296)
	{
		g_had_at4cs[id] = 1
		entity_set_int(id, EV_INT_impulse, 0)
		
		return HAM_HANDLED
	}		

	if(g_had_at4cs[id])
	{
		message_begin(MSG_ONE, get_user_msgid("WeaponList"), _, id)
		write_string("weapon_at4cs");    // WeaponName
		write_byte(3)                  // PrimaryAmmoID
		write_byte(1)                  // PrimaryAmmoMaxAmount
		write_byte(-1)                   // SecondaryAmmoID
		write_byte(-1)                   // SecondaryAmmoMaxAmount
		write_byte(0)                    // SlotID (0...N)
		write_byte(4)                    // NumberInSlot (1...N)
		write_byte(CSW_AT4CS)            // WeaponID
		write_byte(0)                   // Flags
		message_end()
	}
	
	return HAM_HANDLED	
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return FMRES_IGNORED

	if(get_user_weapon(id) != CSW_AT4CS || !g_had_at4cs[id])
		return FMRES_IGNORED
		
	static CurButton
	CurButton = get_uc(uc_handle, UC_Buttons)
	
	if(CurButton & IN_ATTACK)
	{
		static Float:CurTime
		CurTime = get_gametime()
		
		static at4cs
		at4cs = fm_find_ent_by_owner(-1, weapon_at4cs, id)		
		
		if(cs_get_weapon_ammo(at4cs) > 0 && !is_reloading[id])
		{
			if(CurTime - 4.5 > g_lastfire[id])
			{
				set_weapon_anim(id, 1)
				emit_sound(id, CHAN_WEAPON, at4cs_sound[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
				
				create_rocket(id)
				
				static Float:Punch_Angles[3]
				
				Punch_Angles[0] = -20.0
				Punch_Angles[1] = 0.0
				Punch_Angles[2] = 0.0
				
				set_pev(id, pev_punchangle, Punch_Angles)
				cs_set_weapon_ammo(at4cs, cs_get_weapon_ammo(at4cs) - 1)
				
				if(cs_get_weapon_ammo(at4cs) <= 0 && !is_reloading[id])
				{
					if(cs_get_user_bpammo(id, CSW_AT4CS) > 0)
					{
						set_task(1.0, "at4cs_reload", id)
					}
				}
				
				if(cs_get_user_zoom(id))
					cs_set_user_zoom(id, CS_RESET_ZOOM, 1)
				
				g_lastfire[id] = CurTime
			}
		} else {
			if(!is_reloading[id])
			{
				if(cs_get_user_bpammo(id, CSW_AT4CS) > 0)
				{
					if(CurTime - 1.0 > g_lastfire[id])
					{
						at4cs_reload(id)
						g_lastfire[id] = CurTime
					}
				}
			}
		}
	}
	
	if(CurButton & IN_ATTACK2)
	{
		static Float:CurTime
		CurTime = get_gametime()
		
		if((CurTime - 0.5 > g_lastaim[id]) && !is_reloading[id])
		{
			if(!g_aiming[id])
			{
				cs_set_user_zoom(id, CS_SET_FIRST_ZOOM, 1)
				g_aiming[id] = 1
			} else {
				cs_set_user_zoom(id, CS_RESET_ZOOM, 1)
				g_aiming[id] = 0
			}
			
			g_lastaim[id] = CurTime
		}
	}
	
	CurButton &= ~IN_ATTACK
	set_uc(uc_handle, UC_Buttons, CurButton)
	
	CurButton &= ~IN_RELOAD
	set_uc(uc_handle, UC_Buttons, CurButton)

	return FMRES_HANDLED
}

public fw_SetModel(ent, const model[])
{
	if(!is_valid_ent(ent))
		return FMRES_IGNORED
	
	static szClassName[33]
	entity_get_string(ent, EV_SZ_classname, szClassName, charsmax(szClassName))
	
	if(!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED
	
	static iOwner
	iOwner = entity_get_edict(ent, EV_ENT_owner)
	
	if(equal(model, "models/w_m249.mdl"))
	{
		static at4cs
		at4cs = find_ent_by_owner(-1, "weapon_m249", ent)
		
		if(!is_valid_ent(at4cs))
			return FMRES_IGNORED;
		
		if(g_had_at4cs[iOwner])
		{
			entity_set_int(at4cs, EV_INT_impulse, 61296)
			g_had_at4cs[iOwner] = 0
			entity_set_model(ent, w_model)
			
			return FMRES_SUPERCEDE
		}
	}
	
	return FMRES_IGNORED
}

public at4cs_reload(id)
{
	if(is_reloading[id])
		return
	
	is_reloading[id] = 1
	set_weapon_anim(id, 3)
	
	set_task(0.1, "checking_reload", id+TASK_CHECKRELOAD, _, _, "b")
	set_task(4.0, "reload_complete", id+TASK_RELOAD)
}

public checking_reload(id)
{
	id -= TASK_CHECKRELOAD
	
	if(cs_get_user_zoom(id))
		cs_set_user_zoom(id, CS_RESET_ZOOM, 1)	
	
	if(get_user_weapon(id) != CSW_AT4CS || !g_had_at4cs[id])
	{
		remove_task(id+TASK_CHECKRELOAD)
		remove_task(id+TASK_RELOAD)
		
		is_reloading[id] = 0
	}
}

public reload_complete(id)
{
	id -= TASK_RELOAD
	
	if(!is_reloading[id])
		return
		
	remove_task(id+TASK_CHECKRELOAD)	
		
	static at4cs
	at4cs = fm_find_ent_by_owner(-1, weapon_at4cs, id)	
	
	cs_set_weapon_ammo(at4cs, 1)
	cs_set_user_bpammo(id, CSW_AT4CS, cs_get_user_bpammo(id, CSW_AT4CS) - 1)
	is_reloading[id] = 0
}

public fw_WeaponReload(ent)
{
	static id
	id = pev(ent, pev_owner)
	
	if(!is_user_alive(id) || !is_user_connected(id))
		return HAM_IGNORED
		
	if(get_user_weapon(id) != CSW_AT4CS || !g_had_at4cs[id])
		return HAM_IGNORED
		
	static Float:CurTime
	CurTime = get_gametime()		
		
	if(!is_reloading[id])
	{
		if(cs_get_user_bpammo(id, CSW_AT4CS) > 0)
		{
			if(CurTime - 1.0 > g_lastfire[id])
			{
				at4cs_reload(id)
				g_lastfire[id] = CurTime
			}
		}
	}	
		
	return HAM_SUPERCEDE
}

public create_rocket(id)
{
	new ent, Float:Origin[3], Float:Angles[3], Float:Velocity[3]
	
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	engfunc(EngFunc_GetAttachment, id, 0, Origin, Angles)
	pev(id, pev_angles, Angles)
	
	set_pev(ent, pev_origin, Origin)
	set_pev(ent, pev_angles, Angles)
	set_pev(ent, pev_solid, 2)
	set_pev(ent, pev_movetype, 5)
	set_pev(ent, pev_classname, "at4ex_rocket")
	set_pev(ent, pev_owner, id)
	engfunc(EngFunc_SetModel, ent, s_model)
	
	set_pev(ent, pev_mins, {-1.0, -1.0, -1.0})
	set_pev(ent, pev_maxs, {1.0, 1.0, 1.0})
	
	velocity_by_aim(id, 1750, Velocity)
	set_pev(ent, pev_velocity, Velocity)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) // TE id
	write_short(ent) // entity:attachment to follow
	write_short(g_spr_trail) // sprite index
	write_byte(25) // life in 0.1's
	write_byte(2) // line width in 0.1's
	write_byte(255) // r
	write_byte(255) // g
	write_byte(255) // b
	write_byte(200) // brightness
	message_end()	
	
	set_pev(ent, pev_iuser4, 0)
	set_pev(ent, pev_nextthink, halflife_time() + 0.1)
}

public fw_rocket_think(ent)
{
	if(!pev_valid(ent))
		return

	static Float:Origin[3]
	pev(ent, pev_origin, Origin)
		
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_short(g_smoke_id) 
	write_byte(2) 
	write_byte(200)
	message_end()
	
	if(pev(ent, pev_iuser4) == 0)
	{
		static Victim
		Victim = FindClosesEnemy(ent)
		
		if(is_user_alive(Victim))
		{
			set_pev(ent, pev_iuser4, Victim)
		}
	} else {
		static Victim
		Victim = pev(ent, pev_iuser4)
		
		if(is_user_alive(Victim))
		{
			static Float:VicOrigin[3]
			pev(Victim, pev_origin, VicOrigin)
			
			turn_to_target(ent, Origin, Victim, VicOrigin)
			hook_ent(ent, Victim, 500.0)
		} else {
			set_pev(ent, pev_iuser4, 0)
		}
	}
		
	set_pev(ent, pev_nextthink, halflife_time() + 0.075)
}

public fw_rocket_touch(rocket, touch)
{
	if(!pev_valid(rocket))
		return	
		
	if(is_user_alive(touch) && pev(rocket, pev_owner) == touch)
		return
		
	static Float:Origin[3]
	pev(rocket, pev_origin, Origin)		
		
	message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_short(g_spr_exp)	// sprite index
	write_byte(20)	// scale in 0.1's
	write_byte(30)	// framerate
	write_byte(0)	// flags
	message_end()
	
	static owner, iVictim
	
	iVictim = -1
	owner = pev(rocket, pev_owner)	

	while((iVictim = find_ent_in_sphere(iVictim, Origin, get_pcvar_float(cvar_radius))) != 0)
	{
		if((0 < iVictim < 32) && is_user_alive(iVictim)
		&& iVictim != owner)
		{
			new Float:MaxDamage, Float:Damage
			
			MaxDamage = get_pcvar_float(cvar_maxdamage)
			Damage = random_float(MaxDamage - random_float(0.0, 100.0), MaxDamage + random_float(0.0, 100.0))
			
			ExecuteHam(Ham_TakeDamage, iVictim, 0, owner, 0, DMG_BULLET)
			
			static health
			health = get_user_health(iVictim)
				
			if(health - Damage >= 1)
			{
				fm_set_user_health(iVictim, health - floatround(Damage))
			}
			else
			{
				death_message(owner, iVictim, 1)
			}			
		}
	}	
	
	engfunc(EngFunc_RemoveEntity, rocket)
}

stock set_weapon_anim(id, anim)
{
	set_pev(id, pev_weaponanim, anim)

	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(anim)
	write_byte(pev(id,pev_body))
	message_end()
}

stock death_message(Killer, Victim, ScoreBoard)
{
	// Block death msg
	set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET)
	ExecuteHamB(Ham_Killed, Victim, Killer, 2)
	set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT)
	
	// Death
	make_deathmsg(Killer, Victim, 0, "")

	// Update score board
	if (ScoreBoard)
	{
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
		write_byte(Killer) // id
		write_short(pev(Killer, pev_frags)) // frags
		write_short(cs_get_user_deaths(Killer)) // deaths
		write_short(0) // class?
		write_short(get_user_team(Killer)) // team
		message_end()
		
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
		write_byte(Victim) // id
		write_short(pev(Victim, pev_frags)) // frags
		write_short(cs_get_user_deaths(Victim)) // deaths
		write_short(0) // class?
		write_short(get_user_team(Victim)) // team
		message_end()
	}
}

stock FindClosesEnemy(entid)
{
	new Float:Dist
	new Float:maxdistance=300.0
	new indexid=0	
	for(new i=1;i<=get_maxplayers();i++){
		if(is_user_alive(i) && is_valid_ent(i) && can_see_fm(entid, i)
		&& pev(entid, pev_owner) != i && cs_get_user_team(pev(entid, pev_owner)) != cs_get_user_team(i))
		{
			Dist = entity_range(entid, i)
			if(Dist <= maxdistance)
			{
				maxdistance=Dist
				indexid=i
				
				return indexid
			}
		}	
	}	
	return 0
}

stock bool:can_see_fm(entindex1, entindex2)
{
	if (!entindex1 || !entindex2)
		return false

	if (pev_valid(entindex1) && pev_valid(entindex1))
	{
		new flags = pev(entindex1, pev_flags)
		if (flags & EF_NODRAW || flags & FL_NOTARGET)
		{
			return false
		}

		new Float:lookerOrig[3]
		new Float:targetBaseOrig[3]
		new Float:targetOrig[3]
		new Float:temp[3]

		pev(entindex1, pev_origin, lookerOrig)
		pev(entindex1, pev_view_ofs, temp)
		lookerOrig[0] += temp[0]
		lookerOrig[1] += temp[1]
		lookerOrig[2] += temp[2]

		pev(entindex2, pev_origin, targetBaseOrig)
		pev(entindex2, pev_view_ofs, temp)
		targetOrig[0] = targetBaseOrig [0] + temp[0]
		targetOrig[1] = targetBaseOrig [1] + temp[1]
		targetOrig[2] = targetBaseOrig [2] + temp[2]

		engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the had of seen player
		if (get_tr2(0, TraceResult:TR_InOpen) && get_tr2(0, TraceResult:TR_InWater))
		{
			return false
		} 
		else 
		{
			new Float:flFraction
			get_tr2(0, TraceResult:TR_flFraction, flFraction)
			if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
			{
				return true
			}
			else
			{
				targetOrig[0] = targetBaseOrig [0]
				targetOrig[1] = targetBaseOrig [1]
				targetOrig[2] = targetBaseOrig [2]
				engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the body of seen player
				get_tr2(0, TraceResult:TR_flFraction, flFraction)
				if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
				{
					return true
				}
				else
				{
					targetOrig[0] = targetBaseOrig [0]
					targetOrig[1] = targetBaseOrig [1]
					targetOrig[2] = targetBaseOrig [2] - 17.0
					engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the legs of seen player
					get_tr2(0, TraceResult:TR_flFraction, flFraction)
					if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
					{
						return true
					}
				}
			}
		}
	}
	return false
}

stock turn_to_target(ent, Float:Ent_Origin[3], target, Float:Vic_Origin[3]) 
{
	if(target) 
	{
		new Float:newAngle[3]
		entity_get_vector(ent, EV_VEC_angles, newAngle)
		new Float:x = Vic_Origin[0] - Ent_Origin[0]
		new Float:z = Vic_Origin[1] - Ent_Origin[1]

		new Float:radians = floatatan(z/x, radian)
		newAngle[1] = radians * (180 / 3.14)
		if (Vic_Origin[0] < Ent_Origin[0])
			newAngle[1] -= 180.0
        
		entity_set_vector(ent, EV_VEC_angles, newAngle)
	}
}

stock hook_ent(ent, victim, Float:speed)
{
	static Float:fl_Velocity[3]
	static Float:VicOrigin[3], Float:EntOrigin[3]

	pev(ent, pev_origin, EntOrigin)
	pev(victim, pev_origin, VicOrigin)
	
	static Float:distance_f
	distance_f = get_distance_f(EntOrigin, VicOrigin)

	if (distance_f > 10.0)
	{
		new Float:fl_Time = distance_f / speed

		fl_Velocity[0] = (VicOrigin[0] - EntOrigin[0]) / fl_Time
		fl_Velocity[1] = (VicOrigin[1] - EntOrigin[1]) / fl_Time
		fl_Velocity[2] = (VicOrigin[2] - EntOrigin[2]) / fl_Time
	} else
	{
		fl_Velocity[0] = 0.0
		fl_Velocity[1] = 0.0
		fl_Velocity[2] = 0.0
	}

	entity_set_vector(ent, EV_VEC_velocity, fl_Velocity)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
