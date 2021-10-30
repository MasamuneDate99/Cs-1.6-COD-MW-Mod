/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <codmod>
#include <engine>

new sprite_white;
new ilosc_trutek_gracza[33];
new ma_klase[33];

new const nazwa[] = "Chesmik";
new const opis[] = "It has three poison that can kill [E]";
new const bronie = 1<<CSW_AK47 | 1<<CSW_USP;
new const zdrowie = 30;
new const kondycja = 10;
new const inteligencja = 5;
new const wytrzymalosc = 15;

public plugin_init() 
{
	register_plugin("Chemik", "1.0", "QTM_Peyote");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_think("poison","PoisonThink");
	
	register_event("ResetHUD", "ResetHUD", "abe");
}

public plugin_precache()
{
	sprite_white = precache_model("sprites/white.spr");
	precache_model("models/QTM_CodMod/w_trutko.mdl");
	precache_model("models/QTM_CodMod/w_trutkot.mdl");
}

public cod_class_enabled(id)
{
	ilosc_trutek_gracza[id] = 3;
	ma_klase[id] = true;
}

public cod_class_disabled(id)
{
	ilosc_trutek_gracza[id] = 0;
	ma_klase[id] = false;
}

public cod_class_skill_used(id)
{
	if(!ma_klase[id])
	{
		return PLUGIN_CONTINUE;
	}
	
	
	if(!ilosc_trutek_gracza[id])
	{
		client_print(id, print_center, "You only have 3 poison per round!");
		return PLUGIN_CONTINUE;
	}
		
	ilosc_trutek_gracza[id]--;
	
	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin, origin);
	
	new ent = create_entity("info_target");
	entity_set_string(ent, EV_SZ_classname, "poison");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_solid, SOLID_NOT);
	entity_set_vector(ent, EV_VEC_origin, origin);
	entity_set_float(ent, EV_FL_ltime, halflife_time() + 5 + 0.1);
	
	
	entity_set_model(ent, "models/QTM_CodMod/w_trutko.mdl");
	set_rendering(ent, kRenderFxGlowShell, 0,255,0, kRenderFxNone, 255);
	drop_to_floor(ent);
	
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1);
	
	return PLUGIN_CONTINUE;
}

public PoisonThink(ent)
{
	new id = entity_get_edict(ent, EV_ENT_owner);
	new dist = 300;

	if (entity_get_edict(ent, EV_ENT_euser2) == 1)
	{		
		new Float:forigin[3];
		entity_get_vector(ent, EV_VEC_origin, forigin);
		
		new entlist[33];
		new numfound = find_sphere_class(0,"player", float(dist),entlist, 32,forigin);
		
		for (new i=0; i < numfound; i++)
		{		
			new pid = entlist[i];
			
			if (get_user_team(pid) == get_user_team(id))
				continue;
			
			cod_inflict_damage(id, pid, 1.0, 0.2, ent, (1<<24))
		}
		
		entity_set_edict(ent, EV_ENT_euser2, 0);
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.5);
		
		return PLUGIN_CONTINUE;
	}
	
	if (entity_get_float(ent, EV_FL_ltime) < halflife_time() || !is_user_alive(id))
	{
		remove_entity(ent);
		return PLUGIN_CONTINUE;
	}
	
	if (entity_get_float(ent, EV_FL_ltime)-2.0 < halflife_time())
		set_rendering ( ent, kRenderFxNone, 255,255,255, kRenderTransAlpha, 100 );
		
	new Float:forigin[3];
	entity_get_vector(ent, EV_VEC_origin, forigin);
					
	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(forigin[i]);
		
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] );
	write_coord( iOrigin[2] );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] + dist );
	write_coord( iOrigin[2] + dist );
	write_short( sprite_white );
	write_byte( 0 ); // startframe
	write_byte( 0 ); // framerate
	write_byte( 10 ); // life
	write_byte( 10 ); // width
	write_byte( 255 ); // noise
	write_byte( 100 ); // r, g, b
	write_byte( 255 );// r, g, b
	write_byte( 100 ); // r, g, b
	write_byte( 128 ); // brightness
	write_byte( 0 ); // speed
	message_end();
	
	entity_set_edict(ent, EV_ENT_euser2 ,1);
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.5);
	    
	return PLUGIN_CONTINUE;

}

public ResetHUD(id)
{
	if(ma_klase[id])
		ilosc_trutek_gracza[id] = 3;
}

public client_disconnect(id)
{
	new ent = find_ent_by_class(0, "poison");
	while(ent > 0)
	{
		if(entity_get_edict(id, EV_ENT_owner) == id)
			remove_entity(ent);
		ent = find_ent_by_class(ent, "poison");
	}
}
