#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fakemeta>
#include <fakemeta_util>
#include <engine>
#include <hamsandwich>
#include <cstrike>
#include <xs>
#include <fun>
        
new const nazwa[]   = "Sentry Engineer";
new const opis[]    = "You can deploy a sentry gun each round";
new const bronie    = (1<<CSW_XM1014)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FIVESEVEN)|(1<<CSW_MP5NAVY)|(1<<CSW_FLASHBANG);
new const zdrowie   = 50;
new const kondycja  = 10;
new const inteligencja = 0;
new const wytrzymalosc = 10;
    
#define SENTRY_THINK 0.3

#define OFFSET_WPN_LINUX  4
#define OFFSET_WPN_WIN 	  41

#define fm_point_contents(%1) engfunc(EngFunc_PointContents, %1)

#define fm_DispatchSpawn(%1) dllfunc(DLLFunc_Spawn, %1)

new bool:ma_dzialko[33];
new gMenuDzialko[33]

new g_maxplayers;

new mdl_gib_build1
new mdl_gib_build2
new mdl_gib_build3
new mdl_gib_build4

static const Nazwy_broni[][] = {
	"", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
	"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
	"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
	"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
	"weapon_ak47", "weapon_knife", "weapon_p90" }

new pcvarPercent,pcvarHealth,pcvarDamage;

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
   
	register_event("HLTV", "NowaRunda_Dzialko", "a", "1=0", "2=0");

	RegisterHam(Ham_Spawn, "player", "DajNoweDzialko", 1);
	RegisterHam(Ham_TakeDamage, "func_breakable", "fwHamTakeDamage_Dzialko" );
	RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack_Building")

	for (new i = 1; i < sizeof Nazwy_broni; i++)
	{
		if (Nazwy_broni[i][0]) RegisterHam(Ham_Item_Deploy, Nazwy_broni[i], "ham_ItemDeploy_Post", 1)
	}

	register_think("sentry_shot","sentry_shot")

	g_maxplayers = get_maxplayers();

	pcvarPercent = register_cvar("inzynier_percent","4")
	pcvarHealth = register_cvar("inzynier_health","800")
	pcvarDamage = register_cvar("inzynier_damage","25.0");

}

public plugin_precache()
{


	precache_sound("sentry_shoot.wav");
	
	precache_model("models/v_tfc_spanner.mdl")
	precache_model("models/base2.mdl")
	precache_model("models/sentry2.mdl")
	
	mdl_gib_build1 = engfunc(EngFunc_PrecacheModel,"models/mbarrel.mdl")
	mdl_gib_build2 = engfunc(EngFunc_PrecacheModel,"models/computergibs.mdl")
	mdl_gib_build3 = engfunc(EngFunc_PrecacheModel,"models/metalplategibs.mdl")
	mdl_gib_build4 = engfunc(EngFunc_PrecacheModel,"models/cindergibs.mdl")
	
	precache_sound("debris/bustmetal1.wav");
	precache_sound("debris/bustmetal2.wav");

}

public cod_class_enabled(id)
{

	ma_dzialko[id] = true;
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_smokegrenade");
	ma_klase[id] = true;

}

public cod_class_disabled(id)
{
	ma_klase[id] = false;

}

