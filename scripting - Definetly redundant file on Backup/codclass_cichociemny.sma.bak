#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <codmod>
#include <colorchat>

#define CZAS 3 //SEKUND NIEWIDZIALNOSCI

new const nazwa[] = "Cicho";
new const opis[] = "has 3 seconds invisibility, deals 10% more damage FAMAS, see invisible ";
new const bronie = 1<<CSW_FAMAS | 1<<CSW_HEGRENADE | 1<<CSW_FIVESEVEN;
new const zdrowie = 20;
new const kondycja = 10;
new const inteligencja = 5;
new const wytrzymalosc = 15;

new bool:wykorzystal[33];
new bool:ma_klase[33];

new msg_bartime;

public plugin_init() {
        register_plugin(nazwa, "1.0", "RbK");
    
        cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
    
        register_event("ResetHUD", "ResetHUD", "abe");

        register_forward(FM_AddToFullPack, "FwdAddToFullPack", 1);
    
        RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
    
        msg_bartime = get_user_msgid("BarTime");
}

public cod_class_enabled(id)
{
        ma_klase[id] = true;
        ResetHUD(id);
}

public cod_class_disabled(id)
{
        ma_klase[id] = false;
}

public cod_class_skill_used(id)
{
        if(!is_user_alive(id))
        return;
        
        if(wykorzystal[id])
        {
			ColorChat(id, RED, "Have already used your invisible.");
        return;
        }
    
        wykorzystal[id] = true;
    
        set_user_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, 1);
        set_task(CZAS.0, "Wylacz", id);
    
        message_begin(MSG_ONE, msg_bartime, _, id)
        write_short(CZAS)
        message_end()
}

public Wylacz(id)
{
        if(!is_user_connected(id)) return;
    
        set_user_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, 255);
}

public ResetHUD(id)
{
        if(ma_klase[id])
        wykorzystal[id] = false;
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
        
        if(get_user_weapon(idattacker) != CSW_FAMAS)
        return HAM_IGNORED;
        
        cod_inflict_damage(idattacker, this, damage*0.1, 0.0, idinflictor, damagebits);
        
        return HAM_IGNORED;
}