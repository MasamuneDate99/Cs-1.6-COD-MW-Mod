#include <amxmodx>
#include <amxmisc>
#include <nvault>
#include <fakemeta>
#include <fun>
#include <colorchat>

new gEntAiming[33];
new Vault;
new const szPrefix[] = "[Warn]^x01";

public plugin_init()
{
	register_plugin("Warn Mine", "1.0", "GeDox");
	
	Vault = nvault_open("warn_mine");
	
	register_forward(FM_AddToFullPack, "fwdAddToFullPack", 1);
	
	register_clcmd("amx_warn_mine", "cmd_warn_mine");
}
public plugin_end()
	nvault_close(Vault)
	
public client_PostThink(id)
{
	if(is_user_alive(id) || !is_user_admin(id))
	{
		gEntAiming[id] = 0;
		return;
	}
	
	static body, szClass[32];
	get_user_aiming(id, gEntAiming[id], body, 1000);
	pev(gEntAiming[id], pev_classname, szClass, 31);
	
	if(!equal(szClass, "mine"))
		gEntAiming[id] = 0;
}

public fwdAddToFullPack(es_handle, e, ent, host, hostflags, player, pSet)
{
	if(!is_user_connected(host) || !pev_valid(ent) || is_user_alive(host) || !is_user_admin(host))
		return;
	
	new szClass[32];
	pev(ent, pev_classname, szClass, 31);
	
	if(equal(szClass, "mine"))
	{
		if(ent != gEntAiming[host])
		{
			set_es(es_handle, ES_RenderMode, kRenderTransAdd);
			set_es(es_handle, ES_RenderAmt, 255.0);
		}
		else if(pev_valid(gEntAiming[host]))
		{
			set_es(es_handle, ES_RenderFx, kRenderFxGlowShell)
			set_es(es_handle, ES_RenderColor, {255, 0, 0});
			set_es(es_handle, ES_RenderMode, kRenderGlow);
			set_es(es_handle, ES_RenderAmt, 125.0);
			
			new owner_name[32];
			new owner = pev(ent, pev_owner);
			
			if(is_user_connected(owner))
				get_user_name(owner, owner_name, charsmax(owner_name));
			else
				format(owner_name, charsmax(owner_name), "h4xer");
				
			client_print(host, print_center, "Admin: %s", owner_name);
		}
	}
}

public cmd_warn_mine(id)
{
	if(!(get_user_flags(id) & ADMIN_BAN))
		return PLUGIN_HANDLED;
		
	if(pev_valid(gEntAiming[id]))
	{
		new lsWarn[5], ldWarn;
		new owner_name[32], admin_name[32];
		
		get_user_name(id, admin_name, charsmax(admin_name));
		get_user_name(pev(gEntAiming[id], pev_owner), owner_name, charsmax(owner_name));
	
		if(nvault_get(Vault, owner_name, lsWarn, 4)) 
			ldWarn = str_to_num(lsWarn)+1;
		else
			ldWarn = 1;
		
	
		if(ldWarn >= 2)
		{
			client_print(id, print_chat, "amx_ssban 5 #%d ^"Illegal mines^"", get_user_userid(get_user_index(owner_name)));
			client_cmd(id, "amx_ssban 5 #%d ^"Illegal mines^"", get_user_userid(get_user_index(owner_name)));
		}
		
		ColorChat(0, GREEN, "%s Player^x04 %s^x01 He got a warning from^x04 %s^x01 for mine in a bad place (^x03Warning: %d/2^x01).", szPrefix, owner_name, admin_name, ldWarn);

		formatex(lsWarn, charsmax(lsWarn), "%d", ldWarn);
		nvault_set(Vault, owner_name, lsWarn);

		//log_amx("[Warn] Dostal: %s | Admin: %s | Ma: %d", owner_name, admin_name, ldWarn);
		
		client_cmd(id, "snapshot");
		
		set_task(0.2, "remove_mine", id);
	}
	else
		ColorChat(id, GREEN, "%s Hover on mine.", szPrefix);

	return PLUGIN_CONTINUE;
}

public remove_mine(id)
	if(pev_valid(gEntAiming[id]))
		engfunc(EngFunc_RemoveEntity, gEntAiming[id]);
