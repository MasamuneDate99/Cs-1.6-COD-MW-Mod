#include <amxmodx>
#include <amxmisc>
#include <colorchat>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fun>
#include <codmod>

#define PLUGIN "Bonusowe Paczki"
#define VERSION "1.0"
#define AUTHOR "radim edytowal ricO"

new const modelitem[] = "models/box_new.mdl";
new const prefix[] = "^04[BONUS]^01"

public plugin_init()
{
	register_plugin(PLUGIN, AUTHOR, VERSION)
	
	register_forward(FM_Touch, "fwd_touch")
	
	register_event("DeathMsg", "DeathMsg", "a")
	register_logevent("PoczatekRundy", 2, "1=Round_Start"); 
	
}

public plugin_precache()
{
	precache_model(modelitem);
}


public PoczatekRundy()	
	kill_all_entity("paczka")


public DeathMsg()
{
	new kid = read_data(1)
	new vid = read_data(2)
	
	if( kid == vid )
		return PLUGIN_CONTINUE;
	if(is_user_connected(kid) && is_user_connected(vid))
        create_itm(vid, 0) // linia 46
	
	return PLUGIN_CONTINUE;
}

public UzyjPaczki(id)
{
	if( !is_user_connected(id) || !is_user_alive(id) )
		return PLUGIN_HANDLED;
	
	
	switch(random_num(1, 5))
	{
		case 1:
		{
			new hp = get_user_health(id);
			new losowehp = random_num(-40, -470);
			set_user_health(id, hp+losowehp)
			ColorChat(id, GREY, "^x04%s ^x01zFind poison. You lose^x03%i^x01 HP!", prefix, losowehp)
		}
		case 2:
		{
			new hp = get_user_health(id);
			new losowehp = random_num(15, 70);
			set_user_health(id, hp+losowehp)
			ColorChat(id, GREY, "^x04%s ^x01zFind a first aid kit. you get ^x03%i^x01 HP!", prefix, losowehp)	
		}
		case 3:
		{
			new kasa = cs_get_user_money(id);
			new losowakasa = random_num(300, 4000);
			cs_set_user_money(id, kasa+losowakasa)
			ColorChat(id, GREY, "^x04%s ^x01zYou found a purse of gold. You got ^x03%i^x01 $!", prefix, losowakasa)	
		}
		case 5:
		{
			new losowyexp = random_num(110, 5150);
			cod_set_user_xp(id, cod_get_user_xp(id) + losowyexp);
			ColorChat(id, GREY, "^x04%s ^x01zFind ^x03%i^x01 Exp!", prefix, losowyexp)
		}
	}
	return PLUGIN_HANDLED;
}


public create_itm(id, id_item)
{ 
	new Float:origins[3]
	pev(id,pev_origin,origins);
	new entit=create_entity("info_target")
	
	origins[0]+=50.0
	origins[2]-=32.0
	
	set_pev(entit,pev_origin,origins)
	entity_set_model(entit,modelitem)
	set_pev(entit,pev_classname,"paczka");
	
	dllfunc(DLLFunc_Spawn, entit); 
	set_pev(entit,pev_solid,SOLID_BBOX); 
	set_pev(entit,pev_movetype,MOVETYPE_FLY);
	
	engfunc(EngFunc_SetSize,entit,{-1.1, -1.1, -1.1},{1.1, 1.1, 1.1});
	
	engfunc(EngFunc_DropToFloor,entit);
	
	set_pev(entit, pev_iuser1, id_item)
}
public fwd_touch(ent,id)
{       
	if(!is_user_alive(id)) return FMRES_IGNORED;
	
	if(!pev_valid(ent)) return FMRES_IGNORED;
	
	static classname[32];
	pev(ent,pev_classname,classname,31); 
	
	if(!equali(classname,"paczka")) return FMRES_IGNORED;
	
	if(pev(id,pev_button))
	{
	{
		UzyjPaczki(id)
		engfunc(EngFunc_RemoveEntity,ent);
	}
}
	return FMRES_IGNORED; 
}
public kill_all_entity(classname[]) {
new iEnt = find_ent_by_class(-1, classname)
while(iEnt > 0) {
	remove_entity(iEnt)
	iEnt = find_ent_by_class(iEnt, classname)		
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
