#include <amxmodx>

#include <amxmisc>
#include <codmod>
#include <cstrike>
#include <fakemeta>
 
#define PLUGIN "Chameleon"
#define VERSION "1.0"
#define AUTHOR "Wyntelek"
 
new const nazwa[] = "Chameleon";
new const opis[] = "From the M4A1 looks like CT with AK47 looks like T, 3 jumps";
new const bronie = 1<<CSW_M4A1 | 1<<CSW_AK47 ;
new const zdrowie = 20;
new const kondycja = 30;
new const inteligencja = 0;
new const wytrzymalosc = 20;
new skoki[33];
 
new Ubrania_CT[4][]={"sas","gsg9","urban","gign"};
new Ubrania_Terro[4][]={"arctic","leet","guerilla","terror"};
 
new bool:ma_klase[33];
 
public plugin_init() {
register_plugin(PLUGIN, VERSION, AUTHOR)
 
cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
register_event("CurWeapon","CurWeapon","be", "1=1");
register_forward(FM_CmdStart, "CmdStart");
}
public cod_class_enabled(id)
ma_klase[id] = true;
 
public cod_class_disabled(id)
ma_klase[id] = false;
 
public CurWeapon(id)
{
 
new weapon = read_data(2);
new num = random_num(0,3);
 
if(ma_klase[id] && weapon == CSW_M4A1)
{
cs_set_user_model(id, Ubrania_CT[num]);
}
if(ma_klase[id] && weapon == CSW_AK47)
{
cs_set_user_model(id, Ubrania_Terro[num]);
}
 
return PLUGIN_CONTINUE;
}
public CmdStart(id, uc_handle)
 
{
 
if(!is_user_alive(id) || !ma_klase[id]) //jeśli tworzymy perk, wstawiamy ma_perk zamiast ma_klase
 
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
 
skoki[id] = 2; //Here we give the number of jumps in the air, which can carry class
 
 
 
return FMRES_IGNORED;
 
}