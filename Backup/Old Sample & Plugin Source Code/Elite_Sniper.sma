#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <codmod>
#include <cstrike>

#define DMG_BULLET (1<<1)
        
new const nazwa[]   = "Elite Sniper";
new const opis[]    = "Awp 1/2, 1/8 with Deagle and clothes enemy.";
new const bronie    = (1<<CSW_AWP)|(1<<CSW_DEAGLE);
new const zdrowie   = 50;
new const kondycja  = 30;
new const inteligencja = 0;
new const wytrzymalosc = 30;

new identyfikator[33];
new bool: ma_klase[33];

new CT_Skins[4][] = {"sas","gsg9","urban","gign"};
new Terro_Skins[4][] = {"arctic","leet","guerilla","terror"};
 
public plugin_init()
{
	register_plugin(nazwa, "1.0", "Alelluja");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	get_user_name(id, identyfikator, 32);
	if(!equal(identyfikator, "Provocation|PhantomKing*") && !equal(identyfikator, "AuliaSyafira>//<") && !equal(identyfikator, "b|nk.") && !equal(identyfikator, "[Team Rzuh] | riora1996") && !equal(identyfikator, "capung") && !equal(identyfikator, "Whistle*") && !equal(identyfikator, "sL.-") && !equal(identyfikator, "R.D") && !equal(identyfikator, "Orang") && !equal(identyfikator, "rzy.-") && !equal(identyfikator, "Nabilah48")  && !equal(identyfikator, "Break Event") && !equal(identyfikator, "qillanssa"))
	{
		client_print(id, print_chat, "[ELITE] Do not have permission to use this class.")
		return COD_STOP;
	}
   
   
	ZmienUbranie(id, 0);
	ma_klase[id] = true;
   
	return COD_CONTINUE;
}


public cod_class_disabled(id)

{

	ZmienUbranie(id, 1);

	ma_klase[id] = false;

}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED; 
	
	if(!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if(damagebits & DMG_BULLET)
	{
		new weapon = get_user_weapon(idattacker);
		
		if(weapon == CSW_AWP && damage > 20.0 && random_num(1,2) == 1) 
			cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
			
		if(weapon == CSW_DEAGLE && damage > 20.0 && random_num(1,7) == 1) 
			cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
			
	}
	
	return HAM_IGNORED;
}


public ZmienUbranie(id,reset)

{

	if (!is_user_connected(id))

		return PLUGIN_CONTINUE;

	

	if (reset)

		cs_reset_user_model(id);

	else

	{

		new num = random_num(0,3);

		cs_set_user_model(id, (get_user_team(id) == 1)? CT_Skins[num]: Terro_Skins[num]);

	}

	

	return PLUGIN_CONTINUE;

}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2057\\ f0\\ fs16 \n\\ par }
*/
