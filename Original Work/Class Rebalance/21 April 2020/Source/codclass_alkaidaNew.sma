#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <colorchat>

new bool:ma_klase[33];
        
new const nazwa[]   	= "Alkaida";
new const opis[]    	= "70 hp for killing enemy, +150 additional EXP , also see invisible";
new const bronie    	= (1<<CSW_HEGRENADE)|(1<<CSW_M4A1) | (1<<CSW_DEAGLE);
new const zdrowie   	= 50;
new const kondycja  	= 25;
new const inteligencja 	= 0;
new const wytrzymalosc 	= 50;

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");
	register_event("DeathMsg", "DeathMsg", "ade");
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	register_forward(FM_AddToFullPack, "FwdAddToFullPack", 1);
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	register_event("ResetHUD", "ResetHUD", "abe");
	register_forward(FM_EmitSound, "EmitSound");
}

public cod_class_enabled(id)
{
	ColorChat(id, GREEN, "Rework by MasamuneDate", nazwa);
	ma_klase[id] = true;
	return COD_CONTINUE;
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

public DeathMsg()
{
    new killer = read_data(1);
    new victim = read_data(2);
    
    if(!is_user_connected(killer))
        return PLUGIN_CONTINUE;
    
    if(ma_klase[victim] && !ma_klase[killer])
        cod_set_user_xp(killer, cod_get_user_xp(killer)+150);
    
    if(ma_klase[killer])
    {
        new cur_health = pev(killer, pev_health);
        new Float:max_health = 100.0+cod_get_user_health(killer);
        new Float:new_health = cur_health+100.0<max_health? cur_health+100.0: max_health;
        set_pev(killer, pev_health, new_health);
    }
    return PLUGIN_CONTINUE;
}


public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
    if(!is_user_connected(idattacker))
        return HAM_IGNORED;
    
    if(!ma_klase[idattacker])
        return HAM_IGNORED;
    
    return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1041\\ f0\\ fs16 \n\\ par }
*/
