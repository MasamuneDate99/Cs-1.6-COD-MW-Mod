#include <amxmodx>
#include <tutor>
#include <codmod>
#include <nvault>
#include <Colorchat>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN "Premium Points"
#define VERSION "0.2"
#define AUTHOR "Grzesiek edit: Na 5tyk, Koong"

#define ADMIN ADMIN_IMMUNITY
#define TASK_ID 666

new const prefix[] = "FORUM.RAJAGAME.COM";

new punkty_gracza[33];
new pozioms[33];
new nazwa_perku[256]
new g_vault;
new cvar[4], cena[4];
new num[8][33];
new mun[8][33];
new const co_ile[] = { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 100, 200, 400, 800 }
new const brak[] = "You do not have enough CP"
new szybkosc_rozdania[33];
new nazwa_klasy[256]
new nazwa_gracza[64],
identyfikator[32][64];
new g_pPointsPerKill;
new player_password[33];
new password[33];
new wpisal_haslo[33];
new wpisane_haslo[33];
new co_wybrales[33];
new gracz_id[33]
new player_id;
new name[33]
new g_haslo



new iTime, pCvarEvent;
new cvar_eventpk, cvar_eventoff;


new sprite;

public plugin_init() 
{
	new sz_Dir[128];
	get_configsdir(sz_Dir, charsmax(sz_Dir));
	format(sz_Dir, charsmax(sz_Dir), "%s/premium_points.cfg", sz_Dir);
	server_cmd("exec %s", sz_Dir);
	
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say /cp", "Mymenu");
	register_clcmd("say /cp", "Mymenu");
	register_clcmd("say /event", "Start");
	register_clcmd("say /sejw","Zapisz") 

	register_event( "DeathMsg", "Event_DeathMsg", "a" );
	register_concmd("enter_pass", "stworz_haslo")
	register_concmd("enter_pass", "wpisz_haslo1")
	
	tutorInit();
	register_menucmd(register_menuid("Exp"), 1023, "handleExp");
	register_concmd("amx_pkt", "give_pkt", ADMIN_IMMUNITY, "<Nick> <RP>")
	
	g_pPointsPerKill = register_cvar( "jb_points_per_kill",	"1" );
	
	pCvarEvent = register_cvar("cod_eventczas", "300");  
	cvar_eventoff = register_cvar("cod_eventoff", "0");  
	cvar_eventpk = register_cvar("cod_eventpk", "1");
	cvar[0] = register_cvar("premium_exp1", "3000");
	cvar[1] = register_cvar("premium_exp2", "7000");
	cvar[2] = register_cvar("premium_exp3", "16000");
	cvar[3] = register_cvar("premium_exp4", "32000");
	cena[0] = register_cvar("premium_cena1", "5");
	cena[1] = register_cvar("premium_cena2", "10");
	cena[2] = register_cvar("premium_cena3", "20");
	cena[3] = register_cvar("premium_cena4", "30");
	g_vault =       nvault_open("CP");
	g_haslo =       nvault_open("Player Password");
	
	if(file_exists(sz_Dir))
	{
		return PLUGIN_HANDLED
	}
	write_file(sz_Dir, "//Ceny Expa", 1);
	write_file(sz_Dir, " // Cena pierwszego expa  [ w sklepie ]", 2);
	write_file(sz_Dir, "premium_cena1 5",3);
	write_file(sz_Dir, " // Cena drugiego expa  [ w sklepie ]", 4);
	write_file(sz_Dir, "premium_cena2 10", 5);
	write_file(sz_Dir, " // Cena trzeciego expa  [ w sklepie ]", 6);
	write_file(sz_Dir, "premium_cena3 20", 7);
	write_file(sz_Dir, " // Cena czwartego expa  [ w sklepie ]",8);
	write_file(sz_Dir, "premium_cena4 30", 9);
	write_file(sz_Dir, " // Ilosc pierwszego expa  [ w sklepie ]", 10);
	write_file(sz_Dir, "premium_exp1 3000", 11);
	write_file(sz_Dir, " // Ilosc drugiego expa  [ w sklepie ]", 12);
	write_file(sz_Dir, "premium_exp2 7000", 13);
	write_file(sz_Dir, " // Ilosc trzeciego expa  [ w sklepie ]", 14);
	write_file(sz_Dir, "premium_exp3 16000", 15);
	write_file(sz_Dir, " // Ilosc czwartego expa  [ w sklepie ]", 16);
	write_file(sz_Dir, "premium_exp4 32000", 17);

	
	return PLUGIN_CONTINUE;
	
}
public plugin_natives()
{
	register_library("premiump")
	register_native("premium_points_get", "Zwroc_Premium",1)
	register_native("premium_points_add", "Zmien_Premium", 1)
}
public plugin_precache()
{
	tutorPrecache()
	sprite = engfunc(EngFunc_PrecacheModel, "sprites/true_beam.spr");
	
}

