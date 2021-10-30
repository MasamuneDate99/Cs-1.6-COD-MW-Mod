new g_szTeamName[4][0] =
{
	{
		85, ...
	},
	{
		84, ...
	},
	{
		67, ...
	},
	{
		83, ...
	}
};
new maxAmmo[31] =
{
	0, 52, 0, 90, 1, 31, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120, 30, 120, 200, 31, 90, 120, 90, 2, 35, 90, 90, 0, 100
};
new co_ile[5] =
{
	1, 4, 8, 16, 24
};
new szybkosc_rozdania[33];
new MsgScreenfade;
new vault;
new g_szModName[32];
new SyncHudObj;
new SyncHudObj2;
new cvar_doswiadczenie_za_zabojstwo;
new cvar_doswiadczenie_za_obrazenia;
new cvar_doswiadczenie_za_wygrana;
new cvar_typ_zapisu;
new cvar_limit_poziomu;
new cvar_proporcja_poziomu;
new cvar_blokada_broni;
new perk_zmieniony;
new klasa_zmieniona;
new frakcja_klas[101][65];
new nazwy_perkow[121][33];
new opisy_perkow[121][257];
new max_wartosci_perkow[121];
new min_wartosci_perkow[121];
new pluginy_perkow[121];
new ilosc_perkow;
new nazwa_gracza[33][64];
new klasa_gracza[33];
new nowa_klasa_gracza[33];
new poziom_gracza[33];
new doswiadczenie_gracza[33];
new perk_gracza[2][33];
new wartosc_perku_gracza[2][33];
new Float:maksymalne_zdrowie_gracza[33];
new Float:szybkosc_gracza[33];
new Float:redukcja_obrazen_gracza[33];
new punkty_gracza[33];
new zdrowie_gracza[33];
new inteligencja_gracza[33];
new wytrzymalosc_gracza[33];
new kondycja_gracza[33];
new bool:gracz_ma_tarcze[33];
new bool:gracz_ma_noktowizor[33];
new bonusowe_bronie_gracza[33];
new bonusowe_zdrowie_gracza[33];
new bonusowa_inteligencja_gracza[33];
new bonusowa_wytrzymalosc_gracza[33];
new bonusowa_kondycja_gracza[33];
new bronie_klasy[101];
new zdrowie_klas[101];
new kondycja_klas[101];
new inteligencja_klas[101];
new wytrzymalosc_klas[101];
new nazwy_klas[101][33];
new opisy_klas[101][257];
new pluginy_klas[101];
new ilosc_klas;
new bronie_druzyny[3];
new bronie_dozwolone = 536870976;
new bool:freezetime = 1;
new weaponname[22];
new licznik_zabiccod[33];
new licznik_smiercicod[33];
new min_lvl;
new Float:procent = 1025758986;
new nazwa_klasy[101][64];
new nazwa_frakcji[101][64];
new klasid;
Float:operator*(Float:,_:)(Float:oper1, oper2)
{
	return floatmul(oper1, float(oper2));
}

Float:operator+(Float:,_:)(Float:oper1, oper2)
{
	return floatadd(oper1, float(oper2));
}

Float:operator-(Float:,_:)(Float:oper1, oper2)
{
	return floatsub(oper1, float(oper2));
}

bool:operator>(Float:,Float:)(Float:oper1, Float:oper2)
{
	return 0 < floatcmp(oper1, oper2);
}

bool:operator>(Float:,_:)(Float:oper1, oper2)
{
	return 0 < floatcmp(oper1, float(oper2));
}

split(szInput[], szLeft[], pL_Max, szRight[], pR_Max, szDelim[])
{
	new iEnd = contain(szInput, szDelim);
	new iStart = strlen(szDelim) + iEnd;
	if (iEnd == -1)
	{
		iStart = copy(szLeft, pL_Max, szInput);
		copy(szRight, pR_Max, szInput[iStart]);
		return 0;
	}
	if (pL_Max >= iEnd)
	{
		copy(szLeft, iEnd, szInput);
	}
	else
	{
		copy(szLeft, pL_Max, szInput);
	}
	copy(szRight, pR_Max, szInput[iStart]);
	return 0;
}

replace_all(string[], len, what[], with[])
{
	new pos;
	if ((pos = contain(string, what)) == -1)
	{
		return 0;
	}
	new total;
	new with_len = strlen(with);
	new diff = strlen(what) - with_len;
	new total_len = strlen(string);
	new temp_pos;
	while (replace(string[pos], len - pos, what, with))
	{
		total++;
		pos = with_len + pos;
		total_len -= diff;
		if (!(pos >= total_len))
		{
			temp_pos = contain(string[pos], what);
			if (!(temp_pos == -1))
			{
				pos = temp_pos + pos;
			}
			return total;
		}
		return total;
	}
	return total;
}

get_configsdir(name[], len)
{
	return get_localinfo("amxx_configsdir", name, len);
}

public __fatal_ham_error(Ham:id, HamError:err, reason[])
{
	new func = get_func_id("HamFilter", -1);
	new bool:fail = 1;
	new var1;
	if (func != -1 && callfunc_begin_i(func, -1) == 1)
	{
		callfunc_push_int(id);
		callfunc_push_int(err);
		callfunc_push_str(reason, "amxx_configsdir");
		if (callfunc_end() == 1)
		{
			fail = false;
		}
	}
	if (fail)
	{
		set_fail_state(reason);
	}
	return 0;
}

client_print_color(id, iColor, szMsg[])
{
	new var1;
	if (id && !is_user_connected(id))
	{
		return 0;
	}
	if (iColor > 3)
	{
		iColor = 0;
	}
	new szMessage[192];
	if (iColor)
	{
		szMessage[0] = 3;
	}
	else
	{
		szMessage[0] = 4;
	}
	new iParams = numargs();
	if (id)
	{
		if (iParams == 3)
		{
			copy(szMessage[1], 190, szMsg);
		}
		else
		{
			vformat(szMessage[1], 190, szMsg, 4);
		}
		if (iColor)
		{
			new szTeam[11];
			get_user_team(id, szTeam, 10);
			Send_TeamInfo(id, id, g_szTeamName[iColor]);
			Send_SayText(id, id, szMessage);
			Send_TeamInfo(id, id, szTeam);
		}
		else
		{
			Send_SayText(id, id, szMessage);
		}
	}
	else
	{
		new iPlayers[32];
		new iNum;
		get_players(iPlayers, iNum, "ch", 268);
		if (!iNum)
		{
			return 0;
		}
		new iFool = iPlayers[0];
		new iMlNumber;
		new i;
		new j;
		new Array:aStoreML = ArrayCreate(1, 32);
		if (iParams >= 5)
		{
			j = 4;
			while (j < iParams)
			{
				if (getarg(j, "amxx_configsdir") == -1)
				{
					i = 0;
					do {
						i++;
					} while ((szMessage[i] = getarg(j + 1, i)));
					if (GetLangTransKey(szMessage) != -1)
					{
						j++;
						ArrayPushCell(aStoreML, j);
						iMlNumber++;
					}
				}
				j++;
			}
		}
		if (!iMlNumber)
		{
			if (iParams == 3)
			{
				copy(szMessage[1], 190, szMsg);
			}
			else
			{
				vformat(szMessage[1], 190, szMsg, 4);
			}
			if (iColor)
			{
				new szTeam[11];
				get_user_team(iFool, szTeam, 10);
				Send_TeamInfo(0, iFool, g_szTeamName[iColor]);
				Send_SayText(0, iFool, szMessage);
				Send_TeamInfo(0, iFool, szTeam);
			}
			else
			{
				Send_SayText(0, iFool, szMessage);
			}
		}
		else
		{
			new szTeam[11];
			new szFakeTeam[10];
			if (iColor)
			{
				get_user_team(iFool, szTeam, 10);
				copy(szFakeTeam, 9, g_szTeamName[iColor]);
			}
			i = 0;
			while (i < iNum)
			{
				id = iPlayers[i];
				j = 0;
				while (j < iMlNumber)
				{
					setarg(ArrayGetCell(aStoreML, j), "amxx_configsdir", id);
					j++;
				}
				vformat(szMessage[1], 190, szMsg, 4);
				if (iColor)
				{
					Send_TeamInfo(id, iFool, szFakeTeam);
					Send_SayText(id, iFool, szMessage);
					Send_TeamInfo(id, iFool, szTeam);
				}
				else
				{
					Send_SayText(id, iFool, szMessage);
				}
				i++;
			}
			ArrayDestroy(aStoreML);
		}
	}
	return 1;
}

Send_TeamInfo(iReceiver, iPlayerId, szTeam[])
{
	static iTeamInfo;
	if (!iTeamInfo)
	{
		iTeamInfo = get_user_msgid("TeamInfo");
	}
	new var1;
	if (iReceiver)
	{
		var1 = 8;
	}
	else
	{
		var1 = 0;
	}
	message_begin(var1, iTeamInfo, 312, iReceiver);
	write_byte(iPlayerId);
	write_string(szTeam);
	message_end();
	return 0;
}

