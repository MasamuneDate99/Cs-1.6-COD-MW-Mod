#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fakemeta>
#include <fakemeta_util>
#include <xs>

#define SKIN_AK47	"models/v_ak47_law.mdl"
#define SHOOT_SOUND	"weapons/law_shoot.wav"

#define FLAMING_TOTAL 40
#define DAMAGE_FLAMING 3
#define DELAY_FLAMING 8.0

#define TASK_DELAY 293566
#define TASK_BURN 293697
new identyfikator[33];
/* --------------------------------------------- */

new const NAMA_CLASS[]		= "Elite Law";
new const INFO_CLASS[]		= "Press E To Shoot Flame Laser, Delay 8 Seconds";
new const SENJATA_CLASS		= 1<<CSW_AK47 | 1<<CSW_MP5NAVY | 1<<CSW_DEAGLE | 1<<CSW_ELITE; // Upgrade dikit ini class , tambahin mp5navy
new const HEALTH_CLASS		= 50;
new const CONDITION_CLASS	= 60;
new const INTELEGENT_CLASS	= 0;
new const ENDURANCE_CLASS	= 50;
   
new sprite_fire, sprite_smoke, sTrail
new law_class[33], flame_count[33], can_flame[33]

public plugin_init()
{
	register_plugin(NAMA_CLASS, "1.0", "t1t1z")  
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	cod_register_class(NAMA_CLASS, INFO_CLASS, SENJATA_CLASS, HEALTH_CLASS, CONDITION_CLASS, INTELEGENT_CLASS, ENDURANCE_CLASS)
}
 
public plugin_precache()
{
	sprite_fire = precache_model("sprites/fire.spr")
	sprite_smoke = precache_model("sprites/steam1.spr")
	sTrail = precache_model("sprites/laserbeam.spr")
	
	precache_sound(SHOOT_SOUND)
	precache_model(SKIN_AK47)
}

public Event_CurWeapon(id)
{
	if(!is_user_alive(id))
		return
	
	if(get_user_weapon(id) == CSW_AK47)
	{
		if(law_class[id])
			set_pev(id, pev_viewmodel2, SKIN_AK47)
	}
}

public cod_class_enabled(id)
{

	get_user_name(id, identyfikator, 32);
	if(!equal(identyfikator, "Xeruex.") && !equal(identyfikator, "Slashwires") && !equal(identyfikator, "Hengky.-") && !equal(identyfikator, "mbah jiman") && !equal(identyfikator, "YeonHon") && !equal(identyfikator, "vN!") && !equal (identyfikator, "-RequiemID-") && !equal (identyfikator, "K.A") && !equal (identyfikator, "the fast killer"))
	{
		client_print(id, print_chat, "[ELITE] Do not have permission to use this class.")
		return COD_STOP;
	}
	law_class[id] = true
	can_flame[id] = true
	
	return COD_CONTINUE
}
 
public cod_class_disabled(id)
{
	law_class[id] = false
	can_flame[id] = false
}



public cod_class_skill_used(id)
{
	if(law_class[id] && can_flame[id])
	{
		new target, body
		get_user_aiming(id, target, body)
			
		new Float:originF[3]
		fm_get_aim_origin(id, originF)
			
		if(target > 0 && target <= get_maxplayers() && get_user_team(target) != get_user_team(id))
		{
			can_flame[id] = false
			set_task(DELAY_FLAMING, "can_flaming_again", id+TASK_DELAY)
			
			new Float:Origin_Laser[3], aimOrigin[3]
			get_position(id, 10.0, 2.0, 0.0, Origin_Laser)
			get_user_origin(id, aimOrigin, 3)
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMPOINTS)
			engfunc(EngFunc_WriteCoord, Origin_Laser[0])
			engfunc(EngFunc_WriteCoord, Origin_Laser[1])
			engfunc(EngFunc_WriteCoord, Origin_Laser[2])
			engfunc(EngFunc_WriteCoord, originF[0])
			engfunc(EngFunc_WriteCoord, originF[1])
			engfunc(EngFunc_WriteCoord, originF[2])
			write_short(sTrail)
			write_byte(0) // start frame
			write_byte(0) // framerate
			write_byte(15) // life
			write_byte(6) // line width
			write_byte(0) // amplitude
			write_byte(200) // red
			write_byte(50) // green
			write_byte(0) // blue
			write_byte(200) // brightness
			write_byte(0) // speed
			message_end()
			
			Make_BulletHole(id, originF, 120.0)
			emit_sound(id, CHAN_WEAPON, SHOOT_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		
			new Float:fStart[3], Float:fEnd[3], Float:fVel[3]
			pev(id, pev_origin, fStart)
			velocity_by_aim(id, 64, fVel)
			fStart[0] = float(aimOrigin[0])
			fStart[1] = float(aimOrigin[1])
			fStart[2] = float(aimOrigin[2])
			fEnd[0] = fStart[0]+fVel[0]
			fEnd[1] = fStart[1]+fVel[1]
			fEnd[2] = fStart[2]+fVel[2]
			
			cod_inflict_damage(id, target, 12.0, 0.0, 0, DMG_BURN)
				
			if(task_exists(id+TASK_BURN))
				remove_task(id+TASK_BURN)
			
			flame_count[target] = FLAMING_TOTAL
				
			new data[2]
			data[0] = target
			data[1] = id
			set_task(0.1, "burning_flame", target+TASK_BURN, data, 2, "b")
		}
	}
}
 
