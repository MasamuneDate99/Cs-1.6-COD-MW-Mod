    #include <amxmodx>
    #include <orpheu>
    #define PLUGIN "Anti flood"
    #define VERSION "1.1"
    #define AUTHOR "kanagava"
    //native halflife_time ( )
    
    new MAX_WARN=1 
    new CONN_TIME=2 
    new CONN_TIME_IP=3 
    new RST_WARN_TIME_IP=10
     
    new Msg[256]
    new OrpheuHook:handlePrintf
    new ip_list[5][16]
    new time_list[5]
    new warn_list[5]
    new old_time
    new registered
    public plugin_init()
    {
        register_plugin(PLUGIN, VERSION, AUTHOR)
        set_task(5.0, "regfunctions")  
        register_srvcmd("floodlist","floodlist")  
    }
     
    public regfunctions()
    {
        //log_amx("try to reg_func")
        OrpheuRegisterHook(OrpheuGetFunction("SV_ConnectClient"),"OnSV_ConnectClientPre", OrpheuHookPre)
        OrpheuRegisterHook(OrpheuGetFunction("SV_ConnectClient"),"OnSV_ConnectClientPost", OrpheuHookPost)
        server_cmd("mp_logecho 1")
        server_cmd("log on")
    }
     
    public OrpheuHookReturn:OnSV_ConnectClientPre()
    {
        registered=0
        if(get_systime()-old_time <= CONN_TIME)
        {
            //log_amx("Reg %d %d ",halflife_time ( ), get_systime())
            handlePrintf = OrpheuRegisterHook( OrpheuGetFunction( "Con_Printf" ), "Con_Printf" , OrpheuHookPre);
            registered=1
            //log_amx("Reg %d %d ",halflife_time ( ), get_systime())
        }
        old_time=get_systime()
        return OrpheuIgnored;
    }
     
     
    public OrpheuHookReturn:OnSV_ConnectClientPost()
    {
        if(registered)
        {
            OrpheuUnregisterHook(handlePrintf)
            //log_amx("Unreg %d %d ",halflife_time ( ), get_systime())
        }
        return OrpheuIgnored;
    }
     
    public OrpheuHookReturn:Con_Printf(const a[], const message[] )
    {
        registered=1
        if (containi(message,"^" connected, address ^"")!=-1)
        {
            new msg[256]
            copy(msg,255,message)
            checkip(msg)
        }
        return OrpheuIgnored;
    }
     
    public floodlist()
    {
        new h_time[32]
        console_print(0,"Anti Flood ======== ON")
        for (new i=0;i<5;i++)
            {    if(time_list[i]!=0)
        {
            format_time ( h_time,31, "%d.%m %H:%M:%S",time_list[i])
            console_print(0,"[%d] [IP %s] [TIME %s]   [WARN's %d]",i,ip_list[i],h_time,warn_list[i])
        }
    }
    }
     
    public checkip(message[])
    {
        new len=255
        new temp_right[256],temp_left[256],conn_ip[256]
        formatex( Msg,charsmax( Msg ),"%s", message );
        split(Msg, temp_left, len, temp_right, len, "^" connected, address ^"")
        strtok(temp_right, conn_ip, len, temp_right, len, ':')
        new mintime
        new replace_index
        mintime=get_systime()
        for (new i=0;i<5;i++)
        {
            if (time_list[i]<mintime )
            {
                mintime=time_list[i]
                replace_index=i
            }
           
        }
        new ipwarn
        ipwarn=false
        for (new i=0;i<5;i++)
        {    
            if (equal(conn_ip,ip_list[i]) && !equal(conn_ip,""))
            {
                if ((get_systime()-time_list[i])<CONN_TIME_IP)
                {
                    warn_list[i]=warn_list[i]+1
                    if(warn_list[i]>MAX_WARN)
                    {
                        //log_amx("Ban %d %d ",halflife_time ( ), get_systime())
                        log_amx("[NOFLOOD] Connection flood detected from ip %s",conn_ip)
                        server_cmd("addip 60.0 %s",conn_ip)
                    }
                }
                else
                {
                    if ((get_systime()-time_list[i])>RST_WARN_TIME_IP)
                        warn_list[i]=0
                }
                   
                time_list[i]=get_systime()
                ipwarn=true
                break
            }
        }
           
        if (!ipwarn)
        {
            warn_list[replace_index]=0
            time_list[replace_index]=get_systime()
            copy(ip_list[replace_index],15,conn_ip)
        }
    } 