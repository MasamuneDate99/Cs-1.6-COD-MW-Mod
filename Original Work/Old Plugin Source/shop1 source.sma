#include <amxmodx>
#include <codmod>
#include <engine>
#include <cstrike>
#include <fun>

#define PLUGIN "[COD:MW] SHOP MENU"
#define VERSION "1.0"
#define AUTHOR "AsepKhairulAnam"

#define COD_TITLE_MENU	"\d[\rCOD:MW\d] \ySHOP:"

// ITEM FOR MACRO
enum _:COD_ITEM
{
	ITEM_FIRST_AID_KIT,
	ITEM_COMFORTABLE_SHOES,
	ITEM_ROULETTE,
	ITEM_EXPERIENCE,
	ITEM_PERK_I,
	ITEM_PERK_II,
	MAX_ITEM
}

// NAMA ITEM SHOP MENU
new const cod_item_shop_name[MAX_ITEM][] =
{
	"First Aid Kit",
	"Comfortable Shoes",
	"Roulette",
	"Experience",
	"Perk I",
	"Perk II"
}

// HARGA ITEM SHOP MENU
new const cod_item_shop_cash[MAX_ITEM] =
{
	2000,
	1000,
	4000,
	8000,
	4000,
	8000
}

// DESKRIPSI ITEM SHOP MENU
new const cod_item_shop_desc[MAX_ITEM][] =
{
	"Heals +70hp",
	"Jump Higher",
	"Random Bonus",
	"Random EXP",
	"Random Perk I",
	"Random Perk II"
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say /shop", "codmw_shop_menu")
	register_clcmd("say /buy", "codmw_shop_menu")
	
	
}

public codmw_shop_menu(id)
{
	if(!is_user_connected(id) || !is_user_alive(id))
	{
		color_chat(id, "!g[COD:MW] !yYou Must Be Alive To Show COD:MW Shop Menu")
		return
	}
		
	new menu, cash, flags
	menu = menu_create(COD_TITLE_MENU, "codmw_shop_handle")
	cash = cs_get_user_money(id)
	flags = get_user_flags(id)
	
	for(new i = 0; i < ITEM_PERK_II; i++)
	{
		new buffer_menu[201], sInfo[2]
		if(cash >= cod_item_shop_cash[i])
			formatex(buffer_menu, charsmax(buffer_menu), "\y%s \d[\w%s\d] (\y$\r%i\d)", cod_item_shop_name[i], cod_item_shop_desc[i], cod_item_shop_cash[i])
		else
			formatex(buffer_menu, charsmax(buffer_menu), "\d%s \d[\w%s\d] (\y$\r%i\d)", cod_item_shop_name[i], cod_item_shop_desc[i], cod_item_shop_cash[i])
		
		num_to_str(i, sInfo[0], 2)
		menu_additem(menu, buffer_menu, sInfo[0])
	}
	
	// MENAMPILKAN MENU PERK II UNTUK VIP ATAU CLASS LEVEL DI BAWAH 100
	if(flags & ADMIN_LEVEL_E || cod_get_user_level(id) < 100)
	{
		new buffer_menu[201], sInfo[2]
		if(cash >= cod_item_shop_cash[ITEM_PERK_II])
			formatex(buffer_menu, charsmax(buffer_menu), "\y%s \d[\w%s\d] (\y$\r%i\d)", cod_item_shop_name[ITEM_PERK_II], cod_item_shop_desc[ITEM_PERK_II], cod_item_shop_cash[ITEM_PERK_II])
		else
			formatex(buffer_menu, charsmax(buffer_menu), "\d%s \d[\w%s\d] (\y$\r%i\d)", cod_item_shop_name[ITEM_PERK_II], cod_item_shop_desc[ITEM_PERK_II], cod_item_shop_cash[ITEM_PERK_II])
			
		num_to_str(ITEM_PERK_II, sInfo, 2)
		menu_additem(menu, buffer_menu, sInfo)
	}
		
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu)
}

public codmw_shop_handle(id, menu, item)
{
	if(!is_user_connected(id) || !is_user_alive(id))
	{
		menu_destroy(menu)
		color_chat(id, "!g[COD:MW] !yYou Must Be Alive To Show COD:MW Shop Menu")
		return PLUGIN_CONTINUE
	}
	
	new data[6], item_name[64], access, callback
	menu_item_getinfo(menu, item, access, data, 5, item_name, 63, callback)
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	
	new item_shop, cash
	cash = cs_get_user_money(id)
	item_shop = str_to_num(data)
	
	if(cash >= cod_item_shop_cash[item_shop])
	{
		if(codmw_shop_select(id, item_shop))
			cs_set_user_money(id, cash - cod_item_shop_cash[item_shop])
	}
	else
	{
		menu_destroy(menu)
		codmw_shop_menu(id)
		
		// Print Center , Biar Kagak Spam Di Chat
		client_print(id, print_center, "You Don't Have Money To Buy The Item !!")
	}
	
	return PLUGIN_CONTINUE
}

