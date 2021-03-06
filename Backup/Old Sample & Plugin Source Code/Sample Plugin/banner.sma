#include <amxmodx>

#define PLUGIN "Loading Game Banner"
#define VERSION "1.0"
#define AUTHOR "DaddyKuba"

#define MAX_SIZE 1012
#define BANNER_FILE "gfx/rglagi.tga"

new const g_Files[][64] =
{
	"resource/LoadingDialog.res",
	"resource/LoadingDialogNoBanner.res",
	"resource/LoadingDialogVAC.res"
}

new g_Text[MAX_SIZE], g_CvarEnabled

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	g_CvarEnabled	= register_cvar("amx_banner", "1")
	
	if (get_pcvar_num(g_CvarEnabled))
		set_task(0.1, "Read_LoadingGame")
}

public client_connect(id)
{
	client_cmd(id, "cl_allowdownload 1")
}

public plugin_precache()
{
	precache_generic(BANNER_FILE)
}

public Read_LoadingGame()
{
	new i_File, s_File[128], s_Banner[32], i_Len

	i_Len = strlen(BANNER_FILE)
	get_configsdir(s_File, charsmax(s_File))
	format(s_File, charsmax(s_File), "%s/banner.ini", s_File)
	formatex(s_Banner, i_Len - 4, "%s", BANNER_FILE)
	i_File = fopen(s_File, "r")
	fgets(i_File, g_Text, MAX_SIZE)
	replace(g_Text, charsmax(g_Text), "banner_file", s_Banner)
	fclose(i_File)
}

public client_putinserver(id)
{
	if (get_pcvar_num(g_CvarEnabled))
		set_task(3.0, "Change_LoadingGame")
}

public Change_LoadingGame(id)
{
	for (new i = 0; i < 3; i++)
	{
		client_cmd(id, "motdfile %s", g_Files[i])
		client_cmd(id, "motd_write %s", g_Text)
	}

	client_cmd(id, "motdfile motd.txt")    
}
 
stock get_configsdir(s_Name[], i_Len)
{
	return get_localinfo("amxx_configsdir", s_Name, i_Len)
}
