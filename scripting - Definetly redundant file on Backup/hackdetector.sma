#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <common_functions>
#include <hackd>

#pragma semicolon 1
#pragma ctrlchar '\'

// Uncomment to debug
//#define _DEBUG			// Enable debug output at server console.

#define AUTHOR "Lev @ AGHL.RU DevTeam"
#define PLUGIN "HackDetector"
#define PLUGIN_TAG "HackD"
#define VERSION "0.15.lite"
#define VERSION_CVAR "hackdetector_amxx_version"

// MAX constants
#define MAX_PLAYERS				32
#define MAX_PUNISH_LENGTH		128
#define MAX_FILENAME_LENGTH		256

// Constants
#define DEF_ADMIN_LEVEL			ADMIN_BAN	// Default access level for commands (flag d).
#define TASK_PUNISH_BASE		500


new const Float:SpeedhackDetectionThreshold = 1.0;			// Overspeed values (in percents) below this will not account for speedhack detection
new const Float:SlowmotionDetectionThreshold = -20.0;		// Slowspeed values (in percents) above this will not account for slowmotion detection

new const Float:InstantPunishDelay = -1.0;
new const Float:MaxPunishDelay = 90.0;
new const Float:MinPunishDelay = 90.0;

new const _shPunish[] = "kick [userid] '[reason]'; addip 60.0 [ip]";
new const _smPunish[] = "kick [userid] '[reason]'";
new const _shReason[] = "Speed hack detected";
new const _smReason[] = "Slow motion detected";

new const _warningSound[] = "buttons/blip2.wav";
new const _fullLogFile[] = "HD_%Y%m%d.log";

// Players' data
new _playerSpeedhackDetections[MAX_PLAYERS + 1];			// Player speedhack detections
new Float:_playerSpeedhackPercent[MAX_PLAYERS + 1];			// Player speedhack summary percent
new bool:_playerSpeedhackPunished[MAX_PLAYERS + 1];			// Player punishment was applied for speedhack violation
new _playerSlowmotionDetections[MAX_PLAYERS + 1];			// Player slowmotion detections
new Float:_playerSlowmotionPercent[MAX_PLAYERS + 1];		// Player slowmotion summary percent
new bool:_playerSlowmotionPunished[MAX_PLAYERS + 1];		// Player punishment was applied for slowmotion violation
new _playerPunishment[MAX_PLAYERS + 1][MAX_PUNISH_LENGTH + 1];		// Player punish command text if any

// CVARs
new hd_admin_notify, hd_sh_punish, hd_sm_punish;
new hd_sh_reason, hd_sm_reason;


public plugin_precache()
{
	precache_sound(_warningSound);
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar(VERSION_CVAR, VERSION, FCVAR_SPONLY | FCVAR_SERVER | FCVAR_UNLOGGED);

	hd_admin_notify = register_cvar("hd_admin_notify", "2");		// Level for admins notification: 0 - none, 1 - bad, 2 - notify, 3 - warning
	hd_sh_punish = register_cvar("hd_sh_punish", _shPunish);		// Command for automatic punishing of player with speedhack
	hd_sm_punish = register_cvar("hd_sm_punish", _smPunish);		// Command for automatic punishing of player with slowmotion
	hd_sh_reason = register_cvar("hd_sh_reason", _shReason);		// Reason for banning player with speedhack
	hd_sm_reason = register_cvar("hd_sm_reason", _smReason);		// Reason for banning player with slowmotion

	register_concmd("hd_stat", "CmdStat", DEF_ADMIN_LEVEL, "(Outputs users info)");

	hackd_speedhack_forward("speedhack_detected");
	hackd_slowmotion_forward("slowmotion_detected");
}

public client_disconnect(id)
{
	if (_playerSpeedhackDetections[id] > 0)
		AddLog(id, _fullLogFile, "SH: D: %2i %5.1f", _playerSpeedhackDetections[id], _playerSpeedhackPercent[id]);
	if (_playerSlowmotionDetections[id] > 0)
		AddLog(id, _fullLogFile, "SM: D: %2i %5.1f", _playerSlowmotionDetections[id], _playerSlowmotionPercent[id]);
	if (task_exists(TASK_PUNISH_BASE + id))
	{
		remove_task(TASK_PUNISH_BASE + id);
		ApplyPunishToPlayer(TASK_PUNISH_BASE + id);
	}
	_playerSpeedhackDetections[id] = 0;
	_playerSpeedhackPercent[id] = 0.0;
	_playerSpeedhackPunished[id] = false;
	_playerSlowmotionDetections[id] = 0;
	_playerSlowmotionPercent[id] = 0.0;
	_playerSlowmotionPunished[id] = false;
	_playerPunishment[id][0] = 0;
}

