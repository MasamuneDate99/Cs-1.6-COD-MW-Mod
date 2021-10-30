#include <amxmodx>

#define PLUGIN "Remove % bug in chat"
#define VERSION "1.1"
#define AUTHOR "Sn!ff3r"

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say","hook")
	register_clcmd("say_team","hook")
}

public hook(id)
{
	new said[3]
	read_args(said,2)
	return said[1] == '%' ? PLUGIN_HANDLED : PLUGIN_CONTINUE
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
