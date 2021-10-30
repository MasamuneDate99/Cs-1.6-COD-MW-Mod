#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <nvault>
#include <ColorChat>

#define PLUGIN "Call of Duty: MW Mod"
#define VERSION "1.0-3"
#define AUTHOR "QTM_Peyote"

#define MAX_WIELKOSC_NAZWY 32
#define MAX_WIELKOSC_OPISU 256
#define MAX_ILOSC_PERKOW 120
#define MAX_ILOSC_KLAS 100

#define STANDARDOWA_SZYBKOSC 250.0

#define ZADANIE_POKAZ_INFORMACJE 672
#define ZADANIE_POKAZ_REKLAME 768
#define ZADANIE_USTAW_SZYBKOSC 832
#define MAX_WIELKOSC_FRAKCJA 64

new const maxAmmo[31] = {0, 52, 0, 90, 1, 31, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120, 30, 120, 200, 31, 90, 120,
 90, 2, 35, 90, 90,0, 100};

new MsgScreenfade;
new g_szModName[32]

new vault;

new SyncHudObj, SyncHudObj2;
 
new cvar_doswiadczenie_za_zabojstwo,
     cvar_doswiadczenie_za_obrazenia,
     cvar_doswiadczenie_za_wygrana,
     cvar_typ_zapisu,
     cvar_limit_poziomu,
     cvar_proporcja_poziomu,
     cvar_blokada_broni;

     
new perk_zmieniony,
     klasa_zmieniona;


new frakcja_klas[MAX_ILOSC_KLAS+1][MAX_WIELKOSC_FRAKCJA+1],      
     nazwy_perkow[MAX_ILOSC_PERKOW+1][MAX_WIELKOSC_NAZWY+1],
     opisy_perkow[MAX_ILOSC_PERKOW+1][MAX_WIELKOSC_OPISU+1],
     max_wartosci_perkow[MAX_ILOSC_PERKOW+1],
     min_wartosci_perkow[MAX_ILOSC_PERKOW+1],
     pluginy_perkow[MAX_ILOSC_PERKOW+1],
     ilosc_perkow;

     
new nazwa_gracza[33][64],
     klasa_gracza[33],
     nowa_klasa_gracza[33],
     poziom_gracza[33],
     doswiadczenie_gracza[33],
     perk_gracza[2][33],
	 wartosc_perku_gracza[2][33];

new Float:maksymalne_zdrowie_gracza[33],
     Float:szybkosc_gracza[33],
     Float:redukcja_obrazen_gracza[33];
     
new punkty_gracza[33],
     zdrowie_gracza[33],
     inteligencja_gracza[33],
     wytrzymalosc_gracza[33],
     kondycja_gracza[33];

new bool:gracz_ma_tarcze[33],
     bool:gracz_ma_noktowizor[33];     

new bonusowe_bronie_gracza[33],
     bonusowe_zdrowie_gracza[33],
     bonusowa_inteligencja_gracza[33],
     bonusowa_wytrzymalosc_gracza[33],
     bonusowa_kondycja_gracza[33];

new bronie_klasy[MAX_ILOSC_KLAS+1], 
     zdrowie_klas[MAX_ILOSC_KLAS+1],
     kondycja_klas[MAX_ILOSC_KLAS+1], 
     inteligencja_klas[MAX_ILOSC_KLAS+1], 
     wytrzymalosc_klas[MAX_ILOSC_KLAS+1],
     nazwy_klas[MAX_ILOSC_KLAS+1][MAX_WIELKOSC_NAZWY+1],
     opisy_klas[MAX_ILOSC_KLAS+1][MAX_WIELKOSC_OPISU+1],
     pluginy_klas[MAX_ILOSC_KLAS+1],
     ilosc_klas;

new bronie_druzyny[] = {0, 0, 0},
     bronie_dozwolone = 1<<CSW_KNIFE | 1<<CSW_C4;

new bool:freezetime = true;
new weaponname[22];

new licznik_zabiccod[33];
new licznik_smiercicod[33];
new min_lvl = 0;
new Float:procent = 0.03; // liczba 0.20 oznacza 20 % max lvl'u. Dajac 0.5 damy 50 % a 1.0 - 100 % lvlu

new nazwa_klasy[MAX_ILOSC_KLAS+1][64];
new nazwa_frakcji[MAX_ILOSC_KLAS+1][64];
 
new klasid;

new awanse[MAX_ILOSC_KLAS+1][3], awansuje_do[MAX_ILOSC_KLAS+1], awansuje_z[MAX_ILOSC_KLAS+1];
new ilosc_awansow;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	formatex(g_szModName, charsmax(g_szModName), "COD:MW Extended");
	
	cvar_doswiadczenie_za_zabojstwo = register_cvar("cod_killxp", "10");
	cvar_doswiadczenie_za_obrazenia = register_cvar("cod_damagexp", "1"); // ilosc doswiadczenia za 20 obrazen 
	cvar_doswiadczenie_za_wygrana = register_cvar("cod_winxp", "50");
	cvar_typ_zapisu = register_cvar("cod_savetype", "2");  // 1-Nick; 2-SID dla Steam; 3-IP
	cvar_limit_poziomu = register_cvar("cod_maxlevel", "200"); 
	cvar_proporcja_poziomu = register_cvar("cod_levelratio", "35"); 
	cvar_blokada_broni = register_cvar("cod_weaponsblocking", "1"); 
	
	register_clcmd("say /class", "WybierzKlase");
	register_clcmd("say /classinfo", "OpisKlasy");
	register_clcmd("say /perk", "KomendaOpisPerku");
	register_clcmd("say /perk2", "KomendaOpisPerku2");//
	register_clcmd("say /perks", "OpisPerkow");
	register_clcmd("say /help", "Pomoc");
	register_clcmd("say /item", "OpisPerku");
	register_clcmd("say /drop", "WyrzucPerk");
	register_clcmd("say /drop2", "WyrzucPerk2");
	register_clcmd("say /reset", "KomendaResetujPunkty");
	register_clcmd("say /wyrzuc2", "WyrzucPerk2");
	register_clcmd("say /stats", "PrzydzielPunkty");
	register_clcmd("useperk", "UzyjPerku");
	register_clcmd("radio3", "UzyjPerku");
	register_clcmd("useperk2", "UzyjPerku2");
	register_clcmd("radio2", "UzyjPerku2");
	register_clcmd("fullupdate", "BlokujKomende");
	
	//register_menucmd(register_menuid("class:"), 1023, "OpisKlasy");
	
	RegisterHam(Ham_TakeDamage, "player", "Obrazenia");
	RegisterHam(Ham_TakeDamage, "player", "ObrazeniaPost", 1);
	RegisterHam(Ham_Spawn, "player", "Odrodzenie", 1);
	RegisterHam(Ham_Killed, "player", "SmiercGraczaPost", 1);
	
	RegisterHam(Ham_Touch, "armoury_entity", "DotykBroni");
	RegisterHam(Ham_Touch, "weapon_shield", "DotykTarczy");
	RegisterHam(Ham_Touch, "weaponbox", "DotykBroni");
	
	register_forward(FM_CmdStart, "CmdStart");
	register_forward(FM_EmitSound, "EmitSound");
	
	register_message(get_user_msgid("Health"),"MessageHealth");
	
	register_logevent("PoczatekRundy", 2, "1=Round_Start"); 
	
	register_event("SendAudio", "WygranaTerro" , "a", "2&%!MRAD_terwin");
	register_event("SendAudio", "WygranaCT", "a", "2&%!MRAD_ctwin");
	register_event("CurWeapon","CurWeapon","be", "1=1");
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");
	register_event("DeathMsg", "SmiercGraczaKillCod", "a");
	register_forward(FM_GetGameDescription, "fw_GetGameDescription");
	
	vault = nvault_open("CodMod");
	
	MsgScreenfade = get_user_msgid("ScreenFade");
	
	SyncHudObj = CreateHudSyncObj();
	SyncHudObj2 = CreateHudSyncObj();
	
	perk_zmieniony = CreateMultiForward("cod_perk_changed", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL, FP_CELL);
	klasa_zmieniona = CreateMultiForward("cod_class_changed", ET_CONTINUE, FP_CELL, FP_CELL);

	copy(nazwy_perkow[0], MAX_WIELKOSC_NAZWY, "Lack");
	copy(opisy_perkow[0], MAX_WIELKOSC_OPISU, "Kill someone, to get the object");
	copy(nazwy_klas[0], MAX_WIELKOSC_NAZWY, "Lack");
	
	set_task(1.0, "plugin_cfg");
	
	loadfile()
}		

public fw_GetGameDescription()
{
	forward_return(FMV_STRING, g_szModName)
	return FMRES_SUPERCEDE;
}

