/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <fakemeta>
#include <cstrike>
#include <codmod>

new const nazwa[] = "Secret Asassin";
new const opis[] = "Instant reload and see the invisible";

new bool:ma_perk[33];

new const max_clip[31] = { -1, 13, -1, 10,  1,  7,  1,  30, 30,  1,  30,  20,  25, 30, 35, 25,  12,  20, 
10,  30, 100,  8, 30,  30, 20,  2,  7, 30, 30, -1,  50 };

public plugin_init()
{
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	
	cod_register_perk(nazwa, opis);
	
	register_forward(FM_CmdStart, "CmdStart");
	
	register_forward(FM_AddToFullPack, "FwdAddToFullPack", 1)
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	return COD_CONTINUE;
}
	
public cod_perk_disabled(id)
	ma_perk[id] = false;

public CmdStart(id, uc_handle)
{
	if(!is_user_alive(id) || !ma_perk[id])
		return FMRES_IGNORED;
	
	new buttons = get_uc(uc_handle, UC_Buttons);
	new oldbuttons = pev(id, pev_oldbuttons);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if(max_clip[weapon] == -1 || !ammo)
		return FMRES_IGNORED;
	
	if((buttons & IN_RELOAD && !(oldbuttons & IN_RELOAD) && !(buttons & IN_ATTACK)) || !clip)
	{
		cs_set_user_bpammo(id, weapon, ammo-(max_clip[weapon]-clip));
		new new_ammo = (max_clip[weapon] > ammo)? clip+ammo: max_clip[weapon]
		set_user_clip(id, new_ammo);
	}
	
	return FMRES_IGNORED;
}

stock set_user_clip(id, ammo)
{
	new weaponname[32], weaponid = -1, weapon = get_user_weapon(id, _, _);
	get_weaponname(weapon, weaponname, 31);
	while ((weaponid = engfunc(EngFunc_FindEntityByString, weaponid, "classname", weaponname)) != 0)
		if (pev(weaponid, pev_owner) == id) {
		set_pdata_int(weaponid, 51, ammo, 4);
		return weaponid;
	}
	return 0;
}

public FwdAddToFullPack(es_handle, e, ent, host, hostflags, player, pSet)
{
	if(!is_user_connected(host) || !is_user_connected(ent))
		return;
		
	if(!ma_perk[host])
		return;
		
	set_es(es_handle, ES_RenderAmt, 255.0);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
