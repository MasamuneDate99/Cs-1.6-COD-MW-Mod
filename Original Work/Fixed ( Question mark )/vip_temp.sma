#include <amxmodx>
#include <codmod>
#include <cstrike>
#include <fakemeta>
#include <fun>
#include <hamsandwich>

#define DMG_HE (1<<24)
#define IsPlayer(%1) (1<=%1<=maxPlayers)

forward amxbans_admin_connect(id);

new bool:g_FreezeTime, bool:g_Vip[33], bool:g_speed[33], g_Hudmsg, ioid,
maxPlayers, menu, menu_callback_handler;

public plugin_init(){
	register_plugin("VIP Ultimate", "12.3.0.2", "benio101 & speedkill");
	RegisterHam(get_player_resetmaxspeed_func(), "player", "fw_Player_ResetMaxSpeed", 1);
	register_logevent("logevent_round_start", 2, "1=Round_Start");
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0");
	RegisterHam(Ham_Spawn, "player", "SpawnedEventPre", 1);
	register_logevent("RoundEnd", 2, "1=Round_End");
	RegisterHam(Ham_TakeDamage, "player", "takeDamage", 0);
	register_event("DeathMsg", "DeathMsg", "a");
	register_clcmd("say /vip", "ShowMotd");
	g_Hudmsg=CreateHudSyncObj();
}
public client_authorized(id , const authid[]){
	if(get_user_flags(id) & 65536 == 65536){
		client_authorized_vip(id);
	}
}
public client_authorized_vip(id){
	g_Vip[id]=true;
	new g_Name[64];
	get_user_name(id,g_Name,charsmax(g_Name));
	set_hudmessage(24, 190, 220, 0.25, 0.2, 0, 6.0, 6.0);
	ShowSyncHudMsg(0, g_Hudmsg, "VIP %s coming to play !",g_Name);
}
public client_disconnected(id){
	if(g_Vip[id]){
		client_disconnect_vip(id);
	}
}
public client_disconnect_vip(id){
	g_Vip[id]=false;
	g_speed[id]=false;
}
Ham:get_player_resetmaxspeed_func(){
	#if defined Ham_CS_Player_ResetMaxSpeed
	return IsHamValid(Ham_CS_Player_ResetMaxSpeed)?Ham_CS_Player_ResetMaxSpeed:Ham_Item_PreFrame;
	#else
	return Ham_Item_PreFrame;
	#endif
}
public fw_Player_ResetMaxSpeed(id){
	if(g_Vip[id]){
		if(is_user_alive(id)){
			fw_Player_ResetMaxSpeedVip(id);
		}
	}
}
public logevent_round_start(){
	g_FreezeTime=false;
}
public event_new_round(){
	g_FreezeTime=true;
}
public SpawnedEventPre(id){
	if(g_Vip[id]){
		if(is_user_alive(id)){
			SpawnedEventPreVip(id);
		}
	}
}
public plugin_cfg(){
	maxPlayers=get_maxplayers();
}
public SpawnedEventPreVip(id){
	g_speed[id]=false;
	new henum=(user_has_weapon(id,CSW_HEGRENADE)?cs_get_user_bpammo(id,CSW_HEGRENADE):0);
	give_item(id, "weapon_hegrenade");
	++henum;
	cs_set_user_bpammo(id, CSW_HEGRENADE, 2);
	new fbnum=(user_has_weapon(id,CSW_FLASHBANG)?cs_get_user_bpammo(id,CSW_FLASHBANG):0);
	give_item(id, "weapon_flashbang");
	++fbnum;
	cs_set_user_bpammo(id, CSW_FLASHBANG, 2);
	new sgnum=(user_has_weapon(id,CSW_SMOKEGRENADE)?cs_get_user_bpammo(id,CSW_SMOKEGRENADE):0);
	give_item(id, "weapon_smokegrenade");
	++sgnum;
	show_vip_menu(id);
}
public RoundEnd(){
	for(new i=1; i<=maxPlayers; ++i){
		g_speed[i]=false;
		if(is_user_alive(i)){
			fw_Player_ResetMaxSpeedVip(i);
		}
	}
	for(new i=1; i<=maxPlayers; ++i){
		if(is_user_alive(i)){
			set_user_footsteps(i, 0);
		}
	}
}
public fw_Player_ResetMaxSpeedVip(id){
	if(!g_FreezeTime){
		if(g_speed[id]){
			set_user_maxspeed(id,get_user_maxspeed(id) + 80);
		}
	}
}
public menu_1_handler(id){
	set_user_footsteps(id,1);
}
public takeDamage(this, idinflictor, idattacker, Float:damage, damagebits){
	if(((IsPlayer(idattacker) && is_user_connected(idattacker) && g_Vip[idattacker] && (ioid=idattacker)) ||
	(ioid=pev(idinflictor, pev_owner) && IsPlayer(ioid) && is_user_connected(ioid) && g_Vip[ioid]))){
		if(damagebits & DMG_HE){
			damage*=(100+100)/100;
		}
	}
}
public DeathMsg(){
	new killer=read_data(1);
	new victim=read_data(2);
	
	if(is_user_alive(killer) && g_Vip[killer] && get_user_team(killer) != get_user_team(victim)){
		DeathMsgVip(killer,victim,read_data(3));
	}
}
public DeathMsgVip(kid,vid,hs){
	cod_set_user_xp(kid, cod_get_user_xp(kid)+(hs?150:50));
}
public show_vip_menu(id){
	menu=menu_create("\rMenu VIPa","menu_handler");
	menu_callback_handler=menu_makecallback("menu_callback");
	new bool:active=false, num=-1;
	menu_additem(menu,"\wExtra Speed & Silent Step","",0,menu_callback_handler);
	if(menu_callback(id, menu, ++num)==ITEM_ENABLED){
		active=true;
	}
	if(active){
		menu_setprop(menu,MPROP_EXITNAME,"Exit");
		menu_setprop(menu,MPROP_TITLE,"\wCoD VIP Menu");
		menu_setprop(menu,MPROP_NUMBER_COLOR,"\r");
		menu_display(id, menu);
	} else {
		menu_destroy(menu);
	}
}
public menu_callback(id, menu, item){
	if(is_user_alive(id)){
		if(item==0){
			return ITEM_ENABLED;
		}
	}
	return ITEM_DISABLED;
}
public menu_handler(id, menu, item){
	if(is_user_alive(id)){
		if(item==0){
			menu_1_handler(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public ShowMotd(id){
	show_motd(id, "vip.txt", "Informacje o vipie");
}
public amxbans_admin_connect(id){
	client_authorized(id,"");
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
