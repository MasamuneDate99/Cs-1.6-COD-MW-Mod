#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fakemeta>
#include <engine>
#include <fun>
        
new const nazwa[]   = "Dual kriss";
new const opis[]    = "PB kriss ,AutoBHop";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_MP5NAVY)|(1<<CSW_DEAGLE);
new const zdrowie   = 25;
new const kondycja  = 75;
new const inteligencja = 5;
new const wytrzymalosc = 10;
    
new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "M.Fajar.Ar");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	register_forward(FM_PlayerPreThink, "fwPrethink_AutoBH");

	register_event("CurWeapon", "ModelBroni_CurWeapon", "be", "1=1");
	register_forward(FM_SetModel, "ModelBroni_fw_SetModel");
}

public plugin_precache()
{
	precache_model("models/PointBlank/p_kriss_sv.mdl");
	precache_model("models/PointBlank/v_kriss_sv.mdl");
	precache_model("models/PointBlank/w_kriss_sv.mdl");
}

public cod_class_enabled(id)
{
	give_item(id, "weapon_hegrenade");
	ma_klase[id] = true;

}

public cod_class_disabled(id)
{
	ma_klase[id] = false;

}

public fwPrethink_AutoBH(id)
{
	if(!ma_klase[id])
		return PLUGIN_CONTINUE

	if (pev(id, pev_button) & IN_JUMP) {
		new flags = pev(id, pev_flags)

		if (flags & FL_WATERJUMP)
			return FMRES_IGNORED;
		if ( pev(id, pev_waterlevel) >= 2 )
			return FMRES_IGNORED;
		if ( !(flags & FL_ONGROUND) )
			return FMRES_IGNORED;

		new Float:velocity[3];
		pev(id, pev_velocity, velocity);
		velocity[2] += 250.0;
		set_pev(id, pev_velocity, velocity);

		set_pev(id, pev_gaitsequence, 6);

	}
	return FMRES_IGNORED;
}

public ModelBroni_CurWeapon(id)
{
        new weapon = read_data(2);

        if(ma_klase[id])
        {
                if(weapon == CSW_MP5NAVY)
                {
                        set_pev(id, pev_viewmodel2, "models/PointBlank/v_kriss_sv.mdl")
                        set_pev(id, pev_weaponmodel2, "models/PointBlank/p_kriss_sv.mdl")
                }
        }
}

public ModelBroni_fw_SetModel(entity, model[])
{
        if(!pev_valid(entity))
                return FMRES_IGNORED

        if(!equali(model, "models/w_mp5.mdl"))
                return FMRES_IGNORED;

        new entityowner = pev(entity, pev_owner);

        if(!ma_klase[entityowner])
                return FMRES_IGNORED;

        engfunc(EngFunc_SetModel, entity, "models/PointBlank/w_kriss_sv.mdl")
        return FMRES_SUPERCEDE
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2057\\ f0\\ fs16 \n\\ par }
*/
