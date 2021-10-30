#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fakemeta>
        
new const nazwa[]   = "Executor";
new const opis[]    = "He sees the invisible, fast";
new const bronie    = (1<<CSW_AK47)|(1<<CSW_MP5NAVY)|(1<<CSW_DEAGLE);
new const zdrowie   = 60;
new const kondycja  = 30;
new const inteligencja = 10;
new const wytrzymalosc = 60;
 
new bool:ma_klase[33];
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");
 
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
 
        register_forward(FM_AddToFullPack, "FwdAddToFullPack", 1)
}
 
public cod_class_enabled(id)
{
            ma_klase[id] = true;   
 
	return COD_CONTINUE;
}
 
public cod_class_disabled(id)
            ma_klase[id] = false;
	   
 
public FwdAddToFullPack(es_handle, e, ent, host, hostflags, player, pSet)
{
            if(!is_user_connected(host) || !is_user_connected(ent))
                            return;
                           
            if(!ma_klase[host])
                            return;
                           
            set_es(es_handle, ES_RenderAmt, 255.0);
}