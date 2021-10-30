#include <amxmodx>
#include <amxmisc>
#include <fun>

#define PLUGIN "Bonus"
#define VERSION "1.2"
#define AUTHOR "Xalus"

#define Tag "[Bonus HP]"

new cStatus, cMaxHealth;
new cKill, cKnife, cHeadshot, cKnifeHeadshot;

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    /* Cvar */
    cStatus        = register_cvar("bonus_status", "1");
    cMaxHealth    = register_cvar("bonus_maxhealth", "150");
    /* Bonus */
    cKill        = register_cvar("bonus_kill", "10");
    cKnife        = register_cvar("bonus_knife", "10");
    cHeadshot    = register_cvar("bonus_headshot", "15");
    cKnifeHeadshot    = register_cvar("bonus_knifeheadshot", "20");
    
    /* Player Killed */
    register_event( "DeathMsg", "EventDeathMsg", "a", "1>0" );
}
/*
Bonus:
- Player Killed
*/
public EventDeathMsg() {
    new killer = read_data(1);
    new victim = read_data(2);
    new headshot = read_data(3);
    new weapon = get_user_weapon(killer);
    new num;
    
    if(killer == victim || !get_pcvar_num(cStatus) || !is_user_connected(victim) || !is_user_alive(killer))
        return PLUGIN_HANDLED;
    
    if(headshot && weapon == CSW_KNIFE) {
        num = get_pcvar_num(cKnifeHeadshot)
        GiveHealth(killer, num)
        HudMessage(killer, "You Get +%ihp", num)
    } else if(headshot) {
        num = get_pcvar_num(cHeadshot)
        GiveHealth(killer, num)
        HudMessage(killer, "You Get +%ihp", num)
    } else if(weapon == CSW_KNIFE) {
        num = get_pcvar_num(cKnife)
        GiveHealth(killer, num)
        HudMessage(killer, "You Get +%ihp", num)
    } else {
        num = get_pcvar_num(cKill)
        GiveHealth(killer, num)
        HudMessage(killer, "You Get +%ihp", num)
    }
    return PLUGIN_CONTINUE;
}
/*
Bonus:
    - Give Health
    - Hud Message
*/
GiveHealth(id, count)
    set_user_health(id, min( (get_user_health(id) + count), get_pcvar_num(cMaxHealth) ))

stock HudMessage(const id, const input[], any:...) {
    static msg[191];
    vformat(msg, 190, input, 3);
    
    set_hudmessage(255, 255, 0, 0.27, 0.14, 0, 5.0, 5.0, 0.0, 0.0, -1);
    show_hudmessage(id, "%s^n%s", Tag, msg)
}  