public Start(id)
{
	if(!(get_user_flags(id) & ADMIN_IMMUNITY) || task_exists( TASK_ID ) )
		return PLUGIN_HANDLED;
	
	server_cmd("jb_points_per_kill %i", get_pcvar_num(cvar_eventpk))
	server_exec();
	
	client_print(0, print_center, "RP Event ON!!");
	
	iTime = get_pcvar_num( pCvarEvent );
	
	remove_task( TASK_ID )
	
	set_task( 1.0, "Koniec", TASK_ID, .flags = "b" )
	
	return PLUGIN_HANDLED
}
public Koniec()
{
	if( iTime <= 0 )
	{
		remove_task( TASK_ID )
		
		server_cmd("jb_points_per_kill %i", get_pcvar_num(cvar_eventoff))
		server_exec();
		
		client_print(0, print_center, "CP Event OFF!!");
		
		return PLUGIN_CONTINUE;
	}
	set_hudmessage(255, 255, 0, -1.0, 0.01, 0, 2.0, 1.1)
	show_hudmessage( 0, "^n^n^n[End Event for %d second!]|[Kill to get COD POINT]", iTime )
	
	iTime --;
	
	return PLUGIN_CONTINUE;
}
public client_authorized(id)
{
	
	UsunPunkty(id);
	
	get_user_name(id, nazwa_gracza[id], 63);
	copy(identyfikator[id], 63, nazwa_gracza[id]);
	
	WczytajPkt(id);
}

public Event_DeathMsg()
{
	new iKiller = read_data( 1 );
	
	new iTotal = get_pcvar_num( g_pPointsPerKill );
	
	if( punkty_gracza[ iKiller ] > -1 )
	{
		iTotal += iTotal;
	}
	
	punkty_gracza[ iKiller ] += iTotal;
	
	return PLUGIN_CONTINUE;
}

public client_connect(id)
{
	WczytajPkt(id);
	Wczytaj(id)


}

public client_disconnect(id)
{
	ZapiszPkt(id);
	Zapisz(id)


}


public UsunPunkty(id)
{
	punkty_gracza[id] = 0;
}


public give_pkt(id,level,cid)
{
	if(!cmd_access(id,level,cid,3)) return PLUGIN_HANDLED
	
	new arg1[32]
	new arg2[6]
	
	read_argv(1,arg1,31)
	read_argv(2,arg2,5)
	
	new player=cmd_target(id,arg1,CMDTARGET_ALLOW_SELF)
	new bonus=str_to_num(arg2)
	
	if (!player)
	{
		console_print(id, "Player %s not found!",arg1)
		return PLUGIN_HANDLED
	}
	else
	{
		punkty_gracza[player]+= bonus;
		ZapiszPkt(id)
		ColorChat(id, GREEN, "[%s] ^x01Player %s Got ^x03%d  ^x01CP.", prefix, arg1, bonus)
	}
	return PLUGIN_HANDLED
}

public Mymenu(id)
{	
	new MyMenu=menu_create("\rCP Shop","cbMyMenu");
	new MyMenuFun=menu_makecallback("mcbMyMenu");
	
	menu_additem(MyMenu,"\wShop\y[\rBuy Exp/Perk/Transfer Exp\y]","",0,MyMenuFun);
	menu_additem(MyMenu,"\wCreate Password\y[\rCreate a password\y]","",0,MyMenuFun);
	menu_additem(MyMenu,"\wInformation\y[\rHere you will learn what and dependent COD Point\y]","",0,MyMenuFun);
	if(get_user_flags(id) & ADMIN)
	{
		menu_additem(MyMenu,"\wMenu Admin\y[\rMenu Admina\y]","",0,MyMenuFun);
	}

	menu_setprop(MyMenu,MPROP_EXITNAME,"\rExit");
	menu_setprop(MyMenu,MPROP_EXIT,MEXIT_ALL);
	menu_setprop(MyMenu,MPROP_NUMBER_COLOR, "\r");
	
	
	menu_display(id, MyMenu,0);
	
	
	return PLUGIN_HANDLED;
}

