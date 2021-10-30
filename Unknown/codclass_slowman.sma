#include <amxmodx>
#include <codmod>
#include <engine>
#include <fun>
#include <cstrike>

new bool:ma_klase[33];

new const nazwa[] = "SlowMan";
new const opis[] = "When die, instantly kill enemy around you";
new const bronie = 1<< CSW_GALIL | 1<<CSW_VESTHELM | 1<<CSW_SMOKEGRENADE | 1<<CSW_DEAGLE;
new const zdrowie = 20;
new const kondycja = 15;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new sprite_blast, sprite_white;

public plugin_init()
{
register_plugin(nazwa, "1.0", "QTM_Peyote");

cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

register_event("DeathMsg", "Death", "ade");

register_event("ResetHUD", "ResetHUD", "abe");
}

public plugin_precache()
{
sprite_white = precache_model("sprites/white.spr") ;
sprite_blast = precache_model("sprites/dexplo.spr");
}

public cod_class_enabled(id)
{
set_user_armor(id, 125);
ma_klase[id] = true;
}

public cod_class_disabled(id)
{
set_user_armor(id, 0)
ma_klase[id] = false;
}
public ResetHUD(id)
set_task(0.1, "ResetHUDx", id);

public ResetHUDx(id)
{
if(!is_user_connected(id)) return;

if(!ma_klase[id]) return;

}

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
new numfound = find_sphere_class(id, "player", 100.0 , entlist, 32);

for (new i=0; i < numfound; i++)
{
new pid = entlist[i];

if (!is_user_alive(pid) || get_user_team(id) == get_user_team(pid))
continue;
cod_inflict_damage(id, pid, float(get_user_health(pid)), 0.0);
}
return PLUGIN_CONTINUE;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
