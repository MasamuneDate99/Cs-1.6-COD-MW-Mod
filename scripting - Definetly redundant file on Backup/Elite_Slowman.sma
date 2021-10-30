#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <colorchat>
#include <engine>

new bool:ma_klase[33];

new const nazwa[] = "Elite SlowMan";
new const opis[] = "Explodes after the death of posing and 100 (+ intelgencja) damage";
new const bronie = 1<<CSW_M4A1 | 1<<CSW_HEGRENADE | 1<<CSW_DEAGLE | 1<<CSW_FLASHBANG | 1<<CSW_SMOKEGRENADE;
new const zdrowie = 30;
new const kondycja = 40;
new const inteligencja = 0;
new const wytrzymalosc = 25;

new sprite_blast, sprite_white;

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "Enson");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	register_event("DeathMsg", "Death", "ade");
}

public plugin_precache()
{
	sprite_white = precache_model("sprites/white.spr") ;
	sprite_blast = precache_model("sprites/dexplo.spr");
}

public cod_class_enabled(id)
{
	if(!(get_user_flags(id) & ADMIN_IMMUNITY))
	{
		ColorChat(id, GREY, "[ELITE] Do not have permission to use this class.", nazwa);
		return COD_STOP;
	}
	ma_klase[id] = true;
	return COD_CONTINUE;
}
	
public cod_class_disabled(id)
	ma_klase[id] = false;

public Death()
{
	new id = read_data(2);
	if(ma_klase[id])
		Eksploduj(id);
}

public Eksploduj(id)
{
	new Float:fOrigin[3], iOrigin[3];
	entity_get_vector( id, EV_VEC_origin, fOrigin);
	iOrigin[0] = floatround(fOrigin[0]);
	iOrigin[1] = floatround(fOrigin[1]);
	iOrigin[2] = floatround(fOrigin[2]);
	
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
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] );
	write_coord( iOrigin[2] );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] + 300 );
	write_coord( iOrigin[2] + 300 );
	write_short( sprite_white );
	write_byte( 0 ); // startframe
	write_byte( 0 ); // framerate
	write_byte( 10 ); // life
	write_byte( 10 ); // width
	write_byte( 255 ); // noise
	write_byte( 255 ); // r, g, b
	write_byte( 100 );// r, g, b
	write_byte( 100 ); // r, g, b
	write_byte( 128 ); // brightness
	write_byte( 8 ); // speed
	message_end();
	
	new entlist[33];
	new numfound = find_sphere_class(id, "player", 200.0 , entlist, 32);
	
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		
		if (!is_user_alive(pid) || get_user_team(id) == get_user_team(pid))
			continue;
		cod_inflict_damage(id, pid, 100.0, 0.5);
	}
	return PLUGIN_CONTINUE;
}