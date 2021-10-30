#include <amxmodx>
#include <amxmisc>

public plugin_init()
{
    new szFilepath[128]
    get_configsdir(szFilepath, charsmax(szFilepath))
    add(szFilepath, charsmax(szFilepath), "/lastmap.ini")
    
    new szStoredInfo[3]
    get_localinfo("asdf", szStoredInfo, charsmax(szStoredInfo))
    set_localinfo("asdf", "2")
    
    if( str_to_num(szStoredInfo) == 2 )
    {
        new szMapName[32]; get_mapname(szMapName, charsmax(szMapName));
        new f = fopen(szFilepath, "w")
        if(f)
        {
            fputs(f, szMapName)
            fclose(f)
        }
    }
    else
    {
        new f = fopen(szFilepath, "r")
        if(f)
        {
            new data[32]
            fgets(f, data, charsmax(data))
            trim(data)
            server_cmd("changelevel %s", data)
            fclose(f)
        }
    }
}  