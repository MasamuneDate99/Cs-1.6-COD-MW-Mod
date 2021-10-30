#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fun>
#include <colorchat>
        
new const nazwa[]   = "Elite Dominator";
new const opis[]    = "Has 1/7 Chance To Instant Kill";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_USP)|(1<<CSW_M4A1)|(1<<CSW_FLASHBANG);
new const zdrowie   = 50;
new const kondycja  = 70;
new const inteligencja = 35;
new const wytrzymalosc = 15;

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "Keizuki");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	register_event("CurWeapon", "ModelBroni_CurWeapon", "be", "1=1");
	register_forward(FM_SetModel, "ModelBroni_fw_SetModel"); 
}

public plugin_precache()
{
	precache_model("models/SawahCod/Keizuki/p_m4a1_swh");
	precache_model("models/SawahCod/Keizuki/v_m4a1_swh");
	precache_model("models/SawahCod/Keizuki/w_m4a1_swh");
}

public cod_class_enabled(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_B))
	{
		client_print(id, print_chat, "[Elite Dominator] Anda Tidak Mempunyai Akses Untuk Class Ini.")
		return COD_STOP;
	}
	ColorChat(id, GREEN, "Created by Keizuki ( JANGAN KOMPLEN KE GUA KALO OP - TYR )", nazwa);
	give_item(id, "weapon_hegrenade");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_flashbang");
	ma_klase[id] = true;
   
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;

}

public ModelBroni_CurWeapon(id)
{
        new weapon = read_data(2);

        if(ma_klase[id])
        {
                if(weapon == CSW_M4A1)
                {
                        set_pev(id, pev_viewmodel2, "models/SawahCod/v_m4a1_swh")
                        set_pev(id, pev_weaponmodel2, "models/SawahCod/p_m4a1_swh")
                }
        }
}

public ModelBroni_fw_SetModel(entity, model[])
{
        if(!pev_valid(entity))
                return FMRES_IGNORED

        if(!equali(model, "models/w_m4a1.mdl"))
                return FMRES_IGNORED;

        new entityowner = pev(entity, pev_owner);

        if(!ma_klase[entityowner])
                return FMRES_IGNORED;

        engfunc(EngFunc_SetModel, entity, "models/SawahCod/w_m4a1_swh")
        return FMRES_SUPERCEDE
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
        if(!is_user_connected(idattacker))
                return HAM_IGNORED;
        
        if(!ma_klase[idattacker])
                return HAM_IGNORED;
        
        if(!(damagebits & DMG_BULLET))
                return HAM_IGNORED;
                
        if(random_num(1,7) == 1)
                cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
        
        return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
