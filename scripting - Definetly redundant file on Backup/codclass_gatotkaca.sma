#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <hamsandwich>
#include <fakemeta_util>
#include <codmod>
#include <fun>

#define VERSION "1.0"
#define AUTHOR "Asep"

enum _:SKILL
{
	SKILL_DELAY,
	SKILL_READY,
	SKILL_USE_MELAYANG,
	SKILL_USE_GEMPA
}

new const NAMA_CLASS[]		= "Gatot Kaca";
new const INFO_CLASS[]		= "[E] Skill Tapak Bumi With Delay 8 Seconds, You Have Change 1/3 To Kill Enemy With Keris";
new const P_CLASS_SKINS[] 	= "models/p_keris_gatotkaca.mdl";
new const V_CLASS_SKINS[]	= "models/v_keris_gatotkaca.mdl";
new const SENJATA_CLASS		= 1<<CSW_FIVESEVEN;
new const HEALTH_CLASS		= 10;
new const CONDITION_CLASS	= 5;
new const INTELEGENT_CLASS	= 20;
new const ENDURANCE_CLASS	= 15;

new bool:make_class[33], g_HamBot, sprite_white
new skill_hempas_bumi[33], Float:old_gravity[33]

public plugin_init() 
{
	register_plugin(NAMA_CLASS, VERSION, AUTHOR)
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "Ham_Item_Deploy_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage")
	register_event("ResetHUD", "ResetHUD", "abe");
	cod_register_class(NAMA_CLASS, INFO_CLASS, SENJATA_CLASS, HEALTH_CLASS, CONDITION_CLASS, INTELEGENT_CLASS, ENDURANCE_CLASS);
}

public plugin_precache()
{
	sprite_white = precache_model("sprites/white.spr");
	
	precache_model(P_CLASS_SKINS)
	precache_model(V_CLASS_SKINS)
	
	precache_sound("gatotkaca_terbang.wav")
	precache_sound("gatotkaca_exp.wav")
}

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
	RegisterHamFromEntity(Ham_TakeDamage, id, "TakeDamage");
}

public cod_class_enabled(id)
{
	make_class[id] = true;
	skill_hempas_bumi[id] = SKILL_READY;
}

public ResetHUD(id)
{
	if(make_class[id])
	{
		skill_hempas_bumi[id] = SKILL_READY;
	}
}

public cod_class_disabled(id)
{
	make_class[id] = false;
	skill_hempas_bumi[id] = SKILL_DELAY;
}

public Skill_Delay(id)
{
	id -= 50000
	
	client_print(id, print_center, "Your Skill Is Ready To Use Now")
	skill_hempas_bumi[id] = SKILL_READY
}

public cod_class_skill_used(id)
{
	switch(skill_hempas_bumi[id])
	{
		case SKILL_DELAY:
		{
			client_print(id, print_center, "Your Skill Is Delay Now")
		}
		case SKILL_READY:
		{
			old_gravity[id] = get_user_gravity(id)
			emit_sound(id, CHAN_ITEM, "gatotkaca_terbang.wav", 1.0, ATTN_STATIC, 0, PITCH_HIGH)
			
			set_user_gravity(id, 0.2)
			set_pev(id, pev_velocity, {0.0, 0.0, 1000.0})
			
			skill_hempas_bumi[id] = SKILL_USE_MELAYANG
			set_task(0.1, "Cek_Ground", id+20000)
		}
		case SKILL_USE_GEMPA:
		{
			set_user_godmode(id, 1)
			
			set_user_noclip(id)
			set_pev(id, pev_maxspeed, 250.0+float(cod_get_user_trim(id))*1.3)
			
			new Float:VelocityJatoh[3]
			VelocityByAim(id, 1000, VelocityJatoh)
			set_pev(id, pev_velocity, VelocityJatoh)
			
			set_task(0.5, "Gempa_Now", id+40000)
		}
	}
}

