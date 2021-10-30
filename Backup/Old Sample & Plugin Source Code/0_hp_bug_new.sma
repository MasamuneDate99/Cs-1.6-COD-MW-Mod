#include <amxmodx>

public plugin_init()
{
	register_plugin("Zero (0) HP Bug Fix", "0.4", "Exolent");
	register_message(get_user_msgid("Health"), "message_Health");
}

public message_Health(msgid, dest, id)
{
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;
	
	static hp;
	hp = get_msg_arg_int(1);
	
	if(hp > 255 && (hp % 256) == 0)
		set_msg_arg_int(1, ARG_BYTE, ++hp);
	
	return PLUGIN_CONTINUE;
}