public fwHamTakeDamage_Dzialko( this, idinflictor, idattacker, Float:damage, damagebits ) {
	static classname[ 20 ];
	pev( this, pev_classname, classname, 19 );
	
	if( ( equal( classname, "sentry_shot" ) || equal( classname, "sentry_base" ) ) && is_user_connected( idattacker ) && get_user_team(pev(this,pev_iuser1)) == get_user_team(idattacker) ){
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
	
}

public NowaRunda_Dzialko()
{
	remove_entity_name("sentry_base")
	remove_entity_name("sentry_shot")
}

public OpcjeDzialka(id)
{
	new menu,newmenu,menupage
	player_menu_info(id,menu,newmenu,menupage);
	if(menu > 0 || newmenu != -1)
	{
		return PLUGIN_CONTINUE;
	}
	
	gMenuDzialko[id] = menu_create("Dzialo", "OpcjeDziala_Handle");
	menu_additem(gMenuDzialko[id],"Create Sentry");
	menu_additem(gMenuDzialko[id],"Destroy Sentry");
	
	menu_setprop(gMenuDzialko[id],MPROP_NUMBER_COLOR,"\r")
	menu_display(id,gMenuDzialko[id]);
	return PLUGIN_CONTINUE;
}

public OpcjeDziala_Handle(id,menu,item)
{
	if(item == MENU_EXIT || !is_user_alive(id))
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	switch(item)
	{
		case 0:
		{
			if(ma_klase[id] && ma_dzialko[id])
			{
				new Float:Origin[3]
				pev(id, pev_origin, Origin)
				new Float:vNewOrigin[3]
				new Float:vTraceDirection[3]
				new Float:vTraceEnd[3]
				new Float:vTraceResult[3]
				velocity_by_aim(id, 64, vTraceDirection) // get a velocity in the directino player is aiming, with a multiplier of 64...
				vTraceEnd[0] = vTraceDirection[0] + Origin[0]
				vTraceEnd[1] = vTraceDirection[1] + Origin[1]
				vTraceEnd[2] = vTraceDirection[2] + Origin[2]
				fm_trace_line(id, Origin, vTraceEnd, vTraceResult)
				vNewOrigin[0] = vTraceResult[0]
				vNewOrigin[1] = vTraceResult[1]
				vNewOrigin[2] = Origin[2]
				if(!(StawDzialo(vNewOrigin,id)))
				{
					client_print(id, print_center, "Restricted Area for Sentry !")
				}
				else
				{
					ma_dzialko[id] = false;
				}
			}
		}
		case 1:
		{
			new iEnt = -1;
			while((iEnt = find_ent_by_class(iEnt,"sentry_shot")) != 0)
			{
				if(pev_valid(iEnt) && pev(iEnt,pev_iuser1) == id)
				{
					FX_Demolish(iEnt)
					remove_entity(iEnt);
				}
			}
			iEnt = -1;
			while((iEnt = find_ent_by_class(iEnt,"sentry_base")) != 0)
			{
				if(pev_valid(iEnt) && pev(iEnt,pev_iuser1) == id)
				{
					FX_Demolish(iEnt)
					remove_entity(iEnt);
				}
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_CONTINUE;
}

public bool:StawDzialo(Float:origin[3],id)
{
	if (fm_point_contents(origin) != CONTENTS_EMPTY || is_hull_default(origin, 32.0))
	{
		return false
	}
	new Float:hitPoint[3], Float:originDown[3]
	originDown = origin
	originDown[2] = -5000.0
	fm_trace_line(0, origin, originDown, hitPoint)
	new Float:DistanceFromGround = vector_distance(origin, hitPoint)
	
	new Float:difference = 36.0 - DistanceFromGround
	if (difference < -1 * 10.0 || difference > 10.0) return false
	
	new sentry_base = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"func_breakable"))
	if (!sentry_base){
		return false
	}	
	set_pev(sentry_base, pev_classname, "sentry_base")
	
	engfunc(EngFunc_SetModel, sentry_base, "models/base2.mdl")
	engfunc(EngFunc_SetSize, sentry_base, {-16.0, -16.0, 0.0}, {16.0, 16.0, 25.0})
	engfunc(EngFunc_SetOrigin, sentry_base, origin)
	new Float:fAngle[3];
	pev(id, pev_v_angle, fAngle)
	fAngle[0] = 0.0
	fAngle[1] += 180.0
	fAngle[2] = 0.0
	set_pev(sentry_base, pev_angles, fAngle)
	set_pev(sentry_base, pev_solid, SOLID_BBOX)
	set_pev(sentry_base, pev_movetype, MOVETYPE_TOSS)
	set_pev(sentry_base, pev_iuser1, id)
	set_pev(sentry_base, pev_iuser2, 0)
	set_pev(sentry_base, pev_iuser3, 0)
	
	return true;
}

public ham_ItemDeploy_Post(weapon_ent)
{
	static owner
	owner = get_pdata_cbase(weapon_ent, OFFSET_WPN_WIN, OFFSET_WPN_LINUX);
	
	static weaponid
	weaponid = cs_get_weapon_id(weapon_ent)
	
	if(!is_user_alive(owner))
	{
		return HAM_IGNORED;
	}
	
	static menu,newmenu,menupage
	player_menu_info(owner,menu,newmenu,menupage);
	
	if(gMenuDzialko[owner] && newmenu == gMenuDzialko[owner])
	{
		show_menu(owner,0,"^n");
		gMenuDzialko[owner] = 0;
	}
	
	if(weaponid == CSW_KNIFE && ma_klase[owner])
	{
		entity_set_string(owner, EV_SZ_viewmodel, "models/v_tfc_spanner.mdl")
		OpcjeDzialka(owner);
	}
	return HAM_IGNORED;
}

	
stock FX_Demolish(build)
{
	if(!pev_valid(build)) return;
	
	new Float:forigin[3],iorigin[3],i
	pev(build, pev_origin, forigin)
	FVecIVec(forigin,iorigin)
		
	for(i = 1;i <= 1;i++)
	{
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(iorigin[0])
		write_coord(iorigin[1])
		write_coord(iorigin[2])
		write_coord(random_num(-150,150))
		write_coord(random_num(-150,150))
		write_coord(random_num(150,350))
		write_angle(random_num(0,360))
		write_short(mdl_gib_build1)
		write_byte(0) // bounce
		write_byte(10) // life
		message_end()
	}
	for(i = 1;i <= 1;i++)
	{
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(iorigin[0])
		write_coord(iorigin[1])
		write_coord(iorigin[2])
		write_coord(random_num(-150,150))
		write_coord(random_num(-150,150))
		write_coord(random_num(150,350))
		write_angle(random_num(0,360))
		write_short(mdl_gib_build2)
		write_byte(0) // bounce
		write_byte(10) // life
		message_end()
	}
	for(i = 1;i <= 1;i++)
	{
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(iorigin[0])
		write_coord(iorigin[1])
		write_coord(iorigin[2])
		write_coord(random_num(-150,150))
		write_coord(random_num(-150,150))
		write_coord(random_num(150,350))
		write_angle(random_num(0,360))
		write_short(mdl_gib_build3)
		write_byte(0) // bounce
		write_byte(10) // life
		message_end()
	}
	for(i = 1;i <= 1;i++)
	{
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(iorigin[0])
		write_coord(iorigin[1])
		write_coord(iorigin[2])
		write_coord(random_num(-150,150))
		write_coord(random_num(-150,150))
		write_coord(random_num(150,350))
		write_angle(random_num(0,360))
		write_short(mdl_gib_build4)
		write_byte(0) // bounce
		write_byte(10) // life
		message_end()
	}
}




public DajNoweDzialko(id)
{
	if(!is_user_connected(id) || !is_user_alive(id))
		return PLUGIN_CONTINUE;
		
	if(ma_klase[id])
	{
		ma_dzialko[id] = true;
	}
	return PLUGIN_CONTINUE;
}

set_animation(id, anim) {
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(anim)
	write_byte(pev(id, pev_body))
	message_end()
}

public fw_TraceAttack_Building(id, enemy, Float:damage, Float:direction[3], tracehandle, damagetype){
	if (!(1 <= enemy <= g_maxplayers) || get_user_weapon(enemy) != CSW_KNIFE || !is_user_alive(enemy))
	{
		return HAM_IGNORED
	}
	new classname[24]
	pev(id, pev_classname, classname, sizeof classname - 1)
	new weapon = get_user_weapon(enemy)
	if(weapon == CSW_KNIFE && ma_klase[enemy] && pev(id,pev_iuser1) == enemy && equal(classname,"sentry_base") && pev(id,pev_iuser2) < 100){
		set_pev(id,pev_iuser2,pev(id,pev_iuser2)+get_pcvar_num(pcvarPercent) > 100 ? 100 : pev(id,pev_iuser2)+get_pcvar_num(pcvarPercent));
		set_animation(enemy,8);
		if(pev(id,pev_iuser2) >= 100 && !pev(id,pev_iuser3)){
			client_print(enemy,print_center,"%d %%",pev(id,pev_iuser2))
			set_pev(id,pev_iuser3,stawdzialo2(id));
		}
		else
		{
			client_print(enemy,print_center,"%d %%",pev(id,pev_iuser2))
		}
		
	}
	return HAM_IGNORED
}


public stawdzialo2(ent)
{
	new Float:origin[3];
	pev(ent,pev_origin,origin);
	new sentry_shot2 = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"func_breakable"))
	if (!sentry_shot2)
	{
		return 0
	}	
	new szHealth[16]
	get_pcvar_string(pcvarHealth,szHealth,charsmax(szHealth))
	
	fm_set_kvd(sentry_shot2, "health", szHealth, "func_breakable")
	fm_set_kvd(sentry_shot2, "material", "6", "func_breakable")
	fm_DispatchSpawn(sentry_shot2)
	
	set_pev(sentry_shot2, pev_classname, "sentry_shot")
	
	engfunc(EngFunc_SetModel, sentry_shot2, "models/sentry2.mdl")
	engfunc(EngFunc_SetSize, sentry_shot2, {-16.0, -16.0, 0.0}, {16.0, 16.0, 20.0})
	origin[2] += 25.0;
	engfunc(EngFunc_SetOrigin, sentry_shot2, origin)
	new Float:fAngle[3];
	pev(pev(ent,pev_iuser1), pev_v_angle, fAngle)
	fAngle[0] = 0.0
	fAngle[1] += 180.0
	fAngle[2] = 0.0
	set_pev(sentry_shot2, pev_angles, fAngle)
	set_pev(sentry_shot2, pev_solid, SOLID_BBOX)
	set_pev(sentry_shot2, pev_movetype, MOVETYPE_TOSS)
	set_pev(sentry_shot2, pev_iuser1, pev(ent,pev_iuser1))
	set_pev(sentry_shot2, pev_iuser2, ent)
	
	set_pev( sentry_shot2, pev_sequence, 0 );
	set_pev( sentry_shot2, pev_animtime, get_gametime() );
	set_pev( sentry_shot2, pev_framerate, 1.0 );
	
	set_pev(sentry_shot2, pev_nextthink, get_gametime() + SENTRY_THINK)
	return sentry_shot2;
}

