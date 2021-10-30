#include <amxmodx>
#include <codmod>
#include <engine>
#include <cstrike>
#include <fun>

public plugin_init() 
{
	register_plugin("CodShop by M.Fajar.Ar", "1.0", "M.Fajar.Ar");
	
	register_clcmd("say /shop", "Sklep");
}	

public Sklep(id)
{
	new tytul[25];
	format(tytul, 24, "\rBeli Shop \rM.Fajar.Ar");
	new menu = menu_create(tytul, "Sklep_Handler");
	menu_additem(menu, "Gravitation \r[300 Gravitation] \yCost: \r5000$");//1
	menu_additem(menu, "Roulette \r[Draw Bunos] \yCost: \r4000$");//2
	menu_additem(menu, "Experience \r[Random Experience] \yCost: \r16000$");//3
	menu_additem(menu, "Perk \r[Random perk] \yCost: \r4000$");//4
	menu_additem(menu, "Perk2 \r[Random perk] \yCost: \r5500$");//5
	menu_additem(menu, "Ammo \r[Ammunition for all] \yCost: \r2000$");//6
	menu_additem(menu, "Granat \r[Dapat HE Grem] \yCost: \r3000$");//7
	menu_additem(menu, "Flasbang \r[Dapat Flashbang] \yCost: \r2000$");//8
	menu_additem(menu, "SilentFootstop \r[Tidak ada suara footstep] \yCost: \r10000$");//9
	menu_display(id, menu);
	
}

