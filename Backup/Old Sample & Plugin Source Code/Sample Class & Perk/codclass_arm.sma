#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>
#include <fun>

new const nazwa[]	= "Arm";
new const opis[]	= "Has 5 multijump and fast.";
new const bronie	= (1<<CSW_M3)|(1<<CSW_DEAGLE);
new const zdrowie	= 30;
new const kondycja	= 72;
new const inteligencja	= 0;
new const wytrzymalosc	= 0;

new bool: ma_klase[33];
new skoki[33];

public plugin_init(){
	register_plugin(nazwa, "1.0", "Vasto_Lorde");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_event("CurWeapon", "Bron", "be", "1=1");
	register_forward(FM_CmdStart, "Skok");
}
public cod_class_enabled(id){
	ma_klase[id]=true;
}
public cod_class_disabled(id){
	ma_klase[id]=false;
}
public plugin_precache(){
	precache_model("models/rgcod/v_m3k.mdl");
}
public Bron(id){
	if(!ma_klase[id])
		return;
	
	if(read_data(2)==CSW_M3)
		set_pev(id, pev_viewmodel2, "models/rgcod/v_m3k.mdl");
	
}
public Skok(id, uc_handle){
	if(!is_user_alive(id))
		return FMRES_IGNORED;
	if(!ma_klase[id])
		return FMRES_IGNORED;
	
	if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(pev(id, pev_flags) & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && skoki[id]){
		skoki[id]--;
		new Float:velocity[3];
		pev(id, pev_velocity,velocity);
		velocity[2]=random_float(270.0,280.0);
		set_pev(id, pev_velocity,velocity);
	}
	else
		if(pev(id, pev_flags) & FL_ONGROUND)
			skoki[id]=5;
	
	return FMRES_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
