#include <amxmodx>
#include <codmod>

new const perk_name[] = "Mirror Image";
new const perk_desc[] = "You have a 1/7 chance of blinding the enemy";

new g_msg_screenfade;

new bool:ma_perk[33];
new wartosc_perku[33];

public plugin_init()
{
    register_plugin(perk_name, "1.0", "QTM_Peyote");
    
    cod_register_perk(perk_name, perk_desc);
    
    register_event("Damage", "Damage", "b", "2!=0");    
    
    g_msg_screenfade = get_user_msgid("ScreenFade");
}

public cod_perk_enabled(id, wartosc)
{
    ma_perk[id] = true;
    wartosc_perku[id] = 7;
}

public cod_perk_disabled(id)
{
    ma_perk[id] = false;
}

public Damage(id)
{
    new idattacker = get_user_attacker(id);
    
    if(!is_user_connected(idattacker) || get_user_team(id) == get_user_team(idattacker))
        return PLUGIN_CONTINUE;
    
    if(ma_perk[idattacker] && random_num(1, wartosc_perku[idattacker]) == 1)
        Display_Fade(id, 1<<14, 1<<14 ,1<<16, 0, 255, 0, 230);
    
    return PLUGIN_CONTINUE;
}

stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha)
{
    message_begin( MSG_ONE, g_msg_screenfade,{0,0,0},id );
    write_short( duration );
    write_short( holdtime );    
    write_short( fadetype );    
    write_byte ( red );        
    write_byte ( green );        
    write_byte ( blue );    
    write_byte ( alpha );    
    message_end();
}