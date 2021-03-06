/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <codmod>

#define PLUGIN "Prefixy COD"
#define VERSION "1.0"
#define AUTHOR "DarkGL"

new pCvarPrefixy;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_message(get_user_msgid("SayText"),"handleSayText");
	
	pCvarPrefixy	=	register_cvar("cod_prefix","3");
}

public handleSayText(msgId,msgDest,msgEnt){
	new id = get_msg_arg_int(1);
	
	if(!is_user_connected(id))      return PLUGIN_CONTINUE;
	
	new szTmp[256],szTmp2[256],szTmp3[256];
	get_msg_arg_string(2,szTmp, charsmax( szTmp ) )
	
	new szPrefix[64]
	
	switch(get_pcvar_num(pCvarPrefixy)){
		case 1:{
			cod_get_class_name(cod_get_user_class(id),szTmp3,charsmax( szTmp3 ))
			formatex(szPrefix,charsmax( szPrefix ),"^x04[%s]",szTmp3);
		}
		case 2:{
			formatex(szPrefix,charsmax( szPrefix ),"^x04[%d]",cod_get_user_level(id));
		}
		case 3:{
			cod_get_class_name(cod_get_user_class(id),szTmp3,charsmax( szTmp3 ))
			formatex(szPrefix,charsmax( szPrefix ),"^x04[%s - %d]",szTmp3,cod_get_user_level(id));
		}
	}
	
	if(!equal(szTmp,"#Cstrike_Chat_All")){
		add(szTmp2,charsmax(szTmp2),szPrefix);
		add(szTmp2,charsmax(szTmp2)," ");
		add(szTmp2,charsmax(szTmp2),szTmp);
	}
	else{
		add(szTmp2,charsmax(szTmp2),szPrefix);
		add(szTmp2,charsmax(szTmp2),"^x03 %s1^x01 :  %s2");
	}
	
	set_msg_arg_string(2,szTmp2);
	
	return PLUGIN_CONTINUE;
}