public Sklep_Handler(id, menu, item)
{
	
	if(!is_user_alive(id) || !is_user_connected(id))
		return PLUGIN_CONTINUE;

	new kasa = cs_get_user_money(id);
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	switch(item)
	{
		case 0:
		{
			if(kasa >= 5000)
			{
				cs_set_user_money(id, kasa-5000);
				set_user_gravity(id, 0.3);
				client_print(id, print_chat, "[COD:MW] You have 300 gravit!");
			}
			if(kasa < 5000)
				client_print(id, print_chat, "[COD:MW] Lupakan saja, Anda memiliki terlalu sedikit uang!");
		}
		case 1:
		{

			if(kasa >= 4000)
			{
				cs_set_user_money(id, kasa-4000);
				client_print(id, print_chat, "[COD:MW] It takes a draw!");
				new totek = random_num(0, 10);
				
				switch(totek)
				{
					case 0:
					{
						new moneybonus = random_num(500,5000);
						client_print(id, print_chat, "[COD:MW] You win a lot of money %i$!", moneybonus);
						cs_set_user_money(id, moneybonus);
					}
					case 1:
					{
						new moneybonus = random_num(5000,16000);
						client_print(id, print_chat, "[COD:MW] You win a lot of money %i$!", moneybonus);
						cs_set_user_money(id, moneybonus);
					}
					case 2:
					{
						set_user_gravity(id, get_user_gravity(id)-0.5);
						client_print(id, print_chat, "[COD:MW] You have 300 gravit!");
					}
					case 3:
						client_print(id, print_chat, "[COD:MW] Lipa ada yang menang");
					case 4:
					{
						new bonusxp = random_num(20,100);
						cod_set_user_xp(id, cod_get_user_xp(id)+bonusxp);
						client_print(id, print_chat, "[COD:MW] you win %i additional xp!", bonusxp);
					}
					case 5:
					{
						cod_set_user_perk(id, -1, -1, 1);
						client_print(id, print_chat, "[COD:MW] You win a random perk!");
					}
					case 6:
					{
						new healthbonus = random_num(30,100);
						set_user_health(id, get_user_health(id)+healthbonus);
						client_print(id, print_chat, "[COD:MW] lost your %i HP!", healthbonus);
					}
					case 7:
					{
						new healthbonus = random_num(10,65);
						set_user_health(id, get_user_health(id)-healthbonus);
						client_print(id, print_chat, "[COD:MW] lost your %i HP!", healthbonus);
					}
					case 8:
						client_print(id, print_chat, "[COD:MW] Lipa ada yang menang!");
					case 9:
					{
						new xpbonus = random_num(75,150);
						cod_set_user_xp(id, cod_get_user_xp(id)+xpbonus);
						client_print(id, print_chat, "[kamu mendapatkan %i EXP'a!", xpbonus);
					}
					case 10:
					{
						client_print(id, print_chat, "[COD:MW] Lupakan saja, Anda memiliki terlalu sedikit uang!");
					}
						
				}
			}		
			if(kasa < 4000)
				client_print(id, print_chat, "[COD:MW] Lupakan saja, Anda memiliki terlalu sedikit uang!");
		}
		case 2:
		{
			if(kasa >= 16000)
			{
				new exp = cod_get_user_xp(id);
				new losowy = random_num(25, 350);
				cs_set_user_money(id, kasa-16000);
				cod_set_user_xp(id, exp+losowy)
				client_print(id, print_chat, "[COD:MW] kamu mendapatkan %i EXP'a!", losowy);
			}
			if(kasa < 16000)
				client_print(id, print_chat, "[COD:MW] Lupakan saja, Anda memiliki terlalu sedikit uang!");
		}
		case 3:
		{
			if(kasa >= 3500)
			{
				cs_set_user_money(id, kasa-4000);
				cod_set_user_perk(id, -1, -1, 1, 0);
				client_print(id, print_chat, "[COD:MW] RANDOM PERK!");
			}
			if(kasa < 4000)
				client_print(id, print_chat, "[COD:MW] Lupakan saja, Anda memiliki terlalu sedikit uang!");
		}
		case 4:
		{
			if(kasa >= 4000)
			{
				cs_set_user_money(id, kasa-5500);
				cod_set_user_perk(id, -1, -1, 1, 1);
				client_print(id, print_chat, "[COD:MW] RANDOM PERK2!");
			}
			if(kasa < 5500)
				client_print(id, print_chat, "[COD:MW] Lupakan saja, Anda memiliki terlalu sedikit uang!");
		}
		case 5:
		{
			if(kasa >= 2000)
			{
				give_item(id,"ammo_762nato");
				give_item(id,"ammo_buckshot");
				give_item(id,"ammo_45acp");
				give_item(id,"ammo_556nato");
				give_item(id,"ammo_9mm");
				give_item(id,"ammo_57mm");
				give_item(id,"ammo_45acp");
				give_item(id,"ammo_338magnum");
				give_item(id,"ammo_50ae");
				cs_set_user_money(id, kasa-8500);
				client_print(id, print_chat, "[COD:MW] Dapat peluru semua weapon!!");
			}
			if(kasa < 2000)
				client_print(id, print_chat, "[COD:MW] Lupakan saja, Anda memiliki terlalu sedikit uang!");
		}
		case 6:
		{
			if(kasa >= 3000)
			{
				cod_give_weapon(id, CSW_HEGRENADE);
				cs_set_user_money(id, kasa-3000);
				client_print(id, print_chat, "[COD:MW] Dapat Granat!");
			}
			if(kasa < 3000)
				client_print(id, print_chat, "[COD:MW] Lupakan saja, Anda memiliki terlalu sedikit uang!");
		}
		case 7:
		{
			if(kasa >= 2000)
			{
				cod_give_weapon(id, CSW_FLASHBANG);
				cs_set_user_money(id, kasa-5000);
				client_print(id, print_chat, "[COD:MW] Dapat Flashbang!");
			}
			if(kasa < 2000)
				client_print(id, print_chat, "[COD:MW] Lupakan saja, Anda memiliki terlalu sedikit uang!");
		}
		case 8:
		{
			if(kasa >= 10000)
			{
				set_user_footsteps(id, 1);
				cs_set_user_money(id, kasa-12000);
				client_print(id, print_chat, "[COD:MW] Dapat Sepatu Silent!");
			}
			if(kasa < 12000)
				client_print(id, print_chat, "[COD:MW] Lupakan saja, Anda memiliki terlalu sedikit uang!");
		}
	}
	
	return PLUGIN_CONTINUE;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
