#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <codmod>

new bool:ma_perk[33];

public plugin_init()
{
	register_plugin("AWP Protection", "1.0", "asiap");

	cod_register_perk("AWP Protection", "You are immune to shots of AWP");
	RegisterHam(Ham_TraceAttack, "player", "TraceAttack");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
}

public TraceAttack(id, attacker, Float:fDamage)
{
	if(!is_user_alive(id) || !is_user_connected(attacker) || !ma_perk[id] || GetUserWeapon(attacker) != CSW_AWP)
	{
		return HAM_IGNORED;
	}

	SetHamParamFloat(3, 0.0);
	return HAM_SUPERCEDE;
}

stock GetUserWeapon(id, &iWid = 0)
{
	return pev_valid((iWid = get_pdata_cbase(id, 373))) == 2 ? get_pdata_int(iWid, 43, 4) : 0;
}