public sentry_find_player(ent)
{
	new Float:fOrigin[3],Float:fOrigin2[3],Float:distance = 999999.0,Float:hitOrigin[3],iCloseId = 0,iOwner = 0;
	iOwner = pev(ent,pev_iuser1)
	pev(ent,pev_origin,fOrigin)
	for(new i = 1;i<33;i++)
	{
		if(!is_user_alive(i) || get_user_team(i) == get_user_team(iOwner))
		{
			continue;
		}
		pev(i, pev_origin, fOrigin2)
		new hitent = fm_trace_line(ent, fOrigin, fOrigin2, hitOrigin)
		if(distance > vector_distance(fOrigin,fOrigin2) && hitent == i)
		{
			distance = vector_distance(fOrigin,fOrigin2)
			iCloseId = i;
		}
	}
	return iCloseId;
}

public sentry_shot(ent)
{
	if(!pev_valid(ent))
	{
		return PLUGIN_CONTINUE;
	}
	if(entity_get_float(ent,EV_FL_health) <= 0.0)
	{
		if(pev_valid(pev(ent,pev_iuser2)))
		{
			remove_entity(pev(ent,pev_iuser2));
		}
		remove_entity(ent);
		return PLUGIN_CONTINUE;
	}
	new iFind = 0;
	if((iFind = sentry_find_player(ent)))
	{
		remove_task(ent+45676);
		turntotarget(ent,iFind);
		sentry_shot3(ent,iFind);
		set_task(0.5,"stop_anim",ent+45676)
	}
	set_pev(ent, pev_nextthink, get_gametime() + SENTRY_THINK)
	return PLUGIN_CONTINUE;
}