public cbMyMenu(id, menu, item)
{
	switch(item)
	{
		case 0: 
		{  
			if(player_password[id] >= 1)
			{
				if(wpisal_haslo[id] == 1)
				{
					Sklep(id)
					ColorChat(id,GREEN,"[*CP*]^x01 Already have written a password you will be redirected")
				}
				else if(wpisal_haslo[id] == 0)
				{
					client_cmd(id, "messagemode enter_pass")
					ColorChat(id,GREEN,"[*CP*]^x01 Not typed password. You must now enter")
				}
			}
			else if(player_password[id] == 0)
			{
				ColorChat(id,GREEN,"[*CP*]^x01 Do not yet have a password")
			}
		}
		case 1:
		{
			if(player_password[id] == 0)
			{
				client_cmd(id, "messagemode enter_pass")
				ColorChat(id,GREEN,"[*CP*]^x01 Enter the same numbers. The first digit cannot be 0 Maximum 6cyfr")
				co_wybrales[id] = 3
			}
			else if(player_password[id] >= 1)
				ColorChat(id,GREEN,"[*CP*]^x01 You already have a password ")
			
		}
		case 2:
		{
			info(id);
		}
		case 3: 
		{  
			Admin(id);
	        }
	
	
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}
public stworz_haslo(id)
{
	new text[192]
	read_argv(1,text,191)
	format(password, charsmax(password), "%s", text)
	create(id)
}
public wpisz_haslo1(id)
{
	new text[192]
	read_argv(1,text,191)
	format(wpisane_haslo, charsmax(wpisane_haslo), "%s", text)
	sprawdzaj(id)
}
public sprawdzaj(id)
{
	new haslo = str_to_num(wpisane_haslo)
	if(haslo != player_password[id])
	{
		ColorChat(id,GREEN,"[*CP*]^x01 You have entered the wrong password")
	}
	if(haslo == player_password[id])
	{
		Sklep(id)
		wpisal_haslo[id] = 1
		ColorChat(id,GREEN,"[*CP*]^x01 You have entered the wrong password")
	}
}
public create(id)
{
	if(co_wybrales[id] == 3)
	{
		player_password[id] = str_to_num(password)
		Zapisz(id)
	}
}

public Sklep(id)
{
	new mvip = menu_create("CPShop", "Sklep_Handle");
	menu_additem(mvip, "Buy Item\y[\rBuy any Item\y]\r[\y20 CP\r]");
	menu_additem(mvip, "Buy Exp\y[\rYou are buying EXP\y]");
	menu_additem(mvip, "Move Exp\y[\rAutomatically moves exp\y]\r[\y450 CP\r]");
	menu_display(id, mvip, 0);	
}
public Sklep_Handle(id, mvip, item)
{
	switch(item)
	{
		case 0:
		{
			Item(id)
		}
		case 1:
		{
			Exp(id)
		}
		case 2:
		{
			Wybierz_klase(id)
		}
	}
	menu_destroy(mvip);
}

public mcbMyMenu(id, menu, item){
	
	return ITEM_ENABLED;
}



public handleExp(id, key)
{	
	new player_origin[3];
	get_user_origin(id, player_origin, 0);
	
	switch(key)
	{
		case 0:
		{
			if(punkty_gracza[id] >= get_pcvar_num(cena[0]))
			{
				new win = get_pcvar_num(cvar[0])
				cod_set_user_xp(id, cod_get_user_xp(id) + win)
				punkty_gracza[id]-= get_pcvar_num(cena[0])
				tutorMake(id, TUTOR_YELLOW, 4.0, "You get %d Exp !^nSpent %d CP", win, get_pcvar_num(cena[0]));
				set_sprite(player_origin, sprite, 40); 
			}
			else
			{
				ColorChat(id, GREY, "%s",brak)
				
			}
		}
		case 1:
		{
			if(punkty_gracza[id] >= get_pcvar_num(cena[1]))
			{
				new win = get_pcvar_num(cvar[1])
				cod_set_user_xp(id, cod_get_user_xp(id) + win)
				punkty_gracza[id]-= get_pcvar_num(cena[1])
				tutorMake(id, TUTOR_GREEN, 4.0, "You get %d Exp !^nSpent %d CP", win, get_pcvar_num(cena[1]));
				set_sprite(player_origin, sprite, 40); 
			}
			else
			{
				ColorChat(id, GREEN, "%s", brak)
				
			}
		}
		case 2:
		{
			if(punkty_gracza[id] >= get_pcvar_num(cena[2]))
			{
				new win = get_pcvar_num(cvar[2])
				cod_set_user_xp(id, cod_get_user_xp(id) + win)
				punkty_gracza[id]-= get_pcvar_num(cena[2])
				tutorMake(id, TUTOR_RED, 4.0, "You get %d Exp !^nSpent %d CP", win, get_pcvar_num(cena[2]));
				set_sprite(player_origin, sprite, 40); 
			}
			else
			{
				ColorChat(id, RED, "%s", brak)
				
			}
		}
		case 3:
		{
			if(punkty_gracza[id] >= get_pcvar_num(cena[3]))
			{
				new win = get_pcvar_num(cvar[3])
				cod_set_user_xp(id, cod_get_user_xp(id) + win)
				punkty_gracza[id]-= get_pcvar_num(cena[3])
				tutorMake(id, TUTOR_BLUE, 4.0, "You get %d Exp !^nSpent %d CP", win, get_pcvar_num(cena[3]));
				set_sprite(player_origin, sprite, 40); 
			}
			else
			{
				ColorChat(id, BLUE, "%s", brak)
			}
		}
	}
	
	
	
	ZapiszPkt(id)
	
	return 1;
}

public Exp(id)
{	
	new MenuBody[3184], len, keys;
	mun[0][id] = cod_get_user_level(id)
	mun[1][id] = cod_get_user_level(id)
	mun[2][id] = cod_get_user_level(id)
	mun[3][id] = cod_get_user_level(id)
	
	for( num[0][id] = cod_get_user_xp(id) + get_pcvar_num(cvar[0]); num[0][id] >= cod_get_level_xp(mun[0][id]); mun[0][id]+= 1)
	{
	}
	for( num[1][id] = cod_get_user_xp(id) + get_pcvar_num(cvar[1]); num[1][id] >= cod_get_level_xp(mun[1][id]); mun[1][id]+= 1)
	{
	}
	for( num[2][id] = cod_get_user_xp(id) + get_pcvar_num(cvar[2]); num[2][id] >= cod_get_level_xp(mun[2][id]); mun[2][id]+= 1)
	{
	}
	for( num[3][id] = cod_get_user_xp(id) + get_pcvar_num(cvar[3]); num[3][id] >= cod_get_level_xp(mun[3][id]); mun[3][id]+= 1)
	{
	}
	len = format(MenuBody, sizeof MenuBody - 1, "\ySelect the number of Exp")
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r1.\w%d XP [\r%d Level\w] \y %d CP",get_pcvar_num(cvar[0]), mun[0][id] -= cod_get_user_level(id), get_pcvar_num(cena[0]))
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\w%d XP [\r%d Level\w] \y %d CP", get_pcvar_num(cvar[1]), mun[1][id] -= cod_get_user_level(id), get_pcvar_num(cena[1]))
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r3.\w%d XP [\r%d Level\w]\y %d CP", get_pcvar_num(cvar[2]), mun[2][id] -= cod_get_user_level(id), get_pcvar_num(cena[2]))
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r4.\w%d XP [\r%d Level\w] \y %d CP", get_pcvar_num(cvar[3]), mun[3][id] -= cod_get_user_level(id), get_pcvar_num(cena[3]))
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r%s", prefix)	
	keys = ( 1<<4 | 1<<8 | 1<<9 );
	keys |= ( 1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<5 | 1<<6 );
	show_menu(id, keys, MenuBody, -1, "Exp");
	//tutorMake(id, TUTOR_GREEN, 8.0, " UWAGA ^nPo zakupieniu expa zostaniesz wyrzucony z serwera");
}

public Admin(id)
{
	if(!(get_user_flags(id) &  ADMIN_IMMUNITY))
	{
		return PLUGIN_HANDLED
	}
	new menu = menu_create("Menu Admin", "Admin_Handle");
	menu_additem(menu, "Gift CP");
	menu_additem(menu, "Turn On The PK EVENT");
	menu_additem(menu, "See Password Player");
	menu_display(id, menu);	
	return PLUGIN_CONTINUE
}

public Admin_Handle(id, menu, item)
{
	if(item == MENU_EXIT) 
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}

	switch(item)
	{
		case 0:
		{
			Punkty(id)
		}
		case 1:
		{
			Start(id)
		}
		case 2:
		{
			Gracz(id)
			co_wybrales[id] = 2
		}
	}	
	return PLUGIN_CONTINUE
}

