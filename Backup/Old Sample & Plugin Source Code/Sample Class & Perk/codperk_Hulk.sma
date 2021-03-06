/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <codmod>

new const perk_name[] = "Hulk";
new const perk_desc[] = "You get 250 Health";


public plugin_init() 
{
	register_plugin(perk_name, "1.0", "Mentos");
	
	cod_register_perk(perk_name, perk_desc);
}
public cod_perk_enabled(id)
{
	cod_set_user_bonus_health(id, cod_get_user_health(id, 0, 0)+250);
}

public cod_perk_disabled(id)
{
	cod_set_user_bonus_health(id, cod_get_user_health(id, 0, 0)-250);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