public plugin_cfg()
{
	new lokalizacja_cfg[33];
	get_configsdir(lokalizacja_cfg, charsmax(lokalizacja_cfg));
	server_cmd("exec %s/codmod.cfg", lokalizacja_cfg);
	server_exec();
}

public loadfile()
{
	new file[256];
	get_configsdir(file,charsmax(file));
	formatex(file, charsmax(file), "%s/cod_frakcje.ini", file);
	
	if(!file_exists(file))
		return;
		
	new row[128], trash,  size=file_size(file,1);
	for(new i=0;i<size;i++)
	{
		read_file(file, i, row, charsmax(row), trash);
		
		if((contain(row,";")!=0) && strlen(row) && klasid<MAX_ILOSC_KLAS+1)
		{
			replace(row, charsmax(row), "[klasa]", "");
			split(row, nazwa_klasy[klasid], charsmax(nazwa_klasy[]), nazwa_frakcji[klasid], charsmax(nazwa_frakcji[]), "[frakcja]");
			klasid++;
		}
	}	
}

public plugin_precache()
{	
	precache_sound("QTM_CodMod/select.wav");
	precache_sound("QTM_CodMod/start.wav");
	precache_sound("QTM_CodMod/start2.wav");
	precache_sound("QTM_CodMod/levelup.wav");
}

public plugin_natives()
{
	register_native("cod_set_user_xp", "UstawDoswiadczenie", 1);
	register_native("cod_set_user_class", "UstawKlase", 1);
	register_native("cod_set_user_perk", "UstawPerk", 1);
	register_native("cod_set_user_bonus_health", "UstawBonusoweZdrowie", 1);
	register_native("cod_set_user_bonus_intelligence", "UstawBonusowaInteligencje", 1);
	register_native("cod_set_user_bonus_trim", "UstawBonusowaKondycje", 1);
	register_native("cod_set_user_bonus_stamina", "UstawBonusowaWytrzymalosc", 1);
	
	register_native("cod_points_to_health", "PrzydzielZdrowie", 1);	
	register_native("cod_points_to_intelligence", "PrzydzielInteligencje", 1);	
	register_native("cod_points_to_trim", "PrzydzielKondycje", 1);	
	register_native("cod_points_to_stamina", "PrzydzielWytrzymalosc", 1);	
	
	register_native("cod_get_user_xp", "PobierzDoswiadczenie", 1);
	register_native("cod_get_user_level", "PobierzPoziom", 1);
	register_native("cod_get_user_points", "PobierzPunkty", 1);
	register_native("cod_get_user_class", "PobierzKlase", 1);
	register_native("cod_get_user_perk", "PobierzPerk");
	register_native("cod_get_user_health", "PobierzZdrowie", 1);
	register_native("cod_get_user_intelligence", "PobierzInteligencje", 1);
	register_native("cod_get_user_trim", "PobierzKondycje", 1);
	register_native("cod_get_user_stamina", "PobierzWytrzymalosc", 1);
	
	register_native("cod_get_level_xp", "PobierzDoswiadczeniePoziomu", 1);
	
	register_native("cod_get_perkid", "PobierzPerkPrzezNazwe", 1);
	register_native("cod_get_perks_num", "PobierzIloscPerkow", 1);
	register_native("cod_get_perk_name", "PobierzNazwePerku", 1);
	register_native("cod_get_perk_desc", "PobierzOpisPerku", 1);
	
	register_native("cod_get_classid", "PobierzKlasePrzezNazwe", 1);
	register_native("cod_get_classes_num", "PobierzIloscKlas", 1);
	register_native("cod_get_class_name", "PobierzNazweKlasy", 1);
	register_native("cod_get_class_desc", "PobierzOpisKlasy", 1);
	
	register_native("cod_get_class_health", "PobierzZdrowieKlasy", 1);
	register_native("cod_get_class_intelligence", "PobierzInteligencjeKlasy", 1);
	register_native("cod_get_class_trim", "PobierzKondycjeKlasy", 1);
	register_native("cod_get_class_stamina", "PobierzWytrzymaloscKlasy", 1);
	
	register_native("cod_give_weapon", "DajBron", 1);
	register_native("cod_take_weapon", "WezBron", 1);
	register_native("cod_set_user_shield", "UstawTarcze", 1);
	register_native("cod_set_user_nightvision", "UstawNoktowizor", 1);
	
	register_native("cod_inflict_damage", "ZadajObrazenia", 1);
	
	register_native("cod_register_perk", "ZarejestrujPerk");
	register_native("cod_register_class", "ZarejestrujKlase");
	register_native("cod_register_advance", "ZarejestrujAwans");
}

public CmdStart(id, uc_handle)
{		
	if(!is_user_alive(id))
		return FMRES_IGNORED;

	new Float: velocity[3];
	pev(id, pev_velocity, velocity);
	new Float: speed = vector_length(velocity);
	if(szybkosc_gracza[id] > speed*1.8)
		set_pev(id, pev_flTimeStepSound, 300);
	
	return FMRES_IGNORED;
}

public Odrodzenie(id)
{	
	if(!task_exists(id+ZADANIE_POKAZ_INFORMACJE))
		set_task(0.1, "PokazInformacje", id+ZADANIE_POKAZ_INFORMACJE, _, _, "b");
	
	if(nowa_klasa_gracza[id])
		UstawNowaKlase(id);
	
	if(!klasa_gracza[id])
	{
		WybierzKlase(id);
		return PLUGIN_CONTINUE;
	}
	
	DajBronie(id);
	ZastosujAtrybuty(id);
	
	if(poziom_gracza[id] < min_lvl)
	{
		client_print(id,print_chat,"[Balance Cod] I discovered big problems with the balance of the levels on the server");
		client_print(id,print_chat,"[Balance Cod] As part of this I got %i to start",min_lvl);
		UstawDoswiadczenie(id,PobierzDoswiadczeniePoziomu(min_lvl)+1);
		poziom_gracza[id] = min_lvl;
		SprawdzPoziom(id);
	}
	
	if(punkty_gracza[id] > 0)
		PrzydzielPunkty(id);

	return PLUGIN_CONTINUE;
}

public UstawNowaKlase(id)
{
	new ret;
		
	new forward_handle = CreateOneForward(pluginy_klas[klasa_gracza[id]], "cod_class_disabled", FP_CELL, FP_CELL);
	ExecuteForward(forward_handle, ret, id, klasa_gracza[id]);
	DestroyForward(forward_handle);
		
	forward_handle = CreateOneForward(pluginy_klas[nowa_klasa_gracza[id]], "cod_class_enabled", FP_CELL, FP_CELL);
	ExecuteForward(forward_handle, ret, id, nowa_klasa_gracza[id]);
	DestroyForward(forward_handle);
	
	
	if(ret == 4)	
	{
		klasa_gracza[id] = 0;
		return PLUGIN_CONTINUE;
	}

	ExecuteForward(klasa_zmieniona, ret, id, klasa_gracza[id]);
	
	if(ret == 4)	
	{
		klasa_gracza[id] = 0;
		return PLUGIN_CONTINUE;
	}
	
	klasa_gracza[id] = nowa_klasa_gracza[id];
	nowa_klasa_gracza[id] = 0;
	UstawPerk(id, perk_gracza[0][id], wartosc_perku_gracza[0][id], 0, 0); 
	UstawPerk(id, perk_gracza[1][id], wartosc_perku_gracza[1][id], 0, 1);
	
	WczytajDane(id, klasa_gracza[id]);
	return PLUGIN_CONTINUE;
}

public DajBronie(id)
{
	for(new i=1; i < 32; i++)
	{
		if((1<<i) & (bronie_klasy[klasa_gracza[id]] | bonusowe_bronie_gracza[id]))
		{
			new weaponname[22];
			get_weaponname(i, weaponname, 21);
			fm_give_item(id, weaponname);
		}
	}
	
	if(gracz_ma_tarcze[id])
		fm_give_item(id, "weapon_shield");
		
	if(gracz_ma_noktowizor[id])
		cs_set_user_nvg(id, 1);
	
	new weapons[32];
	new weaponsnum;
	get_user_weapons(id, weapons, weaponsnum);
	for(new i=0; i<weaponsnum; i++)
		if(is_user_alive(id))
			if(maxAmmo[weapons[i]] > 0)
				cs_set_user_bpammo(id, weapons[i], maxAmmo[weapons[i]]);
}

