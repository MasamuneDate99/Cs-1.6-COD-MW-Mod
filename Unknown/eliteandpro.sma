#include <amxmodx>
#include <amxmisc>
#include <ColorChat>

#define PLUGIN "kup_premium"
#define VERSION "v1.0"
#define AUTHOR "Rob Zombie"

new premium_on

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say /kup","premium")
	register_clcmd("say /codinfo","premium")
	premium_on = register_cvar("premium_on","1")
	register_logevent("pokaz_info",2,"1=Round_Start")
}
public premium(id)
{
	if(get_pcvar_num(premium_on))
	{
		show_motd(id,"/addons/amxmodx/data/new.txt","Pro and Elite")
	}
}
public pokaz_info(id)
{
	ColorChat(0,GREEN,"~^x01 Say^x03 /codinfo^x01 to learn how to get Special and Elite^x04~")
	ColorChat(0,RED,"~^x01 [SawaHijau.CS] COD MW Rules^x03 tiny.cc/sawahcod^x01 read it first !^x04~")
	ColorChat(0,RED,"~^x01 Type^x03 /help^x01 to show basic help menu !^x04~")
	ColorChat(0,RED,"^x03~^x01 Visit ^x04 http://sawahijau.web.id/forum/^x01 to get all latest^x04 Information !^x03~")
	ColorChat(0,GREEN,"~^x01 Type^x03 /shop^x01 ,to buy any exp and perk^x04~")
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
