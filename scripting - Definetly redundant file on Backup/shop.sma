#include <amxmodx>
#include <codmod>
#include <engine>
#include <cstrike>
#include <fun>

//==================================================
//Sklep by Damiano1x v1.2
//==================================================
// + Mozliwosc kupna 2 perkow
// + Naprawiono bug ktory nie dawal drugiego perku
//==================================================

public plugin_init() 
{
	register_plugin("CodShop by Lokiec", "1.0", "Damiano1x");
	
	register_clcmd("say /shop", "Sklep_dolary");
	register_clcmd("say /buy" , "Sklep_dolary");

}	


public Sklep_dolary(id)
{
	new tytul[25];
	format(tytul, 24, "\rSHOP:");
	new menu = menu_create(tytul, "Sklepd_Handler");
	
	menu_additem(menu, "First aid kit \r[Heals +70 HP] \yCost: \r8000");//0
	menu_additem(menu, "Comfortable Shoes \r[Jump higher faster running] \yCost: \r4000");//1
	menu_additem(menu, "Totolotek \r[Draw bonuses] \yCost: \r12000");//2
	menu_additem(menu, "Experience \r[Random EXP] \yCost: \r16000");//3
	menu_additem(menu, "Perk I \r[Random Perk] \yCost: \r8500");//4
	menu_additem(menu, "Perk II \r[Random Perk II] \yCost: \r10000");//5
	menu_display(id, menu);
	
}

public Sklepd_Handler(id, menu, item)
{
	
	if(!is_user_alive(id) || !is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	new zdrowie = get_user_health(id);
	new kasa = cs_get_user_money(id);
	new maxzdrowie = cod_get_user_health(id)+100
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	switch(item)
	{
		
		case 0:
		{
			if(kasa >= 8000)
			{
				new nowe_zdrowie = (zdrowie+75);
				if(nowe_zdrowie < maxzdrowie)
				{
					cs_set_user_money(id, kasa-8000);
					set_user_health(id, nowe_zdrowie);
					client_print(id, print_chat, "[COD:MW] Bought 75 hp!");
				}
				if(nowe_zdrowie >= maxzdrowie && zdrowie != maxzdrowie)
				{
					cs_set_user_money(id, kasa-8000);
					set_user_health(id, maxzdrowie);
					client_print(id, print_chat, "[COD:MW] You are fully healed!");
				}
			}
			else
				client_print(id, print_chat, "[COD:MW] You dont have money");
		}
		case 1:
		{
			if(kasa >= 4000)
			{
				cs_set_user_money(id, kasa-4000);
				set_user_gravity(id, 0.5);
				client_print(id, print_chat, "[COD:MW] Bought Comfortable Shoes!");
			}
			if(kasa < 4000)
				client_print(id, print_chat, "[COD:MW] You dont have money!");
		}
		case 2:
		{

			if(kasa >= 12000)
			{
				cs_set_user_money(id, kasa-12000);
				client_print(id, print_chat, "[COD:MW] It takes a draw!");
				new totek = random_num(0, 10);
				
				switch(totek)
				{
					case 0:
					{
						new moneybonus = random_num(500,5000);
						client_print(id, print_chat, "[COD:MW] You win kase %i$!", moneybonus);
						cs_set_user_money(id, moneybonus);
					}
					case 1:
					{
						new moneybonus = random_num(500,1200);
						client_print(id, print_chat, "[COD:MW] You win the super kase %i$!", moneybonus);
						cs_set_user_money(id, moneybonus);
					}
					case 2:
					{
						set_user_gravity(id, get_user_gravity(id)-0.3);
						client_print(id, print_chat, "[COD:MW] You win gravity's below!");
					}
					case 3:
						client_print(id, print_chat, "[COD:MW] nothing you won!");
					case 4:
					{
						new bonusxp = random_num(250,1775);
						cod_set_user_xp(id, cod_get_user_xp(id)+bonusxp);
						client_print(id, print_chat, "[COD:MW] You win %i additional EXP !", bonusxp);
					}
					case 5:
					{
						new healthbonus = random_num(10,55);
						set_user_health(id, get_user_health(id)+healthbonus);
						client_print(id, print_chat, "[COD:MW] You win %i additional HP!", healthbonus);
					}
					case 6:
					{
						new healthbonus = random_num(20,70);
						set_user_health(id, get_user_health(id)-healthbonus);
						client_print(id, print_chat, "[COD:MW] Lost your %i HP!", healthbonus);
					}
					case 7:
						client_print(id, print_chat, "[COD:MW] nothing you won !");
					case 9:
					{
						new xpbonus = random_num(275,1750);
						cod_set_user_xp(id, cod_get_user_xp(id)+xpbonus);
						client_print(id, print_chat, "[COD:MW] You win %i additional EXP!", xpbonus);
					}
					case 10:
					{
						cs_set_user_money(id, 50);
						client_print(id, print_chat, "[COD:MW] Nothing you won, but the money paid off!");
					}
						
				}
			}		
			if(kasa < 1200)
				client_print(id, print_chat, "[COD:MW] You dont have money!");
		}
		case 3:
		{
			if(kasa >= 16000)
			{
				new exp = cod_get_user_xp(id);
				new losowy = random_num(305, 5150);
				cs_set_user_money(id, kasa-16000);
				cod_set_user_xp(id, exp+losowy)
				client_print(id, print_chat, "[COD:MW] You get %i EXP'a!", losowy);
			}
			if(kasa < 16000)
				client_print(id, print_chat, "[COD:MW] Dont have money!");
		}
		case 4:
		{
			if(kasa >= 8500)
			{
				cs_set_user_money(id, kasa-8500);
				cod_set_user_perk(id, -1, -1, 1, 0);
				client_print(id, print_chat, "[COD:MW] Bought a random perk 1!");
			}
			if(kasa < 8500)
				client_print(id, print_chat, "[COD:MW] Dont have money");
		}
		case 5:
		{
			if(kasa >= 10000 && cod_get_user_level(id) < 100)
			{
				cs_set_user_money(id, kasa-10000);
				cod_set_user_perk(id, -1, -1, 1, 1);
				client_print(id, print_chat, "[COD:MW] Bought a random perk 2!");
			}
			if(kasa < 10000)
			{
				client_print(id, print_chat, "[COD:MW] Dont have money or high level!");
			}	
		}
	}
    return PLUGIN_HANDLED;
 }
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1250\\ deff0\\ deflang1045{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