public ZastosujAtrybuty(id)
{
	redukcja_obrazen_gracza[id] = 0.7*(1.0-floatpower(1.1, -0.112311341*PobierzWytrzymalosc(id, 1, 1, 1)));
	
	maksymalne_zdrowie_gracza[id] = 100.0+PobierzZdrowie(id, 1, 1, 1);
	
	szybkosc_gracza[id] = STANDARDOWA_SZYBKOSC+PobierzKondycje(id, 1, 1, 1)*1.3;
	
	set_pev(id, pev_health, maksymalne_zdrowie_gracza[id]);
}

public PoczatekRundy()	
{
	freezetime = false;
	for(new id=0;id<=32;id++)
	{
		if(!is_user_alive(id))
			continue;

		Display_Fade(id, 1<<9, 1<<9, 1<<12, 0, 255, 70, 100);
		
		set_task(0.1, "UstawSzybkosc", id+ZADANIE_USTAW_SZYBKOSC);
		
		switch(get_user_team(id))
		{
			case 1: client_cmd(id, "spk QTM_CodMod/start2");
			case 2: client_cmd(id, "spk QTM_CodMod/start");
		}
	}
}

public NowaRunda()
{
FindMaxLvl();
freezetime = true;
}

public FindMaxLvl()
{
min_lvl = 0;
new max_lvl=0;
for(new id=1;id<=32;id++)
{
  if(poziom_gracza[id] > max_lvl)
   max_lvl = poziom_gracza[id];
}
min_lvl = floatround(max_lvl*procent);
}

public Obrazenia(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_alive(idattacker))
		return HAM_IGNORED;

	if(get_user_team(this) == get_user_team(idattacker))
		return HAM_IGNORED;
		
	if(get_user_health(this) <= 1)
		return HAM_IGNORED;
	
	SetHamParamFloat(4, damage*(1.0-redukcja_obrazen_gracza[this]));
		
	return HAM_IGNORED;
}

public ObrazeniaPost(id, idinflictor, attacker, Float:damage, damagebits)
{
	if(!is_user_connected(attacker) || !klasa_gracza[attacker])
		return HAM_IGNORED;
	
	if(get_user_team(id) != get_user_team(attacker))
	{
		new doswiadczenie_za_obrazenia = get_pcvar_num(cvar_doswiadczenie_za_obrazenia);
		while(damage>20)
		{
			damage -= 20;
			doswiadczenie_gracza[attacker] += doswiadczenie_za_obrazenia;
		}
	}
	SprawdzPoziom(attacker);
	return HAM_IGNORED;
}

public SmiercGraczaPost(id, attacker, shouldgib)
{	
	if(!is_user_connected(attacker))
		return HAM_IGNORED;
		
	if(get_user_team(id) != get_user_team(attacker) && klasa_gracza[attacker])
	{
		new doswiadczenie_za_zabojstwo = get_pcvar_num(cvar_doswiadczenie_za_zabojstwo);
		new nowe_doswiadczenie = get_pcvar_num(cvar_doswiadczenie_za_zabojstwo);
		
		if(poziom_gracza[id] > poziom_gracza[attacker])
			nowe_doswiadczenie += (poziom_gracza[id]-poziom_gracza[attacker])*(doswiadczenie_za_zabojstwo/10);
			
		if(!perk_gracza[0][attacker])
		UstawPerk(attacker, -1, -1, 1, 0);
		else if(!perk_gracza[1][attacker])
		UstawPerk(attacker, -1, -1, 1, 1);
		
		doswiadczenie_gracza[attacker] += nowe_doswiadczenie;
	}
	else if(klasa_gracza[id] && id != attacker) //id != attacker zeby nie pokazywalo gdy sami sie zabijemy
	{
		new szName[64];
		get_user_name(attacker, szName, sizeof szName - 1)
		ColorChat(id, GREEN, "You have been killed by the player^x03 %s^x04 [%s - %d], Have^x03 %d^x04 HP", szName, nazwy_klas[klasa_gracza[attacker]], poziom_gracza[attacker], get_user_health(attacker));
	}
	
	SprawdzPoziom(attacker);
	
	return HAM_IGNORED;
}


public MessageHealth(msg_id, msg_dest, msg_entity)
{
	static health;
	health = get_msg_arg_int(1);
	
	if (health < 256) return;
	
	if (!(health % 256))
		set_pev(msg_entity, pev_health, pev(msg_entity, pev_health)-1);
	
	set_msg_arg_int(1, get_msg_argtype(1), 255);
}

public client_authorized(id)
{
	UsunUmiejetnosci(id);

	get_user_name(id, nazwa_gracza[id], 63);
	
	UsunZadania(id);
	
	set_task(10.0, "PokazReklame", id+ZADANIE_POKAZ_REKLAME);
}

public client_disconnect(id)
{
	ZapiszDane(id);
	UsunUmiejetnosci(id);
	UsunZadania(id);
}

public UsunUmiejetnosci(id)
{
	nowa_klasa_gracza[id] = 0;
	UstawNowaKlase(id);
	klasa_gracza[id] = 0;
	poziom_gracza[id] = 0;
	doswiadczenie_gracza[id] = 0;
	punkty_gracza[id] = 0;
	zdrowie_gracza[id] = 0;
	inteligencja_gracza[id] = 0;
	wytrzymalosc_gracza[id] = 0;
	kondycja_gracza[id] = 0;
	bonusowe_zdrowie_gracza[id] = 0;
	bonusowa_wytrzymalosc_gracza[id] = 0;
	bonusowa_inteligencja_gracza[id] = 0;
	bonusowa_kondycja_gracza[id] = 0;
	maksymalne_zdrowie_gracza[id] = 0.0;
	szybkosc_gracza[id] = 0.0;
	UstawPerk(id, 0, 0, 0, 0);
	UstawPerk(id, 0, 0, 0, 1);
}

public UsunZadania(id)
{
	remove_task(id+ZADANIE_POKAZ_INFORMACJE);
	remove_task(id+ZADANIE_POKAZ_REKLAME);	
	remove_task(id+ZADANIE_USTAW_SZYBKOSC);
}
	
public WygranaTerro()
	WygranaRunda("TERRORIST");
	
public WygranaCT()
	WygranaRunda("CT");

public WygranaRunda(const Team[])
{
	new Players[32], playerCount, id;
	get_players(Players, playerCount, "aeh", Team);
	new doswiadczenie_za_wygrana = get_pcvar_num(cvar_doswiadczenie_za_wygrana);
	
	if(get_playersnum() < 3)
		return;
		
	for (new i=0; i<playerCount; i++) 
	{
		id = Players[i];
		if(!klasa_gracza[id])
			continue;
		
		doswiadczenie_gracza[id] += doswiadczenie_za_wygrana;
		client_print(id, print_chat, "[COD:MW] You got %i experience for winning the round.", doswiadczenie_za_wygrana);
		SprawdzPoziom(id);
	}
}

public KomendaOpisPerku(id)
	OpisPerku(id, perk_gracza[0][id], wartosc_perku_gracza[0][id]);
	
public KomendaOpisPerku2(id)
	OpisPerku(id, perk_gracza[1][id], wartosc_perku_gracza[1][id]);
	
public OpisPerku(id, perk, wartosc)
{
	new opis_perku[MAX_WIELKOSC_OPISU];
	new losowa_wartosc[15];
	if(wartosc > -1)
		num_to_str(wartosc, losowa_wartosc, 14);
	else
		format(losowa_wartosc, charsmax(losowa_wartosc), "%i-%i", min_wartosci_perkow[perk], max_wartosci_perkow[perk]);
		
	format(opis_perku, charsmax(opis_perku), opisy_perkow[perk]);
	replace_all(opis_perku, charsmax(opis_perku), "LW", losowa_wartosc);
	
	client_print(id, print_chat, "Perk: %s.", nazwy_perkow[perk]);
	client_print(id, print_chat, "Opis: %s.", opis_perku);
}

public OpisPerkow(id)
{
	new menu = menu_create("Choose Perk:", "OpisPerkow_Handle");
	for(new i=1; i <= ilosc_perkow; i++)
		menu_additem(menu, nazwy_perkow[i]);
	menu_display(id, menu);
	client_cmd(id, "spk QTM_CodMod/select");
}

