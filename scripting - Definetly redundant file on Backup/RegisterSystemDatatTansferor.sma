#include <amxmodx>
#include <sqlx>

new g_host, g_user, g_pass, g_db;
new Host[64], User[32], Pass[32], DB[128];
new Handle:g_SQLTuple, Handle:SqlConnection;
new g_error[512], errorcode;
new reg_file[256], text[128], name[32], pass[34], status[11], query[512], counter = 0;

public plugin_init()
{
	register_plugin("Register System Data Transferor", "1.0", "m0skVi4a ;]")

	g_host = get_cvar_pointer("rs_host")
	g_user = get_cvar_pointer("rs_user")
	g_pass = get_cvar_pointer("rs_pass")
	g_db = get_cvar_pointer("rs_db")

	register_srvcmd("file_to_mysql", "FileToMYSQL")
	register_srvcmd("mysql_to_file", "MYSQLToFile")

	new configs_dir[64];

	get_localinfo("amxx_configsdir", configs_dir, charsmax(configs_dir))	
	formatex(reg_file, charsmax(reg_file), "%s/regusers.ini", configs_dir)
}

public MYSQLToFile()
{
	server_print("Connecting to MYSQL...")

	get_pcvar_string(g_host, Host, charsmax(Host))
	get_pcvar_string(g_user, User, charsmax(User))
	get_pcvar_string(g_pass, Pass, charsmax(Pass))
	get_pcvar_string(g_db, DB, charsmax(DB))

	g_SQLTuple = SQL_MakeDbTuple(Host, User, Pass, DB)

	SqlConnection = SQL_Connect(g_SQLTuple, errorcode, g_error, charsmax(g_error))

	if(SqlConnection == Empty_Handle) 
	{
		server_print("MYSQL connection failed!")
		server_print(g_error)
		return PLUGIN_HANDLED
	}
	else
	{
		server_print("MYSQL connection succesful!")
	}

	server_print("Checking Register System file...")

	if(!file_exists(reg_file))
	{
		server_print("Register System file -  %s   not found! Creating new...", reg_file)
		write_file(reg_file,";Register System file^n;Modifying may cause the clients to can not Login!^n^n")
	}
	else
	{
		server_print("Register System file found!")
	}

	server_print("Starting to transfer!")

	formatex(query, charsmax(query), "SELECT * FROM `registersystem`;")
	SQL_ThreadQuery(g_SQLTuple, "QuerySelectData", query)

	return PLUGIN_CONTINUE	
}

public QuerySelectData(FailState, Handle:Query, error[], errorcode, data[], datasize, Float:fQueueTime)
{ 
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		server_print(error)
		return
	}
	else
	{
		new col_name = SQL_FieldNameToNum(Query, "Name")
		new col_pass = SQL_FieldNameToNum(Query, "Password")
		new col_status = SQL_FieldNameToNum(Query, "Status")

		new file_pointer = fopen(reg_file, "a")

		counter = 0

		while(SQL_MoreResults(Query)) 
		{
			SQL_ReadResult(Query, col_name, name, charsmax(name))
			SQL_ReadResult(Query, col_pass, pass, charsmax(pass))
			SQL_ReadResult(Query, col_status, status, charsmax(status))

			if(!equal(status, "LOGGED_IN"))
			{
				status = "LOGGED_OUT"
			}			

			formatex(text, charsmax(text), "^n^"%s^" ^"%s^" ^"%s^"", name, pass, status)
			fprintf(file_pointer, text)
			counter++
			server_print("%d. Transfering  %s  's registration, password hash: %s  Status: %s", counter, name, pass, status)
			SQL_NextRow(Query)
		}
		fclose(file_pointer)
		server_print("Transfer finished!  %d registration were transferred!", counter)
	}
}

public FileToMYSQL()
{
	server_print("Checking Register System file...")

	if(!file_exists(reg_file))
	{
		server_print("Register System file -  %s   not find!", reg_file)
		return PLUGIN_HANDLED
	}
	else
	{
		server_print("Register System file found!")
	}

	server_print("Connecting to MYSQL...")

	get_pcvar_string(g_host, Host, charsmax(Host))
	get_pcvar_string(g_user, User, charsmax(User))
	get_pcvar_string(g_pass, Pass, charsmax(Pass))
	get_pcvar_string(g_db, DB, charsmax(DB))

	g_SQLTuple = SQL_MakeDbTuple(Host, User, Pass, DB)

	SqlConnection = SQL_Connect(g_SQLTuple, errorcode, g_error, charsmax(g_error))

	if(SqlConnection == Empty_Handle) 
	{
		server_print("MYSQL connection failed!")
		server_print(g_error)
		return PLUGIN_HANDLED
	}
	else
	{
		server_print("MYSQL connection succesful!")
	}

	new Handle:Query

	Query = SQL_PrepareQuery(SqlConnection, "CREATE TABLE IF NOT EXISTS registersystem (Name VARCHAR(32), Password VARCHAR(34), Status VARCHAR(11))")

	if(!SQL_Execute(Query)) 
	{
		SQL_QueryError(Query, g_error, charsmax(g_error))
		server_print(g_error)
	}

	SQL_FreeHandle(Query)
	SQL_FreeHandle(SqlConnection)

	server_print("Starting to transfer!")

	new length, line = 0;
	counter = 0

	while(read_file(reg_file, line++ , text, charsmax(text), length))
	{
		if(!text[0] || text[0] == '^n' || text[0] == ';')
			continue

		parse(text, name, charsmax(name), pass, charsmax(pass), status, charsmax(status))

		if(!equal(status, "LOGGED_IN"))
		{
			status = "LOGGED_OUT"
		}

		formatex(query, charsmax(query), "INSERT INTO `registersystem` (`Name`, `Password`, `Status`) VALUES (^"%s^", ^"%s^", ^"%s^");", name, pass, status)
		SQL_ThreadQuery(g_SQLTuple, "QuerySetData", query)
		counter++
		server_print("%d. Transfering  %s  's registration, password hash: %s  Status: %s", counter, name, pass, status)
	}

	server_print("Transfer finished!  %d registration were transferred!", counter)

	return PLUGIN_CONTINUE
}

public QuerySetData(FailState, Handle:Query, error[],errcode, data[], datasize)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		server_print(error)
		return
	}
}