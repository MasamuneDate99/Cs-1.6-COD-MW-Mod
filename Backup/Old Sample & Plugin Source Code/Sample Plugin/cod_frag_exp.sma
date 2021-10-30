#include <amxmodx>
#include <amxmisc>
#include <codmod>

#define PLUGIN "[COD] EXP dla najlepszych 3 graczy"
#define VERSION "0.69"
#define AUTHOR "pRED (edit by =ToRRent=)"

// Dla tych nie kumatych ;) jest to przerobiony plugin bf2medals autorstwa pRED

new gmsgSayText;

new cvar_exp_1miejsce, cvar_exp_2miejsce, cvar_exp_3miejsce;
new exp_1miejsce, exp_2miejsce, exp_3miejsce;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cvar_exp_1miejsce = register_cvar("cod_exp1", "35500"); // ilosc doswiadczenia za 1 miejsce 
	cvar_exp_2miejsce = register_cvar("cod_exp2", "27750"); // ilosc doswiadczenia za 2 miejsce 
	cvar_exp_3miejsce = register_cvar("cod_exp3", "17450"); // ilosc doswiadczenia za 3 miejsce
	
	register_message(SVC_INTERMISSION, "Message_Intermission");

	gmsgSayText = get_user_msgid("SayText");
	
	exp_1miejsce = get_pcvar_num(cvar_exp_1miejsce);
	exp_2miejsce = get_pcvar_num(cvar_exp_2miejsce);
	exp_3miejsce = get_pcvar_num(cvar_exp_3miejsce);
}
public Message_Intermission(){
	set_task(0.1, "przyznanie_doswiadczenia");
}
public przyznanie_doswiadczenia()
{
	//uruchom podczas SVC_INTERMISSION (tuz przed zmiana mapy)
	//Znajdz 3 najlepszych graczy z najwieksza liczba fragow i przyznaj doswiadczenie

	new players[32], num;
	get_players(players, num, "h");

	new tempfrags, id;

	new swapfrags, swapid;

	new starfrags[3]; //0 - 3 miejsce / 1 - 2 miejsce / 2 - 1 miejsce
	new starid[3];

	for (new i = 0; i < num; i++)
	{
		id = players[i];
		tempfrags = get_user_frags(id);
		if ( tempfrags > starfrags[0] )
		{
			starfrags[0] = tempfrags;
			starid[0] = id;
			cod_set_user_xp(starid[0], cod_get_user_xp(starid[0])+exp_3miejsce);
			if ( tempfrags > starfrags[1] )
			{
				swapfrags = starfrags[1];
				swapid = starid[1];
				starfrags[1] = tempfrags;
				starid[1] = id;
				starfrags[0] = swapfrags;
				starid[0] = swapid;
				cod_set_user_xp(starid[1], cod_get_user_xp(starid[1])+exp_2miejsce);

				if ( tempfrags > starfrags[2] )
				{
					swapfrags = starfrags[2];
					swapid = starid[2];
					starfrags[2] = tempfrags;
					starid[2] = id;
					starfrags[1] = swapfrags;
					starid[1] = swapid;
					cod_set_user_xp(starid[2], cod_get_user_xp(starid[2])+exp_1miejsce);

				}
			}
		}
	}
	new name[32];
	new winner = starid[2];

	if ( !winner )
		return;

	new line[100];
	line[0] = 0x04;
	formatex(line[1], 98, "The best players on this map:");
	ShowColorMessage(starid[2], MSG_BROADCAST, line);
	line[0] = 0x04;
	get_user_name(starid[2], name, charsmax(name));
	line[0] = 0x04;
	formatex(line[1], 98, "1. %s - %i frags (+%d Exp.)", name, starfrags[2], exp_1miejsce);
	ShowColorMessage(starid[2], MSG_BROADCAST, line);

	get_user_name(starid[1], name, charsmax(name));
	line[0] = 0x04;
	formatex(line[1], 98, "2. %s - %i frags (+%d Exp.)", name, starfrags[1], exp_2miejsce);
	ShowColorMessage(starid[2], MSG_BROADCAST, line);

	get_user_name(starid[0], name, charsmax(name));
	line[0] = 0x04;
	formatex(line[1], 98, "3. %s - %i frags (+%d exp.)", name, starfrags[0], exp_3miejsce);

	ShowColorMessage(starid[2], MSG_BROADCAST, line);
}
ShowColorMessage(id, type, message[])
{
	message_begin(type, gmsgSayText, _, id);
	write_byte(id);
	write_string(message);
	message_end();
}
