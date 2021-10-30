/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <codmod>
#include <engine>

new const perk_name[] = "Camouflage Suit";
new const perk_desc[] = "Your visibility drops to LW";

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "Pas");
	
	cod_register_perk(perk_name, perk_desc, 25, 150);
}

public cod_perk_enabled(id, wartosc)
{
	set_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, wartosc);
}
	
public cod_perk_disabled(id)
	set_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, 255);
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