public Punkty(id)
{
	new nick[33],msg[128], szybkosc[60];
	format(szybkosc, charsmax(szybkosc), "How much: \r%d \y(How many point to add)", co_ile[szybkosc_rozdania[id]]);
	
	new gmenu=menu_create("Select A Player","Punkty_Handle")
	menu_additem(gmenu, szybkosc);
	menu_addblank(gmenu, 0)
	
	for(new i=0; i<get_playersnum() + 1; i++)
	{
		get_user_name(i,nick,31)
		format(msg,127,nick);
		if(is_user_connected(i))
		{
			menu_additem(gmenu,msg)
		}
	}
	
	menu_setprop(gmenu, MPROP_EXITNAME, "Exit");
	menu_setprop(gmenu, MPROP_BACKNAME, "Previous page");
	menu_setprop(gmenu, MPROP_NEXTNAME, "Next page");
	menu_display(id,gmenu,0)
	
}
public Punkty_Handle(id, menu, item)
{
	new ilosc =co_ile[szybkosc_rozdania[id]]
	switch(item) 
	{
		case 0: 
		{
			if(szybkosc_rozdania[id] < charsmax(co_ile)) szybkosc_rozdania[id]++;
			else szybkosc_rozdania[id] = 0;
			Punkty(id);
		}
		case MENU_EXIT :
		{
			menu_destroy(menu);
			return PLUGIN_HANDLED
		}
		default:
		{
		punkty_gracza[item]+= ilosc
		new player_origin[3];
		get_user_origin(id, player_origin, 0);
		set_sprite(player_origin, sprite, 40); 
		ColorChat(item, GREY, "You get %d Cod Point", ilosc);
		Admin(id)
		}
	}
	return PLUGIN_CONTINUE;
}

