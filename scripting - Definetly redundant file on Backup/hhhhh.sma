#include <amxmodx>

public plugin_init()
    register_plugin( "aa", "1.0", "aa" );

public client_putinserver( id ) {
    new szAuthid[32];
    get_user_authid( id, szAuthid, 31 );
    
    if( equal(szAuthid, "HLTV"))
        server_cmd("kick #%d ^"Hltv Not Allowed",get_user_userid(id));
}