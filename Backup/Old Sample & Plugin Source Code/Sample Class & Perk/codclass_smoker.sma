#include <amxmodx>
#include <fun>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <hamsandwich>
#include <fakemeta_util>
#include <codmod>

#define PLUGIN "COD:MW | Class : Smoker"
#define VERSION "1.0"
#define AUTHOR ""

new const NAMA_CLASS[]		= "Smoker";
new const INFO_CLASS[]		= "Get Poison Grenade (1/6)INT, Poison time 12(s), MP5 Navy & USP";
new const SENJATA_CLASS		= (1<<CSW_MP5NAVY)|(1<<CSW_USP)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_KNIFE);
new const HEALTH_CLASS		= 10;
new const CONDITION_CLASS	= 5;
new const INTELEGENT_CLASS	= 20;
new const ENDURANCE_CLASS	= 15;

new const ViewModel[]		= "models/v_poisongrenade.mdl"
new const PlayerModel[]		= "models/p_poisongrenade.mdl"
new const WorldModel[]		= "models/w_poisongrenade.mdl"
new const Gas_Sounds[][]=
{
	"player/gas.wav",
	"player/gasp1.wav",
	"player/gasp2.wav"
}

new const NADE_TYPE_PSGRENADE = 33256
new has_bomb[33], sprites_smoke
new g_smoke[33], Float:g_smoke_origin[3]
static id_smoke
new bool:make_smoker_class[33]

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Touch, "grenade", "fw_TouchGrenade", 1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHam(Ham_Item_Deploy, "weapon_smokegrenade", "Ham_Item_Deploy_Post", 1)
	
	register_message(get_user_msgid("DeathMsg"), "Deathmessage")
	register_forward(FM_SetModel, "fw_SetModel")
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	register_clcmd("weapon_psgrenade", "weapon_hook")
	
	cod_register_class(NAMA_CLASS, INFO_CLASS, SENJATA_CLASS, HEALTH_CLASS, CONDITION_CLASS, INTELEGENT_CLASS, ENDURANCE_CLASS)
}

public plugin_precache()
{
	precache_model(ViewModel)
	precache_model(PlayerModel)
	precache_model(WorldModel)
	
	for(new i; i<=charsmax(Gas_Sounds); i++)
		precache_sound(Gas_Sounds[i])
		
	sprites_smoke = precache_model("sprites/smoke_poison.spr")
	precache_model("sprites/640hud7_poison.spr")
	precache_model("sprites/640hud19_poison.spr")
	
	precache_generic("sprites/weapon_psgrenade.txt")
}

public cod_class_enabled(id)
{
	make_smoker_class[id] = true
	if(make_smoker_class[id])
	{
		g_smoke[id] = 0
		has_bomb[id] = 1
			
		message_begin(MSG_ONE, get_user_msgid("WeaponList"), .player = id)
		write_string("weapon_psgrenade") 
		write_byte(13)
		write_byte(1)
		write_byte(-1)
		write_byte(-1)
		write_byte(3)
		write_byte(3)
		write_byte(CSW_SMOKEGRENADE)
		write_byte(24)
		message_end()
	}
}

public cod_class_disabled(id)
{
	make_smoker_class[id] = false
	g_smoke[id] = 0
	has_bomb[id] = 0
}

public remove_psgrenade(id)
{
	g_smoke[id] = 0
	has_bomb[id] = 0
}

public client_disconnect(id) remove_psgrenade(id)
public client_connect(id) remove_psgrenade(id)
public weapon_hook(id)
{
	client_cmd(id, "weapon_smokegrenade")
}

public Event_CurWeapon(id)
{
	if (!is_user_alive(id))
		return
	
	if(get_user_weapon(id) == CSW_SMOKEGRENADE)
	{
		if(make_smoker_class[id])
		{
			has_bomb[id] = 1
			set_pev(id, pev_viewmodel2, ViewModel)
			set_pev(id, pev_weaponmodel2, PlayerModel)
		}
	}
}