public Item(id)
{
	new menu = menu_create("Select A Perk:", "Item_Handle");
	for(new i=1; i <= cod_get_perks_num(); i++)
	{
		cod_get_perk_name(i, nazwa_perku, 255)
		menu_additem(menu, nazwa_perku);
	}
	menu_setprop(menu, MPROP_EXITNAME, "Exit");
	menu_setprop(menu, MPROP_BACKNAME, "Previous page");
	menu_setprop(menu, MPROP_NEXTNAME, "Next page");
	menu_display(id, menu);	
}

public Item_Handle(id, menu, item)
{
	if(50 >= punkty_gracza[id])
	{
		ColorChat(id, GREEN, "[%s] ^x01You do not have ^x03 CP.", prefix)
		return PLUGIN_HANDLED
	}
	else if(cod_get_user_perk(id) > 0)
	{
		ColorChat(id, GREEN, "[%s]^x01 Currently you have already ^x03 Item.", prefix)
		return PLUGIN_HANDLED
	}


	if(item++ == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	else 
	{
		cod_set_user_perk(id, item, -1, 0);
		cod_get_perk_name(item, nazwa_perku, 255);
		punkty_gracza[id]-= 20
		new player_origin[3];
		get_user_origin(id, player_origin, 0);
		set_sprite(player_origin, sprite, 40); 
	}
	return PLUGIN_CONTINUE;
}

public poziomy(id)
{
	new poziom = cod_get_user_level(id)
	pozioms[id] = poziom
	new wymog = cod_get_level_xp(pozioms[id]);

	new xp = cod_get_user_xp(id) + 15000
	do
	{
		pozioms[id]+= 1
		ColorChat(id, GREEN, "%d", pozioms[id]);
	}
	while(xp > wymog)
}

public info(id)
{
	new MenuBody[3184], len, keys;

	len = format(MenuBody, sizeof MenuBody - 1, "\wCP will be given for winner events on the server.")
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\rCP you can get from event")
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\rBuy Exp")
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\rPerk")
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\rMove Exp")
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\rCP give on event")
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\rMove Exp")
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\rYou'll get everything on the \y[\r%s\y]", prefix)
	keys = ( 1<<4 | 1<<8 | 1<<9 );

	keys |= ( 1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<5 | 1<<6 );
	
	show_menu(id, keys, MenuBody, -1, "info");
}

public handleinfo(id, key)
{	
	return 1;
}

public ZapiszPkt(id)
{
        new vaultkey[64], vaultdata[16];
        formatex(vaultkey, 63, "%s-pp", identyfikator[id]);
        formatex(vaultdata, 15, "%d", punkty_gracza[id]);
        nvault_set(g_vault, vaultkey, vaultdata);
        
        return PLUGIN_CONTINUE
}

public WczytajPkt(id)
{
        new vaultkey[64], vaultdata[16];
        formatex(vaultkey, 63, "%s-pp", identyfikator[id]);
        
        if(nvault_get(g_vault, vaultkey, vaultdata, 15))
                punkty_gracza[id] = str_to_num(vaultdata);
        
        return PLUGIN_CONTINUE
}
public Zapisz(id)
{
	new AuthID[35]
	get_user_name(id,AuthID,34)
	
	new vaultkey[64],vaultdata[128]
	formatex(vaultkey,63,"%s",AuthID)
	formatex(vaultdata,127,"%i",player_password[id])
	nvault_set(g_haslo,vaultkey,vaultdata)
	return PLUGIN_CONTINUE
}

public Wczytaj(id)
{
	new AuthID[35]
	get_user_name(id,AuthID,34)
	
	new vaultkey[64],vaultdata[128]
	formatex(vaultkey,63,"%s",AuthID)
	nvault_get(g_haslo,vaultkey,vaultdata,127)
	
	new ps[12]
	parse(vaultdata, ps, 11)
	
	player_password[id] = str_to_num(ps)
	
	return PLUGIN_CONTINUE
}


public Zwroc_Premium(id)
	return punkty_gracza[id];

public Zmien_Premium(id, ile)
{
	punkty_gracza[id]= ile
}



set_sprite(player_origin[3], sprite, radius){
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, player_origin);
	write_byte(TE_EXPLOSION) //wg uznania;
	write_coord(player_origin[0]); //ja u¿ylem ¿eby dzia³a³ na pozycje gracza. Oczywiœcie mo¿na wed³ug w³asnego uznania;
	write_coord(player_origin[1]);
	write_coord(player_origin[2]);
	write_short(sprite); //bedziemy ustalac nasz sprite;
	write_byte(radius); //bedzie uzywany do nadania sprite (promien razenia);
	write_byte(18);
	write_byte(6);
	message_end();
}

