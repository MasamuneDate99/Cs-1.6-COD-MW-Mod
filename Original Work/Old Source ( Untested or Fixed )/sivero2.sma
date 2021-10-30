#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <cstrike>
#include <xs>
#include <fun>
#include <codmod>

#define PLUGIN "[COD:MW] CLASS: Widowmaker"
#define VERSION "1.0"
#define AUTHOR "Siveroo"

#define message_begin_f(%1,%2,%3,%4) engfunc(EngFunc_MessageBegin, %1, %2, %3, %4)
#define write_coord_f(%1) engfunc(EngFunc_WriteCoord, %1)

new bool:make_class[33]
new bool:hook_used[33]


new const NAME_CLASS[]		= "Widowmaker";
new const INFO_CLASS[]		= "[E] Use grappling hook every 12 seconds. Accurate shot mid-air. Normal AWP damage (+0.5 int)";
new const WEAPON_CLASS		= 1<<CSW_AWP
new const HEALTH_CLASS		= 40;
new const COND_CLASS		= 40;
new const INT_CLASS		= 15;
new const STR_CLASS		= 0;

//Cvars
new pThrowSpeed, pSpeed, pWidth, pSound, pColor
new pInterrupt, pHookSky, pOpenDoors
new pUseButtons, pHostage, pWeapons, pInstant, pHookNoise
// Sprite
new sprBeam

// Players hook entity
new Hook[33]

// MaxPlayers
new gMaxPlayers

// some booleans
new bool:gHooked[33]
new bool:canThrowHook[33]

// Player Spawn
new bool:gRestart[33] = {false, ...}
new bool:gUpdate[33] = {false, ...}




public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	cod_register_class(NAME_CLASS, INFO_CLASS, WEAPON_CLASS, HEALTH_CLASS, COND_CLASS, INT_CLASS, STR_CLASS);
	register_forward(FM_TraceLine,"fw_traceline",1);
	
	RegisterHam(Ham_TakeDamage, "player","TakeDamage");
	
	register_event("HLTV", "round_bstart", "a", "1=0", "2=0")
	
	register_event("TextMsg", "Restart", "a", "2=#Game_will_restart_in")
	register_clcmd("fullupdate", "Update") 
	register_event("ResetHUD", "ResetHUD", "b")
	
	pThrowSpeed = 	register_cvar("sv_hookthrowspeed", "2000")
	pSpeed = 	register_cvar("sv_hookspeed", "800")
	pWidth = 	register_cvar("sv_hookwidth", "32")
	pSound = 	register_cvar("sv_hooksound", "1")
	pColor =	register_cvar("sv_hookcolor", "1")
	pInterrupt = 	register_cvar("sv_hookinterrupt", "0")
	pHookSky = 	register_cvar("sv_hooksky", "0")
	pOpenDoors = 	register_cvar("sv_hookopendoors", "1")
	pUseButtons = 	register_cvar("sv_hookusebuttons", "0")
	pHostage = 	register_cvar("sv_hookhostflollow", "0")
	pWeapons =	register_cvar("sv_hookpickweapons", "0")
	pInstant =	register_cvar("sv_hookinstant", "0")
	pHookNoise = 	register_cvar("sv_hooknoise", "0")
	
	register_forward(FM_Touch, "fwTouch")
	gMaxPlayers = get_maxplayers()
}

public plugin_precache()
{
	// Hook Model
	engfunc(EngFunc_PrecacheModel, "models/rpgrocket.mdl")
	
	// Hook Beam
	sprBeam = engfunc(EngFunc_PrecacheModel, "sprites/zbeam4.spr")
	
	// Hook Sounds
	engfunc(EngFunc_PrecacheSound, "weapons/xbow_hit1.wav") // good hit
	engfunc(EngFunc_PrecacheSound, "weapons/xbow_hit2.wav") // wrong hit
	
	engfunc(EngFunc_PrecacheSound, "weapons/xbow_hitbod1.wav") // player hit
	
	engfunc(EngFunc_PrecacheSound, "weapons/xbow_fire1.wav") // deploy
}

		/******************************
		***** Grappling Hook Part *****
		*******************************/
		