public sentry_shot3(ent,target)
{
	new Float:sentryOrigin[3], Float:targetOrigin[3], Float:hitOrigin[3]
	pev(ent, pev_origin, sentryOrigin)
	sentryOrigin[2] += 18.0
	pev(target, pev_origin, targetOrigin)
	targetOrigin[0] += random_float(-16.0, 16.0)
	targetOrigin[1] += random_float(-16.0, 16.0)
	targetOrigin[2] += random_float(-16.0, 16.0)
	new hit = fm_trace_line(ent, sentryOrigin, targetOrigin, hitOrigin)
	if(hit == target)
	{
		knockback_explode(target, sentryOrigin, 5.0)
		ExecuteHam(Ham_TakeDamage, target, 0, pev(ent,pev_iuser1),get_pcvar_float(pcvarDamage) , 1);
		set_pev( ent, pev_sequence, 1 );
		set_pev( ent, pev_animtime, get_gametime() );
		set_pev( ent, pev_framerate, 1.0 );
	}
	FX_Trace(sentryOrigin, hitOrigin)
	engfunc(EngFunc_EmitSound, ent, CHAN_STATIC, "sentry_shoot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}

public stop_anim(ent){
	ent -= 45676;
	if(pev_valid(ent)){
		set_pev( ent, pev_sequence, 0 );
		set_pev(ent, pev_animtime, get_gametime() );
		set_pev( ent, pev_framerate, 1.0 );
	}
}

public knockback_explode(id, const Float:exp_origin[3], Float:force)
{
	if(!is_user_alive(id)) return
	
	if(force == 0.0) return
	
	new Float:old_velocity[3], Float:velocity[3], Float:id_origin[3], Float:output[3]
	pev(id, pev_origin, id_origin);
	get_speed_vector(exp_origin, id_origin, force, velocity);
	pev(id, pev_velocity, old_velocity);
	xs_vec_add(velocity, old_velocity, output)
	set_pev(id, pev_velocity, output)
}

public turntotarget(ent, target)
{
	if (target)
	{
		new Float:closestOrigin[3],Float:sentryOrigin[3]
		pev(target, pev_origin, closestOrigin)
		pev(ent, pev_origin, sentryOrigin)
		new Float:newAngle[3]
		pev(ent, pev_angles, newAngle)
		new Float:x = closestOrigin[0] - sentryOrigin[0]
		new Float:z = closestOrigin[1] - sentryOrigin[1]
		
		new Float:radians = floatatan(z/x, radian)
		newAngle[1] = radians * 180.0 / 3.14159
		if (closestOrigin[0] < sentryOrigin[0])
		newAngle[1] -= 180.0
		
		new Float:h = closestOrigin[2] - sentryOrigin[2]
		new Float:b = vector_distance(sentryOrigin, closestOrigin)
		radians = floatatan(h/b, radian)
		new Float:degs = radians * 180.0 / 3.14159
		new Float:RADIUS = 830.0
		new Float:degreeByte = RADIUS/256.0
		new Float:tilt = 127.0 - degreeByte * degs
		set_pev(ent, pev_angles, newAngle)
		set_pev(ent, pev_controller_1, floatround(tilt))
	}
}

stock FX_Trace(const Float:idorigin[3], const Float:targetorigin[3])
{
	new id[3],target[3]
	FVecIVec(idorigin,id)
	FVecIVec(targetorigin,target)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(6)//TE_TRACER
	write_coord(id[0])
	write_coord(id[1])
	write_coord(id[2])
	write_coord(target[0])
	write_coord(target[1])
	write_coord(target[2])
	message_end()
}

stock bool:is_hull_default(Float:origin[3], const Float:BOUNDS){
	new Float:traceEnds[8][3], Float:traceHit[3], hitEnt
	traceEnds[0][0] = origin[0] - BOUNDS
	traceEnds[0][1] = origin[1] - BOUNDS
	traceEnds[0][2] = origin[2] - BOUNDS
	
	traceEnds[1][0] = origin[0] - BOUNDS
	traceEnds[1][1] = origin[1] - BOUNDS
	traceEnds[1][2] = origin[2] + BOUNDS
	
	traceEnds[2][0] = origin[0] + BOUNDS
	traceEnds[2][1] = origin[1] - BOUNDS
	traceEnds[2][2] = origin[2] + BOUNDS
	
	traceEnds[3][0] = origin[0] + BOUNDS
	traceEnds[3][1] = origin[1] - BOUNDS
	traceEnds[3][2] = origin[2] - BOUNDS
	
	traceEnds[4][0] = origin[0] - BOUNDS
	traceEnds[4][1] = origin[1] + BOUNDS
	traceEnds[4][2] = origin[2] - BOUNDS
	
	traceEnds[5][0] = origin[0] - BOUNDS
	traceEnds[5][1] = origin[1] + BOUNDS
	traceEnds[5][2] = origin[2] + BOUNDS
	
	traceEnds[6][0] = origin[0] + BOUNDS
	traceEnds[6][1] = origin[1] + BOUNDS
	traceEnds[6][2] = origin[2] + BOUNDS
	
	traceEnds[7][0] = origin[0] + BOUNDS
	traceEnds[7][1] = origin[1] + BOUNDS
	traceEnds[7][2] = origin[2] - BOUNDS
	
	for (new i = 0; i < 8; i++) {
		if (fm_point_contents(traceEnds[i]) != CONTENTS_EMPTY)
		return true
		
		hitEnt = fm_trace_line(0, origin, traceEnds[i], traceHit)
		if (hitEnt != 0)
		return true
		for (new j = 0; j < 3; j++)
		if (traceEnds[i][j] != traceHit[j])
		return true
	}
	return false
}

stock get_speed_vector(const Float:origin1[3], const Float:origin2[3], Float:force, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(force*force / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
