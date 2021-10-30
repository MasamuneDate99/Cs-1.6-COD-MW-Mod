#include <amxmodx>
#include <orpheu>
#include <fakemeta>

#define PLUGIN_NAME       "xxk"
#define PLUGIN_AUTHOR  "fak"
#define PLUGIN_VERSION "1.0"

new CvarAdminFreelook;
new CvarAdminFreeLookFlag;

new CvarForceChaseCam;
new CvarForceCamera;

new PlayerTeam;

const m_iTeam = 114;

const TEAM_UNASSIGNED = 0;
const TEAM_SPECTATOR = 3;

public plugin_init()
{
    register_plugin( PLUGIN_NAME, PLUGIN_AUTHOR, PLUGIN_VERSION );
    
    CvarAdminFreelook     = register_cvar( "amx_adminfreelook", "1" );
    CvarAdminFreeLookFlag = register_cvar( "amx_adminfreelookflag", "d" );
    
    CvarForceChaseCam = get_cvar_pointer( "mp_forcechasecam" );
    CvarForceCamera   = get_cvar_pointer( "mp_forcecamera" );
    
    new OrpheuFunction:Observer_FindNextPlayer = OrpheuGetFunction( "Observer_FindNextPlayer", "CBasePlayer" );
    
    OrpheuRegisterHook( Observer_FindNextPlayer, "OnObserver_FindNextPlayer_Pre" , OrpheuHookPre );
    OrpheuRegisterHook( Observer_FindNextPlayer, "OnObserver_FindNextPlayer_Post", OrpheuHookPost );
}

public OnObserver_FindNextPlayer_Pre( const player, const bool:searchDown, const playerNameToSearch[] )
{
    if( get_pcvar_num( CvarAdminFreelook ) ) 
    {
        new forceChaseCam = get_pcvar_num( CvarForceChaseCam );
        new forceCamera = get_pcvar_num( CvarForceCamera );
    
        if( ( forceChaseCam || forceCamera ) && get_user_flags( player ) & get_pcvar_flags( CvarAdminFreeLookFlag ) )
        {
            PlayerTeam = get_pdata_int( player, m_iTeam );
            set_pdata_int( player, m_iTeam, TEAM_SPECTATOR );
        }
    }
}

public OnObserver_FindNextPlayer_Post( const player, const bool:searchDown, const playerNameToSearch[] )
{
    if( PlayerTeam != TEAM_UNASSIGNED ) 
    {
        set_pdata_int( player, m_iTeam, PlayerTeam );
        PlayerTeam = TEAM_UNASSIGNED;
    }
}  