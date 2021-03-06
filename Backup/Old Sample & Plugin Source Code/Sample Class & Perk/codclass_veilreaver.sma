/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <codmod>
#include <engine>

#define DMG_BULLET (1<<1)

new bool:ma_klase[33];
new identyfikator[33];

new const nazwa[] = "Veil Reaver";
new const opis[] = "While squatting invisible drop to 80";
new const bronie    = (1<<CSW_P228)|(1<<CSW_M4A1)|(1<<CSW_AK47);
new const zdrowie = 40;
new const kondycja = 45;
new const inteligencja = 0;
new const wytrzymalosc = 0;

public plugin_init() 
{
		cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
		register_plugin(nazwa, "1.0", "QTM_Peyote");
}

public cod_class_enabled(id)
{
	get_user_name(id, identyfikator, 32);
	if(!equal(identyfikator, "vN!") && !equal(identyfikator, "shu."))
	{
		client_print(id, print_chat, "[PRO] Do not have permission to use this class.")
		return COD_STOP;
	}
	ma_klase[id] = true;
	return COD_CONTINUE;
}
	
public cod_class_disabled(id)
	ma_klase[id] = false;
	
public client_PreThink(id)
{
	if(!ma_klase[id])
		return;
		
	new button = get_user_button(id);
	if(button & IN_DUCK)
		set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 80);
	else
		set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255);
}
