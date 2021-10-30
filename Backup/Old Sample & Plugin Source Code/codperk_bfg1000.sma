/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <cstrike>
#include <engine>
#include <hamsandwich>
#include <fakemeta_util>
#include <codmod>

#define MAKE_MATTERY 7045

new const nazwa[] = "BFG10000";
new const opis[] = "You Get BFG10000";

new bool: ma_perk[33], bool: ma_bron[33];

new Float:idle[33]
new bfg10k_ammo[33]
new bfg_shooting[33];

enum {NONE = 0, SHOOTING, SHOOTED };

new sprite_blast;
new sprite_laser;

new PCvarAmmo,
	PCvarBundleDMG,
	PCvarBundleINT,
	PCvarMatteryDMG,
	PCvarMatteryINT;
	
public plugin_init()
{
	register_plugin(nazwa, "1.1", "Hleb & Wi'Waldi");
	
	cod_register_perk(nazwa, opis);	
	
	register_forward(FM_CmdStart, "CmdStart")
	register_forward(FM_PlayerPreThink, "PreThink");
	register_forward(FM_Touch, "BFG_Touch");
	RegisterHam(Ham_Item_Deploy, "weapon_p90", "Weapon_Deploy", 1);
	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_p90", "Weapon_WeaponIdle");
	register_event("ResetHUD", "ResetHUD", "abe");
	register_event("HLTV", "Nowa_Runda", "a", "1=0", "2=0");
	register_think("bfg10000", "BFGThink");
	
	PCvarAmmo = register_cvar("cod_bfg_ammo", "2")
	PCvarBundleDMG = register_cvar("cod_bfg_bundle_dmg", "7");
	PCvarBundleINT = register_cvar("cod_bfg_bundle_int", "0.0");
	PCvarMatteryDMG = register_cvar("cod_bfg_mattery_dmg", "40");
	PCvarMatteryINT = register_cvar("cod_bfg_mattery_int", "0.3");
	
}
public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	sprite_laser = precache_model("sprites/dot.spr")
	precache_sound("weapons/bfg_fire.wav");
	precache_model("models/bfg_mattery.mdl");
	precache_model("models/v_bfg10000.mdl");
	precache_model("models/p_bfg10000.mdl");
}
public cod_perk_enabled(id, wartosc)
{
	cod_give_weapon(id, CSW_P90)	
	ma_perk[id] = true;	
	ma_bron[id] = true;
	bfg10k_ammo[id] = get_pcvar_num(PCvarAmmo);
}
public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_P90)
	ma_perk[id] = false;
	ma_bron[id] = false;
	bfg10k_ammo[id] = 0;
}
public CmdStart(id, uc_handle)
{
	new weapon = get_user_weapon(id);
	
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;	
		
	if(weapon == 30 && ma_bron[id])
	{
		if(!ma_perk[id])
		return FMRES_IGNORED
		
		if(!bfg10k_ammo[id] && (pev(id, pev_oldbuttons) & IN_ATTACK))
		{
			client_print(id, print_center, "Have already used all the bundles!");
			return PLUGIN_CONTINUE;
		}
		new Button = get_uc(uc_handle, UC_Buttons)
		new OldButton = pev(id, pev_oldbuttons)	
		new ent = fm_find_ent_by_owner(-1, "weapon_p90", id);
		
		if(Button & IN_ATTACK && !(OldButton & IN_ATTACK) && bfg_shooting[id] == NONE)
		{
			Button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, Button);
			
			if(!bfg10k_ammo[id] || !idle[id]) 
				return FMRES_IGNORED;
			if(idle[id] && (get_gametime()-idle[id]<=0.7)) 
				return FMRES_IGNORED;
				
			set_pev(id, pev_weaponanim, 4);
			emit_sound(id, CHAN_ITEM, "weapons/bfg_fire.wav", 0.5, ATTN_NORM, 0, PITCH_NORM);
	
			message_begin(MSG_ONE, get_user_msgid("BarTime"), {0, 0, 0}, id)
			write_byte(1)
			write_byte(0)
			message_end()
	
			bfg_shooting[id] = SHOOTING
			set_task(0.8, "MakeMattery", id+MAKE_MATTERY)
			return FMRES_IGNORED
		}
		if(bfg_shooting[id] == SHOOTING && (Button & (IN_USE | IN_ATTACK2 | IN_BACK | IN_FORWARD | IN_CANCEL | IN_JUMP | IN_MOVELEFT | IN_MOVERIGHT | IN_RIGHT)))
		{
			remove_task(id+MAKE_MATTERY)
			message_begin(MSG_ONE, get_user_msgid("BarTime"), {0, 0, 0}, id)
			write_byte(0)
			write_byte(0)
			message_end()
			bfg_shooting[id] = NONE
			emit_sound(id, CHAN_ITEM, "weapons/bfg_fire.wav", 0.5, ATTN_NORM, (1<<5), PITCH_NORM)
			return FMRES_IGNORED
		}
		if(Button & IN_RELOAD)
		{
			Button &= ~IN_RELOAD;
			set_uc(uc_handle, UC_Buttons, Button);
			
			set_pev(id, pev_weaponanim, 0);
			set_pdata_float(id, 83, 0.5, 4);
			if(ent)
				set_pdata_float(ent, 48, 0.5+3.0, 4);
		}
		
		if(ent)
			cs_set_weapon_ammo(ent, -1);
		cs_set_user_bpammo(id, 30, bfg10k_ammo[id]);	
	}
	else if(weapon != 30 && ma_bron[id])
	{
		idle[id] = 0.0;
		if(task_exists(id+MAKE_MATTERY))
		{
			remove_task(id+MAKE_MATTERY)
			message_begin(MSG_ONE, get_user_msgid("BarTime"), {0, 0, 0}, id)
			write_byte(0)
			write_byte(0)
			message_end()
			bfg_shooting[id] = NONE
			emit_sound(id, CHAN_ITEM, "weapons/bfg_fire.wav", 0.5, ATTN_NORM, (1<<5), PITCH_NORM)
			return FMRES_IGNORED
		}
	}
	return FMRES_IGNORED
}
public MakeMattery(id)
{
	id-=MAKE_MATTERY
	
	bfg_shooting[id] = SHOOTED
	bfg10k_ammo[id]--
	
	new Float: Origin[3], Float: vAngle[3], Float: Velocity[3];
	pev(id, pev_v_angle, vAngle);
	pev(id, pev_origin , Origin);
	set_pev(id, pev_weaponanim, 2);
	
	new ent = fm_create_entity("info_target");
		
	set_pev(ent, pev_classname, "bfg10000");
	engfunc(EngFunc_SetModel, ent, "models/bfg_mattery.mdl");
	fm_set_user_rendering(ent, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 255)
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"),_, id);
	write_short(255<<14);
	write_short(2<<12);
	write_short(255<<14);
	message_end();
	
	vAngle[0] *= -1.0;
	
	set_pev(ent, pev_origin, Origin);
	set_pev(ent, pev_angles, vAngle);
	
	set_pev(ent, pev_effects, 2);
	set_pev(ent, pev_solid, SOLID_BBOX);
	set_pev(ent, pev_movetype, MOVETYPE_FLY);
	set_pev(ent, pev_owner, id);
	
	velocity_by_aim(id, 300 , Velocity);
	set_pev(ent, pev_velocity, Velocity);
	set_pev(ent, pev_nextthink, get_gametime() + 0.1);
}
public BFG_Touch(ent)
{
	if (!pev_valid(ent))
		return FMRES_IGNORED;
	new class[32]
	pev(ent, pev_classname, class, charsmax(class))

	if(!equal(class, "bfg10000"))
		return FMRES_IGNORED
		
	new attacker = pev(ent, pev_owner);
	
	new Float:fOrigin[3];
	pev(ent, pev_origin, fOrigin);	
	
	new iOrigin[3];
	FVecIVec(fOrigin, iOrigin)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(sprite_blast);
	write_byte(32); 
	write_byte(20); 
	write_byte(0);
	message_end();

	new victim = -1
	while((victim = engfunc(EngFunc_FindEntityInSphere, victim, fOrigin, 120.0)) != 0)
	{		
		if (!is_user_alive(victim) || get_user_team(attacker) == get_user_team(victim))
			continue;
		cod_inflict_damage(attacker, victim, get_pcvar_float(PCvarMatteryDMG), get_pcvar_float(PCvarMatteryINT), ent, (1<<24));
	}
	fm_remove_entity(ent);
	bfg_shooting[attacker] = NONE
	return PLUGIN_CONTINUE
}	
public ResetHUD(id)
{
	bfg10k_ammo[id] = get_pcvar_num(PCvarAmmo);
	bfg_shooting[id] = NONE
}
public client_disconnect(id)
{
	new ent = find_ent_by_class(0, "bfg10000");
	while(ent > 0)
	{
		if(pev(ent, pev_owner) == id)
			fm_remove_entity(ent);
		ent = find_ent_by_class(ent, "bfg10000");
	}
}
public BFGThink(ent)
{
	if(pev(ent, pev_iuser2))
		return PLUGIN_CONTINUE;
	
	
	set_pev(ent, pev_iuser1, 1);
	
	new attacker = pev(ent, pev_owner);
	new Float:vec1[3]	
	pev(ent, pev_origin, vec1);	
	
	new victim = -1
	while((victim = engfunc(EngFunc_FindEntityInSphere, victim, vec1, 500.0)) != 0)	
	{		
		if (is_user_alive(victim) && get_user_team(attacker) != get_user_team(victim) && fm_is_ent_visible(ent, victim))
		{
			cod_inflict_damage(attacker, victim, get_pcvar_float(PCvarBundleDMG), get_pcvar_float(PCvarBundleINT), ent, (1<<24));	
			
			new vec2[3]
			get_user_origin(victim, vec2)
			new iOrigin[3];
			FVecIVec(vec1, iOrigin);

			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte (0)     //TE_BEAMENTPOINTS 0
			write_coord(iOrigin[0])
			write_coord(iOrigin[1])
			write_coord(iOrigin[2])
			write_coord(vec2[0])
			write_coord(vec2[1])
			write_coord(vec2[2])
			write_short(sprite_laser)
			write_byte(1) // framestart
			write_byte(5) // framerate
			write_byte(2) // life
			write_byte(10) // width
			write_byte(0) // noise
			write_byte(0)     // r, g, b
			write_byte(255)       // r, g, b
			write_byte(0)       // r, g, b
			write_byte(255) // brightness
			write_byte(150) // speed
			message_end()
		}
	}

	set_pev(ent, pev_nextthink, get_gametime() + 0.1);
	
	return PLUGIN_CONTINUE;
}
public Weapon_Deploy(ent)
{
	new id = get_pdata_cbase(ent, 41, 4);
	if(!ma_perk[id])
		return PLUGIN_CONTINUE

	set_pev(id, pev_viewmodel2, "models/v_bfg10000.mdl");
	set_pev(id, pev_weaponmodel2, "models/p_bfg10000.mdl");
	set_pev(id, pev_weaponanim, 6)
		
	return PLUGIN_CONTINUE;
}
public Weapon_WeaponIdle(ent)
{
	new id = get_pdata_cbase(ent, 41, 4);
	if(get_user_weapon(id) == 30 && ma_bron[id])
	{
		if(!idle[id]) 
			idle[id] = get_gametime();
	}
}
public Nowa_Runda()
{
        new ent = find_ent_by_class(-1, "bfg10000");
        while(ent > 0)
        {
                fm_remove_entity(ent);
                ent = find_ent_by_class(ent, "bfg10000");
        }       
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
