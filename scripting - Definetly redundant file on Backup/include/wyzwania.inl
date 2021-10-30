/*
*            [WYZWANIA by CYPIS]
*	    
*       ^^^   ^^   ^^   ^^ ^^^    ^^    ^^ ^                                                        
*      ^^      ^^ ^^    ^^    ^   ^^   ^                   
*      ^^       ^^      ^^ ^^^    ^^    ^^ ^                                                                        	
*      ^^       ^^      ^^        ^^        ^                                                                         
*       ^^^     ^^      ^^        ^^    ^ ^^   
*
*	GG: 3800672                                                                                                                                               
*/

#if defined USING_SQL
#include <sqlx>
#else
#include <nvault>
#include <amxmisc>
#endif
new SyncHudObj;
#if defined COD_NOWY
native cod_get_user_xp(id);
native cod_set_user_xp(id, wartosc);
#endif

new const nazwy_nagrody[][] = 
{
	"Exposed %^nCall in & UAV", //0
	"Interference %^nCall in & Counter-UAV", //1
	"Air Mail %^nCall in & Care Packages", //2
	"Sentry Veteran %^nCall in & Sentry Guns",  //3
	"Air To Ground %^nCall in & Predator Missiles", //4
	"Airstrike Veteran %^nCall in & Precision Airstrikes", //5
	"Special Delivery %^n Call in & Emergency Airdrops",//6
	
	"Blackout %^nCall in & EMP", //7
	"End Game %^nCall in & Nuke", //8
	
	"Radar Inbound %^nCall in & UAV or Counter-UAV",  //9
	"Airstrike Inbound %^nCall in & Precision or Harrier Airstrike", //10
	"Airdrop Inbound %^nCall in & Care Packages, Sentry Guns or Emergency Airdrop" //11
};

new const za_nagrode[][3] = 
{
	{400, 2000, 3500}, //uav
	{1000, 2500, 3500}, //cuav
	{1000, 2500, 3500}, //care packages
	{600, 3500, 5000}, //sentry 
	{800, 2500, 4000}, //predator 
	{1500, 3000, 4500}, //nalot
	{2000, 4500, 6000}, //emergy airdrop
	
	{2000, 5000, 65000}, //emp
	{2500, 5500, 7000}, //nuke
	
	{2500, 5000, 25000}, //uav or cuav
	{5000, 8000, 30000}, //nalot2
	{8000, 10000, 40000}  //care packages, sentry or emergy airdrop
};
	
new const rzymskie_liczby[][] = {"I", "II", "III"};	
new ile_nagrod[MAX+1][9], nazwa_gracza[MAX+1][35];

#if defined USING_SQL
new Handle:g_sql;
#else
new g_vault;
#endif

public ks_plugin_init() 
{
	register_clcmd("say /wyzwania", "MOTDwyzwania");
	SyncHudObj = CreateHudSyncObj(4);
#if defined USING_SQL
	register_cvar("ks_sql_host", "localhost");
	register_cvar("ks_sql_user", "root");
	register_cvar("ks_sql_pass", "");
	register_cvar("ks_sql_db", "db");
#endif
}

public ks_plugin_precache()
{
	precache_sound("mw/challenge_completed.wav");
}

