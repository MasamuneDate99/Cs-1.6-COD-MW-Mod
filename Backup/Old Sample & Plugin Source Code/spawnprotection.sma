//----------------------------------------------------------//
/* CREDITS :
      Thanks to Xeroblood, JJkiller, KingPin for helping me make
      this plugin and Firestorm for helping adding a lot of things

   INSTALLING :
      Download .SMA to Scripting folder, run compiler, copy the
      file from Compiled folder and paste in Plugins folder, add the plugin name
      in the Amxx plugins.ini ie : spawnprotection.amxx

   DESCRIPTION :
      Protects players when the spawn from being killed

   CHANGELOG :
      Version 1.0 - First Release
      Version 2.0 - Fixed godmode cvar problems
      Version 3.0 - Added message time control cvar
      Version 4.0 - Fixed errors
      Version 5.0 - Added message control cvar
      Version 6.0 - Fixed errors - THANKS VEN!
      Version 7.0 - Cleaned up plugin and fixed errors - THANKS
                    AVALANCHE, VEN and SubStream!
*/
//----------------------------------------------------------//
#include <amxmodx>
#include <amxmisc>
#include <fun>
//----------------------------------------------------------//
public plugin_init()
{
   register_plugin("Spawn Protection", "7.0", "Peli") // Plugin Information
   register_concmd("amx_sptime", "cmd_sptime", ADMIN_CVAR, "1 through 10 to set Spawn Protection time") // Concmd (Console Command) for the CVAR time
   register_concmd("amx_spmessage", "cmd_spmessage", ADMIN_CVAR, "1 = Turn Spawn Protection Message on , 0 = Turn Spawn Protection message off") // Concmd for the CVAR message
   register_concmd("amx_spshellthickness", "cmd_spshellthickness", ADMIN_CVAR, "1 through 100 to set Glow Shellthickness") // Concmd for the shellthickness
   register_cvar("sv_sp", "1") // Cvar (Command Variable) for the plugin on/off
   register_cvar("sv_sptime", "5") // Cvar for controlling the message time (1-10 seconds)
   register_cvar("sv_spmessage", "1") // Cvar for controlling the message on/off
   register_cvar("sv_spshellthick", "25") // Cvar for controlling the glow shell thickness
   register_event("ResetHUD", "sp_on", "be")
   register_clcmd("fullupdate", "clcmd_fullupdate")
}
//----------------------------------------------------------//
public client_disconnect(id)
{
   remove_task(id)
   return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public cmd_sptime(id, level, cid) // This is the function for the cvar time control
{
   if(!cmd_access(id, level, cid, 2))
   return PLUGIN_HANDLED

   new arg_str[3]
   read_argv(1, arg_str, 3)
   new arg = str_to_num(arg_str)

   if(arg > 10 || arg < 1)
   {
      client_print(id, print_chat, "You have to set the Spawn Protection time between 1 and 10 seconds")
      return PLUGIN_HANDLED
   }

   else if (arg > 0 || arg < 11)
   {
      set_cvar_num("sv_sptime", arg)
      client_print(id, print_chat, "You have set the Spawn Protection time to %d second(s)", arg)
      return PLUGIN_HANDLED
   }
   return PLUGIN_CONTINUE
}
//----------------------------------------------------------//
public cmd_spmessage(id, level, cid) // This is the function for the cvar message control
{
   if (!cmd_access(id, level, cid, 2))
   {
      return PLUGIN_HANDLED
   }

   new sp[3]
   read_argv(1, sp, 2)

   if (sp[0] == '1')
   {
      set_cvar_num("amx_spmessage", 1)
   }

   else if (sp[0] == '0')
   {
      set_cvar_num("amx_spmessage", 0)
   }

   else if (sp[0] != '1' || sp[0] != '0')
   {
      console_print(id, "Usage : amx_spmessage 1 = Messages ON | 0 = Messages OFF")
      return PLUGIN_HANDLED
   }

   return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public cmd_spshellthickness(id, level, cid)
{
   if(!cmd_access(id, level, cid, 2))
   return PLUGIN_HANDLED

   new arg_str[3]
   read_argv(1, arg_str, 3)
   new arg = str_to_num(arg_str)

   if(arg > 100 || arg < 1)
   {
      client_print(id, print_chat, "You have to set the Glow Shellthickness between 1 and 100")
      return PLUGIN_HANDLED
   }

   else if (arg > 0 || arg < 101)
   {
      set_cvar_num("sv_spshellthickness", arg)
      client_print(id, print_chat, "You have set the Glow Shellthickness to %d", arg)
      return PLUGIN_HANDLED
   }
   return PLUGIN_CONTINUE
}
//----------------------------------------------------------//
public sp_on(id) // This is the function for the event godmode
{
   if(get_cvar_num("sv_sp") == 1)
   {
      set_task(0.1, "protect", id)
   }

   return PLUGIN_CONTINUE
}
//----------------------------------------------------------//
public protect(id) // This is the function for the task_on godmode
{
   new Float:SPTime = get_cvar_float("sv_sptime")
   new SPSecs = get_cvar_num("sv_sptime")
   new FTime = get_cvar_num("mp_freezetime")
   new SPShell = get_cvar_num("sv_spshellthick")
   set_user_godmode(id, 1)

   if(get_user_team(id) == 1)
   {
      set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, SPShell)
   }

   if(get_user_team(id) == 2)
   {
      set_user_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, SPShell)
   }

   if(get_cvar_num("sv_spmessage") == 1)
   {
      set_hudmessage(255, 1, 1, -1.0, -1.0, 0, 6.0, SPTime+FTime, 0.1, 0.2, 4)
      show_hudmessage(id, "Spawn Protection is enabled for %d second(s)", SPSecs)
   }

   set_task(SPTime+FTime, "sp_off", id)
   return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public sp_off(id) // This is the function for the task_off godmode
{
   new SPShell = get_cvar_num("sv_spshellthick")
   if(!is_user_connected(id))
   {
      return PLUGIN_HANDLED
   }

   else
   {
      set_user_godmode(id, 0)
      set_user_rendering(id, kRenderFxGlowShell, 0, 0,0, kRenderNormal, SPShell)
      return PLUGIN_HANDLED
   }

   return PLUGIN_HANDLED
}
//----------------------------------------------------------//
public clcmd_fullupdate(id)
{
   return PLUGIN_HANDLED
}
//----------------------------------------------------------//