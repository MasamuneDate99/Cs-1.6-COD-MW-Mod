/*******************************************************************************************
 *   RS Advanced Swear Filter + Punishment (MySQL Support)
 *
 *   By:      Rob Secord
 *   Alias:   xeroblood (aka; Achilles)
 *   Email:   xeroblood@gmail.com
 *
 *   Credits: _KaszpiR_, Util, Knocker, poosmith (See Credits Section Below For More Info)
 *
 *   Tested / Developed On:
 *      CS 1.6 - AMX 0.9.9
 *      CS 1.6 - AMXX 1.0
 *      MySQL v4.0.16-nt (Driver: v03.51)
 *
 ******************************************************************************************/


#if defined _BASE_EFFECTS_INCLUDED
  #endinput
#endif
#define _BASE_EFFECTS_INCLUDED



/***************************************************************************
 ********  Fire Effects By f117bomb (Slightly Modified)  *******************
 **************************************************************************/

public ignite_effects( skIndex[] )
{
    new kIndex = skIndex[0]

    if( is_user_alive(kIndex) && g_bUserFlame[kIndex-1] )
    {
        new korigin[3]
        get_user_origin( kIndex, korigin )

        //TE_SPRITE - additive sprite, plays 1 cycle
        message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
        write_byte( 17 )
        write_coord( korigin[0] )  // coord, coord, coord (position)
        write_coord( korigin[1] )
        write_coord( korigin[2] )
        write_short( g_sprMFlash ) // short (sprite index)
        write_byte( 20 )           // byte (scale in 0.1's)
        write_byte( 200 )          // byte (brightness)
        message_end()

        //Smoke
        message_begin( MSG_BROADCAST, SVC_TEMPENTITY, korigin )
        write_byte( 5 )
        write_coord( korigin[0] )  // coord coord coord (position)
        write_coord( korigin[1] )
        write_coord( korigin[2] )
        write_short( g_sprSmoke )  // short (sprite index)
        write_byte( 20 )           // byte (scale in 0.1's)
        write_byte( 15 )           // byte (framerate)
        message_end()

        set_task( 0.2, "ignite_effects", 0, skIndex, 2 )
    }
    else
    {
        if( g_bUserFlame[kIndex-1] )
        {
            emit_sound( kIndex, CHAN_AUTO, g_szSndScream, 0.6, ATTN_NORM, 0, PITCH_HIGH )
            g_bUserFlame[kIndex-1] = false
        }
    }
    return PLUGIN_CONTINUE
}

public ignite_player( skIndex[] )
{
    new kIndex = skIndex[0]

    if( is_user_alive(kIndex) && g_bUserFlame[kIndex-1] )
    {
        new korigin[3]
        new players[32], inum = 0
        new pOrigin[3]
        new kHealth = get_user_health( kIndex )
        new nDmgAmount = get_cvar_num( "sv_fire_dmg" )
        get_user_origin( kIndex, korigin )

        //create some damage
        set_user_health( kIndex, (kHealth - nDmgAmount) )

        message_begin( MSG_ONE, g_nMsgDamage, {0,0,0}, kIndex )
        write_byte( 30 )          // dmg_save
        write_byte( 30 )          // dmg_take
        write_long( 1<<21 )       // visibleDamageBits
        write_coord( korigin[0] ) // damageOrigin.x
        write_coord( korigin[1] ) // damageOrigin.y
        write_coord( korigin[2] ) // damageOrigin.z
        message_end()

        //create some sound
        emit_sound( kIndex, CHAN_ITEM, g_szSndFlames, 0.6, ATTN_NORM, 0, PITCH_NORM )

        //Ignite Others
        get_players( players, inum, "a" )
        for( new i = 0; i < inum; ++i )
        {
            get_user_origin( players[i], pOrigin )
            if( get_distance( korigin, pOrigin ) < 100  )
            {
                if( !g_bUserFlame[kIndex-1] )
                {
                    new spIndex[2]
                    spIndex[0] = players[i]
                    new pName[32], kName[32]
                    get_user_name( players[i], pName, 31 )
                    get_user_name( kIndex, kName, 31 )
                    emit_sound( players[i], CHAN_WEAPON, g_szSndScream, 1.0, ATTN_NORM, 0, PITCH_HIGH )
                    client_print( 0, print_chat, "%s OH NO! %s has caught %s on fire!", PLUGIN_MOD, kName, pName )
                    g_bUserFlame[players[i]-1] = true
                    ignite_player( players[i] )
                    ignite_effects( players[i] )
                }
            }
        }
        players[0] = 0
        pOrigin[0] = 0
        korigin[0] = 0

        //Call Again in 2 seconds
        set_task( 2.0, "ignite_player", 0, skIndex, 2 )
    }

    return PLUGIN_CONTINUE
}

/***************************************************************************
 ********  Lightning Effects By f117bomb (Slightly Modified)  *************
 **************************************************************************/

public ThrowLightning( victim )
{
    if( is_user_alive( victim ) ) /*If user is alive create effects and user_kill */
    {
        new vec1[3], vec2[3]
        get_user_origin( victim, vec1 )
        vec1[2] -= 26
        vec2[0] = vec1[0] + 150
        vec2[1] = vec1[1] + 150
        vec2[2] = vec1[2] + 400

        emit_sound( victim, CHAN_ITEM, g_szSndThunder, 1.0, ATTN_NORM, 0, PITCH_NORM )

        //Lightning
        message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
        write_byte( 0 )
        write_coord( vec2[0] )
        write_coord( vec2[1] )
        write_coord( vec2[2] )
        write_coord( vec1[0] )
        write_coord( vec1[1] )
        write_coord( vec1[2] )
        write_short( g_sprLight )
        write_byte( 1 )             // framestart
        write_byte( 5 )             // framerate
        write_byte( 2 )             // life
        write_byte( 20 )            // width
        write_byte( 30 )            // noise
        write_byte( 200 )           // r, g, b
        write_byte( 200 )           // r, g, b
        write_byte( 200 )           // r, g, b
        write_byte( 200 )           // brightness
        write_byte( 200 )           // speed
        message_end()

        //Sparks
        message_begin( MSG_PVS, SVC_TEMPENTITY, vec1 )
        write_byte( 9 )
        write_coord( vec1[0] )
        write_coord( vec1[1] )
        write_coord( vec1[2] )
        message_end()

        //s2smoke
        message_begin( MSG_BROADCAST, SVC_TEMPENTITY, vec1 )
        write_byte( 5 )
        write_coord( vec1[0] )
        write_coord( vec1[1] )
        write_coord( vec1[2] )
        write_short( g_sprSmoke )
        write_byte( 10 )
        write_byte( 10 )
        message_end()

        user_kill( victim, 1 )
    }
    return PLUGIN_CONTINUE
}