public speedhack_detected(id, Float:percent, cmds, drops)
{
#if defined _DEBUG
	server_print("speedhack_detected: %i, %f, %i, %i", id, percent, cmds, drops);
#endif
	if (percent < SpeedhackDetectionThreshold)
		return;

	_playerSpeedhackDetections[id]++;
	_playerSpeedhackPercent[id] += percent;

	// Log
	if (_playerSpeedhackDetections[id] < 10)
		AddLog(id, _fullLogFile, "SH: U: %2i %5.1f %4i %3i", _playerSpeedhackDetections[id], _playerSpeedhackPercent[id], cmds, drops);

	// Punish
	new Float:punishDelay = 0.0;
	if (!_playerSpeedhackPunished[id] && (_playerSpeedhackDetections[id] >= 10 || _playerSpeedhackPercent[id] > 100.0))
	{
		_playerSpeedhackPunished[id] = true;
		punishDelay = PunishPlayer(id, hd_sh_punish, hd_sh_reason, InstantPunishDelay);
	}

	// Notify
	if (_playerSpeedhackDetections[id] <= 3 && get_pcvar_num(hd_admin_notify) >= 1)
		ShNotifyAdmins(id, punishDelay);
}

public slowmotion_detected(id, Float:percent, cmds, drops)
{
#if defined _DEBUG
	server_print("slowmotion_detected: %i, %f, %i, %i", id, percent, cmds, drops);
#endif
	if (percent > SlowmotionDetectionThreshold)
		return;

	_playerSlowmotionDetections[id]++;
	_playerSlowmotionPercent[id] += percent;

	// Log
	if (_playerSlowmotionDetections[id] < 10)
		AddLog(id, _fullLogFile, "SM: U: %2i %5.1f %4i %3i", _playerSlowmotionDetections[id], _playerSlowmotionPercent[id], cmds, drops);

	// Punish
	new Float:punishDelay = 0.0;
	if (!_playerSlowmotionPunished[id] && (_playerSlowmotionDetections[id] >= 10 || _playerSlowmotionPercent[id] < -100.0))
	{
		_playerSlowmotionPunished[id] = true;
		punishDelay = PunishPlayer(id, hd_sm_punish, hd_sm_reason, InstantPunishDelay);
	}

	// Notify
	if (_playerSlowmotionDetections[id] <= 3 && get_pcvar_num(hd_admin_notify) >= 2)
		SmNotifyAdmins(id, punishDelay);
}

NotifyAdmins(id, Float:punishDelay, const reason[])
{
	new players[MAX_PLAYERS], num, message[128], name[32], playerId;
	get_players(players, num);
	for (new i = 0; i < num; ++i)
	{
		playerId = players[i];
		if (!access(playerId, DEF_ADMIN_LEVEL))
			continue;
		if (message[0] == 0)
		{
#if defined _DEBUG
			if (punishDelay > 0.0)
				server_print("Scheduled punish after: %f seconds", punishDelay);
#endif
			get_user_name(id, name, charsmax(name));
			format(message, charsmax(message), "Player \"%s\" triggered %s.%s", name, reason,
				punishDelay < 0 ? " Punishment applied." : (punishDelay > 0 ? " Punishment scheduled." : ""));
		}
		set_hudmessage(250, 160, 0, -1.0, -0.08, 0, 16.0, 3.5, 0.01, 0.5, -1);
		show_hudmessage(playerId, message);
		client_print(playerId, print_chat, message);
		client_cmd(playerId, "spk %s", _warningSound);
	}
}

ShNotifyAdmins(id, Float:punishDelay)
{
	new reason[128];
	format(reason, charsmax(reason), "speedhack alert with speed gain percentage %f", _playerSpeedhackPercent[id]);
	NotifyAdmins(id, punishDelay, reason);
}

SmNotifyAdmins(id, Float:punishDelay)
{
	new reason[128];
	format(reason, charsmax(reason), "slowmotion alert with speed loss percentage %f", _playerSlowmotionPercent[id]);
	NotifyAdmins(id, punishDelay, reason);
}

