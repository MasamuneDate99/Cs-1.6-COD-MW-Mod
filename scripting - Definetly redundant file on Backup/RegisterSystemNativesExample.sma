#include <amxmodx>
#include <register_system>

public plugin_init()
{
	register_plugin("Register System Natives Example Plugin", "1.0", "m0skVi4a ;]")
	
	register_clcmd("say /test_reg", "TestReg")
	register_clcmd("say /test_log", "TestLog")
	register_clcmd("say /test_autolog", "TestAutoLog")
	register_clcmd("say /test_time_login", "TestTimeLogin")
	register_clcmd("say /test_time_pass", "TestTimePass")
}

public TestReg(id)
{
	if(is_registered(id))
	{
		client_print(id, print_chat, "Registerd")
	}
	else
	{
		client_print(id, print_chat, "Not Registerd")
	}
}

public TestLog(id)
{
	if(is_logged(id))
	{
		client_print(id, print_chat, "Logged")
	}
	else
	{
		client_print(id, print_chat, "Not Logged")
	}
}

public TestAutoLog(id)
{
	if(is_autologged(id))
	{
		client_print(id, print_chat, "AutoLoged")
	}
	else
	{
		client_print(id, print_chat, "Not AutoLoged")
	}
}

public TestTimeLogin(id)
{
	client_print(id, print_chat, "You can not Login for %d seconds!", get_cant_login_time(id))
}

public TestTimePass(id)
{
	client_print(id, print_chat, "You can not Change yout password for %d seconds!", get_cant_change_pass_time(id))
}