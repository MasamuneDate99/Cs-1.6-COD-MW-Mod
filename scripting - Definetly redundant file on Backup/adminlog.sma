#include < amxmodx >
#include < sqlx >

new sqlConfig[ ][ ] = {
	"127.0.0.1",
	"rajagame",
	"43szPtUMuyUuXxY8",
	"dataadmin"
}

enum playerData {
	SteamID[ 33 ],
	IP[ 16 ],
	Nick[ 64 ],
	Time
};

new Handle: gSqlTuple;

new gPlayer[ 33 ][ playerData ];

public SqlInit( ) {
	gSqlTuple = SQL_MakeDbTuple( sqlConfig[ 0 ], sqlConfig[ 1 ], sqlConfig[ 2 ], sqlConfig[ 3 ] );
	
	if( gSqlTuple == Empty_Handle )
		set_fail_state( "Nie mozna utworzyc uchwytu do polaczenia" );
	
	new iErr, szError[ 32 ];
	new Handle:link = SQL_Connect( gSqlTuple, iErr, szError, 31 );
	
	if( link == Empty_Handle ) {
		log_amx( "Error (%d): %s", iErr, szError );
		set_fail_state( "Brak polaczenia z baza danych" );
	}
	
	new Handle: query;
	query = SQL_PrepareQuery( link, "CREATE TABLE IF NOT EXISTS `players_time` (\
		`id` int(11) NOT NULL AUTO_INCREMENT,\
		`steamid` varchar(33) NOT NULL,\
		`nick` varchar(64) NOT NULL,\
		`ip` varchar(16) NOT NULL,\
		`first` int(16) NOT NULL,\
		`last` int(16) NOT NULL,\
		`time` int(16) NOT NULL,\
		`type` int(1) NOT NULL,\
		PRIMARY KEY (`id`),\
		UNIQUE KEY `authid` (`nick`)\
	)" );
	
	SQL_Execute( query );
	SQL_FreeHandle( query );
	SQL_FreeHandle( link );
}

public Query( failstate, Handle:query, error[ ] ) {
	if( failstate != TQUERY_SUCCESS ) {
		log_amx( "SQL query error: %s", error );
		return;
	}
}

public plugin_init() {
	register_plugin( "Czas Online", "2.1.0", "byCZEK" );
	
	set_task( 0.1, "SqlInit" );
}

public client_connect( id ) {
	gPlayer[ id ][ Time ] = 0;
	
	get_user_authid( id, gPlayer[ id ][ SteamID ], 32 );
	get_user_ip( id, gPlayer[ id ][ IP ], 15, 1 );
	get_user_name( id, gPlayer[ id ][ Nick ], 63 );
	
	SQL_PrepareString( gPlayer[ id ][ Nick ], gPlayer[ id ][ Nick ], 63 );
}

public client_disconnect( id ) {
	if(is_user_hltv(id) || is_user_bot(id))
		return PLUGIN_HANDLED;
		
	gPlayer[ id ][ Time ] = get_user_time( id, 1 );
	
	saveTime( id );
	
	gPlayer[ id ][ Time ] = 0;
	
	return PLUGIN_CONTINUE;
}

stock SQL_PrepareString( const szQuery[], szOutPut[], size ) {
	copy( szOutPut, size, szQuery );
	replace_all( szOutPut, size, "'", "\'" );
	replace_all( szOutPut, size, "`", "\`" );    
	replace_all( szOutPut, size, "\\", "\\\\" );
	replace_all( szOutPut, size, "^0", "\0");
	replace_all( szOutPut, size, "^n", "\n");
	replace_all( szOutPut, size, "^r", "\r");
	replace_all( szOutPut, size, "^x1a", "\Z");	
}

stock saveTime( id ) {
	if ( get_user_flags( id ) & ADMIN_BAN )
	{
	new     query[ 1024 ],
	flags = get_user_flags( id );
	
	formatex( query, charsmax( query ), "INSERT IGNORE INTO `players_time` ( `steamid`, `nick`, `ip`, `first`, `last`, `time`, `type` ) VALUES ( '%s', '%s', '%s', UNIX_TIMESTAMP(NOW()), UNIX_TIMESTAMP(NOW()), %d, %d ) ON DUPLICATE KEY UPDATE `time` = `time` + %d, `last` = UNIX_TIMESTAMP(NOW())",
	gPlayer[ id ][ SteamID ], gPlayer[ id ][ Nick ], gPlayer[ id ][ IP ], gPlayer[ id ][ Time ], ( ( flags > 1 && !( flags & ADMIN_BAN ) ) ? 1 : 0 ), gPlayer[ id ][ Time ]);
	
	if( gSqlTuple )
		SQL_ThreadQuery (gSqlTuple, "Query", query );
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
