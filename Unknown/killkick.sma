// SweatyBanana
// KillKick.sma
// April 30 2006

#include <amxmodx>

public plugin_init() 
{ 
	register_plugin("KillKick", "1.0", "SweatyBanana") 
	register_event("ResetHUD", "roundStarted", "b") 
	register_cvar("sv_killamount","1") 
}

public roundStarted(id) 
{ 
     
	new Frags = get_user_frags(id) 
	new kills = get_cvar_num("sv_killamount")
    
	if( Frags >= kills ) 
	{
		new Authid[35]
		new name[32];
		get_user_name(id, name, 31);
		get_user_authid(id,Authid,34)
		
		server_cmd("kick #%d kicked becuse of more than %i kills",get_user_userid(id),kills)
		server_cmd("kick %s",Authid)
		
		client_print(0, print_chat, "[AMXX] Kicked %s for having more than %i kills",name,kills)
	}
	
	if( Frags =< kills )
	{
		client_print( 0, print_chat, "[KICKER] Any player with more than %i kills will be kicked.",kills)

	}
	return PLUGIN_HANDLED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
