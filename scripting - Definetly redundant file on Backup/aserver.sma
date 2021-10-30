/*
*      < Coded by grd aka  quark >
*
*  Description 
* This plugin will insert into a MYSQL Database server information as
* hostname, map and players for now.
* 
*
*  Contacts
* Steam: grdPTFMAPS
* Mail: josetxrodrigues@gmail.com
* Website: www.joserodrigues.tk
* 
*
*  Changelog
* 0.1 - First release.
* 0.2 - Fixed bug when change map.
*
*  Original Thread
* https://forums.alliedmods.net/showthread.php?p=2025512
*
*/

/* Includes */
#include <amxmodx>
#include <sqlx>
/* --------- */


/* Uncomment the following line to ignore HLTV / BOTS, */
/*	When counting the players.           */
//#define IGNORE
/*  -----------------------------   */

/* Table Configuration  */
new const QSINFO_TABLE[] = "serverinfo";
/*  -----------------------------   */

/*  Connection Handle/Variables         */
new Handle:qSi_SqlTuple;
/*  -----------------------------   */

/* Variables        */
new g_pcvarHost;
new g_pcvaruUser;
new g_pcvarPass;
new g_pcvarDB;
new g_pcvarSid;

new szMapName[ 32 ];
new szHostName[ 64 ];
new g_iPlayers;
/*  -----------------------------   */

public plugin_init() 
{
	register_plugin("qServerinfo", "0.2", "quark");
	
	/*     Register Cvars       */
	g_pcvarHost = register_cvar( "qSi_host", "localhost", FCVAR_PROTECTED );
	g_pcvaruUser = register_cvar( "qSi_user", "rajagame", FCVAR_PROTECTED );
	g_pcvarPass = register_cvar( "qSi_pass", "43szPtUMuyUuXxY8", FCVAR_PROTECTED );
	g_pcvarDB = register_cvar( "qSi_db", "serverinfo", FCVAR_PROTECTED );
	g_pcvarSid = register_cvar("qSi_sid", "2", FCVAR_PROTECTED);
	/*  ----------------------------------------------------------------------------------  */
	
	g_iPlayers=0;
	
	SqlInit();
}

public SqlInit()
{
	/*     SQL Connection      */
	new szHost[ 32 ];
	new szUser[ 32 ];
	new szPass[ 32 ];
	new szDB[ 32 ];
	
	get_pcvar_string( g_pcvarHost, szHost, charsmax( szHost ) );
	get_pcvar_string( g_pcvaruUser, szUser, charsmax( szUser ) );
	get_pcvar_string( g_pcvarPass, szPass, charsmax( szPass ) );
	get_pcvar_string( g_pcvarDB, szDB, charsmax( szDB ) );
	
	qSi_SqlTuple = SQL_MakeDbTuple( szHost, szUser, szPass, szDB );
	
	new g_Error[ 512 ];
	new ErrorCode;
	new Handle:SqlConnection = SQL_Connect( qSi_SqlTuple, ErrorCode, g_Error, charsmax( g_Error ) );
	/*  ----------------------------------------------------------------------------------  */
	
	if( SqlConnection == Empty_Handle )
		set_fail_state( g_Error );
	
	/*    Create the SQL Table      */
	new Handle:Queries;
	Queries = SQL_PrepareQuery( SqlConnection,
	"CREATE TABLE IF NOT EXISTS %s \
	( id INT( 2 ) PRIMARY KEY,\
	hostname VARCHAR( 64 ),\
	map VARCHAR( 32 ),\
	players INT( 11 ) )",
	QSINFO_TABLE );
	/*  -----------------------------   */
	
	if( !SQL_Execute( Queries ) )
	{
		SQL_QueryError( Queries, g_Error, charsmax( g_Error ) );
		set_fail_state( g_Error );
	}
	
	/*  Some delay so hostname won't be "Half Life" */
	set_task(5.0, "CheckqSi");
	/* ----------------------------------------- */
	
	
	SQL_FreeHandle( Queries );	
	SQL_FreeHandle( SqlConnection );
}