public plugin_cfg()
{
#if defined USING_SQL
	register_cvar("ks_sql_host", "localhost");
	register_cvar("ks_sql_user", "root");
	register_cvar("ks_sql_pass", "");
	register_cvar("ks_sql_db", "db");

	new host[64], user[64], pass[64], db[64];
	get_cvar_string("ks_sql_host", host, 63);
	get_cvar_string("ks_sql_user", user, 63);
	get_cvar_string("ks_sql_pass", pass, 63);
	get_cvar_string("ks_sql_db", db, 63);
	
	g_sql = SQL_MakeDbTuple(host, user, pass, db);
	if(g_sql == Empty_Handle){
		set_fail_state("Brak polaczenia z baza danych!");
		return;
	}
	new szTemp[1024];
	add(szTemp, 1023, "CREATE TABLE IF NOT EXISTS `cod_ks` (`name` VARCHAR(35) NOT NULL,");
	add(szTemp, 1023, "`0` INT UNSIGNED NOT NULL DEFAULT 0, ");
	add(szTemp, 1023, "`1` INT UNSIGNED NOT NULL DEFAULT 0, ");
	add(szTemp, 1023, "`2` INT UNSIGNED NOT NULL DEFAULT 0, ");
	add(szTemp, 1023, "`3` INT UNSIGNED NOT NULL DEFAULT 0, ");
	add(szTemp, 1023, "`4` INT UNSIGNED NOT NULL DEFAULT 0, ");
	add(szTemp, 1023, "`5` INT UNSIGNED NOT NULL DEFAULT 0, ");
	add(szTemp, 1023, "`6` INT UNSIGNED NOT NULL DEFAULT 0, ");
	add(szTemp, 1023, "`7` INT UNSIGNED NOT NULL DEFAULT 0, ");
	add(szTemp, 1023, "`8` INT UNSIGNED NOT NULL DEFAULT 0, ");
	add(szTemp, 1023, "PRIMARY KEY(name));");
	SQL_ThreadQuery(g_sql, "handleInsert", szTemp);
#else
	g_vault = nvault_open("killstreak");
#endif
}

public plugin_end()
{
#if defined USING_SQL
	SQL_FreeHandle(g_sql);
#else
	nvault_close(g_vault);
#endif
}

