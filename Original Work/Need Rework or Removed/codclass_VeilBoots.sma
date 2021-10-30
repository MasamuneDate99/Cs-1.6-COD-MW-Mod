#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <fun>
        
new const nazwa[]   = "Veil Boots";
new const opis[]    = "You can not see it on the knife, and you can not hear his footsteps";
new const bronie    = (1<<CSW_M4A1) | CSW_DEAGLE;
new const zdrowie   = 60;
new const kondycja  = 5;
new const inteligencja = 0;
new const wytrzymalosc = 10;
    
new bool:ma_klase[33];
new identyfikator[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	register_event("CurWeapon", "eventKnife_Niewidzialnosc", "be", "1=1");

}

public cod_class_enabled(id)
{
	get_user_name(id, identyfikator, 32);
	if(!equal(identyfikator, "EX7.-") && !equal(identyfikator, "urang ti bandung euy") && !equal(identyfikator, "Hengky.-") 
&& !equal(identyfikator, "vN!"))
	{
		client_print(id, print_chat, "[PRO] Do not have permission to use this class.")
		return COD_STOP;
	}
	set_user_footsteps(id, 1);
	ma_klase[id] = true;
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
    	ma_klase[id] = false;
        set_user_footsteps(id, 0);
}

public eventKnife_Niewidzialnosc(id)
{
	if(!ma_klase[id])
		return;

	if( read_data(2) == CSW_KNIFE )
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 40);
	}
	else
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	}
}