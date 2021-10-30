#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fun>
#include <fakemeta>
        
new const nazwa[]   = "Obronca";
new const opis[]    = "See Mines";
new const bronie    =(1<<CSW_M249)|(1<<CSW_FLASHBANG) |(1<<CSW_DEAGLE);
new const zdrowie   = 50;
new const kondycja  = 10;
new const inteligencja = 0;
new const wytrzymalosc = 30;

new bool:ma_klase[33];
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	register_forward(FM_AddToFullPack, "FwdAddToFullPack", 1);
}

public cod_class_enabled(id)
{
	give_item(id, "weapon_hegrenade");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_smokegrenade");
	ma_klase[id] = true;

}

public cod_class_disabled(id)
{
     ma_klase[id] = false;
}

public FwdAddToFullPack(es_handle, e, ent, host, hostflags, player, pSet)
{
	if(!is_user_connected(host))
		return;
	
	if(!ma_klase[host])
		return;
	
	if(!pev_valid(ent))
		return;
	
	new classname[5];
	pev(ent, pev_classname, classname, 4);
	if(equal(classname, "mine"))
	{
		set_es(es_handle, ES_RenderMode, kRenderTransAdd);
		set_es(es_handle, ES_RenderAmt, 90.0);
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1250\\ deff0\\ deflang1045{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