public MOTDwyzwania(id)
{
	#define LICZBA(%1,%2,%3,%4) (%1 >= %2? (%1 >= %3? %4: %3): %2)
	#define RZYMSKALICZ(%1,%2,%3) (%1 >= %2? (%1 >= %3? "III": "II"): "I")
	#define KOLOR(%1) ((zmienna[%1] > 0)? "#0099FF": "#CC0033")
	
	new szTemp[1500], iLen = 0, zmienna[3];
	iLen += copy(szTemp[iLen], charsmax(szTemp)-iLen, "<html><style type=^"text/css^">body{font-family:verdana,arial;background:#666666;margin:10px;}img{border:0px none;}.at{font-size:9px;color:red;}.green{font-size:11px;color:#00FF00;}.white{font-size:11px;color:#FFFFFF;}.red{color:#FF0000;}</style><font color=FFFFFF><small><b>Twój przebieg wyzwañ:</b><br/><br/>");
	
	iLen += formatex(szTemp[iLen], charsmax(szTemp)-iLen, "Exposed %s - %i / %i (Call UAV)<br/><br/>", 			RZYMSKALICZ(ile_nagrod[id][0],5,25), min(ile_nagrod[id][0],50), LICZBA(ile_nagrod[id][0],5,25,50));
	iLen += formatex(szTemp[iLen], charsmax(szTemp)-iLen, "Interference %s - %i / %i (Call C-UAV)<br/><br/>", 		RZYMSKALICZ(ile_nagrod[id][1],5,25), min(ile_nagrod[id][1],50), LICZBA(ile_nagrod[id][1],5,25,50));
	iLen += formatex(szTemp[iLen], charsmax(szTemp)-iLen, "Air Mail %s - %i / %i (Call Care Package)<br/><br/>", 		RZYMSKALICZ(ile_nagrod[id][2],5,25), min(ile_nagrod[id][2],50), LICZBA(ile_nagrod[id][2],5,25,50));
	iLen += formatex(szTemp[iLen], charsmax(szTemp)-iLen, "Sentry Veteran %s - %i / %i (Call Sentry Gun)<br/><br/>",	     	RZYMSKALICZ(ile_nagrod[id][3],5,25), min(ile_nagrod[id][3],50), LICZBA(ile_nagrod[id][3],5,25,50));
	iLen += formatex(szTemp[iLen], charsmax(szTemp)-iLen, "Air To Ground %s - %i / %i (Call Predator Missle)<br/><br/>",  	RZYMSKALICZ(ile_nagrod[id][4],5,25), min(ile_nagrod[id][4],50), LICZBA(ile_nagrod[id][4],5,25,50));
	iLen += formatex(szTemp[iLen], charsmax(szTemp)-iLen, "Airstrike Veteran %s - %i / %i (Call Airstrike)<br/><br/>",	RZYMSKALICZ(ile_nagrod[id][5],5,25), min(ile_nagrod[id][5],50), LICZBA(ile_nagrod[id][5],5,25,50));
	iLen += formatex(szTemp[iLen], charsmax(szTemp)-iLen, "Special Delivery %s - %i / %i (Call Emergency Airdrops)<br/><br/>",RZYMSKALICZ(ile_nagrod[id][6],5,25), min(ile_nagrod[id][6],50), LICZBA(ile_nagrod[id][6],5,25,50));
	
	iLen += formatex(szTemp[iLen], charsmax(szTemp)-iLen, "Blackout %s - %i / %i (Call EMP)<br/><br/>",			RZYMSKALICZ(ile_nagrod[id][7],2,5),  min(ile_nagrod[id][7],10), LICZBA(ile_nagrod[id][7],2,5,10));
	iLen += formatex(szTemp[iLen], charsmax(szTemp)-iLen, "End Game %s - %i / %i (Call Nuke)<br/><br/><br/>", 		RZYMSKALICZ(ile_nagrod[id][8],2,5),  min(ile_nagrod[id][8],10), LICZBA(ile_nagrod[id][8],2,5,10));
	
	iLen += copy(szTemp[iLen], charsmax(szTemp)-iLen, "<b>Dalsze wyzwania dostepne po odblokowaniu:</b><br/><br/>");
	
	if(ile_nagrod[id][0] >= 50 && ile_nagrod[id][1] >= 50)
		zmienna[0] = max(ile_nagrod[id][0], ile_nagrod[id][1])-50;
			
	if(ile_nagrod[id][5] >= 50)
		zmienna[1] = ile_nagrod[id][5]-50;
			
	if(ile_nagrod[id][2] >= 50 && ile_nagrod[id][4] >= 50 && ile_nagrod[id][6] >= 50/*25*/)
	{
		new makas = max(max(ile_nagrod[id][2], ile_nagrod[id][4]), ile_nagrod[id][6]);
		zmienna[2] = makas - 50/*(makas == ile_nagrod[id][6]? 25: 50)*/;	
	}
	
	iLen += formatex(szTemp[iLen], charsmax(szTemp)-iLen, "Radar Inbound %s - %i / %i (<font color=%s>UNLOCK Exposed III AND Interference III<font color=FFFFFF>)<br/><br/>", 	RZYMSKALICZ(zmienna[0],50,100), min(zmienna[0],1000), LICZBA(zmienna[0],50,100,1000), KOLOR(0));
	iLen += formatex(szTemp[iLen], charsmax(szTemp)-iLen, "Airstrike Inbound %s - %i / %i (<font color=%s>UNLOCK Airstrike Veteran III<font color=FFFFFF>)<br/><br/>",	 	RZYMSKALICZ(zmienna[1],50,100), min(zmienna[1],1000), LICZBA(zmienna[1],50,100,1000), KOLOR(1));
	iLen += formatex(szTemp[iLen], charsmax(szTemp)-iLen, "Airdrop Inbound %s - %i / %i (<font color=%s>UNLOCK Air Mail III AND Air To Ground III AND Special Delivery III<font color=FFFFFF>)%s",	RZYMSKALICZ(zmienna[2],50,100), min(zmienna[2],1000), LICZBA(zmienna[2],50,100,1000), KOLOR(2), "</small><br/><br/>Wyzwania^x20^x62^x79^x20^x43^x79^x70^x69^x73^x20</html>");
	show_motd(id, szTemp);
}

public ks_client_putinserver(id)
{
	get_user_name(id, nazwa_gracza[id], 34);
	replace_all(nazwa_gracza[id], 34, "'", "\'");
	replace_all(nazwa_gracza[id], 34, "`", "\`");
	
	WczytajDaneStreak(id);
}

