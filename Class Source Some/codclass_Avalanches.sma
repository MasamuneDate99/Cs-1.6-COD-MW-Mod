/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <codmod>
#include <colorchat>
#include <engine>
#include <hamsandwich>

new const nazwa[] = "Avalanche";
new const opis[] = "Can put 2 of their replicas, which are reflected damage. Each replica has 400 Health.";
new const bronie = 1<<CSW_MP5NAVY | 1<<CSW_USP | 1<<CSW_FLASHBANG;
new const zdrowie = 20;
new const kondycja = 40;
new const inteligencja = 10;
new const wytrzymalosc = 10;

new pcvar_ilosc_replik, pcvar_hp_replik;

new ilosc_kukiel[33];

new sprite_blast;

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	RegisterHam(Ham_TakeDamage, "info_target", "TakeDamage");
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");
	
	pcvar_ilosc_replik = register_cvar("ilosc_replik", "2");
	pcvar_hp_replik = register_cvar("hp_replik", "400");
}

public plugin_precache()
	sprite_blast = precache_model("sprites/dexplo.spr");

public cod_class_enabled(id)
{
	Spawn(id);
}

public cod_class_skill_used(id)
{
	if(ilosc_kukiel[id] < 1)
	{
		client_print(id, print_center, "You used all the replicas!");
		return;
	}
	
	new Float:OriginGracza[3], Float:OriginKukly[3], Float:VBA[3];
	entity_get_vector(id, EV_VEC_origin, OriginGracza);
	VelocityByAim(id, 50, VBA);
	
	VBA[2] = 0.0;
	
	for(new i=0; i < 3; i++)
		OriginKukly[i] = OriginGracza[i]+VBA[i];
		
	if(get_distance_f(OriginKukly, OriginGracza) < 40.0)
	{
		client_print(id, print_center, "You will need to provide a working replica on!");
		return;
	}
	
	new model[55], Float:AngleKukly[3],
	
	SekwencjaKukly = entity_get_int(id, EV_INT_gaitsequence);
	SekwencjaKukly = SekwencjaKukly == 3 || SekwencjaKukly == 4? 1: SekwencjaKukly;
	
	entity_get_string(id, EV_SZ_model, model, 54);
	entity_get_vector(id, EV_VEC_angles, AngleKukly);
	
	AngleKukly[0] = 0.0;
	
	new ent = create_entity("info_target");
	
	entity_set_string(ent, EV_SZ_classname, "Kukla");
	entity_set_model(ent, model);
	entity_set_vector(ent, EV_VEC_origin, OriginKukly);
	entity_set_vector(ent, EV_VEC_angles, AngleKukly);
	entity_set_vector(ent, EV_VEC_v_angle, AngleKukly);
	entity_set_int(ent, EV_INT_sequence, SekwencjaKukly);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	entity_set_float(ent, EV_FL_health, get_pcvar_float(pcvar_hp_replik));
	entity_set_float(ent, EV_FL_takedamage, DAMAGE_YES);
	entity_set_size(ent, Float:{-16.0,-16.0, -36.0}, Float:{16.0,16.0, 40.0});
	entity_set_int(ent, EV_INT_iuser1, id);
	
	ilosc_kukiel[id]--;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_alive(idattacker))
		return HAM_IGNORED;
		
	new classname[33];
	entity_get_string(this, EV_SZ_classname, classname, 32);
	
	if(!equal(classname, "Kukla")) 
		return HAM_IGNORED;
	
	new owner = entity_get_int(this, EV_INT_iuser1);
	
	if(get_user_team(owner) == get_user_team(idattacker))
		return HAM_SUPERCEDE;
		
	new bool:bez_obrazen = get_user_weapon(idattacker) == CSW_KNIFE && damagebits & DMG_BULLET
	
	if(!bez_obrazen)
		cod_inflict_damage(owner, idattacker, damage, 0.2, this, damagebits);
	
	new Float:fOrigin[3], iOrigin[3];
	
	entity_get_vector(this, EV_VEC_origin, fOrigin);
	
	FVecIVec(fOrigin, iOrigin);
	
	if(damage > entity_get_float(this, EV_FL_health))
	{
		if(!bez_obrazen)
		{
			new entlist[33];
			new numfound = find_sphere_class(this, "player", 120.0, entlist, 32);
			
			for (new i=0; i < numfound; i++)
			{		
				new pid = entlist[i];
				
				if (!is_user_alive(pid) || get_user_team(owner) == get_user_team(pid))
					continue;
				cod_inflict_damage(owner, pid, 40.0, 0.3, this, (1<<24));
			}
		}
	
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
	}
	
	return HAM_IGNORED;
}

public Spawn(id)
	ilosc_kukiel[id] = get_pcvar_num(pcvar_ilosc_replik);

public NowaRunda()
	remove_entity_name("Kukla")
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