Send_SayText(iReceiver, iPlayerId, szMessage[])
{
	static iSayText;
	if (!iSayText)
	{
		iSayText = get_user_msgid("SayText");
	}
	new var1;
	if (iReceiver)
	{
		var1 = 8;
	}
	else
	{
		var1 = 0;
	}
	message_begin(var1, iSayText, 312, iReceiver);
	write_byte(iPlayerId);
	write_string(szMessage);
	message_end();
	return 0;
}

public plugin_init()
{
	register_plugin("Call of Duty: MW Mod", "1.0-3", "QTM_Peyote");
	formatex(g_szModName, 31, "COD:MW Extended");
	cvar_doswiadczenie_za_zabojstwo = register_cvar("cod_killxp", "10", "amxx_configsdir", "amxx_configsdir");
	cvar_doswiadczenie_za_obrazenia = register_cvar("cod_damagexp", 355520, "amxx_configsdir", "amxx_configsdir");
	cvar_doswiadczenie_za_wygrana = register_cvar("cod_winxp", "50", "amxx_configsdir", "amxx_configsdir");
	cvar_typ_zapisu = register_cvar("cod_savetype", 355632, "amxx_configsdir", "amxx_configsdir");
	cvar_limit_poziomu = register_cvar("cod_maxlevel", "200", "amxx_configsdir", "amxx_configsdir");
	cvar_proporcja_poziomu = register_cvar("cod_levelratio", "35", "amxx_configsdir", "amxx_configsdir");
	cvar_blokada_broni = register_cvar("cod_weaponsblocking", 355860, "amxx_configsdir", "amxx_configsdir");
	register_clcmd("say /class", "WybierzKlase", -1, 355964, -1);
	register_clcmd("say /classinfo", "OpisKlasy", -1, 355964, -1);
	register_clcmd("say /perk", "KomendaOpisPerku", -1, 355964, -1);
	register_clcmd("say /perk2", "KomendaOpisPerku2", -1, 355964, -1);
	register_clcmd("say /perks", "OpisPerkow", -1, 355964, -1);
	register_clcmd("say /help", "Pomoc", -1, 355964, -1);
	register_clcmd("say /item", "OpisPerku", -1, 355964, -1);
	register_clcmd("say /drop", "WyrzucPerk", -1, 355964, -1);
	register_clcmd("say /drop2", "WyrzucPerk2", -1, 355964, -1);
	register_clcmd("say /reset", "KomendaResetujPunkty", -1, 355964, -1);
	register_clcmd("say /wyrzuc2", "WyrzucPerk2", -1, 355964, -1);
	register_clcmd("say /stats", "PrzydzielPunkty", -1, 355964, -1);
	register_clcmd("useperk", "UzyjPerku", -1, 355964, -1);
	register_clcmd("radio3", "UzyjPerku", -1, 355964, -1);
	register_clcmd("useperk2", "UzyjPerku2", -1, 355964, -1);
	register_clcmd("radio2", "UzyjPerku2", -1, 355964, -1);
	register_clcmd("fullupdate", "BlokujKomende", -1, 355964, -1);
	RegisterHam(9, "player", "Obrazenia", "amxx_configsdir");
	RegisterHam(9, "player", "ObrazeniaPost", 1);
	RegisterHam("amxx_configsdir", "player", "Odrodzenie", 1);
	RegisterHam(11, "player", "SmiercGraczaPost", 1);
	RegisterHam(42, "armoury_entity", "DotykBroni", "amxx_configsdir");
	RegisterHam(42, "weapon_shield", "DotykTarczy", "amxx_configsdir");
	RegisterHam(42, "weaponbox", "DotykBroni", "amxx_configsdir");
	register_forward(125, "CmdStart", "amxx_configsdir");
	register_forward(28, "EmitSound", "amxx_configsdir");
	register_message(get_user_msgid("Health"), "MessageHealth");
	register_logevent("PoczatekRundy", 2, "1=Round_Start");
	register_event("SendAudio", "WygranaTerro", 358404, "2&%!MRAD_terwin");
	register_event("SendAudio", "WygranaCT", 358556, "2&%!MRAD_ctwin");
	register_event("CurWeapon", "CurWeapon", "be", "1=1");
	register_event("HLTV", "NowaRunda", 358792, "1=0", "2=0");
	register_event("DeathMsg", "SmiercGraczaKillCod", 358948, 358956);
	register_forward(109, "fw_GetGameDescription", "amxx_configsdir");
	vault = nvault_open("CodMod");
	MsgScreenfade = get_user_msgid("ScreenFade");
	SyncHudObj = CreateHudSyncObj("amxx_configsdir");
	SyncHudObj2 = CreateHudSyncObj("amxx_configsdir");
	perk_zmieniony = CreateMultiForward("cod_perk_changed", "", 0, 0, 0, 0);
	klasa_zmieniona = CreateMultiForward("cod_class_changed", "", 0, 0);
	new var1 = nazwy_perkow;
	copy(var1[0][var1], 32, "Lack");
	new var2 = opisy_perkow;
	copy(var2[0][var2], "ch", "Kill someone, to get the object");
	new var3 = nazwy_klas;
	copy(var3[0][var3], 32, "Lack");
	set_task(1065353216, "plugin_cfg", "amxx_configsdir", 359472, "amxx_configsdir", 359476, "amxx_configsdir");
	loadfile();
	return 0;
}

public plugin_cfg()
{
	new lokalizacja_cfg[33];
	get_configsdir(lokalizacja_cfg, 32);
	server_cmd("exec %s/codmod.cfg", lokalizacja_cfg);
	server_exec();
	return 0;
}

public loadfile()
{
	new file[256];
	get_configsdir(file, 255);
	formatex(file, "", "%s/cod_frakcje.ini", file);
	if (!file_exists(file))
	{
		return 0;
	}
	new row[128];
	new trash;
	new size = file_size(file, 1);
	new i;
	while (i < size)
	{
		read_file(file, i, row, 127, trash);
		new var1;
		if (contain(row, 359632) && strlen(row) && klasid < 101)
		{
			replace(row, 127, "[klasa]", 359672);
			split(row, nazwa_klasy[klasid], 63, nazwa_frakcji[klasid], 63, "[frakcja]");
			klasid += 1;
		}
		i++;
	}
	return 0;
}

public plugin_precache()
{
	precache_sound("QTM_CodMod/select.wav");
	precache_sound("QTM_CodMod/start.wav");
	precache_sound("QTM_CodMod/start2.wav");
	precache_sound("QTM_CodMod/levelup.wav");
	return 0;
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
	register_native("cod_get_user_perk", "PobierzPerk", "amxx_configsdir");
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
	register_native("cod_register_perk", "ZarejestrujPerk", "amxx_configsdir");
	register_native("cod_register_class", "ZarejestrujKlase", "amxx_configsdir");
	return 0;
}

public CmdStart(id, uc_handle)
{
	if (!is_user_alive(id))
	{
		return 1;
	}
	new Float:velocity[3] = 0.0;
	pev(id, 120, velocity);
	new Float:speed = vector_length(velocity);
	if (szybkosc_gracza[id] > floatmul(1072064102, speed))
	{
		set_pev(id, 93, 300);
	}
	return 1;
}

public Odrodzenie(id)
{
	if (!task_exists(id + 672, "amxx_configsdir"))
	{
		set_task(1036831949, "PokazInformacje", id + 672, 359472, "amxx_configsdir", 366256, "amxx_configsdir");
	}
	if (nowa_klasa_gracza[id])
	{
		UstawNowaKlase(id);
	}
	if (100 < poziom_gracza[id])
	{
		if (!(get_user_flags(id, "amxx_configsdir") & 524288))
		{
			DropPerka(id, 1);
		}
	}
	if (!klasa_gracza[id])
	{
		WybierzKlase(id);
		return 0;
	}
	DajBronie(id);
	ZastosujAtrybuty(id);
	if (min_lvl > poziom_gracza[id])
	{
		client_print(id, "", "[Balance Cod] I discovered big problems with the balance of the levels on the server");
		client_print(id, "", "[Balance Cod] As part of this I got %i to start", min_lvl);
		UstawDoswiadczenie(id, PobierzDoswiadczeniePoziomu(min_lvl) + 1);
		poziom_gracza[id] = min_lvl;
		SprawdzPoziom(id);
	}
	if (0 < punkty_gracza[id])
	{
		PrzydzielPunkty(id);
	}
	return 0;
}