public fw_SetModel(ent, const Model[])
{
	if(!pev_valid(ent))return FMRES_IGNORED;
	if(equal(Model, "models/w_smokegrenade.mdl"))
	{
		static id
		id = pev(ent, pev_owner)
		
		if(make_smoker_class[id] && has_bomb[id])
		{	
			fm_set_rendering(ent, kRenderFxGlowShell, 128, 0, 255, kRenderNormal, 3)
			set_pev(ent, pev_dmgtime, get_gametime()+9999999.0)
			set_pev(ent, pev_flTimeStepSound, NADE_TYPE_PSGRENADE)
			engfunc(EngFunc_SetModel, ent, WorldModel)
			
			has_bomb[id] = 0
			
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

public fw_SetModelPost(ent, const model[])
{	
	if(pev(ent, pev_flTimeStepSound) == NADE_TYPE_PSGRENADE)
		engfunc(EngFunc_SetModel, ent, WorldModel)
}

public fw_TouchGrenade(ent)
{
	if(pev(ent, pev_flTimeStepSound) == NADE_TYPE_PSGRENADE)
		set_task(1.0, "explode", ent)
}

public Ham_Item_Deploy_Post(ent)
{
	if(!pev_valid(ent))return
	
	new id = get_pdata_cbase(ent, 41, 4)
	
	if (is_user_alive(id))
	if(has_bomb[id])
	{
		set_pev(id, pev_viewmodel2, ViewModel)
		set_pev(id, pev_weaponmodel2, PlayerModel)
	}
}

public explode(ent)
{
	if (!pev_valid(ent))
		return
	
	id_smoke = pev(ent, pev_owner)
	pev(ent, pev_origin, g_smoke_origin)
	
	if(!g_smoke[id_smoke])
	{
		g_smoke[id_smoke] = 1
		
		Sound_Poison_Gas(ent)
		SmokeExplode(ent)
	}
}

public fw_PlayerKilled(id, attacker, shouldgib) has_bomb[id] = 0
public SmokeExplode(ent)
{
	if (!pev_valid(ent))
		return
		
	if(g_smoke[id_smoke])
	{
		Create_Smoke_Group(g_smoke_origin)
		static i = FM_NULLENT
		while((i = fm_find_ent_in_sphere(i, g_smoke_origin, 200.0))!=0)
		{
			if(is_user_alive(i) && i > 0)
			{
				new Origin[3]
				Origin[0] = floatround(g_smoke_origin[0])
				Origin[1] = floatround(g_smoke_origin[1])
				Origin[2] = floatround(g_smoke_origin[2])
				
				DamagePoisonGrenade(i, id_smoke, cod_get_user_intelligence(id_smoke)/6.0, Origin)
			}
		}
		
		Sound_Poison_Gas(ent)
		set_task(0.5, "Sound_Poison_Gas", ent)
		set_task(1.0, "Sound_Poison_Gas", ent)
		
		set_task(1.5, "SmokeExplode", ent)
		set_task(12.0, "Remove_Smoke", id_smoke)
	}
	else if(!g_smoke[id_smoke])
	{
		has_bomb[id_smoke] = 1
		remove_entity(ent)
	}
}

public Sound_Poison_Gas(id)
{
	emit_sound(id, CHAN_STATIC, Gas_Sounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

public Remove_Smoke(id)
{
	g_smoke[id] = 0
}

public Deathmessage()
{
	static iAttacker
	iAttacker = get_msg_arg_int(1)
	 
	if(!is_user_connected(iAttacker))
		return PLUGIN_CONTINUE;
	
	if(g_smoke[iAttacker] && make_smoker_class[iAttacker])
	{
		set_msg_arg_string(4, "PoisonGrenade")
	}
	
	return PLUGIN_CONTINUE;
}

get_spherical_coord(const Float:ent_origin[3], Float:redius, Float:level_angle, Float:vertical_angle, Float:origin[3])
{
	new Float:length
	length  = redius * floatcos(vertical_angle, degrees)
	origin[0] = ent_origin[0] + length * floatcos(level_angle, degrees)
	origin[1] = ent_origin[1] + length * floatsin(level_angle, degrees)
	origin[2] = ent_origin[2] + redius * floatsin(vertical_angle, degrees)
}

Create_Smoke_Group(Float:position[3])
{
	new Float:origin[12][3]
	get_spherical_coord(position, 40.0, 0.0, 0.0, origin[0])
	get_spherical_coord(position, 40.0, 90.0, 0.0, origin[1])
	get_spherical_coord(position, 40.0, 180.0, 0.0, origin[2])
	get_spherical_coord(position, 40.0, 270.0, 0.0, origin[3])
	get_spherical_coord(position, 100.0, 0.0, 0.0, origin[4])
	get_spherical_coord(position, 100.0, 45.0, 0.0, origin[5])
	get_spherical_coord(position, 100.0, 90.0, 0.0, origin[6])
	get_spherical_coord(position, 100.0, 135.0, 0.0, origin[7])
	get_spherical_coord(position, 100.0, 180.0, 0.0, origin[8])
	get_spherical_coord(position, 100.0, 225.0, 0.0, origin[9])
	get_spherical_coord(position, 100.0, 270.0, 0.0, origin[10])
	get_spherical_coord(position, 100.0, 315.0, 0.0, origin[11])
	
	for (new i = 0; i < 4; i++)
		create_Smoke(origin[i], sprites_smoke, 15/2+10)
}

create_Smoke(const Float:position[3], sprite_index, life)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, position, 0)
	write_byte(TE_FIREFIELD);
	engfunc(EngFunc_WriteCoord, position[0]);
	engfunc(EngFunc_WriteCoord, position[1]);
	engfunc(EngFunc_WriteCoord, position[2] + 50);
	write_short(150);
	write_short(sprite_index);
	write_byte(100);
	write_byte(TEFIRE_FLAG_ALPHA | TEFIRE_FLAG_SOMEFLOAT | TEFIRE_FLAG_LOOP);
	write_byte(life);
	message_end();
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, position, 0)
	write_byte(TE_FIREFIELD);
	engfunc(EngFunc_WriteCoord, position[0]);
	engfunc(EngFunc_WriteCoord, position[1]);
	engfunc(EngFunc_WriteCoord, position[2] + 50);
	write_short(150);
	write_short(sprite_index);
	write_byte(10);
	write_byte(TEFIRE_FLAG_ALPHA | TEFIRE_FLAG_SOMEFLOAT | TEFIRE_FLAG_LOOP);
	write_byte(life);
	message_end();
}

do_attack(Attacker, Victim, Inflictor, Float:fDamage)
{
	fake_player_trace_attack(Attacker, Victim, fDamage)
	fake_take_damage(Attacker, Victim, fDamage, Inflictor, DMG_POISON)
}

fake_player_trace_attack(iAttacker, iVictim, &Float:fDamage)
{
	new Float:fAngles[3], Float:fDirection[3]
	pev(iAttacker, pev_angles, fAngles)
	angle_vector(fAngles, ANGLEVECTOR_FORWARD, fDirection)
	
	new Float:fStart[3], Float:fViewOfs[3]
	pev(iAttacker, pev_origin, fStart)
	pev(iAttacker, pev_view_ofs, fViewOfs)
	xs_vec_add(fViewOfs, fStart, fStart)
	
	new iAimOrigin[3], Float:fAimOrigin[3]
	get_user_origin(iAttacker, iAimOrigin, 3)
	IVecFVec(iAimOrigin, fAimOrigin)
	
	new ptr = create_tr2() 
	engfunc(EngFunc_TraceLine, fStart, fAimOrigin, DONT_IGNORE_MONSTERS, iAttacker, ptr)
	new pHit = get_tr2(ptr, TR_pHit)
	new iHitgroup = get_tr2(ptr, TR_iHitgroup)
	new Float:fEndPos[3]
	get_tr2(ptr, TR_vecEndPos, fEndPos)

	new iTarget, iBody
	get_user_aiming(iAttacker, iTarget, iBody)
	
	if (iTarget == iVictim)
	{
		iHitgroup = iBody
	}
	else if (pHit != iVictim)
	{
		new Float:fVicOrigin[3], Float:fVicViewOfs[3], Float:fAimInVictim[3]
		pev(iVictim, pev_origin, fVicOrigin)
		pev(iVictim, pev_view_ofs, fVicViewOfs) 
		xs_vec_add(fVicViewOfs, fVicOrigin, fAimInVictim)
		fAimInVictim[2] = fStart[2]
		fAimInVictim[2] += get_distance_f(fStart, fAimInVictim) * floattan( fAngles[0] * 2.0, degrees )
		
		new iAngleToVictim = get_angle_to_target(iAttacker, fVicOrigin)
		iAngleToVictim = abs(iAngleToVictim)
		new Float:fDis = 2.0 * get_distance_f(fStart, fAimInVictim) * floatsin( float(iAngleToVictim) * 0.5, degrees )
		new Float:fVicSize[3]
		pev(iVictim, pev_size , fVicSize)
		if ( fDis <= fVicSize[0] * 0.5 )
		{
			new ptr2 = create_tr2() 
			engfunc(EngFunc_TraceLine, fStart, fAimInVictim, DONT_IGNORE_MONSTERS, iAttacker, ptr2)
			new pHit2 = get_tr2(ptr2, TR_pHit)
			new iHitgroup2 = get_tr2(ptr2, TR_iHitgroup)
			
			if ( pHit2 == iVictim && (iHitgroup2 != HIT_HEAD || fDis <= fVicSize[0] * 0.25) )
			{
				pHit = iVictim
				iHitgroup = iHitgroup2
				get_tr2(ptr2, TR_vecEndPos, fEndPos)
			}
			
			free_tr2(ptr2)
		}
		
		if (pHit != iVictim)
		{
			iHitgroup = HIT_GENERIC
			
			new ptr3 = create_tr2() 
			engfunc(EngFunc_TraceLine, fStart, fVicOrigin, DONT_IGNORE_MONSTERS, iAttacker, ptr3)
			get_tr2(ptr3, TR_vecEndPos, fEndPos)
			
			free_tr2(ptr3)
		}
	}

	set_tr2(ptr, TR_pHit, iVictim)
	set_tr2(ptr, TR_iHitgroup, iHitgroup)
	set_tr2(ptr, TR_vecEndPos, fEndPos)
	
	new Float:fMultifDamage 
	switch(iHitgroup)
	{
		case HIT_HEAD: fMultifDamage  = 1.0
		case HIT_STOMACH: fMultifDamage  = 1.0
		case HIT_LEFTLEG: fMultifDamage  = 1.0
		case HIT_RIGHTLEG: fMultifDamage  = 1.0
		default: fMultifDamage  = 1.0
	}
	fDamage *= fMultifDamage
	
	fake_trake_attack(iAttacker, iVictim, fDamage, fDirection, ptr, DMG_POISON)
	free_tr2(ptr)
}

stock ham_strip_weapon(id,weapon[])
{
	if(!equal(weapon,"weapon_",7)) return 0;

	new wId = get_weaponid(weapon);
	if(!wId) return 0;

	new wEnt;
	while((wEnt = engfunc(EngFunc_FindEntityByString,wEnt,"classname",weapon)) && pev(wEnt,pev_owner) != id) {}
	if(!wEnt) return 0;
	
	if(get_user_weapon(id) == wId) ExecuteHamB(Ham_Weapon_RetireWeapon,wEnt);

	if(!ExecuteHamB(Ham_RemovePlayerItem,id,wEnt) ) return 0;
	ExecuteHamB(Ham_Item_Kill,wEnt);

	set_pev(id,pev_weapons,pev(id,pev_weapons) & ~(1<<wId));

	return 1;
}

stock DamagePoisonGrenade(victim, attacker, Float:damage, Origin[3])
{
	if(is_user_alive(victim))
	{
		if(cs_get_user_team(victim) != cs_get_user_team(attacker))
		{
			do_attack(attacker, victim, 0, damage)
				
			message_begin(MSG_ONE, get_user_msgid("Damage"), {0,0,0}, victim)
			write_byte(30)
			write_byte(30)
			write_long((1 << 16))
			write_coord(Origin[0])
			write_coord(Origin[1])
			write_coord(Origin[2])
			message_end()
				
			new number = random_num(1,2)
			switch (number)
			{
				case 1:emit_sound(victim, CHAN_VOICE, "player/gasp1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				case 2:emit_sound(victim, CHAN_VOICE, "player/gasp2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
	}
}

stock fake_trake_attack(iAttacker, iVictim, Float:fDamage, Float:fDirection[3], iTraceHandle, iDamageBit)
{
	ExecuteHamB(Ham_TraceAttack, iVictim, iAttacker, fDamage, fDirection, iTraceHandle, iDamageBit)
}

stock fake_take_damage(iAttacker, iVictim, Float:fDamage, iInflictor = 0, iDamageBit)
{
	iInflictor = (!iInflictor) ? iAttacker : iInflictor
	ExecuteHamB(Ham_TakeDamage, iVictim, iInflictor, iAttacker, fDamage, iDamageBit)
}

stock get_angle_to_target(id, const Float:fTarget[3], Float:TargetSize = 0.0)
{
	new Float:fOrigin[3], iAimOrigin[3], Float:fAimOrigin[3], Float:fV1[3]
	pev(id, pev_origin, fOrigin)
	get_user_origin(id, iAimOrigin, 3) // end position from eyes
	IVecFVec(iAimOrigin, fAimOrigin)
	xs_vec_sub(fAimOrigin, fOrigin, fV1)
	
	new Float:fV2[3]
	xs_vec_sub(fTarget, fOrigin, fV2)
	
	new iResult = get_angle_between_vectors(fV1, fV2)
	
	if (TargetSize > 0.0)
	{
		new Float:fTan = TargetSize / get_distance_f(fOrigin, fTarget)
		new fAngleToTargetSize = floatround( floatatan(fTan, degrees) )
		iResult -= (iResult > 0) ? fAngleToTargetSize : -fAngleToTargetSize
	}
	
	return iResult
}

stock get_angle_between_vectors(const Float:fV1[3], const Float:fV2[3])
{
	new Float:fA1[3], Float:fA2[3]
	engfunc(EngFunc_VecToAngles, fV1, fA1)
	engfunc(EngFunc_VecToAngles, fV2, fA2)
	
	new iResult = floatround(fA1[1] - fA2[1])
	iResult = iResult % 360
	iResult = (iResult > 180) ? (iResult - 360) : iResult
	
	return iResult
}
