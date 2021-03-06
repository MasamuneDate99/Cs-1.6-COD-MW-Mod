/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <codmod>
#include <fakemeta>

new const perk_name[] = "Reducing scatter of weapons";
new const perk_desc[] = "Reduces the spread of weapons";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "QTM_Peyote");
	
	cod_register_perk(perk_name, perk_desc);
	
	register_forward(FM_CmdStart, "CmdStart");
}

public cod_perk_enabled(id)
	ma_perk[id] = true;
	
public cod_perk_disabled(id)
	ma_perk[id] = false;


public CmdStart(id, uc_handle)
{
	if(ma_perk[id] && get_uc(uc_handle, UC_Buttons) & IN_ATTACK)
	{
		new Float:punchangle[3]
		pev(id, pev_punchangle, punchangle)
		for(new i=0; i<3;i++) 
				punchangle[i]*=0.9;
		set_pev(id, pev_punchangle, punchangle)
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