public UstawNowaKlase(id)
{
	new ret;
	new forward_handle = CreateOneForward(pluginy_klas[klasa_gracza[id]], "cod_class_disabled", 0, 0);
	ExecuteForward(forward_handle, ret, id, klasa_gracza[id]);
	DestroyForward(forward_handle);
	forward_handle = CreateOneForward(pluginy_klas[nowa_klasa_gracza[id]], "cod_class_enabled", 0, 0);
	ExecuteForward(forward_handle, ret, id, nowa_klasa_gracza[id]);
	DestroyForward(forward_handle);
	if (ret == 4)
	{
		klasa_gracza[id] = 0;
		return 0;
	}
	ExecuteForward(klasa_zmieniona, ret, id, klasa_gracza[id]);
	if (ret == 4)
	{
		klasa_gracza[id] = 0;
		return 0;
	}
	klasa_gracza[id] = nowa_klasa_gracza[id];
	nowa_klasa_gracza[id] = 0;
	new var1 = wartosc_perku_gracza;
	new var2 = perk_gracza;
	UstawPerk(id, var2[0][var2][id], var1[0][var1][id], 0, 0);
	if (get_user_flags(id, "amxx_configsdir") & 65536)
	{
		UstawPerk(id, perk_gracza[1][id], wartosc_perku_gracza[1][id], 0, 1);
	}
	WczytajDane(id, klasa_gracza[id]);
	return 0;
}

public DajBronie(id)
{
	new i = 1;
	while (i < 32)
	{
		if (bonusowe_bronie_gracza[id] | bronie_klasy[klasa_gracza[id]] & 1 << i)
		{
			new weaponname[22];
			get_weaponname(i, weaponname, 21);
			fm_give_item(id, weaponname);
		}
		i++;
	}
	if (gracz_ma_tarcze[id])
	{
		fm_give_item(id, "weapon_shield");
	}
	if (gracz_ma_noktowizor[id])
	{
		cs_set_user_nvg(id, 1);
	}
	new weapons[32];
	new weaponsnum;
	get_user_weapons(id, weapons, weaponsnum);
	new i;
	while (i < weaponsnum)
	{
		if (is_user_alive(id))
		{
			if (0 < maxAmmo[weapons[i]])
			{
				cs_set_user_bpammo(id, weapons[i], maxAmmo[weapons[i]]);
			}
		}
		i++;
	}
	return 0;
}

public ZastosujAtrybuty(id)
{
	redukcja_obrazen_gracza[id] = floatmul(1060320051, floatsub(1065353216, floatpower(1066192077, -1108999299 * PobierzWytrzymalosc(id, 1, 1, 1))));
	maksymalne_zdrowie_gracza[id] = 1120403456 + PobierzZdrowie(id, 1, 1, 1);
	szybkosc_gracza[id] = floatadd(1132068864, 1067869798 * PobierzKondycje(id, 1, 1, 1));
	set_pev(id, 41, maksymalne_zdrowie_gracza[id]);
	return 0;
}

public PoczatekRundy()
{
	freezetime = false;
	new id;
	while (id <= 32)
	{
		if (is_user_alive(id))
		{
			Display_Fade(id, 512, 512, 4096, 0, 255, 70, 100);
			set_task(1036831949, "UstawSzybkosc", id + 832, 359472, "amxx_configsdir", 359476, "amxx_configsdir");
			switch (get_user_team(id, {0}, "amxx_configsdir"))
			{
				case 1:
				{
					client_cmd(id, "spk QTM_CodMod/start2");
				}
				case 2:
				{
					client_cmd(id, "spk QTM_CodMod/start");
				}
				default:
				{
				}
			}
		}
		id++;
	}
	return 0;
}

public NowaRunda()
{
	FindMaxLvl();
	freezetime = true;
	return 0;
}

public FindMaxLvl()
{
	min_lvl = 0;
	new max_lvl;
	new id = 1;
	while (id <= 32)
	{
		if (max_lvl < poziom_gracza[id])
		{
			max_lvl = poziom_gracza[id];
		}
		id++;
	}
	min_lvl = floatround(procent * max_lvl, "amxx_configsdir");
	return 0;
}

public Obrazenia(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if (!is_user_alive(idattacker))
	{
		return 1;
	}
	if (get_user_team(idattacker, {0}, "amxx_configsdir") == get_user_team(this, {0}, "amxx_configsdir"))
	{
		return 1;
	}
	if (1 >= get_user_health(this))
	{
		return 1;
	}
	SetHamParamFloat(4, floatmul(damage, floatsub(1065353216, redukcja_obrazen_gracza[this])));
	return 1;
}

public ObrazeniaPost(id, idinflictor, attacker, Float:damage, damagebits)
{
	new var1;
	if (!is_user_connected(attacker) || !klasa_gracza[attacker])
	{
		return 1;
	}
	if (get_user_team(attacker, {0}, "amxx_configsdir") != get_user_team(id, {0}, "amxx_configsdir"))
	{
		new doswiadczenie_za_obrazenia = get_pcvar_num(cvar_doswiadczenie_za_obrazenia);
		while (damage > 2.8E-44)
		{
			damage -= 20;
			new var2 = doswiadczenie_gracza[attacker];
			var2 = var2[doswiadczenie_za_obrazenia];
		}
	}
	SprawdzPoziom(attacker);
	return 1;
}

public fw_GetGameDescription()
{
	forward_return(1, g_szModName);
	return 4;
}

public SmiercGraczaPost(id, attacker, shouldgib)
{
	if (!is_user_connected(attacker))
	{
		return 1;
	}
	new var1;
	if (get_user_team(attacker, {0}, "amxx_configsdir") != get_user_team(id, {0}, "amxx_configsdir") && klasa_gracza[attacker])
	{
		new doswiadczenie_za_zabojstwo = get_pcvar_num(cvar_doswiadczenie_za_zabojstwo);
		new nowe_doswiadczenie = get_pcvar_num(cvar_doswiadczenie_za_zabojstwo);
		if (poziom_gracza[attacker] < poziom_gracza[id])
		{
			nowe_doswiadczenie = doswiadczenie_za_zabojstwo / 10 * poziom_gracza[id] - poziom_gracza[attacker] + nowe_doswiadczenie;
		}
		new var5 = perk_gracza;
		if (!var5[0][var5][attacker])
		{
			UstawPerk(attacker, -1, -1, 1, 0);
		}
		else
		{
			new var2;
			if (!perk_gracza[1][attacker] && get_user_flags(attacker, "amxx_configsdir") & 65536)
			{
				UstawPerk(attacker, -1, -1, 1, 1);
			}
			new var3;
			if (!perk_gracza[1][attacker] && poziom_gracza[attacker] < 100)
			{
				UstawPerk(attacker, -1, -1, 1, 1);
			}
		}
		new var6 = doswiadczenie_gracza[attacker];
		var6 = var6[nowe_doswiadczenie];
	}
	else
	{
		new var4;
		if (klasa_gracza[id] && attacker != id)
		{
			new szName[64];
			get_user_name(attacker, szName, "");
			client_print_color(id, 0, "You have been killed by the player\x03 %s\x04 [%s - %d], Have\x03 %d\x04 HP", szName, nazwy_klas[klasa_gracza[attacker]], poziom_gracza[attacker], get_user_health(attacker));
		}
	}
	SprawdzPoziom(attacker);
	return 1;
}

public MessageHealth(msg_id, msg_dest, msg_entity)
{
	static health;
	health = get_msg_arg_int(1);
	if (health < 256)
	{
		return 0;
	}
	if (!health % 256)
	{
		set_pev(msg_entity, 41, pev(msg_entity, 41) - 1);
	}
	set_msg_arg_int(1, get_msg_argtype(1), "");
	return 0;
}

public client_authorized(id)
{
	UsunUmiejetnosci(id);
	get_user_name(id, nazwa_gracza[id], "");
	UsunZadania(id);
	set_task(1092616192, "PokazReklame", id + 768, 359472, "amxx_configsdir", 359476, "amxx_configsdir");
	return 0;
}

public client_disconnect(id)
{
	ZapiszDane(id);
	UsunUmiejetnosci(id);
	UsunZadania(id);
	return 0;
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
	maksymalne_zdrowie_gracza[id] = 0;
	szybkosc_gracza[id] = 0;
	UstawPerk(id, 0, 0, 0, 0);
	UstawPerk(id, 0, 0, 0, 1);
	return 0;
}

public UsunZadania(id)
{
	remove_task(id + 672, "amxx_configsdir");
	remove_task(id + 768, "amxx_configsdir");
	remove_task(id + 832, "amxx_configsdir");
	return 0;
}

public WygranaTerro()
{
	WygranaRunda("TERRORIST");
	return 0;
}

public WygranaCT()
{
	WygranaRunda("CT");
	return 0;
}

public WygranaRunda(Team[])
{
	new Players[32];
	new playerCount;
	new id;
	get_players(Players, playerCount, "aeh", Team);
	new doswiadczenie_za_wygrana = get_pcvar_num(cvar_doswiadczenie_za_wygrana);
	if (3 > get_playersnum("amxx_configsdir"))
	{
		return 0;
	}
	new i;
	while (i < playerCount)
	{
		id = Players[i];
		if (klasa_gracza[id])
		{
			new var1 = doswiadczenie_gracza[id];
			var1 = var1[doswiadczenie_za_wygrana];
			client_print(id, "", "[COD:MW] You got %i experience for winning the round.", doswiadczenie_za_wygrana);
			SprawdzPoziom(id);
		}
		i++;
	}
	return 0;
}

