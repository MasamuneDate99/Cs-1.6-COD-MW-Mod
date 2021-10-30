#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <codmod>
#include <colorchat>

#define CZAS 8 //SEKUND NIEWIDZIALNOSCI

new const nazwa[] = "Elite Shadow";
new const opis[] = "He has 8 seconds round of invisibility which, deals 10% more damage with FAMAS, see invisible, less gravity";
new const bronie = 1<<CSW_FAMAS | 1<<CSW_HEGRENADE | 1<<CSW_DEAGLE | 1<<CSW_USP | 1<<CSW_GALIL;
new const zdrowie = 40;
new const kondycja = 20;
new const inteligencja = 5;
new const wytrzymalosc = 15;

new bool:wykorzystal[33];
new identyfikator[33];
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
        get_user_name(id, identyfikator, 32);
	if(!equal(identyfikator, "kira") && !equal(identyfikator, "nerco4")  && !equal(identyfikator, "wang.") && !equal(identyfikator, "[SPZ]:.Newbie") && !equal(identyfikator, "SaiWong") && !equal(identyfikator, "Modifer~|xSwiFT"))
        {
		client_print(id, print_chat, "[ELITE] Do not have permission to use this class.")
		return COD_STOP;
        }
        ma_klase[id] = true;
        ResetHUD(id);
        set_pev(id, pev_gravity, 0.6);
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
        ColorChat(id, RED, "Already used his Invisibility.");
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
        set_pev(id, pev_gravity, 0.6);
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
