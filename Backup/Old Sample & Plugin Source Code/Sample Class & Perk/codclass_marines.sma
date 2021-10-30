#include <amxmodx>
#include <codmod>
#include <fakemeta_util>
#include <fakemeta>

#define PLUGIN	"Marines"
#define AUTHOR	"KaMeR"
#define VERSION	"0.94Ev"

new const nazwa[] = "Marines";
new const opis[] = "Every 4 seconds regeneration 15hp , Triple Jump";
new const bronie = 1<<CSW_AUG | 1<<CSW_USP;
new const zdrowie = 25;
new const kondycja = 41;
new const inteligencja = 0;
new const wytrzymalosc = 10;

new skoki[33];
new ma_klase[33];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_CmdStart, "fwCmdStart_MultiJump");
     cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}

public cod_class_enabled(id)
{
	ma_klase[id] = true;
        set_task(4.0, "DodajHP", id, _, _, "b");
}

public cod_class_disabled(id)
{
    ma_klase[id] = false;
    
	remove_task(id);
}

public DodajHP(id)
{
        if(get_user_health(id) < 100+cod_get_user_health(id))
                fm_set_user_health(id, get_user_health(id)+15);
}

public fwCmdStart_MultiJump(id, uc_handle)
{
if(!is_user_alive(id) || !ma_klase[id])
return FMRES_IGNORED;

new flags = pev(id, pev_flags);

if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(flags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && skoki[id])
{
skoki[id]--;
new Float:velocity[3];
pev(id, pev_velocity,velocity);
velocity[2] = random_float(265.0,285.0);
set_pev(id, pev_velocity,velocity);
}
else if(flags & FL_ONGROUND)
skoki[id] = 3;///Tu zmieniamy ilosc skokow

return FMRES_IGNORED;
}