public KomendaOpisPerku(id)
{
	new var1 = wartosc_perku_gracza;
	new var2 = perk_gracza;
	OpisPerku(id, var2[0][var2][id], var1[0][var1][id]);
	return 0;
}

public KomendaOpisPerku2(id)
{
	OpisPerku(id, perk_gracza[1][id], wartosc_perku_gracza[1][id]);
	return 0;
}

public OpisPerku(id, perk, wartosc)
{
	new opis_perku[256];
	new losowa_wartosc[15];
	if (wartosc > -1)
	{
		num_to_str(wartosc, losowa_wartosc, 14);
	}
	else
	{
		format(losowa_wartosc, 14, "%i-%i", min_wartosci_perkow[perk], max_wartosci_perkow[perk]);
	}
	format(opis_perku, "", opisy_perkow[perk]);
	replace_all(opis_perku, 255, "LW", losowa_wartosc);
	client_print(id, "", "Perk: %s.", nazwy_perkow[perk]);
	client_print(id, "", "Opis: %s.", opis_perku);
	return 0;
}

public OpisPerkow(id)
{
	new menu = menu_create("Choose Perk:", "OpisPerkow_Handle", "amxx_configsdir");
	new i = 1;
	while (i <= ilosc_perkow)
	{
		menu_additem(menu, nazwy_perkow[i], 368068, "amxx_configsdir", -1);
		i++;
	}
	menu_display(id, menu, "amxx_configsdir");
	client_cmd(id, "spk QTM_CodMod/select");
	return 0;
}

public OpisPerkow_Handle(id, menu, item)
{
	item++;
	if (item == -3)
	{
		menu_destroy(menu);
		return 0;
	}
	OpisPerku(id, item, -1);
	OpisPerkow(id);
	return 0;
}

public OpisKlasy(id)
{
	new menu = menu_create("Select class:", "OpisKlase_Frakcje", "amxx_configsdir");
	new i = 1;
	while (i <= ilosc_klas)
	{
		if (!is_in_previous(frakcja_klas[i], i))
		{
			menu_additem(menu, frakcja_klas[i], frakcja_klas[i], "amxx_configsdir", -1);
		}
		i++;
	}
	menu_setprop(menu, 4, "Exit");
	menu_setprop(menu, 2, "Previous page");
	menu_setprop(menu, "", "Next page");
	menu_display(id, menu, "amxx_configsdir");
	return 0;
}

public OpisKlase_Frakcje(id, menu, item)
{
	if (item == -3)
	{
		menu_destroy(menu);
		return 0;
	}
	new data[65];
	new iName[64];
	new acces;
	new callback;
	menu_item_getinfo(menu, item, acces, data, "HamFilter", iName, "", callback);
	new menu2 = menu_create("Select class:", "OpisKlasy_Handle", "amxx_configsdir");
	new klasa[50];
	new szTmp[5];
	new i = 1;
	while (i <= ilosc_klas)
	{
		if (equali(data, frakcja_klas[i], "amxx_configsdir"))
		{
			format(klasa, 49, "%s", nazwy_klas[i]);
			num_to_str(i, szTmp, 4);
			menu_additem(menu2, klasa, szTmp, "amxx_configsdir", -1);
		}
		i++;
	}
	menu_setprop(menu2, 4, "Exit");
	menu_setprop(menu2, 2, "Previous page");
	menu_setprop(menu2, "", "Next page");
	menu_display(id, menu2, "amxx_configsdir");
	client_cmd(id, "spk QTM_CodMod/select");
	menu_destroy(menu);
	return 0;
}

public OpisKlasy_Handle(id, menu, item)
{
	client_cmd(id, "spk QTM_CodMod/select");
	if (item == -3)
	{
		menu_destroy(menu);
		return 0;
	}
	new data[65];
	new iName[64];
	new acces;
	new callback;
	menu_item_getinfo(menu, item, acces, data, "HamFilter", iName, "", callback);
	item = str_to_num(data);
	new bronie[320];
	new i = 1;
	new n = 1;
	while (i <= 32)
	{
		if (bronie_klasy[item] & 1 << i)
		{
			new weaponname[22];
			get_weaponname(i, weaponname, 21);
			replace_all(weaponname, 21, "weapon_", 368864);
			if (n > 1)
			{
				add(bronie, 319, 368872, "amxx_configsdir");
			}
			add(bronie, 319, weaponname, "amxx_configsdir");
			n++;
		}
		i++;
	}
	new opis[672];
	format(opis, 671, "\yClass: \w%s\n\yIntelligence: \w%i\n\yHealth: \w%i\n\yStrength: \w%i\n\ySpeed: \w%i\n\yWeapons:\w%s\n\yAdditional description: \w%s\n%s", nazwy_klas[item], inteligencja_klas[item], zdrowie_klas[item], wytrzymalosc_klas[item], kondycja_klas[item], bronie, opisy_klas[item], opisy_klas[item][79]);
	show_menu(id, 1023, opis, -1, 369400);
	return 0;
}

public WybierzKlase(id)
{
	new menu = menu_create("Select Class:", "WybierzKlase_Frakcje", "amxx_configsdir");
	new i = 1;
	while (i <= ilosc_klas)
	{
		new var1;
		if (!equal(frakcja_klas[i], 369544, "amxx_configsdir") && !is_in_previous(frakcja_klas[i], i))
		{
			menu_additem(menu, frakcja_klas[i], frakcja_klas[i], "amxx_configsdir", -1);
		}
		i++;
	}
	menu_setprop(menu, 4, "Exit");
	menu_setprop(menu, 2, "Previous page");
	menu_setprop(menu, "", "Next page");
	menu_display(id, menu, "amxx_configsdir");
	return 0;
}

public WybierzKlase_Frakcje(id, menu, item)
{
	if (item == -3)
	{
		menu_destroy(menu);
		return 0;
	}
	new data[65];
	new iName[64];
	new acces;
	new callback;
	menu_item_getinfo(menu, item, acces, data, "HamFilter", iName, "", callback);
	new menu2 = menu_create("Select class:", "WybierzKlase_Handle", "amxx_configsdir");
	new klasa[50];
	new szTmp[5];
	new i = 1;
	while (i <= ilosc_klas)
	{
		if (equali(data, frakcja_klas[i], "amxx_configsdir"))
		{
			WczytajDane(id, i);
			format(klasa, 49, "%s \y[Level: %i]", nazwy_klas[i], poziom_gracza[id]);
			num_to_str(i, szTmp, 4);
			menu_additem(menu2, klasa, szTmp, "amxx_configsdir", -1);
		}
		i++;
	}
	WczytajDane(id, klasa_gracza[id]);
	menu_setprop(menu2, 4, "Exit");
	menu_setprop(menu2, 2, "Previous page");
	menu_setprop(menu2, "", "Next Page");
	menu_display(id, menu2, "amxx_configsdir");
	client_cmd(id, "spk QTM_CodMod/select");
	menu_destroy(menu);
	return 0;
}

public WybierzKlase_Handle(id, menu, item)
{
	client_cmd(id, "spk QTM_CodMod/select");
	if (item == -3)
	{
		menu_destroy(menu);
		return 0;
	}
	new data[65];
	new iName[64];
	new acces;
	new callback;
	menu_item_getinfo(menu, item, acces, data, "HamFilter", iName, "", callback);
	item = str_to_num(data);
	new var1;
	if (klasa_gracza[id] == item && !nowa_klasa_gracza[id])
	{
		return 0;
	}
	nowa_klasa_gracza[id] = item;
	if (klasa_gracza[id])
	{
		client_print(id, "", "[RAJAGAME] Class will be changed in the next round.");
	}
	else
	{
		UstawNowaKlase(id);
		DajBronie(id);
		ZastosujAtrybuty(id);
	}
	return 0;
}

public PrzydzielPunkty(id)
{
	new inteligencja[65];
	new zdrowie[60];
	new wytrzymalosc[60];
	new kondycja[60];
	new tytul[25];
	new szybkosc[64];
	format(szybkosc, "", "Much: \r[%d] \y(How many points to add )", co_ile[szybkosc_rozdania[id]]);
	format(inteligencja, "HamFilter", "Intelligence: \r%i \y(Increases Damage skills class perks)", PobierzInteligencje(id, 1, 1, 1));
	format(zdrowie, 59, "Health: \r%i \y(Increases Health)", PobierzZdrowie(id, 1, 1, 1));
	format(wytrzymalosc, 59, "Strength: \r%i \y(Reduces damage)", PobierzWytrzymalosc(id, 1, 1, 1));
	format(kondycja, 59, "Speed: \r%i \y(Increases walking speed)", PobierzKondycje(id, 1, 1, 1));
	format(tytul, 24, "Assign Points(%i):", punkty_gracza[id]);
	new menu = menu_create(tytul, "PrzydzielPunkty_Handler", "amxx_configsdir");
	menu_additem(menu, szybkosc, 368068, "amxx_configsdir", -1);
	menu_addblank(menu, "amxx_configsdir");
	menu_additem(menu, inteligencja, 368068, "amxx_configsdir", -1);
	menu_additem(menu, zdrowie, 368068, "amxx_configsdir", -1);
	menu_additem(menu, wytrzymalosc, 368068, "amxx_configsdir", -1);
	menu_additem(menu, kondycja, 368068, "amxx_configsdir", -1);
	menu_setprop(menu, 6, 0);
	menu_display(id, menu, "amxx_configsdir");
	return 0;
}

