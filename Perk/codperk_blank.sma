#include <amxmodx>
#include <codmod>


new const perk_name[] = "Blank";
new const perk_desc[] = "Have 1/LW chance to blinding the enemy";

new g_msg_screenfade;

new bool:ma_perk[33];
new wartosc_perku[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "QTM_Peyote");
	
	cod_register_perk(perk_name, perk_desc, 2, 15);
	
	register_event("Damage", "Damage", "b", "2!=0");	
	
	g_msg_screenfade = get_user_msgid("ScreenFade");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
}

public cod_perk_disabled(id)
ma_perk[id] = false;

public Damage(id)
{
	new idattacker = get_user_attacker(id);
	
	if(!is_user_connected(idattacker) || get_user_team(id) == get_user_team(idattacker))
	return PLUGIN_CONTINUE;
	
	if(ma_perk[idattacker] && random_num(1, wartosc_perku[idattacker]) == 1)
	Display_Fade(id, 1<<14, 1<<14 ,1<<16, 255, 255, 255, 255);
	
	return PLUGIN_CONTINUE;
}

stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha)
{
	message_begin( MSG_ONE, g_msg_screenfade,{0,0,0},id );
	write_short( duration );
	write_short( holdtime );	
	write_short( fadetype );	
	write_byte ( red );		
	write_byte ( green );		
	write_byte ( blue );	
	write_byte ( alpha );	
	message_end();
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