public OpisPerkow_Handle(id, menu, item)
{
	if(item++ == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	OpisPerku(id, item, -1);
	OpisPerkow(id);
	return PLUGIN_CONTINUE;
}


public OpisKlasy(id)
{    
    new menu = menu_create("Select class:", "OpisKlase_Frakcje");
    for(new i=1; i <= ilosc_klas; i++)
    {
        if(!is_in_previous(frakcja_klas[i],i)){
            menu_additem(menu,frakcja_klas[i],frakcja_klas[i])
        }
    }
    
    menu_setprop(menu, MPROP_EXITNAME, "Exit");
    menu_setprop(menu, MPROP_BACKNAME, "Previous page");
    menu_setprop(menu, MPROP_NEXTNAME, "Next page");
    menu_display(id, menu);
}

public OpisKlase_Frakcje(id, menu, item)
{
    if(item == MENU_EXIT){
        menu_destroy(menu);
        return PLUGIN_CONTINUE;
    }
    
    new data[65], iName[64]
    new acces, callback
    menu_item_getinfo(menu, item, acces, data,64, iName, 63, callback)
    
    new menu2 = menu_create("Select class:", "OpisKlasy_Handle");
    
    new klasa[50],szTmp[5];
    for(new i=1; i <= ilosc_klas; i++)
    {
        if(equali(data,frakcja_klas[i])){
            format(klasa, charsmax(klasa), "%s", nazwy_klas[i]);
            num_to_str(i,szTmp,charsmax(szTmp));
            menu_additem(menu2, klasa,szTmp);
        }
    }
        
    menu_setprop(menu2, MPROP_EXITNAME, "Exit");
    menu_setprop(menu2, MPROP_BACKNAME, "Previous page");
    menu_setprop(menu2, MPROP_NEXTNAME, "Next page");
    menu_display(id, menu2);
    
    client_cmd(id, "spk QTM_CodMod/select");
    
    menu_destroy(menu);
    return PLUGIN_CONTINUE;
}


public OpisKlasy_Handle(id, menu, item)
{
    client_cmd(id, "spk QTM_CodMod/select");
    
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_CONTINUE;
    }
    
    new data[65], iName[64]
    new acces, callback
    menu_item_getinfo(menu, item, acces, data,64, iName, 63, callback)
    
    item = str_to_num(data);
    
    new bronie[320];
    for(new i=1, n=1; i <= 32; i++)
    {
        if((1<<i) & bronie_klasy[item])
        {
            new weaponname[22];
            get_weaponname(i, weaponname, 21);
            replace_all(weaponname, 21, "weapon_", " ");
            if(n > 1)    
                add(bronie, charsmax(bronie), ",");
            add(bronie, charsmax(bronie), weaponname);
            n++;
        }
    }
    
    new opis[416+MAX_WIELKOSC_OPISU];
    format(opis, charsmax(opis), "\yClass: \w%s^n\yIntelligence: \w%i^n\yHealth: \w%i^n\yStrength: \w%i^n\ySpeed: \w%i^n\yWeapons:\w%s^n\yAdditional description: \w%s^n%s", nazwy_klas[item], inteligencja_klas[item], zdrowie_klas[item], wytrzymalosc_klas[item], kondycja_klas[item], bronie, opisy_klas[item], opisy_klas[item][79]);
    show_menu(id, 1023, opis);
    
    return PLUGIN_CONTINUE;
}

public WybierzKlase(id)
{
        new menu = menu_create("Choose fractions:", "WybierzKlase_Frakcje");
        for(new i=1; i <= ilosc_klas; i++)
        {
                if(!equal(frakcja_klas[i],"") && !is_in_previous(frakcja_klas[i],i)){
                        menu_additem(menu,frakcja_klas[i],frakcja_klas[i])
                }
        }
        menu_additem(menu,"UP","UP")
        
        menu_setprop(menu, MPROP_EXITNAME, "Exit");
        menu_setprop(menu, MPROP_BACKNAME, "Previous page");
        menu_setprop(menu, MPROP_NEXTNAME, "Next page");
        menu_display(id, menu);
}

public WybierzKlase_Frakcje(id, menu, item)
{
        if(item == MENU_EXIT){
                menu_destroy(menu);
                return PLUGIN_CONTINUE;
        }
        
        new data[65], iName[64] 
        new acces, callback 
        menu_item_getinfo(menu, item, acces, data,64, iName, 63, callback) 
        
        new menu2 = menu_create("Select Class:", "WybierzKlase_Handle");
        
        new klasa[50],szTmp[5];
        for(new i=1; i <= ilosc_klas; i++)
        {
				if(equali(data,frakcja_klas[i]) || (equali(data,"Pro") && JestAwansem(i))){
                        WczytajDane(id, i);
                        format(klasa, charsmax(klasa), "%s%s \yLevel: %i", JestAwansem(i)? "\r": "", nazwy_klas[i], poziom_gracza[id]);
                        num_to_str(i,szTmp,charsmax(szTmp));
                        menu_additem(menu2, klasa, szTmp);
                }
        }
        
        WczytajDane(id, klasa_gracza[id]);
        
        menu_setprop(menu2, MPROP_EXITNAME, "Exit");
        menu_setprop(menu2, MPROP_BACKNAME, "Previous page");
        menu_setprop(menu2, MPROP_NEXTNAME, "Next page");
        menu_display(id, menu2);
        
        client_cmd(id, "spk QTM_CodMod/select");
        
        menu_destroy(menu);
        return PLUGIN_CONTINUE;
}



public WybierzKlase_Handle(id, menu, item)
{
		client_cmd(id, "spk QTM_CodMod/select");
        
		if(item == MENU_EXIT)
		{
			menu_destroy(menu);
			return PLUGIN_CONTINUE;
		}       
        
		new data[65], iName[64] 
		new acces, callback 
		menu_item_getinfo(menu, item, acces, data,64, iName, 63, callback) 
        
		item = str_to_num(data);
		
		if(JestAwansem(item))
		{
			WczytajDane(id, awansuje_z[item]);
			new lvl = poziom_gracza[id], alvl = awanse[ZnajdzAwans(awansuje_z[item], item)][2];
			WczytajDane(id, klasa_gracza[id]);
			if(lvl < alvl)	
			{
				client_print(id, print_center, "Najpierw musisz zdobyc %i poziom na klasie %s!", alvl, nazwy_klas[awansuje_z[item]]);
				return PLUGIN_HANDLED;
			}
		}
        
		if(item == klasa_gracza[id] && !nowa_klasa_gracza[id])
			return PLUGIN_CONTINUE;
        
		nowa_klasa_gracza[id] = item;
        
		if(klasa_gracza[id])
			client_print(id, print_chat, "[COD:MW] Class will be changed in the next round.");
		else
		{
				UstawNowaKlase(id);
				DajBronie(id);
				ZastosujAtrybuty(id);
		}
       
		return PLUGIN_CONTINUE;
}

public PrzydzielPunkty(id)
{
	new inteligencja[65];
	new zdrowie[60];
	new wytrzymalosc[60];
	new kondycja[60];
	new tytul[25];
	new kondycjaa[60];
	new wytrzymalosca[60];
	new zdrowiea[60];
	new inteligencjaa[60];
	format(inteligencja, charsmax(inteligencja), "Intelligence: \r%i \y(Increases damage perk and skill class)", PobierzInteligencje(id, 1, 1, 1));
	format(zdrowie, charsmax(zdrowie), "Health: \r%i \y(Increases health)", PobierzZdrowie(id, 1, 1, 1));
	format(wytrzymalosc, charsmax(wytrzymalosc), "Strength: \r%i \y(Reduces damage)", PobierzWytrzymalosc(id, 1, 1, 1));
	format(kondycja, charsmax(kondycja), "Speed: \r%i \y(Increases the pace of walking)", PobierzKondycje(id, 1, 1, 1));
	format(tytul, charsmax(tytul), "Assign Points(%i):", punkty_gracza[id]);
	format(inteligencjaa, charsmax(inteligencjaa), "Add 20 point inteligencje");
	format(zdrowiea, charsmax(zdrowiea), "Add 20 point healt");
	format(wytrzymalosca, charsmax(wytrzymalosca), "Add 20 point strength");
	format(kondycjaa, charsmax(kondycjaa), "Add 20 point speed");
	new menu = menu_create(tytul, "PrzydzielPunkty_Handler");
	menu_additem(menu, inteligencja);
	menu_additem(menu, zdrowie);
	menu_additem(menu, wytrzymalosc);
	menu_additem(menu, kondycja);
	menu_additem(menu, inteligencjaa);
	menu_additem(menu, zdrowiea);
	menu_additem(menu, wytrzymalosca);
	menu_additem(menu, kondycjaa);
	menu_setprop(menu, MPROP_EXIT, 0);
	menu_display(id, menu);
}