public PrzydzielPunkty_Handler(id, menu, item)
{
	client_cmd(id, "spk QTM_CodMod/select");
	if (item == -3)
	{
		menu_destroy(menu);
		return 0;
	}
	if (1 > punkty_gracza[id])
	{
		return 0;
	}
	new limit_poziomu = get_pcvar_num(cvar_limit_poziomu);
	decl ilosc;
	new var1;
	if (co_ile[szybkosc_rozdania[id]] > punkty_gracza[id])
	{
		var1 = punkty_gracza[id];
	}
	else
	{
		var1 = co_ile[szybkosc_rozdania[id]];
	}
	ilosc = var1;
	switch (item)
	{
		case 0:
		{
			if (4 > szybkosc_rozdania[id])
			{
				szybkosc_rozdania[id]++;
			}
			else
			{
				szybkosc_rozdania[id] = 0;
			}
		}
		case 1:
		{
			new var5 = inteligencja_gracza[id];
			var5 = var5[ilosc];
			punkty_gracza[id] -= ilosc;
		}
		case 2:
		{
			new var4 = zdrowie_gracza[id];
			var4 = var4[ilosc];
			punkty_gracza[id] -= ilosc;
		}
		case 3:
		{
			new var3 = wytrzymalosc_gracza[id];
			var3 = var3[ilosc];
			punkty_gracza[id] -= ilosc;
		}
		case 4:
		{
			new var2 = kondycja_gracza[id];
			var2 = var2[ilosc];
			punkty_gracza[id] -= ilosc;
		}
		default:
		{
		}
	}
	if (0 < punkty_gracza[id])
	{
		PrzydzielPunkty(id);
	}
	return 0;
}

public KomendaResetujPunkty(id)
{
	client_print(id, "", "[COD:MW] Skills will be reset.");
	client_cmd(id, "spk QTM_CodMod/select");
	ResetujPunkty(id);
	return 0;
}

public ResetujPunkty(id)
{
	punkty_gracza[id] = poziom_gracza[id] - 1 * 2;
	inteligencja_gracza[id] = 0;
	zdrowie_gracza[id] = 0;
	kondycja_gracza[id] = 0;
	wytrzymalosc_gracza[id] = 0;
	if (punkty_gracza[id])
	{
		PrzydzielPunkty(id);
	}
	return 0;
}

public CurWeapon(id)
{
	if (!is_user_connected(id))
	{
		return 0;
	}
	new team = get_user_team(id, {0}, "amxx_configsdir");
	if (team > 2)
	{
		return 0;
	}
	new bron = read_data(2);
	new bronie = bronie_dozwolone | bronie_druzyny[team] | bonusowe_bronie_gracza[id] | bronie_klasy[klasa_gracza[id]];
	if (!bronie & 1 << bron)
	{
		new param[2];
		param[0] = id;
		param[1] = bron;
		set_task(1036831949, "Strip", "amxx_configsdir", param, 2, 359476, "amxx_configsdir");
	}
	new var1;
	if (cs_get_user_shield(id) && !gracz_ma_tarcze[id])
	{
		engclient_cmd(id, "drop", "weapon_shield", 371772);
	}
	UstawSzybkosc(id);
	return 0;
}

public Strip(param[2])
{
	new var1;
	if (is_user_alive(param[0]) && 1 <= param[1] <= 30)
	{
		get_weaponname(param[1], weaponname, 21);
		ham_strip_weapon(param[0], weaponname);
	}
	return 0;
}

public EmitSound(id, iChannel, szSound[], Float:fVol, Float:fAttn, iFlags, iPitch)
{
	if (!is_user_alive(id))
	{
		return 1;
	}
	if (equal(szSound, "common/wpn_denyselect.wav", "amxx_configsdir"))
	{
		new forward_handle = CreateOneForward(pluginy_klas[klasa_gracza[id]], "cod_class_skill_used", 0);
		ExecuteForward(forward_handle, id, id);
		DestroyForward(forward_handle);
		return 4;
	}
	if (equal(szSound, "items/ammopickup2.wav", "amxx_configsdir"))
	{
		cs_set_user_armor(id, "amxx_configsdir", "amxx_configsdir");
		return 4;
	}
	new var1;
	if (equal(szSound, "items/equip_nvg.wav", "amxx_configsdir") && !gracz_ma_noktowizor[id])
	{
		cs_set_user_nvg(id, "amxx_configsdir");
		return 4;
	}
	return 1;
}

public UzyjPerku(id)
{
	return UzyjPerki(id, 0);
}

public UzyjPerku2(id)
{
	return UzyjPerki(id, 1);
}

public UzyjPerki(id, lp)
{
	if (!is_user_alive(id))
	{
		return 1;
	}
	decl forward_handle;
	new var1 = CreateOneForward(pluginy_perkow[perk_gracza[lp][id]], "cod_perk_used", 0);
	forward_handle = var1;
	forward_handle = var1;
	ExecuteForward(forward_handle, id, id);
	DestroyForward(forward_handle);
	return 1;
}

public ZapiszDane(id)
{
	if (!klasa_gracza[id])
	{
		return 0;
	}
	new vaultkey[128];
	new vaultdata[256];
	new identyfikator[64];
	format(vaultdata, "", "#%i#%i#%i#%i#%i#%i", doswiadczenie_gracza[id], poziom_gracza[id], inteligencja_gracza[id], zdrowie_gracza[id], wytrzymalosc_gracza[id], kondycja_gracza[id]);
	new typ_zapisu = get_pcvar_num(cvar_typ_zapisu);
	switch (typ_zapisu)
	{
		case 1:
		{
			copy(identyfikator, "", nazwa_gracza[id]);
		}
		case 2:
		{
			get_user_authid(id, identyfikator, "");
		}
		case 3:
		{
			get_user_ip(id, identyfikator, "", "amxx_configsdir");
		}
		default:
		{
		}
	}
	format(vaultkey, 127, "%s-%s-%i-cod", identyfikator, nazwy_klas[klasa_gracza[id]], typ_zapisu);
	nvault_set(vault, vaultkey, vaultdata);
	return 0;
}

public WczytajDane(id, klasa)
{
	new vaultkey[128];
	new vaultdata[256];
	new identyfikator[64];
	new typ_zapisu = get_pcvar_num(cvar_typ_zapisu);
	switch (typ_zapisu)
	{
		case 1:
		{
			copy(identyfikator, "", nazwa_gracza[id]);
		}
		case 2:
		{
			get_user_authid(id, identyfikator, "");
		}
		case 3:
		{
			get_user_ip(id, identyfikator, "", "amxx_configsdir");
		}
		default:
		{
		}
	}
	format(vaultkey, 127, "%s-%s-%i-cod", identyfikator, nazwy_klas[klasa], typ_zapisu);
	if (!nvault_get(vault, vaultkey, vaultdata, 255))
	{
		format(vaultkey, 127, "%s-%i-cod", nazwa_gracza[id], klasa);
		nvault_get(vault, vaultkey, vaultdata, 255);
	}
	replace_all(vaultdata, 255, 372408, 372416);
	new danegracza[6][32] = {
		{
			91, 67, 79, 68, 58, 77, 87, 93, 32, 68, 114, 111, 112, 32, 37, 115, 46, 0, 91, 67, 79, 68, 58, 77, 87, 93, 32, 89, 111, 117, 32, 104
		},
		{
			97, 118, 101, 32, 110, 111, 32, 112, 101, 114, 107, 46, 0, 70, 97, 108, 108, 101, 110, 32, 116, 111, 32, 37, 105, 32, 108, 101, 118, 101, 108, 33
		},
		{
			0, 71, 111, 116, 32, 112, 114, 111, 109, 111, 116, 101, 100, 32, 116, 111, 32, 37, 105, 32, 108, 101, 118, 101, 108, 33, 0, 115, 112, 107, 32, 81
		},
		{
			84, 77, 95, 67, 111, 100, 77, 111, 100, 47, 108, 101, 118, 101, 108, 117, 112, 0, 73, 78, 70, 79, 32, 86, 73, 80, 32, 80, 76, 65, 89, 69
		},
		{
			82, 58, 10, 124, 67, 108, 97, 115, 115, 32, 58, 32, 37, 115, 10, 124, 69, 120, 112, 32, 58, 32, 37, 48, 46, 48, 102, 37, 37, 10, 124, 76
		},
		{
			101, 118, 101, 108, 32, 58, 32, 37, 105, 10, 124, 80, 101, 114, 107, 32, 58, 32, 37, 115, 10, 124, 80, 101, 114, 107, 50, 32, 58, 32, 37, 115
		}
	};
	parse(vaultdata, danegracza[0][danegracza], 31, danegracza[1], 31, danegracza[2], 31, danegracza[3], 31, danegracza[4], 31, danegracza[5], 31);
	doswiadczenie_gracza[id] = str_to_num(danegracza[0][danegracza]);
	new var1;
	if (str_to_num(danegracza[1]) > 0)
	{
		var1 = str_to_num(danegracza[1]);
	}
	else
	{
		var1 = 1;
	}
	poziom_gracza[id] = var1;
	inteligencja_gracza[id] = str_to_num(danegracza[2]);
	zdrowie_gracza[id] = str_to_num(danegracza[3]);
	wytrzymalosc_gracza[id] = str_to_num(danegracza[4]);
	kondycja_gracza[id] = str_to_num(danegracza[5]);
	punkty_gracza[id] = poziom_gracza[id] - 1 * 2 - inteligencja_gracza[id] - zdrowie_gracza[id] - wytrzymalosc_gracza[id] - kondycja_gracza[id];
	return 0;
}

