#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fakemeta>
        
new const nazwa[]   = "Elite SS II";
new const opis[]    = "No recoil, 4 Jump";
new const bronie    = (1<<CSW_M4A1)|(1<<CSW_AK47) | 1<<CSW_DEAGLE | 1<<CSW_FLASHBANG;
new const zdrowie   = 50;
new const kondycja  = 30;
new const inteligencja = 0;
new const wytrzymalosc = 30;
    
new skoki[33];
new identyfikator[33];
new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
   
	register_forward(FM_CmdStart, "fwCmdStart_MultiJump");
	register_forward(FM_UpdateClientData, "UpdateClientData", 1);
	register_forward(FM_PlayerPreThink, "PreThink");
}

public cod_class_enabled(id)
{
	get_user_name(id, identyfikator, 32);
	if(!equal(identyfikator, "The Magician") && !equal(identyfikator, "vN!") && !equal(identyfikator, "Sybilla<3") && !equal(identyfikator, "Naomi-Chan") && !equal(identyfikator, "Dom_Trise.-") && !equal(identyfikator, "neozi/?"))
	{
		client_print(id, print_chat, "[ELITE] Do not have permission to use this class.")
		return COD_STOP;
	}
	ma_klase[id] = true;
   
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;

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
		skoki[id] = 3;

	return FMRES_IGNORED;
}

public PreThink(id)
{
    if(ma_klase[id])
        set_pev(id, pev_punchangle, {0.0,0.0,0.0})
}
        
public UpdateClientData(id, sw, cd_handle)
{
    if(ma_klase[id])
        set_cd(cd_handle, CD_PunchAngle, {0.0,0.0,0.0})   
}
