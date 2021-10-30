    #include <amxmodx> 
    #include <hamsandwich> 
    #include <codmod> 
     
    #define PLUGIN "Say / class & / stats"
    #define VERSION "0.1"
    #define AUTHOR "MasamuneDate / TYR"
     
    new oldLevel [ 33 ];
     
    public plugin_init () 
    {
    	register_plugin ( PLUGIN , VERSION , AUTHOR )
        
    	RegisterHam ( Ham_Spawn , "player" , "Fw_Spawn" , 1 )    
    }
     
    public Fw_Spawn ( id )  
    {
    	if (! is_user_alive ( id )) {  
    		return HAM_IGNORED ;
    	}
     
    	new currentLevel = cod_get_user_level ( id );
    	new classid = cod_get_user_class ( id );
    	if ( classid == 0 )  
    	{
    		client_cmd ( id , "say /class" ) 
    	}
    	else if ( oldLevel [ id ] < currentLevel )   
    	{	
    		client_cmd ( id , "say /stats" ) 
    	}
     
    	oldLevel [ id ] = currentLevel ; // update current level  
     
    	return HAM_IGNORED ;
    }
     
    public client_connect ( id ) { 
    	oldLevel [ id ] = - 1 ; // reset data   
    }
     
    public cod_class_changed ( id , class ) {  
    	set_task ( 1.0 , "wait_for_data" , id ); // we have to wait because cod_class_changed is called before load class data  
    }
     
    public wait_for_data ( id ) { 
    	oldLevel [ id ] = cod_get_user_level ( id ); // remember current level  
    }
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