public WyrzucPerk(id)
{
	DropPerka(id, 0);
	return 0;
}

public WyrzucPerk2(id)
{
	DropPerka(id, 1);
	return 0;
}

public DropPerka(id, lp)
{
	if (perk_gracza[lp][id])
	{
		client_print(id, "", 372448, nazwy_perkow[perk_gracza[lp][id]]);
		UstawPerk(id, 0, 0, 0, lp);
	}
	else
	{
		client_print(id, "", "[COD:MW] You have no perk.");
	}
	return 0;
}

public SprawdzPoziom(id)
{
	if (!is_user_connected(id))
	{
		return 0;
	}
	new limit_poziomu = get_pcvar_num(cvar_limit_poziomu);
	new bool:zdobyl_poziom;
	new bool:stracil_poziom;
	while (doswiadczenie_gracza[id] >= PobierzDoswiadczeniePoziomu(poziom_gracza[id]) && poziom_gracza[id] < limit_poziomu)
	{
		poziom_gracza[id]++;
		punkty_gracza[id] = poziom_gracza[id] - 1 * 2 - inteligencja_gracza[id] - zdrowie_gracza[id] - wytrzymalosc_gracza[id] - kondycja_gracza[id];
		zdobyl_poziom = true;
	}
	while (PobierzDoswiadczeniePoziomu(poziom_gracza[id] - 1) > doswiadczenie_gracza[id])
	{
		poziom_gracza[id]--;
		stracil_poziom = true;
	}
	if (limit_poziomu < poziom_gracza[id])
	{
		poziom_gracza[id] = limit_poziomu;
		ResetujPunkty(id);
	}
	if (stracil_poziom)
	{
		ResetujPunkty(id);
		set_hudmessage(212, "", 85, 1050589266, 1050924810, "amxx_configsdir", 1086324736, 1084227584, 1036831949, 1045220557, 4);
		ShowSyncHudMsg(id, SyncHudObj2, "Fallen to %i level!", poziom_gracza[id]);
	}
	else
	{
		if (zdobyl_poziom)
		{
			punkty_gracza[id] = poziom_gracza[id] - 1 * 2 - inteligencja_gracza[id] - zdrowie_gracza[id] - wytrzymalosc_gracza[id] - kondycja_gracza[id];
			set_hudmessage(212, "", 85, 1050589266, 1050924810, "amxx_configsdir", 1086324736, 1084227584, 1036831949, 1045220557, 4);
			ShowSyncHudMsg(id, SyncHudObj2, "Got promoted to %i level!", poziom_gracza[id]);
			client_cmd(id, "spk QTM_CodMod/levelup");
		}
	}
	ZapiszDane(id);
	return 0;
}

public PokazInformacje(id)
{
	if (!is_user_connected(id))
	{
		remove_task(id + 672, "amxx_configsdir");
		return 0;
	}
	if (!is_user_alive(id))
	{
		new target = pev(id, 101);
		if (!target)
		{
			return 0;
		}
		new ileMa = doswiadczenie_gracza[target];
		new ilePotrzeba = PobierzDoswiadczeniePoziomu(poziom_gracza[target]);
		new ilePotrzebaBylo = PobierzDoswiadczeniePoziomu(poziom_gracza[target] - 1);
		new Float:fProcent = floatmul(1120403456, floatdiv(float(ileMa - ilePotrzebaBylo), float(ilePotrzeba - ilePotrzebaBylo)));
		if (get_user_flags(target, "amxx_configsdir") & 65536)
		{
			set_hudmessage("amxx_configsdir", "", "amxx_configsdir", 1017370378, 1041194025, "amxx_configsdir", 1065353216, 1065353216, 1036831949, 1036831949, 4);
			new var1 = perk_gracza;
			ShowSyncHudMsg(id, SyncHudObj, "INFO VIP PLAYER:\n|Class : %s\n|Exp : %0.0f%%\n|Level : %i\n|Perk : %s\n|Perk2 : %s\n", nazwy_klas[klasa_gracza[target]], fProcent, poziom_gracza[target], nazwy_perkow[var1[0][var1][target]], nazwy_perkow[perk_gracza[1][target]]);
		}
		else
		{
			if (100 >= poziom_gracza[target])
			{
				set_hudmessage("amxx_configsdir", "", "amxx_configsdir", 1017370378, 1041194025, "amxx_configsdir", 1065353216, 1065353216, 1036831949, 1036831949, 4);
				new var2 = perk_gracza;
				ShowSyncHudMsg(id, SyncHudObj, "INFO LOW PLAYER:\n|Class : %s\n|Exp : %0.0f%%\n|Level : %i\n|Perk : %s\n|Perk2 : %s\n", nazwy_klas[klasa_gracza[target]], fProcent, poziom_gracza[target], nazwy_perkow[var2[0][var2][target]], nazwy_perkow[perk_gracza[1][target]]);
			}
			if (100 < poziom_gracza[target])
			{
				set_hudmessage("amxx_configsdir", "", "amxx_configsdir", 1017370378, 1041194025, "amxx_configsdir", 1065353216, 1065353216, 1036831949, 1036831949, 4);
				new var3 = perk_gracza;
				ShowSyncHudMsg(id, SyncHudObj, "INFO PLAYER:\n|Class : %s\n|Exp : %0.0f%%\n|Level : %i\n|Perk : %s\n", nazwy_klas[klasa_gracza[target]], fProcent, poziom_gracza[target], nazwy_perkow[var3[0][var3][target]]);
			}
		}
		return 0;
	}
	new hp = get_user_health(id);
	new ileMa = doswiadczenie_gracza[id];
	new ilePotrzeba = PobierzDoswiadczeniePoziomu(poziom_gracza[id]);
	new ilePotrzebaBylo = PobierzDoswiadczeniePoziomu(poziom_gracza[id] - 1);
	new Float:fProcent = floatmul(1120403456, floatdiv(float(ileMa - ilePotrzebaBylo), float(ilePotrzeba - ilePotrzebaBylo)));
	if (get_user_flags(id, "amxx_configsdir") & 65536)
	{
		set_hudmessage("amxx_configsdir", "", "amxx_configsdir", 1017370378, 1047233823, "amxx_configsdir", "amxx_configsdir", 1050253722, "amxx_configsdir", "amxx_configsdir", 4);
		new var4 = perk_gracza;
		ShowSyncHudMsg(id, SyncHudObj, "[Class : %s]\n[Exp : %i | %0.0f%%]\n[LvL : %i]\n[Perk : %s]\n[Perk2 : %s]\n[KS : x%d]\n[HP : %d]", nazwy_klas[klasa_gracza[id]], doswiadczenie_gracza[id], fProcent, poziom_gracza[id], nazwy_perkow[var4[0][var4][id]], nazwy_perkow[perk_gracza[1][id]], licznik_zabiccod[id], hp);
	}
	else
	{
		if (100 < poziom_gracza[id])
		{
			set_hudmessage("amxx_configsdir", "", "amxx_configsdir", 1017370378, 1047233823, "amxx_configsdir", "amxx_configsdir", 1050253722, "amxx_configsdir", "amxx_configsdir", 4);
			new var5 = perk_gracza;
			ShowSyncHudMsg(id, SyncHudObj, "[Class : %s]\n[Exp : %i | %0.0f%%]\n[LvL : %i]\n[Perk : %s]\n[KS : x%d]\n[HP : %d]", nazwy_klas[klasa_gracza[id]], doswiadczenie_gracza[id], fProcent, poziom_gracza[id], nazwy_perkow[var5[0][var5][id]], licznik_zabiccod[id], hp);
		}
		if (100 > poziom_gracza[id])
		{
			set_hudmessage("amxx_configsdir", "", "amxx_configsdir", 1017370378, 1047233823, "amxx_configsdir", "amxx_configsdir", 1050253722, "amxx_configsdir", "amxx_configsdir", 4);
			new var6 = perk_gracza;
			ShowSyncHudMsg(id, SyncHudObj, "[Class : %s]\n[Exp : %i | %0.0f%%]\n[LvL : %i]\n[Perk : %s]\n[Perk2 : %s]\n[KS : x%d]\n[HP : %d]", nazwy_klas[klasa_gracza[id]], doswiadczenie_gracza[id], fProcent, poziom_gracza[id], nazwy_perkow[var6[0][var6][id]], nazwy_perkow[perk_gracza[1][id]], licznik_zabiccod[id], hp);
		}
	}
	return 0;
}

