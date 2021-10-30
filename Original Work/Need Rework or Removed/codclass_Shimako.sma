#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <fun>

#define ZADANIE_WSKRZES 6240

new const nazwa[]   = "Shimako";
new const opis[]    = "1/3 revival of the death.";
new const bronie    = 1<<CSW_AK47;
new const zdrowie   = 40;
new const kondycja  = 10;
new const inteligencja = 15;
new const wytrzymalosc = 15;

new bool:ma_klase[33];

public plugin_init()
{
        cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
		
		RegisterHam(Ham_Killed, "player", "Killed", 1);
}
public cod_class_enabled(id)
{
        ma_klase[id] = true;
}
public cod_class_disabled(id)
{
        ma_klase[id] = false;
}
public Killed(id){
	if(ma_klase[id] && random_num(1, 3)==1)
		set_task(0.1, "Wskrzes", id+ZADANIE_WSKRZES);
}
public Wskrzes(id){
	ExecuteHamB(Ham_CS_RoundRespawn, id-ZADANIE_WSKRZES);
}