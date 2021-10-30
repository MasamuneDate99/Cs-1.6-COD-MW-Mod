#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
#include <cstrike>
#include <colorchat>
#include <engine>
#include <fakemeta>

new const perk_name[] = "Sword of Heaven";
new const perk_desc[] = "Instant kill enemy with a knife";
    
new bool:ma_perk[33];
new ostatnio_prawym[33];

public plugin_init()
{
	register_plugin(perk_name, "1.0", "MasamuneDate");
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_TakeDamage, "player", "fwTakeDamage_JedenCios");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fwPrimaryAttack_JedenCios");
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fwSecondaryAttack_JedenCios");

}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	ColorChat(id, GREEN, "Created by MasamuneDate", perk_name);
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;

}

public fwTakeDamage_JedenCios(id, ent, attacker)
{
	if(is_user_alive(attacker) && ma_perk[attacker] && get_user_weapon(attacker) == CSW_KNIFE && ostatnio_prawym[id])
	{
		cs_set_user_armor(id, 0, CS_ARMOR_NONE);
		SetHamParamFloat(4, float(get_user_health(id) + 1));
		return HAM_HANDLED;
	}
	return HAM_IGNORED;
}

public fwPrimaryAttack_JedenCios(ent)
{
	new id = pev(ent, pev_owner);
	ostatnio_prawym[id] = 1;
}

public fwSecondaryAttack_JedenCios(ent)
{
	new id = pev(ent, pev_owner);
	ostatnio_prawym[id] = 0;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
