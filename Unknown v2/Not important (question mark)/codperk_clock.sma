/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fakemeta_util>
#include <fun>
#include <hamsandwich>

new const perk_name[] = "Clock of Time";
new const perk_desc[] = "Use perk to TURN BACK TIME Once Per Round. Teleport enemy to 2s ago";

new bool:ma_perk[33];
new PobierzUstaw[33];
new Origin[33][3];
new bool:uzyl[33];

public plugin_init()
{
	register_plugin(perk_name, "1.0", "UTeam");
	
	cod_register_perk(perk_name, perk_desc);
	RegisterHam(Ham_Spawn, "player", "Odrodzenie", 1);
}
public client_disconnect(id)
	PobierzUstaw[id] = 0;

public Odrodzenie(id)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	if(ma_perk[id]){	
		PobierzUstaw[id] = 0;
		uzyl[id] = false;
	}
	
	return PLUGIN_CONTINUE;
}
public cod_perk_enabled(id)
	ma_perk[id] = true;

public cod_perk_disabled(id)
	ma_perk[id] = false;

public cod_perk_used(id)
{
	if(!ma_perk[id])
		return PLUGIN_CONTINUE;
		
	if(uzyl[id]){
		client_print(id,print_center,"Ability only useable ONCE per round !");
		return PLUGIN_CONTINUE;
	}
		
	PobierzUstaw[id]++;
	
	if(PobierzUstaw[id] == 1)
		PobierzOrigin(id);
	
	else if(PobierzUstaw[id] == 2)
	{	
		PobierzUstaw[id] = 0;
		UstawOrigin(id);
	}
	
	return PLUGIN_CONTINUE;
}
public PobierzOrigin(id) // origin
{
	for(new i = 1;i<33;i++)
	{
		if(!is_user_alive(i))
			continue;
		
		if(get_user_team(id) == get_user_team(i))
			continue;
		
		get_user_origin(i, Origin[i]);
	}
	client_print(id,print_center,"Creating distruption is SPACE and TIME !");
	
	return PLUGIN_CONTINUE;		
}
public UstawOrigin(id) // origin
{
	for(new i = 1;i<33;i++)
	{
		if(!is_user_alive(i))
			continue;

		if(Origin[i][0] == 0 && Origin[i][1] == 0 && Origin[i][2] == 0)
			continue;
		
		if(get_user_team(id) == get_user_team(i))
			continue;
		
		set_user_origin(i, Origin[i]);
	}
	
	uzyl[id] = true;
	
	return PLUGIN_CONTINUE;	
}	
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1057\\ f0\\ fs16 \n\\ par }
*/