public Gracz(id)
{
	new menu = menu_create("\ySelect a player:", "Wybierz_Gracza_handler");
	
	for(new i=0, n=0; i<=32; i++)
	{
		if(!is_user_connected(i))
			continue;
		
		gracz_id[n++] = i;
		new nazwa_gracza[64];
		get_user_name(i, nazwa_gracza, 63)
		menu_additem(menu, nazwa_gracza, "0", 0);
	}
	menu_display(id, menu);
}
public Wybierz_Gracza_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	player_id = gracz_id[item];
	get_user_name(player_id, name, 32);
	

	if(co_wybrales[id] == 2)
	{
		ColorChat(id,GREEN,"[*CP*]^x01 this player is password %i",player_password[player_id])
	}
	
	return PLUGIN_HANDLED;
}


public Wybierz_klase(id)
{
	new tytul[64];
	format(tytul, sizeof(tytul), "\yFor what class");
	new menu = menu_create(tytul, "wybierzklase_handler");
	for(new i=1; i<=cod_get_classes_num(); i++)
	{
		cod_get_class_name(i, nazwa_klasy, 255)
		menu_additem(menu, nazwa_klasy)
	}
	menu_display(id, menu);
}
public wybierzklase_handler(id, menu, item)
{
	if(100 >= punkty_gracza[id])
	{
		ColorChat(id, GREEN, "[%s] ^x01You do not have a sufficient number of ^x03 CP.", prefix)
		return PLUGIN_HANDLED
	}
	if(item++ == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_CONTINUE;
	}
	{
		new klasa[2][65];
		punkty_gracza[id]-= 450
		new exp = cod_get_user_xp(id);
		cod_get_class_name(cod_get_user_class(id), klasa[0], 64);
		cod_set_user_xp(id, 0);
		cod_set_user_class(id, item, 1);
		cod_get_class_name(cod_get_user_class(id), klasa[1], 64);
		cod_set_user_xp(id, cod_get_user_xp(id)+exp);
		ColorChat(id,GREEN,"[*CP*]^x01 Exp moved from class %s to class %s | CLASS HAS BEEN CHANGED AUTOMATICALLY",klasa[0], klasa[1]);
	}


	return PLUGIN_CONTINUE;
}


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
