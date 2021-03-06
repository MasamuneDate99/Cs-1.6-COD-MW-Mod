/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <codmod>

#define PLUGIN "[COD] Admin Commands"
#define VERSION "0.97"
#define AUTHOR "QTM_Peyote"

#define ACCESS_FLAG ADMIN_RCON

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_concmd("cod_giveperk", "cmd_giveperk", ACCESS_FLAG, "<name> <perk_num> <perk_value>");
	register_concmd("cod_giveperk2", "cmd_giveperk2", ACCESS_FLAG, "<name> <perk_num> <perk_value>");
	register_concmd("cod_giveperkname", "cmd_giveperkbyname", ACCESS_FLAG, "<name> <perk_name> <perk_value>");
	register_concmd("cod_setlvl", "cmd_setlvl", ACCESS_FLAG, "<name> <ammount>");
	register_concmd("cod_givexp", "cmd_givexp", ACCESS_FLAG, "<name> <ammount>");
}

public cmd_giveperk(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3))
		return PLUGIN_CONTINUE;
	
	new arg[33];
	read_argv(1, arg, 32);
	new target = cmd_target(id, arg, CMDTARGET_ALLOW_SELF);
	
	if(!is_user_connected(target))
		return PLUGIN_CONTINUE;
		
	read_argv(2, arg, 32);
	new perk = str_to_num(arg);
	read_argv(3, arg, 32);
	new perk_value = str_to_num(arg);
	
	cod_set_user_perk(target, perk, perk_value, 1);
	
	return PLUGIN_CONTINUE;
}

public cmd_giveperk2(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3))
		return PLUGIN_CONTINUE;
	
	new arg[33];
	read_argv(1, arg, 32);
	new target = cmd_target(id, arg, CMDTARGET_ALLOW_SELF);
	
	if(!is_user_connected(target))
		return PLUGIN_CONTINUE;
		
	read_argv(2, arg, 32);
	new perk = str_to_num(arg);
	read_argv(3, arg, 32);
	new perk_value = str_to_num(arg);
	
	cod_set_user_perk(target, perk, perk_value, 1, 1);
	
	return PLUGIN_CONTINUE;
}

public cmd_giveperkbyname(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3))
		return PLUGIN_CONTINUE;
	
	new arg[33];
	read_argv(1, arg, 32);
	new target = cmd_target(id, arg, CMDTARGET_ALLOW_SELF);
	
	if(!is_user_connected(target))
		return PLUGIN_CONTINUE;
		
	read_argv(2, arg, 32);
	remove_quotes(arg);
	new perk = cod_get_perkid(arg);
	read_argv(3, arg, 32);
	new perk_value = str_to_num(arg);
	
	cod_set_user_perk(target, perk, perk_value, 1);
	
	return PLUGIN_CONTINUE;
}

public cmd_setlvl(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3))
		return PLUGIN_CONTINUE;
	
	new arg[33];
	read_argv(1, arg, 32);
	new target = cmd_target(id, arg, CMDTARGET_ALLOW_SELF);
	
	if(!is_user_connected(target))
		return PLUGIN_CONTINUE;
		
	read_argv(2, arg, 32);
	new level = str_to_num(arg);
	
	cod_set_user_xp(target, cod_get_level_xp(level-1));
	
	return PLUGIN_CONTINUE;
}

public cmd_givexp(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3))
		return PLUGIN_CONTINUE;
	
	new arg[33];
	read_argv(1, arg, 32);
	new target = cmd_target(id, arg, CMDTARGET_ALLOW_SELF);

	if(!is_user_connected(target))
		return PLUGIN_CONTINUE;
		
	read_argv(2, arg, 32);
	new xp = str_to_num(arg);
	
	cod_set_user_xp(target, cod_get_user_xp(id)+xp);
	
	return PLUGIN_CONTINUE;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
