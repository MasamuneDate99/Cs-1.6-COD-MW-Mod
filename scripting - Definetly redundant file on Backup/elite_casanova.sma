#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
#include <fakemeta>

new const nazwa[]   = "Casanova";
new const opis[]    = "It has a 1/20 chance to drop weapons opponent and built-in hard baniak.In addition, 1/6 to deal x2 damage";
new const bronie    = (1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_M4A1);
new const zdrowie   = 50;
new const kondycja  = 25;
new const inteligencja = 0;
new const wytrzymalosc = 25;

new identyfikator[33];
new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "Alelluja");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_TakeDamage, "player", "DMG", 0)
	register_forward(FM_TraceLine, "TwardyBaniak");
	register_event("Damage", "Wyrzucenie", "b", "2!=0");
}

public cod_class_enabled(id)
{
	get_user_name(id, identyfikator, 32);
	if(!equal(identyfikator, "kira") && !equal(identyfikator, "shu."))
	{
		client_print(id, print_chat, "[ELITE] Do not have permission to use this class.")
		return COD_STOP;
	}
	ma_klase[id] = true;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
}

public DMG(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_alive(this) || !is_user_alive(idattacker) || get_user_team(this) == get_user_team(idattacker))
		return HAM_IGNORED;
	
	if(!random(6) && ma_klase[this])
	{ 
		SetHamParamFloat(6, damage*2)
		return HAM_HANDLED;
	}
	
	return HAM_IGNORED;
}

public TwardyBaniak(Float:start[3], Float:end[3], conditions, id, trace)
{ 
	
	if(get_tr2(trace, TR_iHitgroup) != HIT_HEAD)
		return FMRES_IGNORED;
	
	new iHit = get_tr2(trace, TR_pHit);
	
	if(!is_user_connected(iHit))
		return FMRES_IGNORED;
	
	if(!ma_klase[iHit])
		return FMRES_IGNORED;
	
	set_tr2(trace, TR_iHitgroup, 8);
	
	return FMRES_IGNORED;
	
}

public Wyrzucenie(id)
{
	new idattacker = get_user_attacker(id);

	if(!is_user_alive(idattacker))
		return;

	if(!ma_klase[idattacker])
		return;

	if(random_num(1, 20) != 1)
		return;

	client_cmd(id, "drop");
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