public PrzydzielPunkty_Handler(id, menu, item)
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	if(punkty_gracza[id] < 1)
		return PLUGIN_CONTINUE;
	
	new limit_poziomu = get_pcvar_num(cvar_limit_poziomu);
	
	switch(item) 
	{ 
		case 0: 
		{	
			if(inteligencja_gracza[id] < limit_poziomu/2)
			{
				inteligencja_gracza[id]++;
				punkty_gracza[id]--;
			}
			else 
				client_print(id, print_chat, "[COD:MW]Maximum attained level of intelligence");

			
		}
		case 1: 
		{	
			if(zdrowie_gracza[id] < limit_poziomu/2)
			{
				zdrowie_gracza[id]++;
				punkty_gracza[id]--;
			}
			else 
				client_print(id, print_chat, "[COD:MW]Maximum attained level of healt");
		}
		case 2: 
		{	
			if(wytrzymalosc_gracza[id] < limit_poziomu/2)
			{
				wytrzymalosc_gracza[id]++;
				punkty_gracza[id]--;
			}
			else 
				client_print(id, print_chat, "[COD:MW]Maximum attained level of Strength");
			
		}
		case 3: 
		{	
			if(kondycja_gracza[id] < limit_poziomu/2)
			{
				kondycja_gracza[id]++;
				punkty_gracza[id]--;
			}
			else
				client_print(id, print_chat, "[COD:MW]Maximum attained level of speed");
		}
		case 4: 
		{	
			if(inteligencja_gracza[id] < limit_poziomu/2)
			{
				if(punkty_gracza[id] < 20)
				{
					client_print(id, print_chat, "[COD:MW]^x01 You have not enough points");
				}
				else
				{
					if(inteligencja_gracza[id] + 20 <= limit_poziomu/2)
					{
						inteligencja_gracza[id] += 20;
						punkty_gracza[id] -= 20;
					}
					else
					{
						new punktydododania;
						punktydododania = limit_poziomu/2 - inteligencja_gracza[id];
						inteligencja_gracza[id] += punktydododania;
						punkty_gracza[id] -= punktydododania;
					}
				}
			}
			else 
			client_print(id, print_chat, "[COD:MW]Maximum attained level of intelligence");
			
			
		}
		case 5: 
		{	
			if(zdrowie_gracza[id] < limit_poziomu/2)
			{
				if(punkty_gracza[id] < 20)
				{
					client_print(id, print_chat, "[COD:MW]^x01 You have not enough points");
				}
				else
				{
					if(zdrowie_gracza[id] + 20 <= limit_poziomu/2)
					{
						zdrowie_gracza[id] += 20;
						punkty_gracza[id] -= 20;
					}
					else
					{
						new punktydododania;
						punktydododania = limit_poziomu/2 - zdrowie_gracza[id];
						zdrowie_gracza[id] += punktydododania;
						punkty_gracza[id] -= punktydododania;
					}
				}
			}
			else 
			client_print(id, print_chat, "[COD:MW]Maximum attained level of strength");
		}
		case 6: 
		{	
			if(wytrzymalosc_gracza[id] < limit_poziomu/2)
			{
				if(punkty_gracza[id] < 20)
				{
					client_print(id, print_chat, "[COD:MW]^x01 You have not enough points");
				}
				else
				{
					if(wytrzymalosc_gracza[id] + 20 <= limit_poziomu/2)
					{
						wytrzymalosc_gracza[id] += 20;
						punkty_gracza[id] -= 20;
					}
					else
					{
						new punktydododania;
						punktydododania = limit_poziomu/2 - wytrzymalosc_gracza[id];
						wytrzymalosc_gracza[id] += punktydododania;
						punkty_gracza[id] -= punktydododania;
					}
				}
			}
			else 
			client_print(id, print_chat, "[COD:MW]Maximum attained level of Dexterity");
			
		}
		case 7: 
		{	
			if(kondycja_gracza[id] < limit_poziomu/2)
			{
				if(punkty_gracza[id] < 20)
				{
					client_print(id, print_chat, "[COD:MW]^x01 You have not enough points");
				}
				else
				{
					if(kondycja_gracza[id] + 20 <= limit_poziomu/2)
					{
						kondycja_gracza[id] += 20;
						punkty_gracza[id] -= 20;
					}
					else
					{
						new punktydododania;
						punktydododania = limit_poziomu/2 - kondycja_gracza[id];
						kondycja_gracza[id] += punktydododania;
						punkty_gracza[id] -= punktydododania;
					}
				}
			}
			else
			client_print(id, print_chat, "[COD:MW]^x01 Maximum attained level of Speed");
		}
	}
	
	
	if(punkty_gracza[id] > 0)
		PrzydzielPunkty(id);
		
	return PLUGIN_CONTINUE;
}

public KomendaResetujPunkty(id)
{	
	client_print(id, print_chat, "[COD:MW] Skills will be reset.");
	client_cmd(id, "spk QTM_CodMod/select");
	
	ResetujPunkty(id);
}

public ResetujPunkty(id)
{
	punkty_gracza[id] = (poziom_gracza[id]-1)*2;
	inteligencja_gracza[id] = 0;
	zdrowie_gracza[id] = 0;
	kondycja_gracza[id] = 0;
	wytrzymalosc_gracza[id] = 0;
	
	if(punkty_gracza[id])
		PrzydzielPunkty(id);
}

public CurWeapon(id)

{

		if(!is_user_connected(id))

				return;

	  

		new team = get_user_team(id);

	  

		if(team > 2)

				return;

	  

		new bron = read_data(2);

	  

		new bronie = (bronie_klasy[klasa_gracza[id]] | bonusowe_bronie_gracza[id] | bronie_druzyny[team] | bronie_dozwolone);

	  

		if(!(1<<bron & bronie))

		{

				new param[2];

				param[0] = id;

				param[1] = bron;

				set_task(0.1, "Strip", _, param, 2);

		}

	  

		if(cs_get_user_shield(id) && !gracz_ma_tarcze[id])

				engclient_cmd(id, "drop", "weapon_shield");	

	  

		UstawSzybkosc(id);

}

public Strip(param[2])

{

if(is_user_alive(param[0]) && ( 1 <= param[1] <= 30) )

{

  get_weaponname(param[1], weaponname, 21);

  ham_strip_weapon(param[0], weaponname);

}

}

