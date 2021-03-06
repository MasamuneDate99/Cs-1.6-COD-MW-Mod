#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fakemeta>
#include <colorchat>
#include <hamsandwich>
#include <engine>
        
new const nazwa[]   = "Critical Assasin";
new const opis[]    = "He sees the invisible, 1/2 Chance to deal * 1.5 Damage";
new const bronie    = (1<<CSW_M4A1) | 1<<CSW_DEAGLE | 1<<CSW_USP | 1<<CSW_GALIL ;
new const zdrowie   = 10;
new const kondycja  = 60;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new bool:ma_klase[33];
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "MasamuneDate");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_forward(FM_AddToFullPack, "FwdAddToFullPack", 1);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	ColorChat(id, GREEN, "Created by MasamuneDate", nazwa);
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

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits) 
{ 
	if(!is_user_connected(idattacker)) 
		return HAM_IGNORED; 
	
	if(!ma_klase[idattacker]) 
		return HAM_IGNORED; 
	
	if(!(damagebits & (1<<1))) 
		return HAM_IGNORED; 
	
	damage+=10;
	
	if(random_num(1,4) == 1)
	{
		damage*=1.5;
	}
	
	return HAM_IGNORED; 
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