stock ks_print_info(id, nazwa[])
{
	new nagroda;
	switch(nazwa[0])
	{
		case 'U': nagroda = 0; //UAV
		case 'C': nagroda = (nazwa[1] == 'o'? 1: 2); //Counter-UAV, Care Package 
		case 'S': nagroda = 3; //Sentry Gun
		case 'P': nagroda = 4; //Predator Missle
		case 'A': nagroda = 5; //Airstrike
		case 'E': nagroda = (nazwa[1] == 'm'? 6: 7); //Emergency Airdrop, EMP
		case 'N': nagroda = 8; //Nuke
	}

	ile_nagrod[id][nagroda]++;
	if(nagroda >= 7 && ile_nagrod[id][nagroda] <= 10) //emp, nuke
	{
		SpawadzNagrode(id, nagroda, 0, 2, 5); 
		return;
	}
	if(nagroda < 7/*6*/ && ile_nagrod[id][nagroda] <= 50) //Sentry Gun, ect.
	{
		SpawadzNagrode(id, nagroda);
		return;
	}
	/*if(nagroda == 6 && ile_nagrod[id][nagroda] <= 25) //Emergency Airdrop
	{
		SpawadzNagrode(id, nagroda);
		return;
	}*/
	if(nagroda == 5) //Airstrike
	{
		if(ile_nagrod[id][5] >= 50 && (ile_nagrod[id][5]-50) <= 1000)
		{
			SpawadzNagrode(id, nagroda, 10);
		}	
		return;
	}
	if(nagroda == 0 || nagroda == 1) //UAV, Counter-UAV
	{
		if(ile_nagrod[id][0] >= 50 && ile_nagrod[id][1] >= 50 && (max(ile_nagrod[id][0], ile_nagrod[id][1])-50) <= 1000)
		{
			if(max(ile_nagrod[id][0], ile_nagrod[id][1]) == ile_nagrod[id][nagroda])
				SpawadzNagrode(id, nagroda, 9);
		}
		return;
	}
	if(nagroda == 2 || nagroda == 4 || nagroda == 6) //Care Package, Predator Missle, Emergency Airdrop
	{
		new maksa = max(max(ile_nagrod[id][2], ile_nagrod[id][4]), ile_nagrod[id][6]);
		if(ile_nagrod[id][2] >= 50 && ile_nagrod[id][4] >= 50 && ile_nagrod[id][6] >= 50/*25*/ && ((maksa - 50/*(maksa == ile_nagrod[id][6]? 25: 50)*/) <= 1000))
		{
			if(maksa == ile_nagrod[id][nagroda])
				SpawadzNagrode(id, nagroda, 11);
		}	
		return;
	}
}

SpawadzNagrode(id, nagroda, ktore=0, wspolczynnik=5, mnoznik=25)
{
	ZapiszDaneStreak(id, nagroda);
	
	new liczba;
	for(new i=0; i<3; i++)
	{
		if(!ktore)
		{
			//if(nagroda != 6)
			liczba = (i==0? wspolczynnik: (i*mnoznik));
			//else
			//	liczba = (i==0? wspolczynnik: (i==1? (mnoznik/2.5): mnoznik);
		}
		else
			liczba = (i==2? 1000: ((i+1)*50))+/**/50;
			
		if(ile_nagrod[id][nagroda] == liczba)
		{
			if(ktore)
			{
				liczba -= 50;
				nagroda = ktore;
			}
				
			new szNazwa[256], szLiczba[11];
			copy(szNazwa, 255, nazwy_nagrody[nagroda]);
			
			replace(szNazwa, 255, "%", rzymskie_liczby[i]);
			num_to_str(liczba, szLiczba, 10);
			replace(szNazwa, 255, "&", szLiczba);
			
			set_hudmessage(255, 255, 255, -1.0, 0.25, 0, 6.0, 7.0);
			ShowSyncHudMsg(id, SyncHudObj, "%s^n+%iXP", szNazwa, za_nagrode[nagroda][i]);
			
			replace(szNazwa, 255, "^n", " (");
			client_print(0, 3, "[KS] Gracz %s dostal +%iXP za ukonczenie wyzwania %s)", nazwa_gracza[id], za_nagrode[nagroda][i], szNazwa);
			client_cmd(id, "spk mw/challenge_completed.wav");
			
			
#if defined COD_NOWY
			cod_set_user_xp(id, cod_get_user_xp(id)+za_nagrode[nagroda][i]);
#else
			new szNick[32];
			get_user_name(id, szNick, 31);
			server_cmd("cod_addexp ^"%s^" %d", szNick, za_nagrode[nagroda][i]);
#endif
			break;
		}
	}
}

