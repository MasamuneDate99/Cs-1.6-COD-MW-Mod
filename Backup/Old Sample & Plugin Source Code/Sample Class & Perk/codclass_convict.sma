/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <CodMod>
#include <hamsandwich>
#include <fakemeta>

new bool:ma_klase[33];

new const nazwa[] = "Convict";
new const opis[] = "He sees the invisible, has 1/15 to drop weapon of the opponent";
new const bronie = 1<<CSW_AK47 | 1<<CSW_USP;
new const zdrowie = 35;
new const kondycja = 15;
new const inteligencja = 5;
new const wytrzymalosc = 10;

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "Pas");
	register_forward(FM_AddToFullPack, "FwdAddToFullPack", 1)
        register_event("Damage", "Damage_Wyrzucenie", "b", "2!=0");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	register_event("CurWeapon", "CurWeapon", "be", "1=1")
	
}

public cod_class_enabled(id)
{
	ma_klase[id] = true;
	return COD_CONTINUE;
}
	
public cod_class_disabled(id)
{	
    ma_klase[id] = false;
}

public plugin_precache()
{
	precache_model("models/rgcod/v_ak47rg.mdl");
}

public CurWeapon(id)
{
	new weapon = read_data(2);

	if(ma_klase[id])
	{
		if(weapon == CSW_AK47)
		{
			set_pev(id, pev_viewmodel2, "models/rgcod/v_ak47rg.mdl")
		}
	}
}

public FwdAddToFullPack(es_handle, e, ent, host, hostflags, player, pSet)
{
	if(!is_user_connected(host) || !is_user_connected(ent))
		return;
		
	if(!ma_klase[host])
		return;
		
	set_es(es_handle, ES_RenderAmt, 255.0);
}
public Damage_Wyrzucenie(id)
{
	new idattacker = get_user_attacker(id);

	if(!is_user_alive(idattacker))
		return;

	if(!ma_klase[idattacker])
		return;

	if(random_num(1, 15) != 1)
		return;

	client_cmd(id, "drop");
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/