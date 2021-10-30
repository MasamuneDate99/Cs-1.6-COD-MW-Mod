#include <amxmodx>
#include <amxmisc>
#include <codmod>

#define PLUGIN "CoD Talent"
#define VERSION "1.0"
#define AUTHOR "MasamuneDate"

public plugin_init()
{
 	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd( "say /talent","Talent_Menu" );
}
public Talent_Menu( id )
{
    new menu = menu_create( "\rCOD Talent Menu by MasamuneDate", "main_menu" )

    menu_additem( menu, "\wLow Level Talent ( 0 - 150 )", "", 0 );
    menu_additem( menu, "\wBasic Talent ( 151+ ) ( Not Available )", "", 0 );
    menu_additem( menu, "\VIP Talent ( Not available )", "", ADMIN_LEVEL_E, 0 );
    menu_additem( menu, "\wAdvanced Talent ( 250+ ) ( Not Available )", "", 0 );
    menu_additem( menu, "\wSpecial Talent ( Not Available )", "", 0 );

    menu_display( id, menu, 0 );
}
public main_menu( id, menu, item )
{
	switch( item )
	{
	case 0:
	{
		low_level(id);
	}
	case 1:
	{
		basic_talent( id );
	}
	case 2:
	{
		vip_talent(id);
	}
	case 3:
	{
		advance_talent(id);
	}
	case 4:
	{
		special_talent(id);
	}
	case MENU_EXIT:
	{
            //Do nothing?
	}
	}

	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

low_level(id)
{
	new menu = menu_create( "\rLow Level Talent", "lowlevel_handler" )

	menu_additem( menu, "\wExtra 200XP for Kill", "", 0 );
	menu_additem( menu, "\wExtra 60XP each 20 damage you dealt", "", 0 );

	menu_display( id, menu, 0 );
}

basic_talent( id )
{
	//Note that we will be using a different menu handler
	new menu = menu_create( "\rBasic Talent", "basic_handler" )

	menu_additem( menu, "\w10 Extra DMG reduction", "", 0 );
	menu_additem( menu, "\wSilent Steps", "", 0 );
	menu_additem( menu, "\wKnife has 1/5 Chance instant kill ( Left & Right )", "", 0 );
	menu_additem( menu, "\w20% Extra damage", "", 0 );
	menu_additem( menu, "\wReduce Gravity + Extra Speed", "", 0 );
	menu_additem( menu, "\wExtra Strength + Health", "", 0 );

	menu_display( id, menu, 0 );
}

vip_talent(id)
{
	new menu = menu_create( "\rVIP Talent", "vip_handler" )

	menu_additem( menu, "\wAll Stats + 25 + Extra XP / Kill & Damage", "", 0 );
	menu_additem( menu, "\wFree random Perk ( kalo gua bisa ) + Extra XP / Kill & Damage", "", 0 );

	menu_display( id, menu, 0 );
}

advance_talent(id)
{
	new menu = menu_create( "\rAdvance Talent", "advance_handler" )

	menu_additem( menu, "\wDeal 2* Damage when attacking enemy from behind", "", 0 );
	menu_additem( menu, "\wI'm Sub-Selection #2", "", 0 );

	menu_display( id, menu, 0 );
}

special_talent(id)
{
	new menu = menu_create( "\rSpecial Talent", "special_handler" )

	menu_additem( menu, "\wSupport Talent : 1 Medkit each round", "", 0 );
	menu_additem( menu, "\wOffense Talent : 1/2 Chance Instant kill HE Grenade", "", 0 );
	menu_additem( menu, "\wHarras Talent  : Deal 1/20 of total health as damage for each shot", "", 0 );

	menu_display( id, menu, 0 );
}

public basic_handler( id, menu, item )
{
	switch( item )
	{
	case 0:
	{
	client_print( id, print_chat, "[Talent System] Selected 10 DMG reduction !" );
	}
	case 1:
	{
	client_print( id, print_chat, "[Talent System] Silent Step Learned !" );
	}
	case 2:
	{
	client_print( id, print_chat, "[Talent System] Knife Instant Kill Learned !" );
	}
	case 3:
	{
	client_print( id, print_chat, "[Talent System] Selected Extra DMG !" );
	}
	case 4:
	{
	client_print( id, print_chat, "[Talent System] Reduce Gravity Learned ! Selected Extra SPD !" );
	}
	case 5:
	{
	client_print( id, print_chat, "[Talent System] Selected Extra STR and HP !" );
	}
	case MENU_EXIT:
	{
	
	}
	}

	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public lowlevel_handler( id, menu, item )
{
	switch( item )
	{
	case 0:
	{
	client_print( id, print_chat, "[Talent System] Extra 200 XP / Kill Learned !" );
	}
	case 1:
	{
	client_print( id, print_chat, "[Talent System] Extra 60 XP / 20 DMG Learned !" );
	}
	case MENU_EXIT:
	{
	//If they are still connected
	if ( is_user_connected( id ) )
	{
	//Lets send them back to the top menu
	// Or do nothing
	// Talent_Menu( id );
	}
	}

	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public vip_handler( id, menu, item )
{
	switch( item )
	{
	case 0:
	{
	client_print( id, print_chat, "[Talent System] Not Yet Available! - 1" );
	}
	case 1:
	{
	client_print( id, print_chat, "[Talent System] Not Yet Available! - 2" );
	}
	case MENU_EXIT:
	{
	if ( is_user_connected( id ) )
	{
		
	}
	}

	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public advance_handler( id, menu, item )
{
	switch( item )
	{
	case 0:
	{
	client_print( id, print_chat, "[Talent System] Not Yet Available! - 1" );
	}
	case 1:
	{
	client_print( id, print_chat, "[Talent System] Not Yet Available! - 2" );
	}
	case MENU_EXIT:
	{
	if ( is_user_connected( id ) )
	{
		
	}
	}

	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public special_handler( id, menu, item )
{
	switch( item )
	{
	case 0:
	{
	client_print( id, print_chat, "[Talent System] Not Yet Available! - 1" );
	}
	case 1:
	{
	client_print( id, print_chat, "[Talent System] Not Yet Available! - 2" );
	}
	case MENU_EXIT:
	{
	if ( is_user_connected( id ) )
	{
		
	}
	}

	menu_destroy( menu );
	return PLUGIN_HANDLED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