public PokazReklame(id)
{
	client_print(id, "", "[COD:MW] Welcome to the COD:MW Rajagame");
	client_print(id, "", "[COD:MW] For information about commands type /help.");
	return 0;
}

public Pomoc(id)
{
	show_menu(id, 1023, "\y/reset\w -  resets the statistics\n\y/stats\w - displays stats\n\y/Class\w - selection of classes\n\y/drop\w - throws perk\n\y/perk\w - shows a description of your Perk \n\y/classinfo\w - shows the class descriptions\n\y+use\w - use class skills\n\yradio3\w (typically C) or \yuseperk\w -  use of perk\n\y/ks\w -  open menu killstreak\n\y/perk2\w -  shows a description of your Perk\n\y/drop2\w -  throws perk2\n\y/radio2/X\w -  using perk2", -1, "Pomoc");
	return 0;
}

public UstawSzybkosc(id)
{
	new var1;
	if (id > 32)
	{
		var1 = 832;
	}
	else
	{
		var1 = 0;
	}
	id -= var1;
	new var2;
	if (klasa_gracza[id] && !freezetime)
	{
		set_pev(id, 56, szybkosc_gracza[id]);
	}
	return 0;
}

public DotykBroni(weapon, id)
{
	if (1 > get_pcvar_num(cvar_blokada_broni))
	{
		return 1;
	}
	if (!is_user_connected(id))
	{
		return 1;
	}
	new model[23];
	pev(weapon, "", model, 22);
	new var1;
	if (id != pev(weapon, 18) && containi(model, "w_backpack") == -1)
	{
		return 1;
	}
	return 4;
}

public DotykTarczy(weapon, id)
{
	if (1 > get_pcvar_num(cvar_blokada_broni))
	{
		return 1;
	}
	if (!is_user_connected(id))
	{
		return 1;
	}
	if (gracz_ma_tarcze[id])
	{
		return 1;
	}
	return 4;
}

public UstawPerk(id, perk, wartosc, pokaz_info, lp)
{
	if (!ilosc_perkow)
	{
		return 0;
	}
	static obroty[33];
	new var6 = obroty[id];
	var6++;
	if (5 <= var6)
	{
		obroty[id] = 0;
		UstawPerk(id, 0, 0, 0, lp);
		return 0;
	}
	new var1;
	if (perk == -1)
	{
		var1 = random_num(1, ilosc_perkow);
	}
	else
	{
		var1 = perk;
	}
	perk = var1;
	new var2;
	if (perk_gracza[!lp][id] == perk && perk)
	{
		UstawPerk(id, perk, wartosc, pokaz_info, lp);
		return 0;
	}
	new var3;
	if (wartosc == -1 || min_wartosci_perkow[perk] > wartosc || wartosc > max_wartosci_perkow[perk])
	{
		var4 = random_num(min_wartosci_perkow[perk], max_wartosci_perkow[perk]);
	}
	else
	{
		var4 = wartosc;
	}
	wartosc = var4;
	new ret;
	new forward_handle = CreateOneForward(pluginy_perkow[perk_gracza[lp][id]], "cod_perk_disabled", 0, 0);
	ExecuteForward(forward_handle, ret, id, perk);
	DestroyForward(forward_handle);
	perk_gracza[lp][id] = 0;
	forward_handle = CreateOneForward(pluginy_perkow[perk], "cod_perk_enabled", 0, 0, 0);
	ExecuteForward(forward_handle, ret, id, wartosc, perk);
	DestroyForward(forward_handle);
	if (ret == 4)
	{
		UstawPerk(id, -1, -1, 1, lp);
		return 0;
	}
	ExecuteForward(perk_zmieniony, ret, id, perk, wartosc, lp);
	if (ret == 4)
	{
		UstawPerk(id, -1, -1, 1, lp);
		return 0;
	}
	obroty[id] = 0;
	new var5;
	if (pokaz_info && perk)
	{
		client_print(id, "", "[COD:MW] You Got %s.", nazwy_perkow[perk]);
	}
	perk_gracza[lp][id] = perk;
	wartosc_perku_gracza[lp][id] = wartosc;
	return 0;
}

public UstawDoswiadczenie(id, wartosc)
{
	doswiadczenie_gracza[id] = wartosc;
	SprawdzPoziom(id);
	return 0;
}

public UstawKlase(id, klasa, zmien)
{
	nowa_klasa_gracza[id] = klasa;
	if (zmien)
	{
		UstawNowaKlase(id);
		DajBronie(id);
		ZastosujAtrybuty(id);
	}
	return 0;
}

public UstawTarcze(id, wartosc)
{
	if ((gracz_ma_tarcze[id] = wartosc > 0))
	{
		fm_give_item(id, "weapon_shield");
	}
	return 0;
}

public UstawNoktowizor(id, wartosc)
{
	if ((gracz_ma_noktowizor[id] = wartosc > 0))
	{
		cs_set_user_nvg(id, 1);
	}
	return 0;
}

public DajBron(id, bron)
{
	new var1 = bonusowe_bronie_gracza[id];
	var1 = 1 << bron | var1;
	new weaponname[22];
	get_weaponname(bron, weaponname, 21);
	return fm_give_item(id, weaponname);
}

public WezBron(id, bron)
{
	new var1 = bonusowe_bronie_gracza[id];
	var1 = ~1 << bron & var1;
	if (bronie_klasy[klasa_gracza[id]] | bronie_klasy[get_user_team(id, {0}, "amxx_configsdir")] | bronie_dozwolone & 1 << bron)
	{
		return 0;
	}
	new weaponname[22];
	get_weaponname(bron, weaponname, 21);
	if (!1 << bron & 33554960)
	{
		engclient_cmd(id, "drop", weaponname, 371772);
	}
	return 0;
}

public UstawBonusoweZdrowie(id, wartosc)
{
	bonusowe_zdrowie_gracza[id] = wartosc;
	return 0;
}

public UstawBonusowaInteligencje(id, wartosc)
{
	bonusowa_inteligencja_gracza[id] = wartosc;
	return 0;
}

public UstawBonusowaKondycje(id, wartosc)
{
	bonusowa_kondycja_gracza[id] = wartosc;
	return 0;
}

public UstawBonusowaWytrzymalosc(id, wartosc)
{
	bonusowa_wytrzymalosc_gracza[id] = wartosc;
	return 0;
}

public PrzydzielZdrowie(id, wartosc)
{
	new max_statystyka = get_pcvar_num(cvar_limit_poziomu) / 2;
	wartosc = min(min(punkty_gracza[id], wartosc), max_statystyka - zdrowie_gracza[id]);
	punkty_gracza[id] -= wartosc;
	new var1 = zdrowie_gracza[id];
	var1 = var1[wartosc];
	return 0;
}

public PrzydzielInteligencje(id, wartosc)
{
	new max_statystyka = get_pcvar_num(cvar_limit_poziomu) / 2;
	wartosc = min(min(punkty_gracza[id], wartosc), max_statystyka - inteligencja_gracza[id]);
	punkty_gracza[id] -= wartosc;
	new var1 = inteligencja_gracza[id];
	var1 = var1[wartosc];
	return 0;
}

public PrzydzielKondycje(id, wartosc)
{
	new max_statystyka = get_pcvar_num(cvar_limit_poziomu) / 2;
	wartosc = min(min(punkty_gracza[id], wartosc), max_statystyka - kondycja_gracza[id]);
	punkty_gracza[id] -= wartosc;
	new var1 = kondycja_gracza[id];
	var1 = var1[wartosc];
	return 0;
}

public PrzydzielWytrzymalosc(id, wartosc)
{
	new max_statystyka = get_pcvar_num(cvar_limit_poziomu) / 2;
	wartosc = min(min(punkty_gracza[id], wartosc), max_statystyka - wytrzymalosc_gracza[id]);
	punkty_gracza[id] -= wartosc;
	new var1 = wytrzymalosc_gracza[id];
	var1 = var1[wartosc];
	return 0;
}

public PobierzPerk(plugin, params)
{
	if (params != 3)
	{
		return 0;
	}
	new id = get_param(1);
	new lp = get_param("");
	set_param_byref(2, wartosc_perku_gracza[lp][id]);
	return perk_gracza[lp][id];
}

public PobierzIloscPerkow()
{
	return ilosc_perkow;
}

public PobierzNazwePerku(perk, Return[], len)
{
	if (perk <= ilosc_perkow)
	{
		param_convert(2);
		copy(Return, len, nazwy_perkow[perk]);
	}
	return 0;
}

public PobierzOpisPerku(perk, Return[], len)
{
	if (perk <= ilosc_perkow)
	{
		param_convert(2);
		copy(Return, len, opisy_perkow[perk]);
	}
	return 0;
}