public ZapiszDaneStreak(id, nagroda)
{
#if defined USING_SQL
	new szTemp[256];
	formatex(szTemp, 255, "UPDATE `cod_ks` SET `%i` = (`%i` + 1) WHERE `name` = '%s'", nagroda, nagroda, nazwa_gracza[id]);
	SQL_ThreadQuery(g_sql, "handleInsert", szTemp);
#else
	new vaultkey[37],vaultdata[512];
	formatex(vaultdata, 511,"%i#%i#%i#%i#%i#%i#%i#%i#%i", ile_nagrod[id][0], ile_nagrod[id][1], ile_nagrod[id][2], ile_nagrod[id][3], ile_nagrod[id][4], ile_nagrod[id][5], ile_nagrod[id][6], ile_nagrod[id][7], ile_nagrod[id][8]);
	formatex(vaultkey, 36,"%s-ks", nazwa_gracza[id]);
	nvault_set(g_vault, vaultkey, vaultdata);
#endif
}

public WczytajDaneStreak(id)
{
#if defined USING_SQL
	new data[1], szTemp[512];
	data[0] = id;
	formatex(szTemp, 511, "SELECT * FROM `cod_ks` WHERE `name` = '%s'", nazwa_gracza[id]);
	SQL_ThreadQuery(g_sql, "handleSelect", szTemp, data, 1);
#else
	new vaultkey[37], vaultdata[512];
	formatex(vaultkey, 36,"%s-ks", nazwa_gracza[id]);
	
	nvault_get(g_vault, vaultkey, vaultdata, 511);
	replace_all(vaultdata, 511, "#", " ");
	 
	new danegracza[9][32];
	parse(vaultdata, danegracza[0], 31, danegracza[1], 31, danegracza[2], 31, danegracza[3], 31, danegracza[4], 31, danegracza[5], 31, danegracza[6], 31, danegracza[7], 31, danegracza[8], 31);
		
	ile_nagrod[id][0] = str_to_num(danegracza[0]);
	ile_nagrod[id][1] = str_to_num(danegracza[1]);
	ile_nagrod[id][2] = str_to_num(danegracza[2]);
	ile_nagrod[id][3] = str_to_num(danegracza[3]);
	ile_nagrod[id][4] = str_to_num(danegracza[4]);
	ile_nagrod[id][5] = str_to_num(danegracza[5]);
	ile_nagrod[id][6] = str_to_num(danegracza[6]);
	ile_nagrod[id][7] = str_to_num(danegracza[7]);
	ile_nagrod[id][8] = str_to_num(danegracza[8]);
#endif
}

#if defined USING_SQL
public handleSelect(failstate, Handle:query, error[], errnum, data[], size)
{
	if(failstate != TQUERY_SUCCESS){
		log_amx("[KS] MySQL (handleSelect) error: %s",error);
		return;
	}
	new id = data[0];
	
	if(SQL_NumRows(query))
	{
		for(new i=0; i<9; i++)
		{
			ile_nagrod[id][i] = ile_nagrod[id][i]+SQL_ReadResult(query, i+1); //wrazie czego
		}
	}
	else
	{
		new szTemp[256]
		formatex(szTemp, 255, "INSERT INTO `cod_ks` (name) VALUES ('%s');", nazwa_gracza[id]);
		SQL_ThreadQuery(g_sql, "handleInsert", szTemp);
	}
}

public handleInsert(failstate, Handle:query, error[], errnum, data[], size){
	if(failstate != TQUERY_SUCCESS){
		log_amx("[KS] MySQL (handleInsert) error: %s", error);
		return;
	}
}
#endif
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
