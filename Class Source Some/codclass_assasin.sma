#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <codmod>

new bool:ma_klase[33];

new const nazwa[] = "Assasin";
new const opis[] = "Instan Kill wit Knife";
new const bronie = 1<<CSW_ELITE | 1<<CSW_KNIFE | 1<<CSW_TMP;
new const zdrowie = 30;
new const kondycja = 50;
new const inteligencja = 0;
new const wytrzymalosc = 5;

public plugin_init() {

		register_plugin(nazwa, "1.0", "QTM_Peyote");

		cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

		RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
		register_event("CurWeapon", "CurWeapon", "be", "1=1")
}

public cod_class_enabled(id)
{
		ma_klase[id] = true;
}

public cod_class_disabled(id)
{
		ma_klase[id] = false;
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

		precache_model("models/dres/v_assasin.mdl");

}

public CurWeapon(id)

{

		new weapon = read_data(2);

		if(ma_klase[id])

		{

				if(weapon == CSW_KNIFE)

				{

						set_pev(id, pev_viewmodel2, "models/dres/v_assasin.mdl")

				}

		}

}