#include <amxmodx>
#include <codmod>
#include <fakemeta>

#define PLUGIN "Celownik Laserowy"
#define VERSION "1.0"
#define AUTHOR "GreM!"

new const perk_name[] = "Magic Weapon";
new const perk_desc[] = "You get a laser sight";
new bool:ma_perk[33];
new bool:g_laser[33] 
new sprite

public plugin_init() 
{
register_plugin(perk_name, "1.0", "QTM_Peyote")
cod_register_perk(perk_name, perk_desc);
register_forward(FM_PlayerPreThink, "FW_playerprethink")
register_event("DeathMsg", "Death", "a")
}

public cod_perk_enabled(id)
{
g_laser[id] = true
ma_perk[id] = true;
}
public cod_perk_disabled(id)
{
g_laser[id] = false
ma_perk[id] = false;
}

public FW_playerprethink(id)
{
	if(g_laser[id] == true)
	{
		new e[3]
		get_user_origin(id, e, 3)
		message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte (TE_BEAMENTPOINT)
		write_short(id | 0x1000)
		write_coord (e[0])			
		write_coord (e[1])			
		write_coord (e[2])			

		write_short(sprite)			
		
		write_byte (1)      						
		write_byte (10)     								
		write_byte (1)				
		write_byte (5)   						
		write_byte (0)    			
		write_byte (255) 			
		write_byte (0)				
		write_byte (0)				
		write_byte (150)     							
		write_byte (25)      				
		message_end()
	}
}

public plugin_precache()
	sprite = precache_model("sprites/white.spr")

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
