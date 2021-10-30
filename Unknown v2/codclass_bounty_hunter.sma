
#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <codmod>
#define DMG_BULLET (1<<1)

#define nazwa "Bounty Hunter"
#define opis "1/4 Chance to hit on Head"
#define bronie (1<<CSW_M4A1)
#define zdrowie 10
#define kondycja 35
#define wytrzymalosc 0
#define inteligencja 0

new bool:ma_klase[33];

public plugin_init() {
	register_plugin(nazwa, "1,0", "QTM. Peyote")
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	RegisterHam(Ham_TraceAttack, "player", "TraceAttack")	
}

public cod_class_enabled(id)
	ma_klase[id] = true;
	
public cod_class_disabled(id)
	ma_klase[id] = false;

public TraceAttack(id, attacker, Float:damage, Float:direction[3], tr, damagebits)
{
    if(is_user_alive(attacker) && is_user_alive(id) && damagebits & DMG_BULLET && ma_klase[attacker] && !random(4))
    {
        set_tr2(tr, TR_iHitgroup, HIT_HEAD)
        static Float:head_origin[3], Float:angles[3]
        engfunc(EngFunc_GetBonePosition, id, 8, head_origin, angles)
        set_tr2(tr, TR_vecEndPos, head_origin)
    }
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
