/* * * * * * * * * * * * * * *  
* Amx Mod X Script
*	Command Logging.
*                              
* Plugin is used to Log all admin commands.
* 
*******************************************
* Created by: $uicid3 V1.4
*
* V1.0 - First creation. 
* V1.1 - Added DB support.(never released)
* V1.2 - Added clcmd support. 
*	- Made SQL more advanced
*	- Added example php files.
*	- Added blockcmdlist.ini
*	- Added Time to logs
* V1.3 - Change code for less db calls.
*	- Changed blockcmdlist.ini to log_cmdlist.ini
*	- Added cvar: amx_cmd_list.
*	- Cleaned up code again. Changed so plugin makes less db calls.
*	- No longer Logs commands twice.
* V1.4 - Fixed Bug in File Log with Steam ID.
*
* This file is provided as is (no warranties).             
* 
* This file is free software you can redistribute this as
* you please.
*
********************************************
* Credits:
*    Idea/Concept : Everyone on the Forums who has asked for this.
*
******************************************
* Cvar: amx_cmd_list
* Sets how to use the log_cmdlist.ini file
* 0 - Dont use file. (Log all cmds)
* 1 - Use as a Block list. (Dont use commands listed in file)
* 2 - Use as an Allow list. (Only use commands listed in file)
*
* Default is 1
******** If Not using DataBases ******
* Everything gets logged into folder amxmodx/logs/Cmds/
*
* Logged according to cvar: amx_cmd_log_file
* 0 - One big file
* 1 - By Admin Name
* 2 - By Admin AuthID
* 3 - By Date
* 4 - By Map
*
* Default is 2
********************************************
* In File Logging according to cvar: amx_cmd_logging
* Cvar Value - Example Line:
* ---------------------------
* 0 - ADMIN [Time of Day] 'Name here' used 'cmd_here all "args here"'
* 1 - ADMIN [Time of Day] 'Name here'<STEAM_ID_HERE> used 'cmd_here all "args here"'
* 2 - ADMIN [Time of Day] 'Name here' used Cmd 'cmd_here' with args 'all "args here"'
* 3 - ADMIN [Time of Day] 'Name here'<STEAM_ID_HERE> used Cmd 'cmd_here' with args 'all "args here"'
*
* Default is 3
***** If using DataBases ********
* Just load plugin and change map. Everything will be done for you.
*
* Sql variables read out of amxmodx/configs/sql.cfg
*
* If any errors occur while using SQL it stops logging so you dont get the error for every command used. ;p
********************************************/

//Uncomment to use SQL
#define SQL_MODE

#include <amxmodx>
#include <amxmisc>
#if defined SQL_MODE
#include <dbi>
#endif

#define VERSION "1.4"

#define MAX_CMDS 255

new g_szCmds[MAX_CMDS][36]
new g_iCmds = 0
new g_szListed[MAX_CMDS][36]
new g_iListCount = 0

#if defined SQL_MODE
new g_sqlHost[66]
new g_sqlUser[36]
new g_sqlPass[46]
new g_sqlDb[26]
new g_sqlTable[16] = "cmd_log"

new Sql:sql
new Result:result
new bool:g_boolsqlOK = false
#endif

public plugin_init()
{
	register_plugin("Command Logging",VERSION,"$uicid3")
	register_cvar("amx_cmd_list","0")
	#if !defined SQL_MODE
	register_cvar("amx_cmd_log_file","1")
	register_cvar("amx_cmd_logging","0")
	#else
	set_task(0.4,"SetSQL")
	#endif
	set_task(0.1,"GetCmds")
	set_task(0.6,"GetList")
	register_cvar("amx_sql_dbcvar","adminlogging")
}