public CheckqSi()
{
	/*  I only use this so when the results come, i can create     */
	/*  the row for the specific server ID    */
	/*  It will check if the server ID already exists in the database */
	new szTemp[ 512 ];
	format( szTemp, charsmax( szTemp ),
	"SELECT `hostname`, `map` FROM %s WHERE `id`='%d'",
	QSINFO_TABLE, get_pcvar_num(g_pcvarSid) );
	
	SQL_ThreadQuery( qSi_SqlTuple, "LoadqSi_Results", szTemp );
	/* ------------------------------------------------------------ */
}

public LoadqSi_Results( FailState, Handle:Query, Error[ ], Errcode )
{
	if( SQL_IsFail( FailState, Errcode, Error ) )
		return;
		
	/*          Create row for the server ID if not found         */
	if( SQL_NumResults( Query ) < 1 ) 
	{
		get_mapname( szMapName, charsmax( szMapName ) );
		get_cvar_string( "hostname", szHostName, charsmax( szHostName ) );
		
		new szTemp[ 512 ]
		format( szTemp, charsmax( szTemp ),
		"INSERT INTO %s ( id, hostname, map, players )\
		VALUES( '%d', '%s', '%s', '0' )",
		QSINFO_TABLE, get_pcvar_num(g_pcvarSid), szHostName, szMapName);
		
		SQL_ThreadQuery( qSi_SqlTuple, "IgnoreHandle", szTemp );
	}
	/* ----------------------------------------- */
	
	/* If the server ID already has an row, it will update the info */
	else 
		set_task(5.0, "UpdateqSi");
	/* ----------------------------------------- */
		
}

public UpdateqSi()
{
	/* Update Server Information */
	get_mapname( szMapName, charsmax( szMapName ) );
	get_cvar_string( "hostname", szHostName, charsmax( szHostName ) );
	
	new szTemp[ 512 ];
	formatex( szTemp, charsmax( szTemp ),
	"UPDATE `%s` SET `hostname`='%s', `map`='%s' WHERE `id`='%d'",
	QSINFO_TABLE, szHostName, szMapName, get_pcvar_num(g_pcvarSid) );
	
	SQL_ThreadQuery( qSi_SqlTuple, "IgnoreHandle", szTemp );
	/* ----------------------------------------- */
}

public client_connect(player)
{
	/* Check if IGNORE is defined, and ignore BOT / HLTV if true */
	#if defined IGNORE
	if(is_user_bot(player) || is_user_hltv(player))
		return;
	#endif
	/* ----------------------------------------------- */
	
	/* When user connect it will count 1 more in variable, */
	/*          and update the players in the Table        */
	g_iPlayers++;
	UpdateqSiPlayers();
	/* ----------------------- */
}

public client_disconnect(player)
{
	/* Check if IGNORE is defined, and ignore BOT / HLTV if true */
	#if defined IGNORE
	if(is_user_bot(player) || is_user_hltv(player))
		return;
	#endif
	/* ----------------------------------------------- */
	
	/* When user connect it will count 1 less in variable, */
	/*          and update the players in the Table        */
	g_iPlayers--;
	UpdateqSiPlayers();
	/* ----------------------- */
}


public UpdateqSiPlayers()
{
	/* Update the Players num */
	new szTemp[ 512 ];
	formatex( szTemp, charsmax( szTemp ),
	"UPDATE `%s` SET `players`='%d' WHERE `id`='%d'",
	QSINFO_TABLE, g_iPlayers, get_pcvar_num(g_pcvarSid) );
	
	SQL_ThreadQuery( qSi_SqlTuple, "IgnoreHandle", szTemp );
	/* -------------------------------- */
}

public IgnoreHandle( FailState, Handle:Query, Error[ ], Errcode, Data[ ], DataSize )
{
	if(FailState)
	{
		log_amx(Error);
	}
	
	SQL_FreeHandle( Query );
}

stock SQL_IsFail( FailState, Errcode, Error[ ] )
{
	if( FailState == TQUERY_CONNECT_FAILED )
	{
		log_amx( "[Rajagame] Could not connect to SQL database: %s", Error );
		return true;
	}
	
	if( FailState == TQUERY_QUERY_FAILED )
	{
		log_amx( "[Rajagame] Query failed: %s", Error );
		return true;
	}
	
	if( Errcode )
	{
		log_amx( "[Rajagame] Error on query: %s", Error );
		return true;
	}
	
	return false;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