public Gempa_Now(id)
{
	id -= 40000
	if(skill_hempas_bumi[id] == SKILL_USE_GEMPA)
	{
		set_pev(id, pev_maxspeed, 250.0+float(cod_get_user_trim(id))*1.3)
		
		new Float:forigin[3], entlist[33], numfound, iOrigin[3]
		entity_get_vector(id, EV_VEC_origin, forigin)
		FVecIVec(forigin, iOrigin)
		
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
		write_byte( TE_BEAMCYLINDER );
		write_coord( iOrigin[0] );
		write_coord( iOrigin[1] );
		write_coord( iOrigin[2] );
		write_coord( iOrigin[0] );
		write_coord( iOrigin[1] + 400 );
		write_coord( iOrigin[2] + 400 );
		write_short( sprite_white );
		write_byte( 0 ); // startframe
		write_byte( 0 ); // framerate
		write_byte( 10 ); // life
		write_byte( 10 ); // width
		write_byte( 255 ); // noise
		write_byte( 255 ); // r, g, b
		write_byte( 255 );// r, g, b
		write_byte( 255 ); // r, g, b
		write_byte( 255 ); // brightness
		write_byte( 0 ); // speed
		message_end();
	
		numfound = find_sphere_class(0, "player", 400.0, entlist, 32, forigin);
		for(new i = 0; i < numfound; i++)
		{		
			new pid = entlist[i];
			
			if(get_user_team(pid) == get_user_team(id))
				continue;
				
			if(is_user_alive(pid))
			{
				cod_inflict_damage(id, pid, 10.0, 0.1, id, DMG_BULLET)
				Screenshake(pid, 6.0+float(cod_get_user_intelligence(id))*0.2, 600.0, 600.0)
			}
		}
		
		set_user_gravity(id, old_gravity[id])
		emit_sound(id, CHAN_ITEM, "gatotkaca_exp.wav", 1.0, ATTN_STATIC, 0, PITCH_HIGH)
		skill_hempas_bumi[id] = SKILL_DELAY
		
		set_task(0.5, "GodMode", id+50000)
		set_task(8.0, "Skill_Delay", id+50000)
	}
}

public GodMode(id)
{
	id -= 50000
	set_user_godmode(id)
}

public Cek_Ground(id)
{
	id -= 20000
	
	set_user_noclip(id, 1)
	set_user_maxspeed(id, 0.1)
	
	skill_hempas_bumi[id] = SKILL_USE_GEMPA
}

public Ham_Item_Deploy_Post(ent)
{
	if(!pev_valid(ent))
		return
	
	new id = get_pdata_cbase(ent, 41, 4)
	if(is_user_alive(id) && make_class[id])
	{
		set_pev(id, pev_viewmodel2, V_CLASS_SKINS)
		set_pev(id, pev_weaponmodel2, P_CLASS_SKINS)
		
		if(skill_hempas_bumi[id] == SKILL_USE_GEMPA)
		{
			set_user_maxspeed(id, 0.1)
		}
	}
}

public client_PreThink(id)
{
	if(skill_hempas_bumi[id] == SKILL_USE_GEMPA)
	{
		set_user_maxspeed(id, 0.1)
	}
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	if(!make_class[idattacker])
		return HAM_IGNORED;
	
	if(get_user_weapon(idattacker) == CSW_KNIFE && damagebits & DMG_BULLET && damage > 20.0 && random_num(1, 3) == 1)
	{
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	}
	
	return HAM_IGNORED;
}

stock Screenshake(id, Float:duration, Float:frequency, Float:amplitude)
{
	static ScreenShake = 0;
	if(!ScreenShake)
	{
		ScreenShake = get_user_msgid("ScreenShake");
	}
	
	message_begin(id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, ScreenShake, _, id);
	write_short(FixedUnsigned16(amplitude, 1<<12));
	write_short(FixedUnsigned16(duration, 1<<12));
	write_short(FixedUnsigned16(frequency, 1<<8));
	message_end();
}

stock FixedUnsigned16(Float:value, scale)
{
	new output;
	output = floatround(value * scale);
	
	if(output < 0) output = 0;
	if(output > 0xFFFF)
	output = 0xFFFF;
	
	return output;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
