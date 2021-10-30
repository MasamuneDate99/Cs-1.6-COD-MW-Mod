#include <amxmodx>
#include <codmod>
#include <amxmisc>

new opcja, gracz_id[33], wybrany;
new ilosc[33], name[33], nazwa_perku[256], nazwa_klasy[256];

public plugin_init()
{
	register_plugin("COD Admin RAJAGAME", "1.5", "MieTeK");
	
	register_clcmd("say /codadmin", "AM", ADMIN_IMMUNITY);
	register_clcmd("ile","pobierz");
}
	
public AM(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_H))
		return PLUGIN_HANDLED;

	new tytul[64];
	format(tytul, 63, "\rCOD Admin Menu");
	new menu = menu_create(tytul, "AM_handler");
	menu_additem(menu, "Add \rEXP");//1
	menu_additem(menu, "Set \rLVL");//2
	menu_additem(menu, "Give \rPerk");//3
	menu_additem(menu, "Move \rEXP");//4
	menu_additem(menu, "Replace \rEXP");//5
	menu_additem(menu, "Add Up \rEXP");//6
	
	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public AM_handler(id, menu, item)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	switch(item)
	{
		case 0:
		{
			Gracz(id);
			opcja = 1;
		}
		case 1:	
		{
			Gracz(id);
			opcja = 2;
		}
		case 2:	
		{
			Gracz(id);
			opcja = 3;
		}
		case 3:
		{
			Gracz(id);
			opcja = 4;
		}
		case 4:
		{
			Gracz(id);
			opcja = 5;
		}
		case 5:
		{
			Gracz(id);
			opcja = 6;
		}
	}
	
	return PLUGIN_CONTINUE;
}

public Gracz(id)
{
	new menu = menu_create("Select a player:", "Gracz_handler");
	
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

public Gracz_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	wybrany = gracz_id[item];
	get_user_name(wybrany, name, 32);
	
	if(opcja == 3)
		wybierz_slot(id);
	else if(opcja == 4 || opcja == 5 || opcja == 6)
		wybierz_klase(id);
	else
		console_cmd(id, "messagemode ile");
		
	return PLUGIN_HANDLED;
}


public pobierz(id)
{
	new text[192]
	read_argv(1,text,191)
	format(ilosc, charsmax(ilosc), "%s", text);
	dawaj(id)
}
	
public dawaj(id)
{
	if(opcja == 1)
	{
		cod_set_user_xp(wybrany, cod_get_user_xp(wybrany)+str_to_num(ilosc));
		client_print(id, print_chat, "Set the player %s %i EXP", name, str_to_num(ilosc));
	}
	if(opcja == 2)
	{
		new potrzeba;
		potrzeba = cod_get_level_xp(str_to_num(ilosc)-1);
		cod_set_user_xp(wybrany, potrzeba);
		
		client_print(id, print_chat, "Set the player %s %i LVL", name, str_to_num(ilosc));
	}
}

public wybierz_klase(id)
{
	new tytul[64];
	format(tytul, sizeof(tytul), "\rTo Class:");
	new menu = menu_create(tytul, "wybierz_klase_handler");
	for(new i=1; i<=cod_get_classes_num(); i++)
	{
		cod_get_class_name(i, nazwa_klasy, 255)
		menu_additem(menu, nazwa_klasy)
	}
	
	menu_display(id, menu);
}

public wybierz_klase_handler(id, menu, item)
{
	if(item++ == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_CONTINUE;
	}
	new klasa[2][65];
	
	if(opcja == 4)
	{
		new exp = cod_get_user_xp(wybrany);
		cod_get_class_name(cod_get_user_class(wybrany), klasa[0], 64);
		cod_set_user_xp(wybrany, 0);
		cod_set_user_class(wybrany, item, 1);
		cod_get_class_name(cod_get_user_class(wybrany), klasa[1], 64);
		cod_set_user_xp(wybrany, exp);
		client_print(id, print_chat, "Moved EXP player %s class %s to class %s", name, klasa[0], klasa[1]);
	}
	if(opcja == 5)
	{
		new exp = cod_get_user_xp(wybrany);
		new oldclass = cod_get_user_class(wybrany)
		cod_get_class_name(cod_get_user_class(wybrany), klasa[0], 64);
		cod_set_user_class(wybrany, item, 1);
		new exp2 = cod_get_user_xp(wybrany);
		cod_set_user_xp(wybrany, exp);
		cod_get_class_name(cod_get_user_class(wybrany), klasa[1], 64);
		cod_set_user_class(wybrany, oldclass, 1);
		cod_set_user_xp(wybrany, exp2);
		cod_set_user_class(wybrany, item, 1);
		client_print(id, print_chat, "You turned EXP player %s between class %s to class %s", name, klasa[0], klasa[1]);
	}
	if(opcja == 6)
	{
		new exp = cod_get_user_xp(wybrany);
		cod_set_user_xp(wybrany, 0);
		cod_get_class_name(cod_get_user_class(wybrany), klasa[0], 64);
		cod_set_user_class(wybrany, item, 1);
		cod_get_class_name(cod_get_user_class(wybrany), klasa[1], 64);
		cod_set_user_xp(wybrany, cod_get_user_xp(wybrany)+exp);
		client_print(id, print_chat, "Zsumowales EXP graczowi %s z klasy %s na klase %s", name, klasa[0], klasa[1]);
	}
	return PLUGIN_CONTINUE;
}

public wybierz_slot(id)
{
	new tytul[64];
	format(tytul, 63, "\rSelect a slot:");
	new menu = menu_create(tytul, "wybierz_slot_handler");

      menu_additem(menu, "Slot first", "0");
      menu_additem(menu, "Slot second", "1");
	
	menu_display(id, menu);
}

public wybierz_slot_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
      new data[2], szName[16];
      new access, callback;
      menu_item_getinfo(menu, item, access, data, 1, szName, 15, callback);
      
      switch(item)
      {
            case 0: wybierz_perk(id, data[0])
            case 1: wybierz_perk(id, data[0])
      }
      
	return PLUGIN_HANDLED;
}

public wybierz_perk(id, data[])
{
	new tytul[32];
	format(tytul, 31, "\rSelect a perk:");
	new menu = menu_create(tytul, "wybierz_perk_handler");
	for(new i=1; i<=cod_get_perks_num(); i++)
	{
		cod_get_perk_name(i, nazwa_perku, 255)
		menu_additem(menu, nazwa_perku, data[0]);
	}
	
	menu_display(id, menu);
}

public wybierz_perk_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
      new data[2], szName[64];
      new access, callback;
      menu_item_getinfo(menu, item, access, data, 1, szName, 63, callback);

      item++

	new lp = str_to_num(data[0])
	cod_set_user_perk(wybrany, item, -1, 0, lp);
	cod_get_perk_name(item++, nazwa_perku, 255);

	client_print(id, print_chat, "You give %s perk %s at slot %i", name, nazwa_perku, lp);
	
	return PLUGIN_HANDLED;
}