#if defined SQL_MODE
public SetSQL()
{
	get_cvar_string("amx_sql_host",g_sqlHost,65)
	get_cvar_string("amx_sql_user",g_sqlUser,35)
	get_cvar_string("amx_sql_pass",g_sqlPass,45)
	get_cvar_string("amx_sql_dbcvar",g_sqlDb,25)

	new szError[36]
	sql = dbi_connect(g_sqlHost,g_sqlUser,g_sqlPass,g_sqlDb,szError,35)

	if (sql <= SQL_FAILED) 
	{
		log_amx("[Command Log] Couldn't connect to Database^nUsing Host:%s , User %s , db %s",g_sqlHost,g_sqlUser,g_sqlPass,g_sqlDb)
		g_boolsqlOK = false
		dbi_close(sql)
		return
	}

	dbi_query(sql,"CREATE TABLE IF NOT EXISTS `%s` ( `name` VARCHAR( 36 ), `auth` VARCHAR( 32 ) NOT NULL, `command` VARCHAR( 32 ) NOT NULL, `args` VARCHAR( 101 ) DEFAULT 'none' NOT NULL, `date` VARCHAR( 32 ) NOT NULL, `time` VARCHAR( 32 ) NOT NULL,`map` VARCHAR( 36 ) NOT NULL ) COMMENT = 'Command Log Table'",g_sqlTable)

	g_boolsqlOK = true
	return
}
#endif

public GetCmds()
{
	new flags
	for(new x = 0;x < 21;x++)
		flags |= (1<<x)
	flags |= (1<<24)

	new szInfo[46],Temp
	new i , iEnd

	g_iCmds = 0

	iEnd = get_concmdsnum(flags,-1)
	if(iEnd > MAX_CMDS)
		iEnd = MAX_CMDS

	for(i = 0;i < iEnd; i++)
		get_concmd(i,g_szCmds[g_iCmds++],35,Temp,szInfo,45,flags,1)

	new iStart = g_iCmds
	iEnd = get_clcmdsnum(flags)

	for(new x = iStart;x < iEnd; x++)
		get_clcmd(x,g_szCmds[g_iCmds++],35,Temp,szInfo,45,flags)

	return
}
public GetList()
{
	new szFileName[65] , szConf[55]
	get_configsdir(szConf,54)
	format(szFileName,64,"%s/log_cmdlist.ini",szConf)
	szConf[0] = 0

	g_iListCount = 0

	if(!file_exists(szFileName))
		return

	new k = 0 , pos = 0 , szLine[36]
	while( read_file( szFileName, pos++, szLine, 35, k ))
	{
		if( szLine[0] == ';' || !k ) continue

		copy(g_szListed[g_iListCount],75,szLine)
		g_iListCount++
	}
	return
}
public client_command( id )
{
	if( !is_user_admin(id) )
		return PLUGIN_CONTINUE

	new szCmd[36],szArgs[101]
	read_argv(0,szCmd,35)
	read_args(szArgs,100)

	remove_quotes(szArgs)

	switch(get_cvar_num("amx_cmd_list"))
	{
		case 0:
		{
			if(!IsCmd(szCmd))
				return PLUGIN_CONTINUE
		}
		case 1:
		{
			if( ( IsCmd(szCmd) && InList(szCmd) ) || !IsCmd(szCmd) )
				return PLUGIN_CONTINUE
		}
		case 2:
		{
			if( ( IsCmd(szCmd) && !( InList(szCmd)) ) || !IsCmd(szCmd) )
				return PLUGIN_CONTINUE
		}
		default:
		{
			if( ( IsCmd(szCmd) && InList(szCmd) ) || !IsCmd(szCmd) )
				return PLUGIN_CONTINUE
		}
	}

	#if defined SQL_MODE
	LogSQL(id,szCmd,szArgs)
	#else
	LogCmd(id,szCmd,szArgs)
	#endif

	return PLUGIN_CONTINUE
}

stock bool:IsCmd( szCmd[36] )
{
	for(new i = 0; i < g_iCmds; i++)
	{
		if( equali(szCmd,g_szCmds[i]) )
			return true
	}
	return false
}

stock bool:InList( szCmd[36] )
{
	for(new i = 0; i < g_iListCount; i++)
	{
		if( equali(szCmd,g_szListed[i]) )
			return true
	}
	return false
}

