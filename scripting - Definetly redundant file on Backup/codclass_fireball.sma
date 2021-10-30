#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <fun>

#define DMG_BULLET (1<<1)
        
new const nazwa[]   = "Fire ball";
new const opis[]    = "It has 2 FireBall, and an additional 3 damage in FAMAS";
new const bronie    = (1<<CSW_FAMAS)|(1<<CSW_DEAGLE);
new const zdrowie   = 15;
new const kondycja  = 10;
new const inteligencja = 0;
new const wytrzymalosc = 5;

new bool:ma_FireBall[32];
new ilosc_FireBall[32];
new WybuchFireBall;
new WybuchFireBall2;
new ostatni_FireBall[32];
new bool:mozepuscic

new ma_klase[33];
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_Spawn, "player", "Odrodzenie", 1);
	register_event("CurWeapon","Wyciagnij_Bron","be","1=1");
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	register_touch("FireBall", "*" , "DotykFireBall");
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");
	
}
public plugin_precache(){
	precache_model("models/mag/v_knife.mdl");
	precache_model("models/mag/fireball.mdl");
	WybuchFireBall=precache_model("sprites/dexplo.spr");
	WybuchFireBall2=precache_model("sprites/shockwave.spr");
}
public cod_class_enabled(id){
	ilosc_FireBall[id]=2;
	ma_FireBall[id]=true;
	ma_klase[id]=true;
	return COD_CONTINUE;
}
public cod_class_disabled(id){
	ilosc_FireBall[id]=0;
	ma_FireBall[id]=false;
	ma_klase[id]=false;
}
public NowaRunda()
{
	mozepuscic = false;
	set_task(5.0,"Odblokuj")
}
public Odblokuj() {
	mozepuscic = true;
	}
public Odrodzenie(id){
	ilosc_FireBall[id]=2;
}
public Wyciagnij_Bron(id){
	new bron=read_data(2);
	if(bron==CSW_KNIFE && ma_klase[id])
		set_pev(id, pev_viewmodel2, "models/mag/v_knife.mdl");
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits,wartosc){
	if(!is_user_connected(idattacker))
		return HAM_IGNORED; 
	
	if(!ma_klase[idattacker])
		return HAM_IGNORED;
	
	new bron=get_user_weapon(idattacker);
	if(bron==CSW_FAMAS) 
		cod_inflict_damage(idattacker, this, damage+3.0, 0.0, idinflictor, damagebits);
	return HAM_IGNORED;
}

public client_PreThink(id){
	if((pev(id,pev_button) & IN_USE) && !(pev(id,pev_oldbuttons) & IN_USE) && (ma_FireBall[id]))
		StworzFireBall(id);
}
public StworzFireBall(id){
	if(!mozepuscic)
{
  client_print(id,print_center,"Fireball can use after 5 seconds of starting the round!")
  return PLUGIN_CONTINUE;
}
	if (!is_user_alive(id))
		return PLUGIN_CONTINUE;
	if (!ilosc_FireBall[id])
		return PLUGIN_CONTINUE;
	if(ostatni_FireBall[id]+2.0>get_gametime())
		return PLUGIN_CONTINUE;
	
	ostatni_FireBall[id]=floatround(get_gametime());
	ilosc_FireBall[id]--;
	new Float: Origin[3];
	new Float: vAngle[3];
	new Float: Velocity[3];
	entity_get_vector(id, EV_VEC_v_angle, vAngle);
	entity_get_vector(id, EV_VEC_origin , Origin);
	
	new Ent = create_entity("info_target");
	
	entity_set_string(Ent, EV_SZ_classname, "FireBall");
	entity_set_model(Ent, "models/mag/fireball.mdl");
	
	vAngle[0] *= -1.0;
	
	entity_set_origin(Ent, Origin);
	entity_set_vector(Ent, EV_VEC_angles, vAngle);

	entity_set_int(Ent, EV_INT_effects, 2);
	entity_set_int(Ent, EV_INT_solid, SOLID_BBOX);
	entity_set_int(Ent, EV_INT_movetype, MOVETYPE_FLY);
	entity_set_edict(Ent, EV_ENT_owner, id);
	
	VelocityByAim(id, 1000 , Velocity);
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity);
	
	return PLUGIN_CONTINUE;
}

public DotykFireBall(ent){
	if(!is_valid_ent(ent))
		return;
	
	new attacker = entity_get_edict(ent, EV_ENT_owner);
	new entlist[33];
	new numfound = find_sphere_class(ent, "player", 200.0, entlist, 32);
	new Float:fOrigin[3];
	new iOrigin[3];
	
	entity_get_vector(ent, EV_VEC_origin, fOrigin);
	
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(WybuchFireBall);
	write_byte(32);
	write_byte(20);
	write_byte(0);
	message_end();
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(21);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2] + 200);
	write_short(WybuchFireBall2);
	write_byte(0);
	write_byte(0);
	write_byte(4);
	write_byte(60);
	write_byte(0);
	write_byte(237);
	write_byte(28);
	write_byte(28);
	write_byte(100);
	write_byte(0);
	message_end();
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(21);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2] + 300);
	write_short(WybuchFireBall2);
	write_byte(0);
	write_byte(0);
	write_byte(4);
	write_byte(60);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(100);
	write_byte(0);
	message_end();
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(21);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2] + 450);
	write_short(WybuchFireBall);
	write_byte(0);
	write_byte(0);
	write_byte(4);
	write_byte(60);
	write_byte(0);
	write_byte(100); // r
	write_byte(0); // g
	write_byte(0); // b
	write_byte(100);
	write_byte(0);
	message_end();
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(21);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2] + 575);
	write_short(WybuchFireBall2);
	write_byte(0);
	write_byte(0);
	write_byte(4);
	write_byte(60);
	write_byte(0);
	write_byte(237);
	write_byte(28);
	write_byte(28);
	write_byte(100);
	write_byte(0);
	message_end();
	
	for (new i=0; i < numfound; i++){		
		new pid = entlist[i];
		
		if (!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid))
			continue;
		cod_inflict_damage(attacker, pid, 30.0, 0.4, ent, (1<<24));
	}
	remove_entity(ent);
}