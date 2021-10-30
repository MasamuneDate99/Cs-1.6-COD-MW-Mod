#include <amxmodx>
#include <engine>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <codmod>
#include <ColorChat>
#include <fun>
#include <dhudmessage>

#define CZAS_GODMOD 3  //ILE SEKUND MA TRWAC NIEWIDZIALNOSC

new const nazwa[] = "Elite Assasin";
new const opis[] = "Instan Kill wit Knife , triple jump,invisible 3 sec";
new const bronie = 1<<CSW_ELITE | 1<<CSW_KNIFE | 1<<CSW_TMP;
new const zdrowie = 40;
new const kondycja = 45;
new const inteligencja = 10;
new const wytrzymalosc = 5;

new bool:wykorzystal[33];

new identyfikator[33];
new bool:ma_klase[33];
new msg_bartime;
new skoki[33];

public plugin_init() {

		register_plugin(nazwa, "1.0", "QTM_Peyote");

		cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

		RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
		register_forward(FM_CmdStart, "fwCmdStart_MultiJump");
		msg_bartime = get_user_msgid("BarTime");
		register_event("CurWeapon", "CurWeapon", "be", "1=1");
		register_event("ResetHUD", "ResetHUD", "abe");
}

public cod_class_enabled(id)
{
	get_user_name(id, identyfikator, 32);
	if(!equal(identyfikator, "The Magician") && !equal(identyfikator, "Whistle*") && !equal(identyfikator, "Electronic_Arts.-"))
	{
		client_print(id, print_chat, "[ELITE] Do not have permission to use this class.")
		return COD_STOP;
	}
	 ResetHUD(id);
	ma_klase[id] = true;
	return COD_CONTINUE;
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
     set_dhudmessage(0, 255, 0, -1.0, 0.65, 2, 6.0, 3.0, 0.1, 1.5, false);
     
     set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 1);
     set_user_footsteps(id, 1);
     set_task(CZAS_GODMOD.0, "WylaczGod", id);

     message_begin(MSG_ONE, msg_bartime, _, id)
     write_short(CZAS_GODMOD)
     message_end()
}

public WylaczGod(id)
{
     if(!is_user_connected(id)) return;

     set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
     set_user_footsteps(id, 0);
}
public ResetHUD(id)
{
     wykorzystal[id] = false;
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
skoki[id] = 2;///Tu zmieniamy ilosc skokow

return FMRES_IGNORED;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)

{

if(!is_user_connected(idattacker))

  return HAM_IGNORED;



if(!ma_klase[idattacker])

  return HAM_IGNORED;



if(get_user_weapon(idattacker) == CSW_KNIFE && damagebits & DMG_BULLET && damage > 20.0)

  cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);



return HAM_IGNORED;

}

public plugin_precache()

{

		precache_model("models/rgcod/v_assasin_E.mdl");

}

public CurWeapon(id)

{

		new weapon = read_data(2);

		if(ma_klase[id])

		{

				if(weapon == CSW_KNIFE)

				{

						set_pev(id, pev_viewmodel2, "models/rgcod/v_assasin_E.mdl")

				}

		}

}
