#include <amxmodx>
#include <engine> 

#define VERSION "0.0.1"

public plugin_init() {
    register_plugin("Kick Suiciders", VERSION, "ConnorMcLeod")
} 

public client_kill(id) {
    if( is_user_alive(id) )
    {
        emessage_begin(MSG_ONE, SVC_DISCONNECT, _, id)
        ewrite_string("kill command not allowed here, don't use it!")
        emessage_end()
        return PLUGIN_HANDLED
    } 
    return PLUGIN_CONTINUE
}  