public PobierzPerkPrzezNazwe(nazwa[])
{
	param_convert(1);
	new i = 1;
	while (i <= ilosc_perkow)
	{
		if (equal(nazwa, nazwy_perkow[i], "amxx_configsdir"))
		{
			return i;
		}
		i++;
	}
	return 0;
}

public PobierzDoswiadczeniePoziomu(poziom)
{
	return get_pcvar_num(cvar_proporcja_poziomu) * power(poziom, 2);
}

public PobierzDoswiadczenie(id)
{
	return doswiadczenie_gracza[id];
}

public PobierzPunkty(id)
{
	return punkty_gracza[id];
}

public PobierzPoziom(id)
{
	return poziom_gracza[id];
}

public PobierzZdrowie(id, zdrowie_zdobyte, zdrowie_klasy, zdrowie_bonusowe)
{
	new zdrowie;
	if (zdrowie_zdobyte)
	{
		zdrowie = zdrowie_gracza[id][zdrowie];
	}
	if (zdrowie_bonusowe)
	{
		zdrowie = bonusowe_zdrowie_gracza[id][zdrowie];
	}
	if (zdrowie_klasy)
	{
		zdrowie = zdrowie_klas[klasa_gracza[id]][zdrowie];
	}
	return zdrowie;
}

public PobierzInteligencje(id, inteligencja_zdobyta, inteligencja_klasy, inteligencja_bonusowa)
{
	new inteligencja;
	if (inteligencja_zdobyta)
	{
		inteligencja = inteligencja_gracza[id][inteligencja];
	}
	if (inteligencja_bonusowa)
	{
		inteligencja = bonusowa_inteligencja_gracza[id][inteligencja];
	}
	if (inteligencja_klasy)
	{
		inteligencja = inteligencja_klas[klasa_gracza[id]][inteligencja];
	}
	return inteligencja;
}

public PobierzKondycje(id, kondycja_zdobyta, kondycja_klasy, kondycja_bonusowa)
{
	new kondycja;
	if (kondycja_zdobyta)
	{
		kondycja = kondycja_gracza[id][kondycja];
	}
	if (kondycja_bonusowa)
	{
		kondycja = bonusowa_kondycja_gracza[id][kondycja];
	}
	if (kondycja_klasy)
	{
		kondycja = kondycja_klas[klasa_gracza[id]][kondycja];
	}
	return kondycja;
}

public PobierzWytrzymalosc(id, wytrzymalosc_zdobyta, wytrzymalosc_klasy, wytrzymalosc_bonusowa)
{
	new wytrzymalosc;
	if (wytrzymalosc_zdobyta)
	{
		wytrzymalosc = wytrzymalosc_gracza[id][wytrzymalosc];
	}
	if (wytrzymalosc_bonusowa)
	{
		wytrzymalosc = bonusowa_wytrzymalosc_gracza[id][wytrzymalosc];
	}
	if (wytrzymalosc_klasy)
	{
		wytrzymalosc = wytrzymalosc_klas[klasa_gracza[id]][wytrzymalosc];
	}
	return wytrzymalosc;
}

public PobierzKlase(id)
{
	return klasa_gracza[id];
}

public PobierzIloscKlas()
{
	return ilosc_klas;
}

public PobierzNazweKlasy(klasa, Return[], len)
{
	if (klasa <= ilosc_klas)
	{
		param_convert(2);
		copy(Return, len, nazwy_klas[klasa]);
	}
	return 0;
}

public PobierzOpisKlasy(klasa, Return[], len)
{
	if (klasa <= ilosc_klas)
	{
		param_convert(2);
		copy(Return, len, opisy_klas[klasa]);
	}
	return 0;
}

public PobierzKlasePrzezNazwe(nazwa[])
{
	param_convert(1);
	new i = 1;
	while (i <= ilosc_klas)
	{
		if (equal(nazwa, nazwy_klas[i], "amxx_configsdir"))
		{
			return i;
		}
		i++;
	}
	return 0;
}

public PobierzZdrowieKlasy(klasa)
{
	if (klasa <= ilosc_klas)
	{
		return zdrowie_klas[klasa];
	}
	return -1;
}

public PobierzInteligencjeKlasy(klasa)
{
	if (klasa <= ilosc_klas)
	{
		return inteligencja_klas[klasa];
	}
	return -1;
}

public PobierzKondycjeKlasy(klasa)
{
	if (klasa <= ilosc_klas)
	{
		return kondycja_klas[klasa];
	}
	return -1;
}

public PobierzWytrzymaloscKlasy(klasa)
{
	if (klasa <= ilosc_klas)
	{
		return wytrzymalosc_klas[klasa];
	}
	return -1;
}

public ZadajObrazenia(atakujacy, ofiara, Float:obrazenia, Float:czynnik_inteligencji, byt_uszkadzajacy, dodatkowe_flagi)
{
	ExecuteHam(9, ofiara, byt_uszkadzajacy, atakujacy, floatadd(obrazenia, czynnik_inteligencji * PobierzInteligencje(atakujacy, 1, 1, 1)), dodatkowe_flagi | -2147483648);
	return 0;
}

public ZarejestrujPerk(plugin, params)
{
	if (params != 4)
	{
		return 0;
	}
	ilosc_perkow += 1;
	if (ilosc_perkow > 120)
	{
		return -1;
	}
	pluginy_perkow[ilosc_perkow] = plugin;
	get_string(1, nazwy_perkow[ilosc_perkow], 32);
	get_string(2, opisy_perkow[ilosc_perkow], "ch");
	min_wartosci_perkow[ilosc_perkow] = get_param("");
	max_wartosci_perkow[ilosc_perkow] = get_param(4);
	return ilosc_perkow;
}

public ZarejestrujKlase(plugin, params)
{
	if (params != 7)
	{
		return 0;
	}
	ilosc_klas += 1;
	if (ilosc_klas > 100)
	{
		return -1;
	}
	pluginy_klas[ilosc_klas] = plugin;
	get_string(1, nazwy_klas[ilosc_klas], 32);
	get_string(2, opisy_klas[ilosc_klas], "ch");
	bronie_klasy[ilosc_klas] = get_param("");
	zdrowie_klas[ilosc_klas] = get_param(4);
	kondycja_klas[ilosc_klas] = get_param(5);
	inteligencja_klas[ilosc_klas] = get_param(6);
	wytrzymalosc_klas[ilosc_klas] = get_param(7);
	new i;
	while (i < klasid)
	{
		if (equali(nazwy_klas[ilosc_klas], nazwa_klasy[i], "amxx_configsdir"))
		{
		}
		i++;
	}
	return ilosc_klas;
}

public SmiercGraczaKillCod(id)
{
	new zabojcacod = read_data(1);
	new ofiaracod = read_data(2);
	licznik_smiercicod[zabojcacod] = 0;
	licznik_zabiccod[zabojcacod]++;
	if (!is_user_alive(id))
	{
		licznik_zabiccod[ofiaracod] = 0;
		licznik_smiercicod[ofiaracod]++;
	}
	return 0;
}

ham_strip_weapon(id, weapon[])
{
	if (!equal(weapon, "weapon_", 7))
	{
		return 0;
	}
	new wId = get_weaponid(weapon);
	if (!wId)
	{
		return 0;
	}
	new wEnt;
	while ((wEnt = engfunc(12, wEnt, "classname", weapon)) && id != pev(wEnt, 18))
	{
	}
	if (!wEnt)
	{
		return 0;
	}
	if (wId == get_user_weapon(id, 0, 0))
	{
		ExecuteHamB(91, wEnt);
	}
	if (!ExecuteHamB(21, id, wEnt))
	{
		return 0;
	}
	ExecuteHamB(73, wEnt);
	set_pev(id, 79, ~1 << wId & pev(id, 79));
	return 1;
}

Display_Fade(id, duration, holdtime, fadetype, red, green, blue, alpha)
{
	message_begin(1, MsgScreenfade, 377508, id);
	write_short(duration);
	write_short(holdtime);
	write_short(fadetype);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(alpha);
	message_end();
	return 0;
}

public BlokujKomende()
{
	return 1;
}

fm_give_item(index, item[])
{
	new var1;
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
	{
		return 0;
	}
	new ent = engfunc(21, engfunc(43, item));
	if (!pev_valid(ent))
	{
		return 0;
	}
	new Float:origin[3] = 0.0;
	pev(index, 118, origin);
	set_pev(ent, 118, origin);
	set_pev(ent, 83, pev(ent, 83) | 1073741824);
	dllfunc(1, ent);
	new save = pev(ent, 70);
	dllfunc(4, ent, index);
	if (save != pev(ent, 70))
	{
		return ent;
	}
	engfunc(20, ent);
	return -1;
}

public bool:is_in_previous(frakcja[], from)
{
	new i = from + -1;
	while (i >= 1)
	{
		if (equali(frakcja_klas[i], frakcja, "amxx_configsdir"))
		{
			return true;
		}
		i--;
	}
	return false;
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