public codmw_shop_select(id, item_selected)
{
	new health, max_health, condition_messages[101]
	health = get_user_health(id)
	max_health = cod_get_user_health(id) + 100
	
	switch(item_selected)
	{
		case ITEM_FIRST_AID_KIT:
		{
			if(health + 75 <= max_health)
			{
				set_user_health(id, health + 75)
				format(condition_messages, charsmax(condition_messages), "You're !tHealed...")
				
			}
			else
			{
				color_chat(id, "!g[COD:MW]!y You're Health Is Full...", condition_messages)
				return 0;
			}
		}
		case ITEM_COMFORTABLE_SHOES:
		{
			if(get_user_gravity(id) > 0.35)
				set_user_gravity(id, get_user_gravity(id)-0.35)
			
			format(condition_messages, charsmax(condition_messages), "You're Bought !tComfortable Shoes")
		}
		case ITEM_ROULETTE:
		{
			new roulette = random_num(0, 10)
			switch(roulette)
			{
				case 0:
				{
					new money_bonus = random_num(500, 6000)
					format(condition_messages, charsmax(condition_messages), "You're Win !t%i!y Additional Money", money_bonus)
					cs_set_user_money(id, money_bonus)
				}
				case 1:
				{
					if(get_user_gravity(id) > 0.3)
						set_user_gravity(id, get_user_gravity(id)-0.3)
				
					format(condition_messages, charsmax(condition_messages), "You're Win !t%i!y Gravity Below")
				}
				case 2:
				{
					new bonus_xp = random_num(25, 455)
					cod_set_user_xp(id, cod_get_user_xp(id) + bonus_xp)
					format(condition_messages, charsmax(condition_messages), "You're Win !t%i!y Additinal Exp", bonus_xp)
				}
				case 3:
				{
					new bonus_health = random_num(30, 80)
					set_user_health(id, health + bonus_health)
					format(condition_messages, charsmax(condition_messages), "You're Win !t%i!y Additinal Health", bonus_health)
				}
				case 4:
				{
					new lost_health = random_num(30, 80)
					
					if(health > lost_health) set_user_health(id, health - lost_health)
					else if(health <= lost_health) set_user_health(id, 1)
					
					format(condition_messages, charsmax(condition_messages), "You're Lost !t-%i!y Additinal Health", lost_health)
				}
				case 5:
				{
					cs_set_user_money(id, 0)
					format(condition_messages, charsmax(condition_messages), "You're Lost All Money")
				}
				case 6..7:
				{
					format(condition_messages, charsmax(condition_messages), "You're Nothing To Win")
				}
			}
		}
		case ITEM_EXPERIENCE:
		{
			new bonus_xp = random_num(100, 650)
			cod_set_user_xp(id, cod_get_user_xp(id) + bonus_xp)
			format(condition_messages, charsmax(condition_messages), "You're Get %i Additional EXP", bonus_xp)
		}
		case ITEM_PERK_I:
		{
			new perk_name[101], perk_bonusid
			perk_bonusid = random_num(1, cod_get_perks_num())
			
			cod_set_user_perk(id, perk_bonusid, -1, 0, 0)
			cod_get_perk_name(perk_bonusid, perk_name, sizeof(perk_name))
			
			format(condition_messages, charsmax(condition_messages), "You're Bought PERK I '!t%s!y'", perk_name)
		}
		case ITEM_PERK_II:
		{
			new perk_name[101], perk_bonusid
			perk_bonusid = random_num(1, cod_get_perks_num())
			
			cod_set_user_perk(id, perk_bonusid, -1, 0, 1)
			cod_get_perk_name(perk_bonusid, perk_name, sizeof(perk_name))
			
			format(condition_messages, charsmax(condition_messages), "You're Bought PERK II '!t%s!y'", perk_name)
		}
	}
	
	color_chat(id, "!g[COD:MW]!y %s", condition_messages)
	return 1;
}

stock color_chat(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
       
	replace_all(msg, 190, "!g", "^x04")
	replace_all(msg, 190, "!y", "^x01") 
	replace_all(msg, 190, "!t", "^x03")
       
	if(id) players[0] = id; else get_players(players, count, "ch")
	{
		for(new i = 0; i < count; i++)
		{
			if(is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])  
				write_byte(players[i])
				write_string(msg)
				message_end()
			}
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
