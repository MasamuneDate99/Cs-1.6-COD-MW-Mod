#include <amxmodx>

new g_cvar;

public plugin_init(){
    register_clcmd("kill","BlockCmd");

    g_cvar = register_cvar("amx_block_kill","2");
}

public BlockCmd(id){
    switch(get_pcvar_num(g_cvar))
    {
        case 0:
        case 1:
        {
            client_print(id,print_center,"[AMXX] Kill command is blocked!");
        }

        case 2: 
        {
            server_cmd("kick #%d ^"Kill command is not allow on this server^"",get_user_userid(id)
        }
    }
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
