#include <amxmodx>
#include <fakemeta>
#include <codmod>

#define TASK_ID 128000

new const perk_name[] = "Poison Bullet";
new const perk_desc[] = "5s Charge with Knife, All attack deal poison dmg ( + INT )";

#define CZAS_LADOWANIA 5

new bool:moc_zaladowana[33];
new bool:ma_perk[33];
new msg_bartime;

public plugin_init() {
	register_plugin(perk_name, "1.0", "QTM_Peyote")
	
	cod_register_perk(perk_name, perk_desc);
	
	register_event("CurWeapon", "CurWeapon", "be", "1=1");
	register_event("ResetHUD", "ResetHUD", "abe");
	register_event("Damage", "Damage", "be", "2!0", "3=0", "4!0")
	msg_bartime = get_user_msgid("BarTime");
	
	register_forward(FM_PlayerPreThink, "client_PreThink");
	
}

public cod_perk_enabled(id)
	ma_perk[id] = true;
	
public cod_perk_disabled(id)
	ma_perk[id] = false;

public client_PreThink(id)
{
	if(!task_exists(id+TASK_ID))
		return;
		
	if(pev(id, pev_button) & (IN_MOVELEFT+IN_MOVERIGHT+IN_FORWARD+IN_BACK+IN_JUMP+IN_DUCK))
	{
		change_task(id+TASK_ID, CZAS_LADOWANIA.0);
		set_bartime(id, CZAS_LADOWANIA);
	}
}

public CurWeapon(id)
{
	if(get_user_weapon(id) == CSW_KNIFE && !moc_zaladowana[id] && ma_perk[id])
	{
		set_task(CZAS_LADOWANIA.0, "MocZaladowana", id+TASK_ID);
		set_bartime(id, CZAS_LADOWANIA);
	}
	else
	{
		remove_task(id+TASK_ID);
		set_bartime(id, 0);
	}
}

stock set_bartime(id, czas)
{
	message_begin((id)?MSG_ONE:MSG_ALL, msg_bartime, _, id)
	write_short(czas);
	message_end();   
}

public MocZaladowana(id)
{
	id -= TASK_ID;
	
	if(!ma_perk[id]) return;
	
	moc_zaladowana[id] = true;
	client_print(id, print_center, "Skill has been activated!");
	CurWeapon(id);
}
	
	
public ResetHUD(id) moc_zaladowana[id] = false;

#define TASK_ZATRUCIE 64000

new zatruwajacy[33];

public Damage(id)
{
	new attacker = get_user_attacker(id);

	if(!is_user_alive(attacker)) return;
	
	if(!moc_zaladowana[attacker]) return;
	
	zatruwajacy[id] = attacker;
	if(!task_exists(id+TASK_ZATRUCIE)) set_task(1.0, "Zatruj", id+TASK_ZATRUCIE, _, _, "a", 5);
}

public Zatruj(id)
{
	id -= TASK_ZATRUCIE;
	client_print(id, print_center, "You have been poisoned!");
	cod_inflict_damage(zatruwajacy[id], id, 1.0, 0.1);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
