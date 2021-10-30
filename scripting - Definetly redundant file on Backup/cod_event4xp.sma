#include <amxmodx>
#include <amxmisc>

#define PLUGIN "[COD] Exp Event"
#define VERSION "1.0"
#define AUTHOR "RPK. Shark"

/* Optymalizacja kodu by DarkGL */

#define TASK_ID 666

new iTime, pCvarEvent;
new cvar_eventxp, cvar_eventoff;

public plugin_init() {
	register_plugin("Exp Event 4xp", "0.1", "RPK. Shark")
	
	register_clcmd("say /eventwow", "Start");
	
	pCvarEvent = register_cvar("cod_eventczas", "1000");
	cvar_eventoff = register_cvar("cod_eventoff", "1000");
	cvar_eventxp = register_cvar("cod_eventxp", "4000");
}

public Start(id)
{
	if(!(get_user_flags(id) & ADMIN_IMMUNITY) || task_exists( TASK_ID ) )
		return PLUGIN_HANDLED;
	
	server_cmd("cod_killxp %i", get_pcvar_num(cvar_eventxp))
	server_exec();
	
	client_print(0, print_center, "Start EVENT EXP for Kill!");
	
	iTime = get_pcvar_num( pCvarEvent );
	
	remove_task( TASK_ID )
	
	set_task( 1.0, "Koniec", TASK_ID, .flags = "b" )
	
	return PLUGIN_HANDLED
}

public Koniec()
{
	if( iTime <= 0 )
	{
		remove_task( TASK_ID )
		
		server_cmd("cod_killxp %i", get_pcvar_num(cvar_eventoff))
		server_exec();
		
		client_print(0, print_center, "End EVENT EXP for Kill!");
		
		return PLUGIN_CONTINUE;
	}
	set_hudmessage(255, 255, 0, -1.0, 0.01, 0, 2.0, 1.1)
	show_hudmessage( 0, "^n^n^n[End Event for %d second!]|[4x more exp for Kill]", iTime )
	
	iTime --;
	
	return PLUGIN_CONTINUE;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
