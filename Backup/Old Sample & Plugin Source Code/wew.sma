#include <amxmodx>

public plugin_init()
{
	register_plugin("gaying", "1.0", "you")
	
	set_task(10.0, "server_execute" ,_ ,_ ,_ ,"b")
}

public server_execute()
{
		server_cmd("exec server.cfg")
}