#if defined SQL_MODE
public LogSQL(AdminID , szCmd[36] , szArgs[101])
{
	if(!g_boolsqlOK)
		return PLUGIN_CONTINUE
	new szAdminName[36], szAdminAuth[32],szDate[26],szMap[36],szTime[16]
	get_user_name(AdminID,szAdminName,35)
	remove_quotes(szAdminName)
	while(replace(szAdminName,35,"'","")) { }
	get_user_authid(AdminID,szAdminAuth,31)
	get_time("%m-%d-%Y",szDate,25)
	get_time("%H:%M:%S",szTime,15)
	get_mapname(szMap,35)

	if(szArgs[0] == 0)
		format(szArgs,100,"<i>None</i>")
	new szError[126]
	result = dbi_query(sql,"INSERT INTO `%s` (`name`,`auth`,`command`,`args`,`date`,`time`,`map`) VALUES ('%s','%s','%s','%s','%s','%s','%s');",g_sqlTable,szAdminName,szAdminAuth,szCmd,szArgs,szDate,szTime,szMap)

	if(result == RESULT_FAILED)
	{
		dbi_error(sql,szError,125)
		server_print("[Command Log] Couldn't insert new row.^nError:^n^"%s^"^n",szError)
		server_print("[Command Log] Stopping continuation of Command Logging.")
		dbi_free_result(result)
		dbi_close(sql)
		g_boolsqlOK = false
	}
	dbi_free_result(result)
	return PLUGIN_CONTINUE
} 
#else
public LogCmd(AdminID , szCmd[36] , szArgs[101])
{
	new szAdminName[36],szAdminAuth[32],szDate[26],szMap[36],szTime[26]
	new szLogMessage[256],szLogAuth[32]

	get_user_name(AdminID,szAdminName,35)
	get_user_authid(AdminID,szAdminAuth,31)
	get_mapname(szMap,35)
	get_time("%m-%d-%Y",szDate,25)
	get_time("%m-%d-%Y %H:%M:%S",szTime,25)
	copy(szLogAuth,31,szAdminAuth)
	while(replace(szLogAuth,31, ":" , "_" )) { }

	new szFileName[101],szBaseDir[76]
	get_basedir(szBaseDir,75)
	new len = format(szFileName,100,"%s/logs/Cmds/",szBaseDir)
	switch(get_cvar_num("amx_cmd_log_file"))
	{
		case 0: format(szFileName[len],100-len,"log.log")
		case 1: format(szFileName[len],100-len,"%s.log",szAdminName)
		case 2: format(szFileName[len],100-len,"%s.log",szLogAuth)
		case 3: format(szFileName[len],100-len,"%s.log",szDate)
		case 4: format(szFileName[len],100-len,"%s.log",szMap)
		default: format(szFileName[len],100-len,"%s.log",szLogAuth)
	}
	switch(get_cvar_num("amx_cmd_logging"))
	{
		case 0: format(szLogMessage,255,"ADMIN [%s] '%s' used '%s %s'",szTime,szAdminName,szCmd,szArgs)
		case 1: format(szLogMessage,255,"ADMIN [%s] '%s'<%s> used '%s %s'",szTime,szAdminName,szAdminAuth,szCmd,szArgs)
		case 2: format(szLogMessage,255,"ADMIN [%s] '%s' used Command '%s' with Args '%s'",szTime,szAdminName,szCmd,szArgs)
		case 3: format(szLogMessage,255,"ADMIN [%s] '%s'<%s> used Command '%s' with Args '%s'",szTime,szAdminName,szAdminAuth,szCmd,szArgs)
		default: format(szLogMessage,255,"ADMIN [%s] '%s'<%s> used Command '%s' with Args '%s'",szTime,szAdminName,szAdminAuth,szCmd,szArgs)
	}
	if(!file_exists(szFileName))
	{
		new szHeader[75]
		new k = format(szHeader,75,"*File Created By: Command Logger*^n")
		k += format(szHeader[k],75-k,"**A plugin Created by: $uicid3**^n")
		write_file(szFileName,szHeader,0)
			
	}
	write_file(szFileName,szLogMessage,-1)
	return PLUGIN_CONTINUE
}
#endif