/*public client_PreThink(id)
{
	if(is_user_alive(id)) 
	{	
		if(make_class[id])
		{
			if(pev(id, pev_button) & IN_USE)
			{
				if(canThrowHook[id] && !gHooked[id])
				{
					throw_hook(id)
					
				}
				return PLUGIN_HANDLED
			}
			else
				del_hook(id)
		}
	}
	return PLUGIN_HANDLED
}*/
		

public del_hook(id)
{
	// Remove players hook
	if (!canThrowHook[id])
		remove_hook(id)
	
	return PLUGIN_HANDLED
}

public round_bstart()
{
	for (new i = 1; i <= gMaxPlayers; i++)
	{
		if (is_user_connected(i))
		{
			if(!canThrowHook[i])
				remove_hook(i)
		}
	}
}

public Restart()
{
	for (new id = 0; id < gMaxPlayers; id++)
	{
		if (is_user_connected(id))
			gRestart[id] = true
	}
}

public Update(id)
{
	if (!gUpdate[id])
		gUpdate[id] = true
	
	return PLUGIN_CONTINUE
}

public ResetHUD(id)
{
	if (gRestart[id])
	{
		gRestart[id] = false
		return
	}
	if (gUpdate[id])
	{
		gUpdate[id] = false
		return
	}
	if (gHooked[id])
	{
		remove_hook(id)
	}
	
	ResetHook(id);
}

