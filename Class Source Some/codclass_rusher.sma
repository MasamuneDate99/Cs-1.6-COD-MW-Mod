#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <codmod>
#include <colorchat>

#define CZAS 3 //SEKUND NIEWIDZIALNOSCI

#define DMG_BULLET (1<<1)

new const nazwa[] = "Rusher";
new const opis[] = "Intelligence takes additional damage, has 3 seconds of invisibility.";
new const bronie = 1<<CSW_M3 | 1<<CSW_FIVESEVEN;
new const zdrowie = 20;
new const kondycja = 40;
new const inteligencja = 0;
new const wytrzymalosc = 10;

new bool:wykorzystal[33];
new bool:ma_klase[33];

new msg_bartime;

public plugin_init() 
{
        register_plugin(nazwa, "1.0", "^v0L");   
        cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);    
        register_event("ResetHUD", "ResetHUD", "abe");    
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
        ColorChat(id, RED, "Have already used your are invisible.");
        return;
        }
    
        wykorzystal[id] = true;
    
        set_user_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, 1);
        set_task(CZAS.3, "Wylacz", id);
    
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

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)

{

		if(!is_user_connected(idattacker))

				return HAM_IGNORED;



		if(!ma_klase[idattacker])

				return HAM_IGNORED;



		if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_M3 && damagebits & DMG_BULLET)

				cod_inflict_damage(idattacker, this, 0.5, 0.3, idinflictor, damagebits);



		return HAM_IGNORED;

}