public can_flaming_again(id)
{
	id -= TASK_DELAY
	
	if(law_class[id] && !can_flame[id])
	{
		can_flame[id] = true
		client_print(id, print_center, "[SKILL] You can use the skill now")
	}
}
 
public burning_flame(data[2])
{
	new id = data[0]
   
	if(!is_user_alive(id))
	{
		flame_count[id] = 0
		remove_task(id+TASK_BURN)
		
		return PLUGIN_CONTINUE
	}
   
	new origin[3], flags = pev(id, pev_flags)
	get_user_origin(id, origin)
   
	if(flags & FL_INWATER || flame_count[id] < 1 || !get_user_health(id))
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_SMOKE)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2] - 50)
		write_short(sprite_smoke)
		write_byte(random_num(15,20))
		write_byte(random_num(10,20))
		message_end()
		
		remove_task(id+TASK_BURN)
		
		return PLUGIN_CONTINUE
	}
	
	static Float:velocity[3], Float:knockback
	pev(id, pev_velocity, velocity)
	
	if(flags & FL_ONGROUND)
		knockback = 1.0
	else
		knockback = 0.15
	
	xs_vec_mul_scalar(velocity, knockback, velocity)
	set_pev(id, pev_velocity, velocity)
	
	cod_inflict_damage(data[1], id, float(DAMAGE_FLAMING), 0.0, 0, DMG_BURN)
   
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_SPRITE)
	write_coord(origin[0] + random_num(-5,5))
	write_coord(origin[1] + random_num(-5,5))
	write_coord(origin[2] + random_num(-10,10))
	write_short(sprite_fire)
	write_byte(random_num(5,10))
	write_byte(200)
	message_end()
   
	flame_count[id]--
	
	return PLUGIN_CONTINUE
}

stock get_position(id,Float:forw, Float:right, Float:up, Float:vStart[])
{
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_view_ofs, vUp) //for player
	xs_vec_add(vOrigin, vUp, vOrigin)
	pev(id, pev_v_angle, vAngle) // if normal entity ,use pev_angles
	
	angle_vector(vAngle,ANGLEVECTOR_FORWARD, vForward) //or use EngFunc_AngleVectors
	angle_vector(vAngle,ANGLEVECTOR_RIGHT, vRight)
	angle_vector(vAngle,ANGLEVECTOR_UP, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}

stock Make_BulletHole(id, Float:Origin[3], Float:Damage)
{
	static Decal; Decal = random_num(41, 45)
	static LoopTime; 
	
	if(Damage > 100.0) LoopTime = 2
	else LoopTime = 1
	
	for(new i = 0; i < LoopTime; i++)
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		engfunc(EngFunc_WriteCoord, Origin[0])
		engfunc(EngFunc_WriteCoord, Origin[1])
		engfunc(EngFunc_WriteCoord, Origin[2])
		write_byte(Decal)
		message_end()
		
		// Show sparcles
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)
		engfunc(EngFunc_WriteCoord, Origin[0])
		engfunc(EngFunc_WriteCoord, Origin[1])
		engfunc(EngFunc_WriteCoord, Origin[2])
		write_short(id)
		write_byte(Decal)
		message_end()
	}
}