public EmitSound(id, iChannel, szSound[], Float:fVol, Float:fAttn, iFlags, iPitch ) 
{
	if(!is_user_alive(id))
		return FMRES_IGNORED;
		
	if(equal(szSound, "common/wpn_denyselect.wav"))
	{
		new forward_handle = CreateOneForward(pluginy_klas[klasa_gracza[id]], "cod_class_skill_used", FP_CELL);
		ExecuteForward(forward_handle, id, id);
		DestroyForward(forward_handle);
		return FMRES_SUPERCEDE;
	}

	if(equal(szSound, "items/ammopickup2.wav"))
	{
		cs_set_user_armor(id, 0, CS_ARMOR_NONE);
		return FMRES_SUPERCEDE;
	}
	
	if(equal(szSound, "items/equip_nvg.wav") && !gracz_ma_noktowizor[id])
	{
		cs_set_user_nvg(id, 0);
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

public UzyjPerku(id)
	return UzyjPerki(id, 0);

public UzyjPerku2(id)
	return UzyjPerki(id, 1);

public UzyjPerki(id, lp)
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED;
	
	new forward_handle = forward_handle = CreateOneForward(pluginy_perkow[perk_gracza[lp][id]], "cod_perk_used", FP_CELL);
	ExecuteForward(forward_handle, id, id);
	DestroyForward(forward_handle);
	return PLUGIN_HANDLED;
}

public ZapiszDane(id)
{
	if(!klasa_gracza[id])
		return PLUGIN_CONTINUE;
		
	new vaultkey[128],vaultdata[256], identyfikator[64];
	format(vaultdata, charsmax(vaultdata),"#%i#%i#%i#%i#%i#%i", doswiadczenie_gracza[id], poziom_gracza[id], inteligencja_gracza[id], zdrowie_gracza[id], wytrzymalosc_gracza[id], kondycja_gracza[id]);
	
	new typ_zapisu = get_pcvar_num(cvar_typ_zapisu);
	
	switch(typ_zapisu)
	{
		case 1: copy(identyfikator, charsmax(identyfikator), nazwa_gracza[id]);
		case 2: get_user_authid(id, identyfikator, charsmax(identyfikator));
		case 3: get_user_ip(id, identyfikator, charsmax(identyfikator));
	}
		
	format(vaultkey, charsmax(vaultkey),"%s-%s-%i-cod", identyfikator, nazwy_klas[klasa_gracza[id]], typ_zapisu);
	nvault_set(vault,vaultkey,vaultdata);
	
	return PLUGIN_CONTINUE;
}

public WczytajDane(id, klasa)
{
	new vaultkey[128],vaultdata[256], identyfikator[64];
	
	new typ_zapisu = get_pcvar_num(cvar_typ_zapisu);
	
	switch(typ_zapisu)
	{
		case 1: copy(identyfikator, charsmax(identyfikator), nazwa_gracza[id]);
		case 2: get_user_authid(id, identyfikator, charsmax(identyfikator));
		case 3: get_user_ip(id, identyfikator, charsmax(identyfikator));
	}
	
	format(vaultkey, charsmax(vaultkey),"%s-%s-%i-cod", identyfikator, nazwy_klas[klasa], typ_zapisu);
	

	if(!nvault_get(vault,vaultkey,vaultdata,255)) // Jezeli nie ma danych gracza sprawdza stary zapis. 
	{
		format(vaultkey, charsmax(vaultkey), "%s-%i-cod", nazwa_gracza[id], klasa);
		nvault_get(vault,vaultkey,vaultdata,255);
	}

	replace_all(vaultdata, 255, "#", " ");
	 
	new danegracza[6][32];
	
	parse(vaultdata, danegracza[0], 31, danegracza[1], 31, danegracza[2], 31, danegracza[3], 31, danegracza[4], 31, danegracza[5], 31);
	
	doswiadczenie_gracza[id] = str_to_num(danegracza[0]);
	poziom_gracza[id] = str_to_num(danegracza[1])>0?str_to_num(danegracza[1]):1;
	inteligencja_gracza[id] = str_to_num(danegracza[2]);
	zdrowie_gracza[id] = str_to_num(danegracza[3]);
	wytrzymalosc_gracza[id] = str_to_num(danegracza[4]);
	kondycja_gracza[id] = str_to_num(danegracza[5]);
	punkty_gracza[id] = (poziom_gracza[id]-1)*2-inteligencja_gracza[id]-zdrowie_gracza[id]-wytrzymalosc_gracza[id]-kondycja_gracza[id];
	
	return PLUGIN_CONTINUE;
} 


public WyrzucPerk(id)
	DropPerka(id, 0)

public WyrzucPerk2(id)
	DropPerka(id, 1)

public DropPerka(id, lp)
{
	if(perk_gracza[lp][id])
	{
		client_print(id, print_chat, "[COD:MW] Drop %s.", nazwy_perkow[perk_gracza[lp][id]]);
		UstawPerk(id, 0, 0, 0, lp);
	}
	else
		client_print(id, print_chat, "[COD:MW] You have no perk.");
}

public SprawdzPoziom(id)
{	
	if(!is_user_connected(id))
		return;
		
	new limit_poziomu = get_pcvar_num(cvar_limit_poziomu);
	
	new bool:zdobyl_poziom = false, bool:stracil_poziom = false;
	
	while(doswiadczenie_gracza[id] >= PobierzDoswiadczeniePoziomu(poziom_gracza[id]) && poziom_gracza[id] < limit_poziomu)
	{
		poziom_gracza[id]++;
		punkty_gracza[id] = (poziom_gracza[id]-1)*2-inteligencja_gracza[id]-zdrowie_gracza[id]-wytrzymalosc_gracza[id]-kondycja_gracza[id];
		zdobyl_poziom = true;
	}
		
	while(doswiadczenie_gracza[id] < PobierzDoswiadczeniePoziomu(poziom_gracza[id]-1))
	{
		poziom_gracza[id]--;
		stracil_poziom = true;
	}
		
	if(poziom_gracza[id] > limit_poziomu)
	{
		poziom_gracza[id] = limit_poziomu;
		ResetujPunkty(id);
	}
	
	if(stracil_poziom)
	{
		ResetujPunkty(id);
		set_hudmessage(212, 255, 85, 0.31, 0.32, 0, 6.0, 5.0);
		ShowSyncHudMsg(id, SyncHudObj2,"Fallen to %i level!", poziom_gracza[id]);
	}
	else if(zdobyl_poziom)
	{
		punkty_gracza[id] = (poziom_gracza[id]-1)*2-inteligencja_gracza[id]-zdrowie_gracza[id]-wytrzymalosc_gracza[id]-kondycja_gracza[id];
		set_hudmessage(212, 255, 85, 0.31, 0.32, 0, 6.0, 5.0);
		ShowSyncHudMsg(id, SyncHudObj2,"Got promoted to %i level!", poziom_gracza[id]);
		client_cmd(id, "spk QTM_CodMod/levelup");
	}
		
			
	ZapiszDane(id);
	
	if(awansuje_do[klasa_gracza[id]])
	{
		if(poziom_gracza[id] >= awanse[ZnajdzAwans(klasa_gracza[id], awansuje_do[klasa_gracza[id]])][2])
		{
			set_hudmessage(212, 255, 85, 0.31, 0.32, 0, 6.0, 5.0);
			ShowSyncHudMsg(id, SyncHudObj2,"Osiagajac poziom %i, awansowales do klasy %s!", poziom_gracza[id], nazwy_klas[awansuje_do[klasa_gracza[id]]]);
			nowa_klasa_gracza[id] = awansuje_do[klasa_gracza[id]];
			UstawNowaKlase(id);
			DajBronie(id);
			ZastosujAtrybuty(id);
			ZapiszDane(id);
		}
	}
}


public PokazInformacje(id) 
{
	id -= ZADANIE_POKAZ_INFORMACJE;
	
	if(!is_user_connected(id))
	{
		remove_task(id+ZADANIE_POKAZ_INFORMACJE);
		return PLUGIN_CONTINUE;
	}
	
	if(!is_user_alive(id))
	{
		new target = pev(id, pev_iuser2);
		
		if(!target)
			return PLUGIN_CONTINUE;
		
		new ileMa = doswiadczenie_gracza[target],ilePotrzeba = PobierzDoswiadczeniePoziomu(poziom_gracza[target]),ilePotrzebaBylo = PobierzDoswiadczeniePoziomu(poziom_gracza[target]-1)
		new Float:fProcent = 0.0;
		fProcent = (float((ileMa - ilePotrzebaBylo)) / float((ilePotrzeba - ilePotrzebaBylo))) * 100.0;
		
		set_hudmessage(255, 255, 255, 0.02, 0.14, 0, 1.0, 1.0, 0.1, 0.1);
		ShowSyncHudMsg(id, SyncHudObj, "INFO PLAYER:^n|Class : %s^n|Exp : %0.0f%%^n|Level : %i^n", nazwy_klas[klasa_gracza[target]], fProcent, poziom_gracza[target], nazwy_perkow[perk_gracza[0][target]], nazwy_perkow[perk_gracza[1][target]], inteligencja_gracza[target], kondycja_gracza[target]);//
		return PLUGIN_CONTINUE;
	}
	new hp = get_user_health(id);
	new ileMa = doswiadczenie_gracza[id],ilePotrzeba = PobierzDoswiadczeniePoziomu(poziom_gracza[id]),ilePotrzebaBylo = PobierzDoswiadczeniePoziomu(poziom_gracza[id]-1)
	new Float:fProcent = 0.0;
	fProcent = (float((ileMa - ilePotrzebaBylo)) / float((ilePotrzeba - ilePotrzebaBylo))) * 100.0;
	
	set_hudmessage(255, 255, 255, 0.02, 0.23, 0, 0.0, 0.3, 0.0, 0.0);
	ShowSyncHudMsg(id, SyncHudObj, "[Class : %s]^n[Exp : %0.0f%%]^n[Lv : %i]^n[Perk : %s]^n[Perk2 : %s]^n[KS : x%d]^n[HP : %d]", nazwy_klas[klasa_gracza[id]], fProcent, poziom_gracza[id], nazwy_perkow[perk_gracza[0][id]], nazwy_perkow[perk_gracza[1][id]], licznik_zabiccod[id], hp);
	
	return PLUGIN_CONTINUE;
}

public PokazReklame(id)
{
	id-=ZADANIE_POKAZ_REKLAME;
	client_print(id, print_chat, "[COD:MW] Welcome to the COD:MW Rajagame");
	client_print(id, print_chat, "[COD:MW] For information about commands type /help.");
}

public Pomoc(id)
	show_menu(id, 1023, "\y/reset\w -  resets the statistics^n\y/stats\w - displays stats^n\y/Class\w - selection of classes^n\y/drop\w - throws perk^n\y/perk\w - shows a description of your Perk ^n\y/classinfo\w - shows the class descriptions^n\y+use\w - use class skills^n\yradio3\w (typically C) or \yuseperk\w -  use of perk^n\y/ks\w -  open menu killstreak^n\y/perk2\w -  shows a description of your Perk^n\y/drop2\w -  throws perk2^n\y/radio2/X\w -  using perk2", -1, "Pomoc");

public UstawSzybkosc(id)
{
	id -= id>32? ZADANIE_USTAW_SZYBKOSC: 0;
	
	if(klasa_gracza[id] && !freezetime)
		set_pev(id, pev_maxspeed, szybkosc_gracza[id]);
}

public DotykBroni(weapon, id)
{
	if(get_pcvar_num(cvar_blokada_broni) < 1)
		return HAM_IGNORED;
	
	if(!is_user_connected(id))
		return HAM_IGNORED;
		
	new model[23];
	pev(weapon, pev_model, model, 22);
	if (pev(weapon, pev_owner) == id || containi(model, "w_backpack") != -1)
		return HAM_IGNORED;
	return HAM_SUPERCEDE;
}

public DotykTarczy(weapon, id)
{
	if(get_pcvar_num(cvar_blokada_broni) < 1)
		return HAM_IGNORED;
	
	if(!is_user_connected(id))
		return HAM_IGNORED;
		
	if(gracz_ma_tarcze[id])
		return HAM_IGNORED;
		
	return HAM_SUPERCEDE;
}
	
public UstawPerk(id, perk, wartosc, pokaz_info, lp)
{
	if(!ilosc_perkow)
		return PLUGIN_CONTINUE;
	
	static obroty[33];
	
	if(obroty[id]++ >= 5)
	{
		obroty[id] = 0;
		UstawPerk(id, 0, 0, 0, lp);
		return PLUGIN_CONTINUE;
	}
	
	perk = (perk == -1)? random_num(1, ilosc_perkow): perk;
	if(perk == perk_gracza[!lp][id] && perk)
	{
		UstawPerk(id, perk, wartosc, pokaz_info, lp);
		return PLUGIN_CONTINUE;
	}
	wartosc = (wartosc == -1 || min_wartosci_perkow[perk] > wartosc ||  wartosc > max_wartosci_perkow[perk])? random_num(min_wartosci_perkow[perk], max_wartosci_perkow[perk]): wartosc;
	
	new ret;
	
	new forward_handle = CreateOneForward(pluginy_perkow[perk_gracza[lp][id]], "cod_perk_disabled", FP_CELL, FP_CELL);
	ExecuteForward(forward_handle, ret, id, perk);
	DestroyForward(forward_handle);
	
	perk_gracza[lp][id] = 0;
	
	forward_handle = CreateOneForward(pluginy_perkow[perk], "cod_perk_enabled", FP_CELL, FP_CELL, FP_CELL);
	ExecuteForward(forward_handle, ret, id, wartosc, perk);
	DestroyForward(forward_handle);
	
	if(ret == 4)
	{
		UstawPerk(id, -1, -1, 1, lp);
		return PLUGIN_CONTINUE;
	}
	
	ExecuteForward( perk_zmieniony, ret, id, perk, wartosc, lp);
	
	if(ret == 4)
	{
		UstawPerk(id, -1, -1, 1, lp);
		return PLUGIN_CONTINUE;
	}
	
	obroty[id] = 0;
	if(pokaz_info &&  perk)
		client_print(id, print_chat, "[COD:MW] You Got %s.", nazwy_perkow[perk]);
	
	perk_gracza[lp][id] = perk;	
	wartosc_perku_gracza[lp][id] = wartosc;
	return PLUGIN_CONTINUE;
}

public UstawDoswiadczenie(id, wartosc)
{
	doswiadczenie_gracza[id] = wartosc;
	SprawdzPoziom(id);
}

public UstawKlase(id, klasa, zmien)
{
	nowa_klasa_gracza[id] = klasa;
	if(zmien)
	{
		UstawNowaKlase(id);
		DajBronie(id);
		ZastosujAtrybuty(id);
	}
}

public UstawTarcze(id, wartosc)
{
	if((gracz_ma_tarcze[id] = (wartosc > 0)))
		fm_give_item(id, "weapon_shield");
}

public UstawNoktowizor(id, wartosc)
{
	if((gracz_ma_noktowizor[id] = (wartosc > 0)))
		cs_set_user_nvg(id, 1);
}

public DajBron(id, bron)
{
	bonusowe_bronie_gracza[id] |= (1<<bron);
	new weaponname[22];
	get_weaponname(bron, weaponname, 21);
	return fm_give_item(id, weaponname);
}

public WezBron(id, bron)
{
	bonusowe_bronie_gracza[id] &= ~(1<<bron);
	
	if((1<<bron) & (bronie_dozwolone | bronie_klasy[get_user_team(id)] | bronie_klasy[klasa_gracza[id]])) 
		return;
	
	new weaponname[22];
	get_weaponname(bron, weaponname, 21);
	if(!((1<<bron) & (1<<CSW_HEGRENADE | 1<<CSW_SMOKEGRENADE | 1<<CSW_FLASHBANG)))
		engclient_cmd(id, "drop", weaponname);
}

public UstawBonusoweZdrowie(id, wartosc)
	bonusowe_zdrowie_gracza[id] = wartosc;


public UstawBonusowaInteligencje(id, wartosc)
	bonusowa_inteligencja_gracza[id] = wartosc;

	
public UstawBonusowaKondycje(id, wartosc)
	bonusowa_kondycja_gracza[id] = wartosc;

	
public UstawBonusowaWytrzymalosc(id, wartosc)
	bonusowa_wytrzymalosc_gracza[id] = wartosc;

public PrzydzielZdrowie(id, wartosc)
{
	new max_statystyka = get_pcvar_num(cvar_limit_poziomu)/2;
	wartosc = min(min(punkty_gracza[id], wartosc), max_statystyka-zdrowie_gracza[id]);
	
	punkty_gracza[id] -= wartosc;
	zdrowie_gracza[id] += wartosc;
}

public PrzydzielInteligencje(id, wartosc)
{
	new max_statystyka = get_pcvar_num(cvar_limit_poziomu)/2;
	wartosc = min(min(punkty_gracza[id], wartosc), max_statystyka-inteligencja_gracza[id]);
	
	punkty_gracza[id] -= wartosc;
	inteligencja_gracza[id] += wartosc;
}

public PrzydzielKondycje(id, wartosc)
{
	new max_statystyka = get_pcvar_num(cvar_limit_poziomu)/2;
	wartosc = min(min(punkty_gracza[id], wartosc), max_statystyka-kondycja_gracza[id]);
	
	punkty_gracza[id] -= wartosc;
	kondycja_gracza[id] += wartosc;
}

public PrzydzielWytrzymalosc(id, wartosc)
{
	new max_statystyka = get_pcvar_num(cvar_limit_poziomu)/2;
	wartosc = min(min(punkty_gracza[id], wartosc), max_statystyka-wytrzymalosc_gracza[id]);
	
	punkty_gracza[id] -= wartosc;
	wytrzymalosc_gracza[id] += wartosc;
}

public PobierzPerk(plugin, params)
{
	if(params != 3)
		return 0;
		
	new id = get_param(1), lp = get_param(3);
	set_param_byref(2, wartosc_perku_gracza[lp][id]);
	return perk_gracza[lp][id];
}
	
public PobierzIloscPerkow()
	return ilosc_perkow;
	
	
public PobierzNazwePerku(perk, Return[], len)
{
	if(perk <= ilosc_perkow)
	{
		param_convert(2);
		copy(Return, len, nazwy_perkow[perk]);
	}
}
		
public PobierzOpisPerku(perk, Return[], len)
{
	if(perk <= ilosc_perkow)
	{
		param_convert(2);
		copy(Return, len, opisy_perkow[perk]);
	}
}
	
public PobierzPerkPrzezNazwe(const nazwa[])
{
	param_convert(1);
	for(new i=1; i <= ilosc_perkow; i++)
		if(equal(nazwa, nazwy_perkow[i]))
			return i;
	return 0;
}

public PobierzDoswiadczeniePoziomu(poziom)
	return power(poziom, 2)*get_pcvar_num(cvar_proporcja_poziomu);

public PobierzDoswiadczenie(id)
	return doswiadczenie_gracza[id];
	
public PobierzPunkty(id)
	return punkty_gracza[id];
	
public PobierzPoziom(id)
	return poziom_gracza[id];

public PobierzZdrowie(id, zdrowie_zdobyte, zdrowie_klasy, zdrowie_bonusowe)
{
	new zdrowie;
	
	if(zdrowie_zdobyte)
		zdrowie += zdrowie_gracza[id];
	if(zdrowie_bonusowe)
		zdrowie += bonusowe_zdrowie_gracza[id];
	if(zdrowie_klasy)
		zdrowie += zdrowie_klas[klasa_gracza[id]];
	
	return zdrowie;
}

public PobierzInteligencje(id, inteligencja_zdobyta, inteligencja_klasy, inteligencja_bonusowa)
{
	new inteligencja;
	
	if(inteligencja_zdobyta)
		inteligencja += inteligencja_gracza[id];
	if(inteligencja_bonusowa)
		inteligencja += bonusowa_inteligencja_gracza[id];
	if(inteligencja_klasy)
		inteligencja += inteligencja_klas[klasa_gracza[id]];
	
	return inteligencja;
}

public PobierzKondycje(id, kondycja_zdobyta, kondycja_klasy, kondycja_bonusowa)
{
	new kondycja;
	
	if(kondycja_zdobyta)
		kondycja += kondycja_gracza[id];
	if(kondycja_bonusowa)
		kondycja += bonusowa_kondycja_gracza[id];
	if(kondycja_klasy)
		kondycja += kondycja_klas[klasa_gracza[id]];
	
	return kondycja;
}

public PobierzWytrzymalosc(id, wytrzymalosc_zdobyta, wytrzymalosc_klasy, wytrzymalosc_bonusowa)
{
	new wytrzymalosc;
	
	if(wytrzymalosc_zdobyta)
		wytrzymalosc += wytrzymalosc_gracza[id];
	if(wytrzymalosc_bonusowa)
		wytrzymalosc += bonusowa_wytrzymalosc_gracza[id];
	if(wytrzymalosc_klasy)
		wytrzymalosc += wytrzymalosc_klas[klasa_gracza[id]];
	
	return wytrzymalosc;
}

public PobierzKlase(id)
	return klasa_gracza[id];
	
public PobierzIloscKlas()
	return ilosc_klas;
	
public PobierzNazweKlasy(klasa, Return[], len)
{
	if(klasa <= ilosc_klas)
	{
		param_convert(2);
		copy(Return, len, nazwy_klas[klasa]);
	}
}

public PobierzOpisKlasy(klasa, Return[], len)
{
	if(klasa <= ilosc_klas)
	{
		param_convert(2);
		copy(Return, len, opisy_klas[klasa]);
	}
}

public PobierzKlasePrzezNazwe(const nazwa[])
{
	param_convert(1);
	for(new i=1; i <= ilosc_klas; i++)
		if(equal(nazwa, nazwy_klas[i]))
			return i;
	return 0;
}

public PobierzZdrowieKlasy(klasa)
{
	if(klasa <= ilosc_klas)
		return zdrowie_klas[klasa];
	return -1;
}

public PobierzInteligencjeKlasy(klasa)
{
	if(klasa <= ilosc_klas)
		return inteligencja_klas[klasa];
	return -1;
}

public PobierzKondycjeKlasy(klasa)
{
	if(klasa <= ilosc_klas)
		return kondycja_klas[klasa];
	return -1;
}

public PobierzWytrzymaloscKlasy(klasa)
{
	if(klasa <= ilosc_klas)
		return wytrzymalosc_klas[klasa];
	return -1;
}

public ZadajObrazenia(atakujacy, ofiara, Float:obrazenia, Float:czynnik_inteligencji, byt_uszkadzajacy, dodatkowe_flagi)
	ExecuteHam(Ham_TakeDamage, ofiara, byt_uszkadzajacy, atakujacy, obrazenia+PobierzInteligencje(atakujacy, 1, 1, 1)*czynnik_inteligencji, (1<<31) | dodatkowe_flagi);
	
public ZarejestrujPerk(plugin, params)
{
	if(params != 4)
		return PLUGIN_CONTINUE;
		
	if(++ilosc_perkow > MAX_ILOSC_PERKOW)
		return -1;
		
	pluginy_perkow[ilosc_perkow] = plugin;
	get_string(1, nazwy_perkow[ilosc_perkow], MAX_WIELKOSC_NAZWY);
	get_string(2, opisy_perkow[ilosc_perkow], MAX_WIELKOSC_OPISU);
	min_wartosci_perkow[ilosc_perkow] = get_param(3);
	max_wartosci_perkow[ilosc_perkow] = get_param(4);
	
	return ilosc_perkow;
}

public ZarejestrujKlase(plugin, params)
{
	if(params != 7)
		return PLUGIN_CONTINUE;
		
	if(++ilosc_klas > MAX_ILOSC_KLAS)
		return -1;

	pluginy_klas[ilosc_klas] = plugin;
	
	get_string(1, nazwy_klas[ilosc_klas], MAX_WIELKOSC_NAZWY);
	get_string(2, opisy_klas[ilosc_klas], MAX_WIELKOSC_OPISU);
	
	bronie_klasy[ilosc_klas] = get_param(3);
	zdrowie_klas[ilosc_klas] = get_param(4);
	kondycja_klas[ilosc_klas] = get_param(5);
	inteligencja_klas[ilosc_klas] = get_param(6);
	wytrzymalosc_klas[ilosc_klas] = get_param(7);
	for(new i=0;i<klasid;i++){
		if(equali(nazwy_klas[ilosc_klas],nazwa_klasy[i])){
			frakcja_klas[ilosc_klas] = nazwa_frakcji[i];
		}
	}
	return ilosc_klas;
}

public SmiercGraczaKillCod(id)
{
     new zabojcacod = read_data(1)
     new ofiaracod = read_data(2)

     licznik_smiercicod[zabojcacod] = 0;
     licznik_zabiccod[zabojcacod]++;

     if(!is_user_alive(id))
     {
          licznik_zabiccod[ofiaracod] = 0;
          licznik_smiercicod[ofiaracod]++;
     }
}

stock ham_strip_weapon(id, weapon[])

{

if(!equal(weapon, "weapon_", 7) ) return 0

new wId = get_weaponid(weapon)

if(!wId) return 0

new wEnt

while( (wEnt = engfunc(EngFunc_FindEntityByString,wEnt,"classname", weapon) ) && pev(wEnt, pev_owner) != id) {}

if(!wEnt) return 0



if(get_user_weapon(id) == wId) ExecuteHamB(Ham_Weapon_RetireWeapon, wEnt)



if(!ExecuteHamB(Ham_RemovePlayerItem, id, wEnt)) return 0

ExecuteHamB(Ham_Item_Kill ,wEnt)



set_pev(id, pev_weapons, pev(id, pev_weapons) & ~(1<<wId) )

return 1

}

stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha)
{
	message_begin( MSG_ONE, MsgScreenfade,{0,0,0},id );
	write_short( duration );	// Duration of fadeout
	write_short( holdtime );	// Hold time of color
	write_short( fadetype );	// Fade type
	write_byte ( red );		// Red
	write_byte ( green );		// Green
	write_byte ( blue );		// Blue
	write_byte ( alpha );	// Alpha
	message_end();
}

