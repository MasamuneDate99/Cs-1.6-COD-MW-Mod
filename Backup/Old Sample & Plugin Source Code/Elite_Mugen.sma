#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <fakemeta>
#include <fun>

new const nazwa[]   = "Mugen";
new const opis[]    = "Has no recoil, 1x jump , invisible 81 with knife!";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_ELITE)|(1<<CSW_FAMAS)|(1<<CSW_FLASHBANG);
new const zdrowie   = 23;
new const kondycja  = 35;
new const inteligencja = 0;
new const wytrzymalosc = 5;

new ma_klase[33];
new identyfikator[33];

new skoki[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "Alelluja");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_event("CurWeapon", "Niewidzialnosc", "be", "1=1");
	register_forward(FM_CmdStart, "MultiJump");
	register_forward(FM_PlayerPreThink, "PreThink");
	register_forward(FM_UpdateClientData, "UpdateClientData", 1)
}

public cod_class_enabled(id)
{
	get_user_name(id, identyfikator, 32);
	if(!equal(identyfikator, "kira"))
	{
		client_print(id, print_chat, "[ELITE] Do not have permission to use this class.")
		return COD_STOP;
	}
	give_item(id, "weapon_hegrenade");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_flashbang");
	ma_klase[id] = true;
	
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	ma_klase[id] = false;
	
}

public Niewidzialnosc(id)
{
	if(!ma_klase[id])
		return;
	
	if( read_data(2) == CSW_KNIFE )
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 81);
	}
	else
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	}
}

public MultiJump(id, uc_handle)
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
		skoki[id] = 1;
	
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
