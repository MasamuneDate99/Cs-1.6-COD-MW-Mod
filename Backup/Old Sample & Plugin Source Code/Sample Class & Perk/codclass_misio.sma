#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
#include <fakemeta>
#include <xs>
        
new const nazwa[]   = "Misio";
new const opis[]    = "	Teleportation every 5 seconds, to where the sight";
new const bronie    = (1<<CSW_XM1014) | (1<<CSW_DEAGLE);
new const zdrowie   = 15;
new const kondycja  = 30;
new const inteligencja = 0;
new const wytrzymalosc = 7;

new ma_klase[33];

new bool:uzyl[33];
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "CraZzy");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
        register_event("ResetHUD", "ResetHUD", "abe");
}

public cod_class_enabled(id)
{
      	ma_klase[id] = true;
	uzyl[id] = false;
}
public cod_class_disabled(id)
{
    	ma_klase[id] = false;

}
public cod_class_skill_used(id)
{    

if (!uzyl[id]==false)
	{
		client_print(id, print_center, "Teleport can use every 5s");
		return PLUGIN_CONTINUE;
	}

    if(uzyl[id] || !is_user_alive(id))
        return PLUGIN_CONTINUE;
    
    new Float:start[3], Float:view_ofs[3];
    pev(id, pev_origin, start);
    pev(id, pev_view_ofs, view_ofs);
    xs_vec_add(start, view_ofs, start);

    new Float:dest[3];
    pev(id, pev_v_angle, dest);
    engfunc(EngFunc_MakeVectors, dest);
    global_get(glb_v_forward, dest);
    xs_vec_mul_scalar(dest, 999.0, dest);
    xs_vec_add(start, dest, dest);

    engfunc(EngFunc_TraceLine, start, dest, 0, id, 0);
    
    new Float:fDstOrigin[3];
    get_tr2(0, TR_vecEndPos, fDstOrigin);
    
    if(engfunc(EngFunc_PointContents, fDstOrigin) == CONTENTS_SKY)
        return PLUGIN_CONTINUE;

    new Float:fNormal[3];
    get_tr2(0, TR_vecPlaneNormal, fNormal);
    
    xs_vec_mul_scalar(fNormal, 75.0, fNormal);
    xs_vec_add(fDstOrigin, fNormal, fDstOrigin);
    set_pev(id, pev_origin, fDstOrigin);
    uzyl[id] = true;
    set_task ( 5.0, "ResetHUD", id )
    set_task ( 5.0, "InfoTel", id )	
}

public ResetHUD(id)
{
    uzyl[id] = false;
}

public InfoTel(id)
{
    client_print(id, print_center, "You can use the Teleport ");
}