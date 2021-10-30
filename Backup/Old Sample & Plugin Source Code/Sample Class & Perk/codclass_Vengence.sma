#include <amxmodx>
#include <fakemeta>
#include <amxmisc>
#include <codmod>
        
new const nazwa[]   = "Vengence";
new const opis[]    = "Resistant to head shots";
new const bronie    = (1<<CSW_G3SG1) | 1<<CSW_ELITE;
new const zdrowie   = 20;
new const kondycja  = 50;
new const inteligencja = 0;
new const wytrzymalosc = 30;

new bool:g_RestartAttempt[32+1]
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
                register_forward(FM_TraceLine, "forward_traceline", 1);
                register_event("TextMsg", "eRestartAttempt", "a", "2=#Game_will_restart_in")
}
public eRestartAttempt()
{
                new players[32], num;
                get_players(players, num, "a");
                for (new i; i < num; ++i)
                {         
                                g_RestartAttempt[players[i]] = true;
                }
}
public forward_traceline(Float:v1[3], Float:v2[3], noMonsters, pentToSkip)
{
                if(!is_user_alive(pentToSkip)) return FMRES_IGNORED

                static entity2 ; entity2 = get_tr(TR_pHit)
                if(!is_user_alive(entity2)) return FMRES_IGNORED

                if(pentToSkip == entity2) return FMRES_IGNORED

                if(get_tr(TR_iHitgroup) != 1)
                {
                                set_tr(TR_flFraction,1.0)
                                return FMRES_SUPERCEDE
                }
                return FMRES_IGNORED
}