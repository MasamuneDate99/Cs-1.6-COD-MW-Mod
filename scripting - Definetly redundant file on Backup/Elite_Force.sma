#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>
#include <fun>

new const nazwa[]	= "Elite Force";
new const opis[]	= "Has 1/10 and 1/12 of the MP5 to drop weapons enemies.";
new const bronie	= (1<<CSW_MP5NAVY)|(1<<CSW_DEAGLE);
new const zdrowie	= 30;
new const kondycja	= 17;
new const inteligencja	= 0;
new const wytrzymalosc	= 10;

new bool: ma_klase[33];
new identyfikator[33];

public plugin_init(){
	register_plugin(nazwa, "1.0", "Vasto_Lorde");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

}
public cod_class_enabled(id)
{
	get_user_name(id, identyfikator, 32);
	if(!equal(identyfikator, "kira"))
	{
		client_print(id, print_chat, "[ELITE] Do not have permission to use this class.")
		return COD_STOP;
	}
	ma_klase[id]=true;
	
	return COD_CONTINUE;
}
public cod_class_disabled(id)
{
	ma_klase[id]=false;
}

public DMG(this, idinflictor, idattacker, Float:damage, damagebits,wartosc){
	if(!is_user_connected(idattacker))
		return HAM_IGNORED; 
	
	if(!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if(!is_user_connected(this))
		return HAM_IGNORED;
	
	if(get_user_team(this)==get_user_team(idattacker))
		return HAM_IGNORED;
	
	if(damage<=0)
		return HAM_IGNORED;
	
	if(get_user_weapon(idattacker)==CSW_MP5NAVY && is_user_connected(idattacker)){
		if(random_num(1,12)==1)
			client_cmd(this,"drop");
		if(random_num(1,10)==1)
			cod_inflict_damage(idattacker, this, float(get_user_health(this))+1.0, 0.0, idinflictor, damagebits);
	}
	
	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