public BlokujKomende()
	return PLUGIN_HANDLED;
	
public ZarejestrujAwans(plugin, params)
{
	if(params != 9)
		return PLUGIN_CONTINUE;
	  
	if(++ilosc_klas > MAX_ILOSC_KLAS)
		return -1;
 
	pluginy_klas[ilosc_klas] = plugin;
  
	new awans_z = get_param(1);
	awansuje_do[awans_z] = ilosc_klas;
	awansuje_z[ilosc_klas] = awans_z;
	ilosc_awansow++;
	awanse[ilosc_awansow][1] = ilosc_klas;
	awanse[ilosc_awansow][0] = awans_z;
	awanse[ilosc_awansow][2] = get_param(2);
	get_string(3, nazwy_klas[ilosc_klas], MAX_WIELKOSC_NAZWY);
	get_string(4, opisy_klas[ilosc_klas], MAX_WIELKOSC_OPISU);
  
	bronie_klasy[ilosc_klas] = get_param(5);
	zdrowie_klas[ilosc_klas] = get_param(6);
	kondycja_klas[ilosc_klas] = get_param(7);
	inteligencja_klas[ilosc_klas] = get_param(8);
	wytrzymalosc_klas[ilosc_klas] = get_param(9);
  
	return ilosc_klas;
}
 
public ZnajdzAwans(Z, Do)
{
	new Return;
	for(new i=1; i<=ilosc_awansow; i++)
	{
		if(awanse[i][0] == Z && awanse[i][1] == Do)
		{
			Return = i;
			break;
		}
	}
	return Return;
}
 
public JestAwansem(klasa)
{
	new bool:jest;
	for(new i=1; i<=ilosc_awansow; i++)
	{
		if(awanse[i][1] == klasa)
		{
			jest = true;
			break;
		}
	}
	return jest;
}	
	
stock fm_give_item(index, const item[]) {
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0;

	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item));
	if (!pev_valid(ent))
		return 0;

	new Float:origin[3];
	pev(index, pev_origin, origin);
	set_pev(ent, pev_origin, origin);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);

	new save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, index);
	if (pev(ent, pev_solid) != save)
		return ent;

	engfunc(EngFunc_RemoveEntity, ent);

	return -1;
}

public bool:is_in_previous(frakcja[],from){
        for(new i = from - 1;i>=1;i--){
                if(equali(frakcja_klas[i],frakcja)){
                        return true;
                }
        }
        return false;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/