/// PunishPlayer: construct and apply or schedule a punishment for a player.
/// punish - cvar to get punishment from.
/// punishDelay - delay before punishment, 0.0 for auto generate random value, or negative value for instant punish.
/// Returns negative value if punishment was applied, 0.0 if wasn't and positive if punishment was scheduled.
Float:PunishPlayer(id, punish, reason, Float:punishDelay)
{
#if defined _DEBUG
	server_print("PunishPlayer: %u, %f", id, punishDelay);
#endif
	get_pcvar_string(punish, _playerPunishment[id], MAX_PUNISH_LENGTH);
	if (_playerPunishment[id][0] == 0)
		return 0.0;	// punishment isn't applied
	new reasonString[MAX_PUNISH_LENGTH];
	get_pcvar_string(reason, reasonString, charsmax(reasonString));
	replace_all(reasonString, charsmax(reasonString), "\"", "");

	new userid[10], authid[32], name[32], ip[16];
	format(userid, charsmax(userid), "#%i", get_user_userid(id));
	get_user_authid(id, authid, charsmax(authid));
	get_user_name(id, name, charsmax(name));
	get_user_ip(id, ip, charsmax(ip), 1);

	replace_all(_playerPunishment[id], MAX_PUNISH_LENGTH, "'", "\"");
	replace_all(_playerPunishment[id], MAX_PUNISH_LENGTH, "[userid]", userid);
	replace_all(_playerPunishment[id], MAX_PUNISH_LENGTH, "[authid]", authid);
	replace_all(_playerPunishment[id], MAX_PUNISH_LENGTH, "[name]", name);
	replace_all(_playerPunishment[id], MAX_PUNISH_LENGTH, "[ip]", ip);
	replace_all(_playerPunishment[id], MAX_PUNISH_LENGTH, "[reason]", reasonString);

	if (punishDelay < 0.0)
	{
		ApplyPunishToPlayer(TASK_PUNISH_BASE + id);
		return punishDelay;
	}
	if (punishDelay == 0.0)
		punishDelay = random_float(MinPunishDelay, MaxPunishDelay);
	set_task(punishDelay, "ApplyPunishToPlayer", TASK_PUNISH_BASE + id);

	return punishDelay;
}

public ApplyPunishToPlayer(id)
{
	id -= TASK_PUNISH_BASE;
#if defined _DEBUG
	server_print("ApplyPunishToPlayer: %u", id);
	server_print(_playerPunishment[id]);
#endif
	server_cmd(_playerPunishment[id]);
}



//****************************************
//*                                      *
//*  Logging and statistics              *
//*                                      *
//****************************************

AddLog(id, const logFileNameTpl[], fmt[], any:...)
{
	// Full connections log
	new text[1024], tmp[64], name[32];
	get_user_name(id, name, charsmax(name));
	format(tmp, charsmax(tmp), "%-25.25s %s", name, fmt);
	vformat(text, charsmax(text), tmp, 4);

	new filename[MAX_FILENAME_LENGTH + 1];
	get_time(logFileNameTpl, filename, charsmax(filename));
	log_to_file(filename, text);
}



//****************************************
//*                                      *
//*  Stat command                        *
//*                                      *
//****************************************

/// Format: hd_stat
public CmdStat(id, level, cid)
{
	// Check if admin has access right
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED;

	// Log command usage
	new authid[32], name[32];
	get_user_authid(id, authid, charsmax(authid));
	get_user_name(id, name, charsmax(name));
	log_amx("CmdStat: \"%s<%d><%s><>\" ask for players list", name, get_user_userid(id), authid);

	// Output table header
	ConsolePrint(id, "\n%L:\n #%-3s %-15.15s %-4s %7s", id, "CLIENTS_ON_SERVER",
		"uid", "name", "sh.c", "sh.gain");

	// Output players' data
	new players[MAX_PLAYERS], num, playerId;
	get_players(players, num);
	for (new i = 0; i < num; i++)
	{
		playerId = players[i];
		get_user_name(playerId, name, charsmax(name));
		ConsolePrint(id, "%5u %-15.15s %4i %7.1f",
			get_user_userid(playerId), name,
			_playerSpeedhackDetections[playerId], _playerSpeedhackPercent[playerId]);
	}
	console_print(id, "%L", id, "TOTAL_NUM", num);

	return PLUGIN_HANDLED;
}
