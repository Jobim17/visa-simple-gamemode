/* 
*	Visa Multiplayer
*	devs: Caliiu, DeviceBlack, Jobim
*	started at 26/03/2023 
*/

//#define LOCALHOST
#define CGEN_MEMORY 60000
#define YSI_YES_HEAP_MALLOC

//-----------------------------------------------------------------------------

#include <a_samp>
#include <a_mysql>
#include <easyDialog>
#include <YSI_Coding\y_timers>
#include <YSI_Coding\y_hooks>
#include <sscanf2>
#include <pawn.cmd>
#include <notify>
#include <YSF>
#include <strlib>
#include <discord-cmd>
#include <discord-connector>

//-----------------------------------------------------------------------------

#include "./modules/player/header.pwn"

#include "./modules/server/a_entry.pwn"
#include "./modules/player/a_entry.pwn"

//-----------------------------------------------------------------------------

main()
{
    print("\n");
	print("  |-------------------------------------------------------");
	print("  |--- Gamemode carregado com sucesso!");
    print("  |--  Script by Caliiu, DeviceBlack & Jobim");
	print("  |-------------------------------------------------------");
	print("\n");	
}

//-----------------------------------------------------------------------------

public OnGameModeInit()
{
	SetGameModeText("ViSA | Fugas/PVP");
	UsePlayerPedAnims();
	ShowNameTags(true);
	DisableInteriorEnterExits();
	SetNameTagDrawDistance(40.0);
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
	return true;
}

//-----------------------------------------------------------------------------

public OnGameModeExit()
{
	return true;
}

//-----------------------------------------------------------------------------