# Cs-1.6-COD-MW-Mod
Old repository for my AMXMODX source code. For Counter Strike 1.6, Call Of Duty : Modern Warfare mod.

Please note that i do not create the base mod. The base mod credit goes to QTM_Peyote on amxx.pl

Some of my old work file are missing ( Hard Drive issue ), and this repository only used to backup all of my old work files. This repository still a mess, there's still to many redundant file, double source, and etc.

Beginner guide for scripting ( Cod : MW mod )
https://pastebin.com/0BrWeXeC

Usefull Links :
  1. AMX Mod X Documentation                 : https://www.amxmodx.org/doc/
  2. AMX Mod X Plugin API Documentation      : https://www.amxmodx.org/api/
  3. CoD Mod Documentation                   : https://codmod_ozone.amxx.pl/cod ( Note this is a documentation for the old Cod. But almost all of the function still work the same as the new Cod, just a little bit different on name and the parameter. )
  4. Class Generator ( Should be usefull )   : https://amxx.pl/generator-klas/
  5. Translator                              : https://www.deepl.com/
  6. CS 1.6 Weapon Code                      : https://forums.alliedmods.net/archive/index.php/t-59003.html

# Current Work-In-Progress / To-Do-List
  1. Translating base mod into English
  2. Cleaning the repository
  3. ~~Updating the compiler Include Folder~~
  4. ~~Adding new Readme.md~~
  5. Updating the repository with new code on local
  6. Updating the Installer folder with AMXX 1.8.2
  7. Updating the Installer with the rest of the plugin

# Installing
> Make sure you have AMX MODX plugin installed on your **cstrike** folder, or else this plugin alone **WILL NOT WORK**

1. Copy paste the **cstrike** folder inside the Installer.
2. Configure the mod on **"Your CS 1.6 or Half-Life folder location"**/cstrike/addons/amxmodx/configs .
> There are 2 configs for Cod, plugins-codmod.ini for Cod mod configuration, and plugins.ini for AMX plugins.
3. Compile the plugin you **WANT** or **NEED**, and put it on the /cstrike/addons/amxmodx/plugins.
4. If you have a plugin that required extra model or sound, put it on /cstrike/models for .mdl folder, /cstrike/sound for sound, and /cstrike/sprite for sprite model.
5. Run the game

# In Game Commands
1. Type /help to shown the key help menu
2. Say /shop for Cod:MW shop ( Plugins, not on base mod )
3. Use perk 1 with "X" ( radio3 ) ( or you can bind with "useperk" )
4. Use perk 2 with "C" ( radio2 ) ( or you can bind with "useperk2" )
5. Type /stats to view your stats
6. Type /reset to reset your stats
7. Type /class to show the Class Selection menu
8. Type /classinfo to show the Class Info menu
9. Type /perks to show all available perk on Mod
10. Type /perk to show your current perk information
11. Type /perk2 to show your current perk 2 information

# Notes
* The registersystem config is for the RegisterSystem plugins.
* The cod_frakcje.ini is not required. But, if it's available, it will split the class with category.
> For example i have a "Normal" class, "Admin" class, and "Elite" class. If you configure it on cod_frakcje.ini it will make those 3 category.
