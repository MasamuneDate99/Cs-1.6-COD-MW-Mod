/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fakemeta>
        
new const nazwa[]   = "Hunter";
new const opis[]    = "He sees the invisible";
new const bronie    = (1<<CSW_M4A1) | 1<<CSW_DEAGLE;
new const zdrowie   = 50;
new const kondycja  = 30;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new bool:ma_klase[33];
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "RasiaQ");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_forward(FM_AddToFullPack, "FwdAddToFullPack", 1);
}

public cod_class_enabled(id)
{
            ma_klase[id] = true;
}
	    
public cod_class_disabled(id)
{
            ma_klase[id] = false;
}

public FwdAddToFullPack(es_handle, e, ent, host, hostflags, player, pSet)
{
            if(!is_user_connected(host) || !is_user_connected(ent))
                            return;
                           
            if(!ma_klase[host])
                            return;
                           
            set_es(es_handle, ES_RenderAmt, 255.0);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
