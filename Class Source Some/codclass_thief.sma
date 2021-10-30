/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <codmod>
#include <engine>
#include <colorchat>

new const nazwa[] = "Thief";
new const opis[] = "Has reduced visibility and a 1/3 chance to take his victim perku";
new const bronie = 1<<CSW_GALIL | 1<<CSW_FLASHBANG | 1<<CSW_HEGRENADE | 1<<CSW_DEAGLE;
new const zdrowie = 15;
new const kondycja = 30;
new const inteligencja = 15;
new const wytrzymalosc = 0;

new bool:ma_klase[33];

new ofiara[33], perk_ofiary[33], wartosc_perku_ofiary[33];

public plugin_init() {
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_event("DeathMsg", "DeathMsg", "ade");
}

public cod_class_enabled(id)
{
	set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 75);
	ma_klase[id] = true;
	ColorChat(id, GREEN, "Klasa %s zostala stworzona przez www.PluginyMody.webd.pl", nazwa);
}

public cod_class_disabled(id)
{
	set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255);
	ma_klase[id] = false;
}

public DeathMsg()
{
	new killer = read_data(1);
	new victim = read_data(2);
	
	if(!is_user_connected(killer))
		return;
		
	if(!ma_klase[killer])
		return;
		
	if(random(3))
		return;
	
	if(!(perk_ofiary[killer] = cod_get_user_perk(victim, wartosc_perku_ofiary[killer])))
		return;

	ofiara[killer] = victim;
	
	Zapytaj(killer);
}

public Zapytaj(id)
{
	new tytul[55];
	new nazwa_perku[33];
	cod_get_perk_name(perk_ofiary[id], nazwa_perku, 32);
	format(tytul, 54, "Do you want to steal perk: %s ?", nazwa_perku);
	new menu = menu_create(tytul, "Zapytaj_Handle");
	
	menu_additem(menu, "Yes");
	menu_setprop(menu, MPROP_EXITNAME, "No");
	
	menu_display(id, menu);
}

public Zapytaj_Handle(id, menu, item)
{
	if(item)
		return;
	
	if(cod_get_user_perk(ofiara[id]) != perk_ofiary[id])
		return;
		
	new nick_zlodzieja[33];
	get_user_name(id, nick_zlodzieja, 32);
	ColorChat(ofiara[id], RED, "Your perk was stolen by %s.", nick_zlodzieja);
	cod_set_user_perk(ofiara[id], 0);
	cod_set_user_perk(id, perk_ofiary[id], wartosc_perku_ofiary[id]);
}