public fwTouch(ptr, ptd)
{
	if (!pev_valid(ptr))
		return FMRES_IGNORED
	
	new id = pev(ptr, pev_owner)
	
	// Get classname
	static szPtrClass[32]	
	pev(ptr, pev_classname, szPtrClass, charsmax(szPtrClass))
	
	if (equali(szPtrClass, "Hook"))
	{		
		static Float:fOrigin[3]
		pev(ptr, pev_origin, fOrigin)
		
		if (pev_valid(ptd))
		{
			static szPtdClass[32]
			pev(ptd, pev_classname, szPtdClass, charsmax(szPtdClass))
						
			
			
			if (equali(szPtdClass, "hostage_entity"))
			{
				// Makes an hostage follow
				if (get_pcvar_num(pHostage) && get_user_team(id) == 2)
				{					
					//cs_set_hostage_foll(ptd, (cs_get_hostage_foll(ptd) == id) ? 0 : id)
					// With the use function we have the sounds!
					dllfunc(DLLFunc_Use, ptd, id)
				}
				/*if (!get_pcvar_num(pPlayers))
				{
					if(get_pcvar_num(pSound))
						emit_sound(ptr, CHAN_STATIC, "weapons/xbow_hitbod1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					remove_hook(id)
				}*/
				return FMRES_HANDLED
			}
			else if (get_pcvar_num(pOpenDoors) && equali(szPtdClass, "func_door") || equali(szPtdClass, "func_door_rotating"))
			{
				// Open doors
				// Double doors tested in de_nuke and de_wallmart
				static szTargetName[32]
				pev(ptd, pev_targetname, szTargetName, charsmax(szTargetName))
				if (strlen(szTargetName) > 0)
				{	
					static ent
					while ((ent = engfunc(EngFunc_FindEntityByString, ent, "target", szTargetName)) > 0)
					{
						static szEntClass[32]
						pev(ent, pev_classname, szEntClass, charsmax(szEntClass))
						
						if (equali(szEntClass, "trigger_multiple"))
						{
							dllfunc(DLLFunc_Touch, ent, id)
							goto stopdoors // No need to touch anymore
						}
					}
				}
				
				// No double doors.. just touch it
				dllfunc(DLLFunc_Touch, ptd, id)
stopdoors:				
			}
			else if (get_pcvar_num(pUseButtons) && equali(szPtdClass, "func_button"))
			{
				if (pev(ptd, pev_spawnflags) & SF_BUTTON_TOUCH_ONLY)
					dllfunc(DLLFunc_Touch, ptd, id) // Touch only
				else			
					dllfunc(DLLFunc_Use, ptd, id) // Use Buttons			
			}
		}
		
		// If cvar sv_hooksky is 0 and hook is in the sky remove it!
		new iContents = engfunc(EngFunc_PointContents, fOrigin)
		if (!get_pcvar_num(pHookSky) && iContents == CONTENTS_SKY)
		{
			if(get_pcvar_num(pSound))
				emit_sound(ptr, CHAN_STATIC, "weapons/xbow_hit2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			remove_hook(id)
			return FMRES_HANDLED
		}
		
		// Pick up weapons..
		if (get_pcvar_num(pWeapons))
		{
			static ent
			while ((ent = engfunc(EngFunc_FindEntityInSphere, ent, fOrigin, 15.0)) > 0)
			{
				static szentClass[32]
				pev(ent, pev_classname, szentClass, charsmax(szentClass))
				
				if (equali(szentClass, "weaponbox") || equali(szentClass, "armoury_entity"))
					dllfunc(DLLFunc_Touch, ent, id)
			}
		}
		
		// Player is now hooked
		gHooked[id] = true
		// Play sound
		if (get_pcvar_num(pSound))
			emit_sound(ptr, CHAN_STATIC, "weapons/xbow_hit1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Make some sparks :D
		message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY, fOrigin, 0)
		write_byte(9) // TE_SPARKS
		write_coord_f(fOrigin[0]) // Origin
		write_coord_f(fOrigin[1])
		write_coord_f(fOrigin[2])
		message_end()		
		
		// Stop the hook from moving
		set_pev(ptr, pev_velocity, Float:{0.0, 0.0, 0.0})
		set_pev(ptr, pev_movetype, MOVETYPE_NONE)
		set_pev(ptr, pev_owner, id)
		
		//Task
		if (!task_exists(id + 856))
		{ 
			static TaskData[2]
			TaskData[0] = id
			TaskData[1] = ptr
			gotohook(TaskData)
			
			set_task(0.1, "gotohook", id + 856, TaskData, 2, "b")
		}
	}
	return FMRES_HANDLED
}

public hookthink(param[])
{
	new id = param[0]
	new HookEnt = param[1]
	
	if (!is_user_alive(id) || !pev_valid(HookEnt) || !pev_valid(id))
	{
		remove_task(id + 890)
		return PLUGIN_HANDLED
	}
	
	
	static Float:entOrigin[3]
	pev(HookEnt, pev_origin, entOrigin)
	
	// If user is behind a box or something.. remove it
	// only works if sv_interrupt 1 or higher is
	if (get_pcvar_num(pInterrupt))
	{
		static Float:usrOrigin[3]
		pev(id, pev_origin, usrOrigin)
		
		static tr
		engfunc(EngFunc_TraceLine, usrOrigin, entOrigin, 1, -1, tr)
		
		static Float:fFraction
		get_tr2(tr, TR_flFraction, fFraction)
		
		if (fFraction != 1.0)
			remove_hook(id)
	}
	
	// If cvar sv_hooksky is 0 and hook is in the sky remove it!
	new iContents = engfunc(EngFunc_PointContents, entOrigin)
	if (!get_pcvar_num(pHookSky) && iContents == CONTENTS_SKY)
	{
		if(get_pcvar_num(pSound))
			emit_sound(HookEnt, CHAN_STATIC, "weapons/xbow_hit2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		remove_hook(id)
	}
	
	//***** MODIFIED PART *****//
	
	new Float:Origin[3],EntList[32]
	new ent = find_ent_by_class(-1, "Hook")
	entity_get_vector(ent,EV_VEC_origin,Origin)
	
//	if(find_sphere_class(0,"player",50.0,EntList,32,Origin) != 0)		
//	{
	new numfound = (find_sphere_class(0,"player",50.0,EntList,32,Origin))
		
	if(numfound != 0)
	{
		for (new i=0; i < numfound; i++)
		{
			new pid = EntList[i];
		
			if (pid == id)
			{
				remove_hook(id);
			}
		}
	}

	//***** MODIFIED PART *****//
	
	return PLUGIN_HANDLED
}

public gotohook(param[])
{
	new id = param[0]
	new HookEnt = param[1]

	if (!is_user_alive(id) || !pev_valid(HookEnt) || !pev_valid(id))
	{
		remove_task(id + 856)
		return PLUGIN_HANDLED
	}
	// If the round isnt started velocity is just 0
	static Float:fVelocity[3]
	fVelocity = Float:{0.0, 0.0, 1.0}
	
	// If the round is started and player is hooked we can set the user velocity!
	if (gHooked[id])
	{
		static Float:fHookOrigin[3], Float:fUsrOrigin[3], Float:fDist
		pev(HookEnt, pev_origin, fHookOrigin)
		pev(id, pev_origin, fUsrOrigin)
		
		fDist = vector_distance(fHookOrigin, fUsrOrigin)
		
		if (fDist >= 30.0)
		{
			new Float:fSpeed = get_pcvar_float(pSpeed)
			
			fSpeed *= 0.52
			
			fVelocity[0] = (fHookOrigin[0] - fUsrOrigin[0]) * (2.0 * fSpeed) / fDist
			fVelocity[1] = (fHookOrigin[1] - fUsrOrigin[1]) * (2.0 * fSpeed) / fDist
			fVelocity[2] = (fHookOrigin[2] - fUsrOrigin[2]) * (2.0 * fSpeed) / fDist
		}
	}
	// Set the velocity
	set_pev(id, pev_velocity, fVelocity)
	
	return PLUGIN_HANDLED
}
		
public throw_hook(id)
{
	// Get origin and angle for the hook
	static Float:fOrigin[3], Float:fAngle[3],Float:fvAngle[3]
	static Float:fStart[3]
	pev(id, pev_origin, fOrigin)
	
	pev(id, pev_angles, fAngle)
	pev(id, pev_v_angle, fvAngle)
	
	if (get_pcvar_num(pInstant))
	{
		get_user_hitpoint(id, fStart)
		
		if (engfunc(EngFunc_PointContents, fStart) != CONTENTS_SKY)
		{
			static Float:fSize[3]
			pev(id, pev_size, fSize)
			
			fOrigin[0] = fStart[0] + floatcos(fvAngle[1], degrees) * (-10.0 + fSize[0])
			fOrigin[1] = fStart[1] + floatsin(fvAngle[1], degrees) * (-10.0 + fSize[1])
			fOrigin[2] = fStart[2]
		}
		else
			xs_vec_copy(fStart, fOrigin)
	}

	
	// Make the hook!
	Hook[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		
	if (Hook[id])
	{
		// Player cant throw hook now
		canThrowHook[id] = false
		
		static const Float:fMins[3] = {-2.840000, -14.180000, -2.840000}
		static const Float:fMaxs[3] = {2.840000, 0.020000, 2.840000}
		
		//Set some Data
		set_pev(Hook[id], pev_classname, "Hook")
		
		
		engfunc(EngFunc_SetModel, Hook[id], "models/rpgrocket.mdl")
		engfunc(EngFunc_SetOrigin, Hook[id], fOrigin)
		engfunc(EngFunc_SetSize, Hook[id], fMins, fMaxs)		
		
		//set_pev(Hook[id], pev_mins, fMins)
		//set_pev(Hook[id], pev_maxs, fMaxs)
		
		set_pev(Hook[id], pev_angles, fAngle)
		
		set_pev(Hook[id], pev_solid, 2)
		set_pev(Hook[id], pev_movetype, 5)
		set_pev(Hook[id], pev_owner, id)
		
		//Set hook velocity
		static Float:fForward[3], Float:Velocity[3]
		new Float:fSpeed = get_pcvar_float(pThrowSpeed)
		
		engfunc(EngFunc_MakeVectors, fvAngle)
		global_get(glb_v_forward, fForward)
		
		Velocity[0] = fForward[0] * fSpeed
		Velocity[1] = fForward[1] * fSpeed
		Velocity[2] = fForward[2] * fSpeed
		
		set_pev(Hook[id], pev_velocity, Velocity)

		// Make the line between Hook and Player
		message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY, Float:{0.0, 0.0, 0.0}, 0)
		if (get_pcvar_num(pInstant))
		{
			write_byte(1) // TE_BEAMPOINT
			write_short(id) // Startent
			write_coord_f(fStart[0]) // End pos
			write_coord_f(fStart[1])
			write_coord_f(fStart[2])
		}
		else
		{
			write_byte(8) // TE_BEAMENTS
			write_short(id) // Start Ent
			write_short(Hook[id]) // End Ent
		}
		write_short(sprBeam) // Sprite
		write_byte(1) // StartFrame
		write_byte(1) // FrameRate
		write_byte(600) // Life
		write_byte(get_pcvar_num(pWidth)) // Width
		write_byte(get_pcvar_num(pHookNoise)) // Noise
		// Colors now
		if (get_pcvar_num(pColor))
		{
			if (get_user_team(id) == 1) // Terrorist
			{
				write_byte(255) // R
				write_byte(0)	// G
				write_byte(0)	// B
			}
			#if defined _cstrike_included
			else if(cs_get_user_vip(id)) // vip for cstrike
			{
				write_byte(0)	// R
				write_byte(255)	// G
				write_byte(0)	// B
			}
			#endif // _cstrike_included
			else if(get_user_team(id) == 2) // CT
			{
				write_byte(0)	// R
				write_byte(0)	// G
				write_byte(255)	// B
			}
			else
			{
				write_byte(255) // R
				write_byte(255) // G
				write_byte(255) // B
			}
		}
		else
		{
			write_byte(255) // R
			write_byte(255) // G
			write_byte(255) // B
		}
		write_byte(192) // Brightness
		write_byte(0) // Scroll speed
		message_end()
		
		if (get_pcvar_num(pSound) && !get_pcvar_num(pInstant))
			emit_sound(id, CHAN_BODY, "weapons/xbow_fire1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_HIGH)
		
		static TaskData[2]
		TaskData[0] = id
		TaskData[1] = Hook[id]
		
		set_task(0.1, "hookthink", id + 890, TaskData, 2, "b")
	}
	else
		client_print(id, print_chat, "Can't create hook")
}

public remove_hook(id)
{
	//Player can now throw hooks
	canThrowHook[id] = true
	
	// Remove the hook if it is valid
	if (pev_valid(Hook[id]))
		engfunc(EngFunc_RemoveEntity, Hook[id])
	Hook[id] = 0
	
	// Remove the line between user and hook
	if (is_user_connected(id))
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, {0,0,0}, id)
		write_byte(99) // TE_KILLBEAM
		write_short(id) // entity
		message_end()
	}
	
	// Player is not hooked anymore
	gHooked[id] = false
	return 1
}

// Stock by Chaosphere
stock get_user_hitpoint(id, Float:hOrigin[3])
{
	if (!is_user_alive(id))
		return 0
	
	static Float:fOrigin[3], Float:fvAngle[3], Float:fvOffset[3], Float:fvOrigin[3], Float:feOrigin[3]
	static Float:fTemp[3]
	
	pev(id, pev_origin, fOrigin)
	pev(id, pev_v_angle, fvAngle)
	pev(id, pev_view_ofs, fvOffset)
	
	xs_vec_add(fOrigin, fvOffset, fvOrigin)
	
	engfunc(EngFunc_AngleVectors, fvAngle, feOrigin, fTemp, fTemp)
	
	xs_vec_mul_scalar(feOrigin, 8192.0, feOrigin)
	xs_vec_add(fvOrigin, feOrigin, feOrigin)
	
	static tr
	engfunc(EngFunc_TraceLine, fvOrigin, feOrigin, 0, id, tr)
	get_tr2(tr, TR_vecEndPos, hOrigin)
	//global_get(glb_trace_endpos, hOrigin)
	
	return 1
}

stock statusMsg(id, szMsg[], {Float,_}:...)
{
	static iStatusText
	if (!iStatusText)
		iStatusText = get_user_msgid("StatusText")
	
	static szBuffer[512]
	vformat(szBuffer, charsmax(szBuffer), szMsg, 3)
	
	message_begin((id == 0) ? MSG_ALL : MSG_ONE, iStatusText, _, id)
	write_byte(0) // Unknown
	write_string(szBuffer) // Message
	message_end()
	
	return 1
}

		/******************************
		****** COD:MW Class Part ******
		*******************************/

public cod_class_enabled(id)
{
	make_class[id] = true;
}

public cod_class_disabled(id)
{
	make_class[id] = false
}

public cod_class_skill_used(id)
{
	if(!hook_used[id] == false)
	{
		client_print(id, print_center, "Your dash ability is still in a cooldown!");
		return PLUGIN_CONTINUE;
	}
	
	if(canThrowHook[id] && !gHooked[id])
	{
		throw_hook(id)	
		set_task(12.0, "ResetHook", id)
		set_task(8.0, "remove_hook", id)
		hook_used[id] = true
	}
	return PLUGIN_HANDLED
}

public ResetHook(id)
{
	hook_used[id] = false;
	client_print(id, print_center, "Your ability is now READY!");
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(!make_class[idattacker])
		return HAM_IGNORED;
		
	if(damagebits & DMG_BULLET)
	{
		new weapon = get_user_weapon(idattacker);
			
		if(weapon == CSW_AWP)
			cod_inflict_damage(idattacker, this, 0.0, 0.5, idinflictor, damagebits);	
	}
	
	return HAM_IGNORED;
}

		/******************************
		**** The High Accuracy Part****
		*******************************/
		
public fw_traceline(Float:v1[3],Float:v2[3],noMonsters,id,ptr)
{
	if(id == 0)
	{
		return FMRES_IGNORED
	}
	
	if(get_user_weapon(id) == CSW_AWP && is_user_alive(id) && make_class[id] && is_user_connected(id))
	{
		// get crosshair aim
		static Float:aim[3];
		get_aim(id,v1,aim);
	
		// do another trace to this spot
		new trace = create_tr2();
		engfunc(EngFunc_TraceLine,v1,aim,noMonsters,id,trace);
		
		// copy ints
		set_tr2(ptr,TR_AllSolid,get_tr2(trace,TR_AllSolid));
		set_tr2(ptr,TR_StartSolid,get_tr2(trace,TR_StartSolid));
		set_tr2(ptr,TR_InOpen,get_tr2(trace,TR_InOpen));
		set_tr2(ptr,TR_InWater,get_tr2(trace,TR_InWater));
		set_tr2(ptr,TR_pHit,get_tr2(trace,TR_pHit));
		set_tr2(ptr,TR_iHitgroup,get_tr2(trace,TR_iHitgroup));

		// copy floats
		get_tr2(trace,TR_flFraction,aim[0]);
		set_tr2(ptr,TR_flFraction,aim[0]);
		get_tr2(trace,TR_flPlaneDist,aim[0]);
		set_tr2(ptr,TR_flPlaneDist,aim[0]);
	
		// copy vecs
		get_tr2(trace,TR_vecEndPos,aim);
		set_tr2(ptr,TR_vecEndPos,aim);
		get_tr2(trace,TR_vecPlaneNormal,aim);
		set_tr2(ptr,TR_vecPlaneNormal,aim);

		// get rid of new trace
		free_tr2(trace);

		return FMRES_IGNORED;
	}
	return FMRES_IGNORED;
}

// gets the end point of an imaginary 2048.0 line from the player's aim
get_aim(id,Float:source[3],Float:ret[3])
{
	static Float:vAngle[3], Float:pAngle[3], Float:dir[3], Float:temp[3];

	// get aiming direction from forward global based on view angle and punch angle
	pev(id,pev_v_angle,vAngle);
	pev(id,pev_punchangle,pAngle);
	xs_vec_add(vAngle,pAngle,temp);
	engfunc(EngFunc_MakeVectors,temp);
	global_get(glb_v_forward,dir);
	
	/* vecEnd = vecSrc + vecDir * flDistance; */
	xs_vec_mul_scalar(dir,8192.0,temp);
	xs_vec_add(source,temp,ret);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1057\\ f0\\ fs16 \n\\ par }
*/
