/* 
*	module: player\worlds.pwn
*	author: Jobim 
*	desc: responsável pelo sistema de mundos
*/

#include <YSI_Coding\y_hooks>

//-----------------------------------------------------------------------------

#define MAX_WORLDS (30)

#define WORLD_PVP 		(0)
#define WORLD_FUGAS 	(1)

//-----------------------------------------------------------------------------

enum e_World
{
	bool: worldIsValid,

	worldHost,
	worldName[48],
	worldPassword[12],
	Float: worldGravity,
	bool: worldNoCollision,
	bool: worldHeavyVehicles,
	bool: worldDamages,
	bool: worldNames,
	bool: worldMarkers,
	bool: worldTeleports,
	bool: worldRepair,
	bool: worldNitro,
	bool: worldFlip
}

new World[MAX_WORLDS][e_World];

new gPlayerWorld[MAX_PLAYERS] = {-1, ...};
new gPlayerWorlds[MAX_PLAYERS][MAX_WORLDS];
new gPlayerVehicle[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...};
new gPlayerWorldConfig[MAX_PLAYERS][e_World];
new gPlayerEnteringWorld[MAX_PLAYERS] = {-1, ...};

new g_arrVehicleNames[212][48] = {
	"Landstalker","Bravura","Buffalo","Linerunner","Pereniel","Sentinel","Dumper","Firetruck","Trashmaster","Stretch","Manana","Infernus",
	"Voodoo","Pony","Mule","Cheetah","Ambulance","Leviathan","Moonbeam","Esperanto","Taxi","Washington","Bobcat","Mr Whoopee","BF Injection",
	"Hunter","Premier","Enforcer","Securicar","Banshee","Predator","Bus","Rhino","Barracks","Hotknife","Trailer","Previon","Coach","Cabbie",
	"Stallion","Rumpo","RC Bandit","Romero","Packer","Monster","Admiral","Squalo","Seasparrow","Pizzaboy","Tram","Trailer","Turismo","Speeder",
	"Reefer","Tropic","Flatbed","Yankee","Caddy","Solair","Berkley's RC Van","Skimmer","PCJ-600","Faggio","Freeway","RC Baron","RC Raider",
	"Glendale","Oceanic","Sanchez","Sparrow","Patriot","Quad","Coastguard","Dinghy","Hermes","Sabre","Rustler","ZR3 50","Walton","Regina",
	"Comet","BMX","Burrito","Camper","Marquis","Baggage","Dozer","Maverick","News Chopper","Rancher","FBI Rancher","Virgo","Greenwood",
	"Jetmax","Hotring","Sandking","Blista Compact","Police Maverick","Boxville","Benson","Mesa","RC Goblin","Hotring Racer A","Hotring Racer B",
	"Bloodring Banger","Rancher","Super GT","Elegant","Journey","Bike","Mountain Bike","Beagle","Cropdust","Stunt","Tanker","RoadTrain",
	"Nebula","Majestic","Buccaneer","Shamal","Hydra","FCR-900","NRG-500","HPV1000","Cement Truck","Tow Truck","Fortune","Cadrona","FBI Truck",
	"Willard","Forklift","Tractor","Combine","Feltzer","Remington","Slamvan","Blade","Freight","Streak","Vortex","Vincent","Bullet","Clover",
	"Sadler","Firetruck","Hustler","Intruder","Primo","Cargobob","Tampa","Sunrise","Merit","Utility","Nevada","Yosemite","Windsor","Monster A",
	"Monster B","Uranus","Jester","Sultan","Stratum","Elegy","Raindance","RC Tiger","Flash","Tahoma","Savanna","Bandito","Freight","Trailer",
	"Kart","Mower","Duneride","Sweeper","Broadway","Tornado","AT-400","DFT-30","Huntley","Stafford","BF-400","Newsvan","Tug","Trailer A","Emperor",
	"Wayfarer","Euros","Hotdog","Club","Trailer B","Trailer C","Andromada","Dodo","RC Cam","Launch","Police Car (LSPD)","Police Car (SFPD)",
	"Police Car (LVPD)","Police Ranger","Picador","S.W.A.T. Van","Alpha","Phoenix","Glendale","Sadler","Luggage Trailer A","Luggage Trailer B",
	"Stair Trailer","Boxville","Farm Plow","Utility Trailer"
};

//-----------------------------------------------------------------------------

hook OnGameModeInit()
{
	for (new i = 0; i < MAX_WORLDS; i++)
	{
		World_Reset(i);
	}

	// PvP
	World[WORLD_PVP][worldIsValid] = true;
	World[WORLD_PVP][worldHost] = INVALID_PLAYER_ID;
	World[WORLD_PVP][worldNoCollision] = false;
	World[WORLD_PVP][worldHeavyVehicles] = false;
	World[WORLD_PVP][worldDamages] = true;
	World[WORLD_PVP][worldNames] = true;
	World[WORLD_PVP][worldMarkers] = true;
	World[WORLD_PVP][worldTeleports] = true;
	World[WORLD_PVP][worldRepair] = true;
	World[WORLD_PVP][worldNitro] = true;
	World[WORLD_PVP][worldFlip] = true;
	World[WORLD_PVP][worldGravity] = 0.008;
	format (World[WORLD_PVP][worldPassword], 12, "");
	format (World[WORLD_PVP][worldName], 48, "Mundo Livre");

	// Fugas
	World[WORLD_FUGAS][worldIsValid] = true;
	World[WORLD_FUGAS][worldHost] = INVALID_PLAYER_ID;
	World[WORLD_FUGAS][worldNoCollision] = false;
	World[WORLD_FUGAS][worldHeavyVehicles] = false;
	World[WORLD_FUGAS][worldDamages] = false;
	World[WORLD_FUGAS][worldNames] = true;
	World[WORLD_FUGAS][worldMarkers] = false;
	World[WORLD_FUGAS][worldTeleports] = false;
	World[WORLD_FUGAS][worldRepair] = true;
	World[WORLD_FUGAS][worldNitro] = true;
	World[WORLD_FUGAS][worldFlip] = true;
	World[WORLD_FUGAS][worldGravity] = 0.008;
	format (World[WORLD_FUGAS][worldPassword], 12, "");
	format (World[WORLD_FUGAS][worldName], 48, "Mundo Fugas");
	return true;
}

hook OnPlayerConnect(playerid)
{
	World_SetPlayer(playerid, -1);
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDisconnect@0(playerid)
{
	World_SetPlayer(playerid, -1);
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerStreamIn(playerid, forplayerid)
{
	new
		idx = gPlayerWorld[playerid];

	// world
	if (World_Same(playerid, forplayerid))
	{
		// com name tag
		if (World[idx][worldNames])
		{
			ShowPlayerNameTagForPlayer(forplayerid, playerid, true);
		}

		// sem name tag
		else
		{
			ShowPlayerNameTagForPlayer(forplayerid, playerid, false);
		}	
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerSpawn(playerid)
{
	if (gPlayerWorld[playerid] == -1 || !IsPlayerLogged(playerid))
	{
		Kick(playerid);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, gPlayerWorld[playerid]);
	World_PlayerUpdate(playerid);
	SetCameraBehindPlayer(playerid);

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if (newstate == PLAYER_STATE_DRIVER)
	{
		new
			idx = GetPlayerVehicleID(playerid);

		if (Internal_IsValidBoost(idx) && World[gPlayerWorld[playerid]][worldNitro])
		{
			AddVehicleComponent(idx, 1010);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if (IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
	    new 
	    	idx = GetPlayerVehicleID(playerid);

	    // flip
	    if ((newkeys & KEY_LOOK_BEHIND) && !(oldkeys & KEY_LOOK_BEHIND) && World[gPlayerWorld[playerid]][worldFlip])
	    {
	    	new
	    		Float: z;

	    	GetVehicleZAngle(idx, z);
	    	SetVehicleZAngle(idx, z);
	    }

	    // reparo
	   	if (World[gPlayerWorld[playerid]][worldRepair] && (newkeys & KEY_CROUCH) && !(oldkeys & KEY_CROUCH))
	   	{
	   		RepairVehicle(idx);
	   	}

	    // nitro
	    if(Internal_IsValidBoost(idx) && World[gPlayerWorld[playerid]][worldNitro] && (oldkeys & 1 || oldkeys & 4))
	    {
	       	RemoveVehicleComponent(idx, 1010);
	        AddVehicleComponent(idx, 1010);
	    }
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if (!World[gPlayerWorld[playerid]][worldTeleports])
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Teleporte bloqueado pelo Anfitrião");
		return Y_HOOKS_BREAK_RETURN_1;
	}

	new
		idx = INVALID_VEHICLE_ID;

	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		idx = GetPlayerVehicleID(playerid);
	}

	SetPlayerPosFindZ(playerid, fX, fY, fZ);

	if (idx != INVALID_VEHICLE_ID)
	{
		new
			Float: x, Float: y, Float: z, Float: a;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);

		SetVehiclePos(idx, x, y, z);
		SetVehicleZAngle(idx, a);
		PutPlayerInVehicle(playerid, idx, 0);
		SetCameraBehindPlayer(playerid);
	}
	return Y_HOOKS_CONTINUE_RETURN_1;
}

public OnPlayerText(playerid, text[])
{
	if (!IsPlayerLogged(playerid) || gPlayerWorld[playerid] == -1)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não pode usar o chat agora");
		return false;
	}

	new
		str[192]
	;

	if (text[0] == '@')
	{
		format (str, sizeof str, "[Global] {%06x}%s {FFFFFF}(%i): %s", GetPlayerColor(playerid) >>> 8, ReturnPlayerName(playerid), playerid, text[1]);
		SendClientMessageToAll(0xC0C0C0FF, str);	
		return 0;
	}

	// Format
	if (Player[playerid][pAdmin])
	{
		format (str, sizeof str, "%s {FFFFFF}(%i) [{0096FF}Admin{FFFFFF}]: %s", ReturnPlayerName(playerid), playerid, text);
	}
	else
	{
		format (str, sizeof str, "%s {FFFFFF}(%i): %s", ReturnPlayerName(playerid), playerid, text);
	}

	SetPlayerChatBubble(playerid, text, -1, 20.0, 10000);

	// Send
	foreach (new i : Player)
	{
		if (!IsPlayerLogged(i))
			continue;

		if (gPlayerWorld[i] != gPlayerWorld[playerid])
			continue;

		SendClientMessage(i, GetPlayerColor(playerid), str);
	}

	return 0;
}

//-----------------------------------------------------------------------------

Dialog:Dialog_WorldPassword(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		World_Show(playerid);
		return true;
	}

	new idx = gPlayerEnteringWorld[playerid];

	if (idx == -1 || !World[idx][worldIsValid])
	{
		World_Show(playerid);
		return true;
	}

	if (!strcmp(inputtext, World[idx][worldPassword], false) || IsNull(World[idx][worldPassword]) || IsNull(inputtext) && Player[playerid][pAdmin])
	{
		World_SetPlayer(playerid, idx, true);
	}
	else
	{
		Dialog_Show(playerid, Dialog_WorldPassword, DIALOG_STYLE_INPUT, "{FF5555}ViSA > Mundos > Senha", "{FF5555}ERRO: Senha inválida\n\n{FFFFFF}Insira a senha para entrar no mundo:", "Inserir", "Voltar");
	}
	return true;
}

Dialog:Dialog_Worlds(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		if (gPlayerWorld[playerid] == -1)
		{
			World_Show(playerid);
		}
		return true;
	}

	if (gPlayerWorlds[playerid][listitem] != -1 && World[gPlayerWorlds[playerid][listitem]][worldIsValid])
	{
		if (IsNull(World[gPlayerWorlds[playerid][listitem]][worldPassword]))
		{
			World_SetPlayer(playerid, gPlayerWorlds[playerid][listitem], true);
		}
		else
		{
			gPlayerEnteringWorld[playerid] = gPlayerWorlds[playerid][listitem];
			Dialog_Show(playerid, Dialog_WorldPassword, DIALOG_STYLE_INPUT, "{FF5555}ViSA > Mundos > Senha", "{FFFFFF}Insira a senha para entrar no mundo:", "Inserir", "Voltar");
		}
	}
	else
	{
		WorldCreate_InitialConfig(playerid);
		WorldCreate_ShowConfig(playerid);
	}
	return true;
}

Dialog:Dialog_WorldCreateName(playerid, response, listitem, inputtext[])
{
	if (!response)
		return WorldCreate_ShowConfig(playerid);

	if (!(3 <= strlen(inputtext) <= 30))
	{
		Dialog_Show(playerid, Dialog_WorldCreateName, DIALOG_STYLE_INPUT, "{FF5555}ViSA > Criar Mundo > Nome", "{FF5555}ERRO: Nome muito grande ou pequeno.\n\n{FFFFFF}Nome atual: {FF5555}%s\n\n{FFFFFF}Insira o novo nome para o mundo:", "Inserir", "Voltar", gPlayerWorldConfig[playerid][worldName]);
		return true;
	}

	format (gPlayerWorldConfig[playerid][worldName], 32, inputtext);
	WorldCreate_ShowConfig(playerid);
	return true;
}

Dialog:Dialog_WorldCreatePass(playerid, response, listitem, inputtext[])
{
	if (!response)
		return WorldCreate_ShowConfig(playerid);

	if (strlen(inputtext) >= 10)
	{
		Dialog_Show(playerid, Dialog_WorldCreatePass, DIALOG_STYLE_INPUT, "{FF5555}ViSA > Criar Mundo > Senha", "{FF5555}ERRO: Senha muito grande\n{FFFFFF}Senha atual: {FF5555}%s\n\n{FFFFFF}Insira a nova senha para o mundo:", "Inserir", "Voltar", gPlayerWorldConfig[playerid][worldPassword]);
		return true;
	}

	if (strfind(inputtext, " ") != -1)
	{
		Dialog_Show(playerid, Dialog_WorldCreatePass, DIALOG_STYLE_INPUT, "{FF5555}ViSA > Criar Mundo > Senha", "{FF5555}ERRO: Senha inválida\n{FFFFFF}Senha atual: {FF5555}%s\n\n{FFFFFF}Insira a nova senha para o mundo:", "Inserir", "Voltar", gPlayerWorldConfig[playerid][worldPassword]);
		return true;
	}

	format (gPlayerWorldConfig[playerid][worldPassword], 12, inputtext);
	WorldCreate_ShowConfig(playerid);
	return true;
}

Dialog:WorldCreateGravity(playerid, response, listitem, inputtext[])
{
	if (!response)
		return WorldCreate_ShowConfig(playerid);

	new
		Float: gravity;

	if (sscanf(inputtext, "f", gravity))
	{
		Dialog_Show(playerid, WorldCreateGravity, DIALOG_STYLE_INPUT, "{FF5555}ViSA > Criar Mundo > Gravidade", "{FF5555}ERRO: Gravidade inválida\n{FFFFFF}Gravidade atual: {FF5555}%s\n\n{FFFFFF}Insira a nova gravidade para o mundo:", "Inserir", "Voltar", gPlayerWorldConfig[playerid][worldGravity]);
		return true;
	}

	gPlayerWorldConfig[playerid][worldGravity] = gravity;
	WorldCreate_ShowConfig(playerid);
	return true;
}

Dialog:Dialog_WorldCreate(playerid, response, listitem, inputtext[])
{
	if (!response)
		return World_Show(playerid);

	switch (listitem)
	{
		// Nome
		case 0:
		{
			Dialog_Show(playerid, Dialog_WorldCreateName, DIALOG_STYLE_INPUT, "{FF5555}ViSA > Criar Mundo > Nome", "{FFFFFF}Nome atual: {FF5555}%s\n\n{FFFFFF}Insira o novo nome para o mundo:", "Inserir", "Voltar", gPlayerWorldConfig[playerid][worldName]);
			return true;
		}

		// Senha
		case 1:
		{
			Dialog_Show(playerid, Dialog_WorldCreatePass, DIALOG_STYLE_INPUT, "{FF5555}ViSA > Criar Mundo > Senha", "{FFFFFF}Senha atual: {FF5555}%s\n\n{FFFFFF}Insira a nova senha para o mundo:", "Inserir", "Voltar", gPlayerWorldConfig[playerid][worldPassword]);
			return true;
		}

		// Gravidade
		case 2:
		{
			Dialog_Show(playerid, WorldCreateGravity, DIALOG_STYLE_INPUT, "{FF5555}ViSA > Criar Mundo > Gravidade", "{FFFFFF}Gravidade atual: {FF5555}%.03f\n\n{FFFFFF}Insira a nova gravidade para o mundo:", "Inserir", "Voltar", gPlayerWorldConfig[playerid][worldGravity]);
			return true;
		}

		// Sem colisão
		case 3: gPlayerWorldConfig[playerid][worldNoCollision] = !gPlayerWorldConfig[playerid][worldNoCollision];

		// Sem Danos
		case 4: gPlayerWorldConfig[playerid][worldDamages] = !gPlayerWorldConfig[playerid][worldDamages];

		// Veículos pesados
		case 5: gPlayerWorldConfig[playerid][worldHeavyVehicles] = !gPlayerWorldConfig[playerid][worldHeavyVehicles];

		// Teleportes
		case 6: gPlayerWorldConfig[playerid][worldTeleports] = !gPlayerWorldConfig[playerid][worldTeleports];

		// Flip
		case 7: gPlayerWorldConfig[playerid][worldFlip] = !gPlayerWorldConfig[playerid][worldFlip];

		// Name tags
		case 8: gPlayerWorldConfig[playerid][worldNames] = !gPlayerWorldConfig[playerid][worldNames];

		// Markers
		case 9: gPlayerWorldConfig[playerid][worldMarkers] = !gPlayerWorldConfig[playerid][worldMarkers];

		// Repair
		case 10: gPlayerWorldConfig[playerid][worldRepair] = !gPlayerWorldConfig[playerid][worldRepair];

		// Nitro
		case 11: gPlayerWorldConfig[playerid][worldNitro] = !gPlayerWorldConfig[playerid][worldNitro];

		// Create
		default: 
		{
			new
				idx = World_GetFreeID()
			;

			if (idx == -1)
			{
				ShowPlayerNotification(playerid, 0x33FF33FF, 5000, -1, "ERRO", "Limite de mundos atingido");
				return true;
			}

			World[idx] = gPlayerWorldConfig[playerid];
			World_SetPlayer(playerid, idx, true);
			return true;
		}
	}

	WorldCreate_ShowConfig(playerid);
	return true;
}

Dialog:Dialog_WorldConfigName(playerid, response, listitem, inputtext[])
{
	if (!response)
		return World_ShowConfig(playerid);

	format (inputtext, 64, "/mundonome %s", inputtext);
	PC_EmulateCommand(playerid, inputtext);
	World_ShowConfig(playerid);
	return true;
}

Dialog:Dialog_WorldConfigPass(playerid, response, listitem, inputtext[])
{
	if (!response)
		return World_ShowConfig(playerid);

	format (inputtext, 64, "/mundosenha %s", inputtext);
	PC_EmulateCommand(playerid, inputtext);
	World_ShowConfig(playerid);
	return true;
}

Dialog:WorldConfigGravity(playerid, response, listitem, inputtext[])
{
	if (!response)
		return World_ShowConfig(playerid);

	format (inputtext, 64, "/mundogravidade %s", inputtext);
	PC_EmulateCommand(playerid, inputtext);
	World_ShowConfig(playerid);
	return true;
}

Dialog:Dialog_WorldConfig(playerid, response, listitem, inputtext[])
{
	if (!response)
		return true;

	new
		idx = gPlayerWorld[playerid];

	switch (listitem)
	{
		// Nome
		case 0:
		{
			Dialog_Show(playerid, Dialog_WorldConfigName, DIALOG_STYLE_INPUT, "{FF5555}ViSA > Mundo Config > Nome", "{FFFFFF}Nome atual: {FF5555}%s\n\n{FFFFFF}Insira o novo nome para o mundo:", "Inserir", "Voltar", World[idx][worldName]);
			return true;
		}

		// Senha
		case 1:
		{
			Dialog_Show(playerid, Dialog_WorldConfigPass, DIALOG_STYLE_INPUT, "{FF5555}ViSA > Mundo Config > Senha", "{FFFFFF}Senha atual: {FF5555}%s\n\n{FFFFFF}Insira a nova senha para o mundo:", "Inserir", "Voltar", World[idx][worldPassword]);
			return true;
		}

		// Gravidade
		case 2:
		{
			Dialog_Show(playerid, WorldConfigGravity, DIALOG_STYLE_INPUT, "{FF5555}ViSA > Mundo Config > Gravidade", "{FFFFFF}Gravidade atual: {FF5555}%s\n\n{FFFFFF}Insira a nova gravidade para o mundo:", "Inserir", "Voltar", World[idx][worldGravity]);
			return true;
		}

		// Sem colisão
		case 3: PC_EmulateCommand(playerid, "/mundosemcolisao");

		// Sem Danos
		case 4: PC_EmulateCommand(playerid, "/mundosemdanos");

		// Veículos pesados
		case 5: PC_EmulateCommand(playerid, "/mundosemveiculospesados");

		// Teleportes
		case 6: PC_EmulateCommand(playerid, "/mundoteleportes");

		// Flip
		case 7: PC_EmulateCommand(playerid, "/mundoflip");

		// Name tags
		case 8: PC_EmulateCommand(playerid, "/mundonicknames");

		// Markers
		case 9: PC_EmulateCommand(playerid, "/mundoicones");

		// Reparo
		case 10: PC_EmulateCommand(playerid, "/mundoreparo");

		// Nitro
		case 11: PC_EmulateCommand(playerid, "/mundonitro");

		// Delete
		default: 
		{
			World_Reset(idx);

			foreach (new i : Player)
			{
				if (!IsPlayerLogged(i))
					continue;

				if (gPlayerWorld[i] != idx)
					continue;

				ShowPlayerNotification(i, 0xFF5555FF, 5000, -1, "MUNDO", "Mundo deletado pelo Anfitrião ou por um Admin");
				World_SetPlayer(i, WORLD_PVP, true);
			}

			return true;
		}
	}

	World_ShowConfig(playerid);
	return true;
}

//-----------------------------------------------------------------------------

WorldCreate_InitialConfig(playerid)
{
	if (!IsPlayerConnected(playerid))
		return false;

	if (!IsPlayerLogged(playerid))
		return false;

	gPlayerWorldConfig[playerid][worldIsValid] = true;
	gPlayerWorldConfig[playerid][worldGravity] = 0.008;
	gPlayerWorldConfig[playerid][worldNames] = true;
	gPlayerWorldConfig[playerid][worldMarkers] = true;
	gPlayerWorldConfig[playerid][worldTeleports] = true;
	gPlayerWorldConfig[playerid][worldRepair] = true;
	gPlayerWorldConfig[playerid][worldNitro] = true;
	gPlayerWorldConfig[playerid][worldHost] = playerid;
	format (gPlayerWorldConfig[playerid][worldPassword], 12, "");
	format (gPlayerWorldConfig[playerid][worldName], 48, "Mundo de %s", ReturnPlayerName(playerid));
	return true;
}

WorldCreate_ShowConfig(playerid)
{
	if (!IsPlayerConnected(playerid))
		return false;

	if (!IsPlayerLogged(playerid))
		return false;

	new
		big_str[1024],
		tmp_str[128]
	;

	format (big_str, sizeof big_str, "{FFFFFF}Parâmetro\t{FFFFFF}Valor\n");

	// Nome
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Nome\t{FFFFFF}%s\n", gPlayerWorldConfig[playerid][worldName]);
	strcat (big_str, tmp_str);

	// Senha
	strcat (big_str, "{FFFFFF}Senha\t");

	if (IsNull(gPlayerWorldConfig[playerid][worldPassword]))
	{
		strcat (big_str, "{C0C0C0}Nenhuma\n");
	}
	else
	{
		format (tmp_str, sizeof tmp_str, "{FF5555}%s\n", gPlayerWorldConfig[playerid][worldPassword]);
		strcat (big_str, tmp_str);
	}

	// Gravidade
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Gravidade\t{C0C0C0}%.03f\n", gPlayerWorldConfig[playerid][worldGravity]);
	strcat (big_str, tmp_str);

	// Sem Colisão
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Sem colisão\t%s\n", (gPlayerWorldConfig[playerid][worldNoCollision] ? ("{33FF33}Sim") : ("{C0C0C0}Não")));
	strcat (big_str, tmp_str);

	// Sem danos
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Sem danos\t%s\n", (gPlayerWorldConfig[playerid][worldDamages] ? ("{C0C0C0}Não") : ("{33FF33}Sim")));
	strcat (big_str, tmp_str);

	// Veículos Pesados
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Veículos pesados\t%s\n", (gPlayerWorldConfig[playerid][worldHeavyVehicles] ? ("{C0C0C0}Permitido") : ("{FF5555}Bloqueado")));
	strcat (big_str, tmp_str);

	// Teleportes
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Teleportes\t%s\n", (gPlayerWorldConfig[playerid][worldTeleports] ? ("{C0C0C0}Permitido") : ("{FF5555}Bloqueado")));
	strcat (big_str, tmp_str);

	// Desvirar veículo (/F)
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Desvirar veículo (/F)\t%s\n", (gPlayerWorldConfig[playerid][worldFlip] ? ("{C0C0C0}Permitido") : ("{FF5555}Bloqueado")));
	strcat (big_str, tmp_str);

	// Nicknames
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Nametags\t%s\n", (gPlayerWorldConfig[playerid][worldNames] ? ("{C0C0C0}Visíveis") : ("{FF5555}Ocultas")));
	strcat (big_str, tmp_str);

	// Ícones
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Ícones\t%s\n", (gPlayerWorldConfig[playerid][worldMarkers] ? ("{C0C0C0}Visíveis") : ("{FF5555}Ocultos")));
	strcat (big_str, tmp_str);

	// Reparo
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Reparo (H)\t%s\n", (gPlayerWorldConfig[playerid][worldRepair] ? ("{C0C0C0}Ativado") : ("{FF5555}Desativado")));
	strcat (big_str, tmp_str);

	// Nitro
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Nitro infinito\t%s\n", (gPlayerWorldConfig[playerid][worldNitro] ? ("{C0C0C0}Ativado") : ("{FF5555}Desativado")));
	strcat (big_str, tmp_str);

	// Criar mundo
	strcat (big_str, "{FF5555}-> Finalizar configurações");

	// Show
	Dialog_Show(playerid, Dialog_WorldCreate, DIALOG_STYLE_TABLIST_HEADERS, "{FF5555}ViSA > Mundos > Criar Mundo", big_str, "Editar", "Voltar");
	return true;
}

World_ShowConfig(playerid)
{
	if (!IsPlayerConnected(playerid))
		return false;

	if (!IsPlayerLogged(playerid))
		return false;

	new
		idx = gPlayerWorld[playerid],
		big_str[1024],
		tmp_str[128]
	;

	if (idx == -1)
		return false;

	if (!Player[playerid][pAdmin] && !World_IsOwner(playerid))
		return false;

	format (big_str, sizeof big_str, "{FFFFFF}Parâmetro\t{FFFFFF}Valor\n");

	// Nome
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Nome\t{FFFFFF}%s\n", World[idx][worldName]);
	strcat (big_str, tmp_str);

	// Senha
	strcat (big_str, "{FFFFFF}Senha\t");

	if (IsNull(World[idx][worldPassword]))
	{
		strcat (big_str, "{C0C0C0}Nenhuma\n");
	}
	else
	{
		format (tmp_str, sizeof tmp_str, "{FF5555}%s\n", World[idx][worldPassword]);
		strcat (big_str, tmp_str);
	}

	// Gravidade
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Gravidade\t%.03f\n", World[idx][worldGravity]);
	strcat (big_str, tmp_str);

	// Sem Colisão
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Sem colisão\t%s\n", (World[idx][worldNoCollision] ? ("{33FF33}Sim") : ("{C0C0C0}Não")));
	strcat (big_str, tmp_str);

	// Sem danos
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Sem danos\t%s\n", (World[idx][worldDamages] ? ("{C0C0C0}Não") : ("{33FF33}Sim")));
	strcat (big_str, tmp_str);

	// Veículos Pesados
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Veículos pesados\t%s\n", (World[idx][worldHeavyVehicles] ? ("{C0C0C0}Permitido") : ("{FF5555}Bloqueado")));
	strcat (big_str, tmp_str);

	// Teleportes
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Teleportes\t%s\n", (World[idx][worldTeleports] ? ("{C0C0C0}Permitido") : ("{FF5555}Bloqueado")));
	strcat (big_str, tmp_str);

	// Desvirar veículo
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Desvirar veículo (/F)\t%s\n", (World[idx][worldFlip] ? ("{C0C0C0}Permitido") : ("{FF5555}Bloqueado")));
	strcat (big_str, tmp_str);

	// Nicknames
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Nametags\t%s\n", (World[idx][worldNames] ? ("{C0C0C0}Visíveis") : ("{FF5555}Ocultas")));
	strcat (big_str, tmp_str);

	// Ícones
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Ícones\t%s\n", (World[idx][worldMarkers] ? ("{C0C0C0}Visíveis") : ("{FF5555}Ocultos")));
	strcat (big_str, tmp_str);

	// Reparo (H)
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Reparo (H)\t%s\n", (World[idx][worldRepair] ? ("{C0C0C0}Ativado") : ("{FF5555}Desativado")));
	strcat (big_str, tmp_str);

	// Nitro infinito
	format (tmp_str, sizeof tmp_str, "{FFFFFF}Nitro infinito\t%s\n", (World[idx][worldNitro] ? ("{C0C0C0}Ativado") : ("{FF5555}Desativado")));
	strcat (big_str, tmp_str);

	// Deletar mundo
	strcat (big_str, "{FF5555}-> Deletar Mundo");

	// Show
	Dialog_Show(playerid, Dialog_WorldConfig, DIALOG_STYLE_TABLIST_HEADERS, "{FF5555}ViSA > Mundos > Mundo Config", big_str, "Editar", "Voltar");
	return true;
}

World_Reset(index)
{
	if (!(0 <= index < MAX_WORLDS))
		return false;

	new emptyWorld[e_World];

	World[index] = emptyWorld;
	return true;
}

World_SetPlayer(playerid, world_id, bool:respawn = false, bool:force = false, bool:destroyvehicle = true)
{
	if (!(-1 <= world_id < MAX_WORLDS))
		return false;

	if (!IsPlayerConnected(playerid))
		return true;

	if (world_id != -1 && !World[world_id][worldIsValid])
		return true;

	if (world_id != -1 && gPlayerWorld[playerid] == world_id && !force)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você já está neste mundo");
		return true;
	}

	if(IsFlyMode(playerid))
	{
		CancelFlyMode(playerid);
	}

	// vehicle
	if (gPlayerVehicle[playerid] != INVALID_VEHICLE_ID && destroyvehicle)
	{
		DestroyVehicle(gPlayerVehicle[playerid]);
		gPlayerVehicle[playerid] = INVALID_VEHICLE_ID;
	}

	new
		idx = gPlayerWorld[playerid];

	// old world
	if (idx != -1 && World[idx][worldIsValid])
	{
		World_SendMessage(idx, 0xFF5555FF, "[Mundo] %s saiu do mundo (players: %i)", ReturnPlayerName(playerid), World_GetCount(idx) - 1);

		if (World_IsOwner(playerid))
		{
			new
				host = INVALID_PLAYER_ID;

			foreach (new i : Player)
			{
				if (!IsPlayerLogged(i))
					continue;

				if (gPlayerWorld[i] != idx)
					continue;

				if (i == playerid)
					continue;

				host = i;
				break;
			}

			if (host == INVALID_PLAYER_ID)
			{
				World[idx][worldIsValid] = false;
			}
			else
			{
				World[idx][worldHost] = host;
				World_SendMessage(idx, 0x33FF33FF, "[Mundo] %s (%i) é o novo Anfitrião do mundo!", ReturnPlayerName(host), host);
				ShowPlayerNotification(host, 0x33FF33FF, 5000, -1, "MUNDO", "Você é novo Anfitrião do mundo!");
			}
		}
	}

	// set
	gPlayerWorld[playerid] = world_id;

	if (world_id != -1)
	{
		SetPlayerVirtualWorld(playerid, world_id);
		World_PlayerUpdate(playerid);
		World_SendMessage(world_id, 0x33FF33FF, "[Mundo] %s entrou no mundo (players: %i)", ReturnPlayerName(playerid), World_GetCount(world_id));
	}

	if (respawn)
	{
		Player_Spawn(playerid);
	}
	return true;
}

World_Same(playerid, forplayerid)
{
	return (gPlayerWorld[playerid] == gPlayerWorld[forplayerid]);
}

World_IsOwner(playerid)
{
	if (!IsPlayerConnected(playerid))
		return false;

	if (playerid == INVALID_PLAYER_ID)
		return false;

	new
		idx = gPlayerWorld[playerid]
	;

	if (idx == -1)
		return false;

	if (World[idx][worldIsValid] == true && World[idx][worldHost] == playerid)
		return true;

	return false;
}

World_GetFreeID()
{
	new
		idx = -1
	;

	for (new i = 0; i < MAX_WORLDS; i++)
	{
		if (World[i][worldIsValid])
			continue;

		idx = i;
		break;
	}

	return idx;
}

World_PlayerUpdate(playerid)
{
	if (!IsPlayerConnected(playerid))
		return true;

	new
		idx = gPlayerWorld[playerid];

	// name tag
	foreach (new i : StreamedPlayer[playerid])
	{
		if (World_Same(playerid, i))
		{
			// com name tag
			if (World[idx][worldNames])
			{
				ShowPlayerNameTagForPlayer(playerid, i, true);
			}

			// sem name tag
			else
			{
				ShowPlayerNameTagForPlayer(playerid, i, false);
			}	
		}
	}

	// colisão
	if (World[idx][worldNoCollision])
	{
		DisableRemoteVehicleCollisions(playerid, true);
	}

	// sem colisão
	else
	{
		DisableRemoteVehicleCollisions(playerid, false);
	}

	// com danos
	if (World[idx][worldDamages])
	{
		SetPlayerTeam(playerid, NO_TEAM);
	}

	// sem danos
	else
	{
		SetPlayerTeam(playerid, 1);
	}

	// with markers
	if (World[idx][worldMarkers])
	{
		SetPlayerColor(playerid, SetColorAlpha(GetPlayerColor(playerid), 0xFF));
	}
	// not with markers
	else 
	{
		SetPlayerColor(playerid, SetColorAlpha(GetPlayerColor(playerid), 0x00));
	}

	// gravity
	SetPlayerGravity(playerid, World[idx][worldGravity]);
	return true;
}

World_Show(playerid)
{
	if (!IsPlayerConnected(playerid))
		return false;

	new
		tmp_str[128],
		big_str[2048],
		count = 0
	;

	format (big_str, sizeof big_str, "{FFFFFF}Mundo\t{FFFFFF}Público\t{FFFFFF}Jogadores\t{FFFFFF}Anfitrião\n");

	for (new i = 0; i < MAX_WORLDS; i++)
	{
		gPlayerWorlds[playerid][i] = -1;

		if (!World[i][worldIsValid])
			continue;

		// mundo
		strcat (big_str, "{FFFFFF}");
		strcat (big_str, World[i][worldName]);
		strcat (big_str, "\t");

		// público
		if (IsNull(World[i][worldPassword]))
		{
			strcat (big_str, "{33FF33}Sim\t");
		}
		else
		{
			strcat (big_str, "{FF1414}Não\t");
		}

		// jogadores
		format (tmp_str, sizeof tmp_str, "{%s}%i\t", (World_GetCount(i) > 0 ? ("33FF33") : ("FFFFFF")), World_GetCount(i));
		strcat (big_str, tmp_str);

		// anfitrião
		if (World[i][worldHost] == INVALID_PLAYER_ID)
		{
			strcat (big_str, "{C0C0C0}Servidor\n");
		}
		else
		{
			strcat (big_str, "{FFFFFF}");
			strcat (big_str, ReturnPlayerName(World[i][worldHost]));
			strcat (big_str, "\n");
		}

		// count
		gPlayerWorlds[playerid][count] = i;
		count += 1;
	}

	strcat (big_str, "{FF5555}-> Hospedar seu próprio mundo");

	Dialog_Show(playerid, Dialog_Worlds, DIALOG_STYLE_TABLIST_HEADERS, "{FF5555}ViSA > Mundos", big_str, "Entrar", "Fechar");
	return true;
}

World_GetCount(idx)
{
	new
		count = 0;

	foreach (new i : Player)
	{
		if (!IsPlayerLogged(i))
			continue;

		if (gPlayerWorld[i] != idx)
			continue;

		count += 1;
	}

	return count;
}

World_SendMessage(world_id, color, const _msg[], va_args<>)
{
	new
		msg[144]
	;

	va_format(msg, sizeof msg, _msg, va_start<3>);

	foreach (new i : Player)
	{
		if (!IsPlayerLogged(i))
			continue;

		if (gPlayerWorld[i] != world_id)
			continue;

		SendClientMessage(i, color, msg);
	}

	return true;
}

Internal_IsValidBoost(arg0) //stock
{
	new var0 = GetVehicleModel(arg0);
	switch(var0)
	{
		case 444:
			return 0;
		case 581:
			return 0;
		case 586:
			return 0;
		case 481:
			return 0;
		case 509:
			return 0;
		case 446:
			return 0;
		case 556:
			return 0;
		case 443:
			return 0;
		case 452:
			return 0;
		case 453:
			return 0;
		case 454:
			return 0;
		case 472:
			return 0;
		case 473:
			return 0;
		case 484:
			return 0;
		case 493:
			return 0;
		case 595:
			return 0;
		case 462:
			return 0;
		case 463:
			return 0;
		case 468:
			return 0;
		case 521:
			return 0;
		case 522:
			return 0;
		case 417:
			return 0;
		case 425:
			return 0;
		case 447:
			return 0;
		case 487:
			return 0;
		case 488:
			return 0;
		case 497:
			return 0;
		case 501:
			return 0;
		case 548:
			return 0;
		case 563:
			return 0;
		case 406:
			return 0;
		case 520:
			return 0;
		case 539:
			return 0;
		case 553:
			return 0;
		case 557:
			return 0;
		case 573:
			return 0;
		case 460:
			return 0;
		case 593:
			return 0;
		case 464:
			return 0;
		case 476:
			return 0;
		case 511:
			return 0;
		case 512:
			return 0;
		case 577:
			return 0;
		case 592:
			return 0;
		case 471:
			return 0;
		case 448:
			return 0;
		case 461:
			return 0;
		case 523:
			return 0;
		case 510:
			return 0;
		case 430:
			return 0;
		case 465:
			return 0;
		case 469:
			return 0;
		case 513:
			return 0;
		case 519:
			return 0;
	}
	return 1;
}

CreatePlayerVehicle(playerid, model)
{
    if (GetPlayerInterior(playerid) != 0)
    {
    	ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não pode criar veículos em interiores");
        return false;
    }

    if (!(400 <= model <= 611))
    {
    	ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Modelo ID inválido");
        return false;
    }

    if (model == 432 || model == 520 || model == 447 || model == 425 || model == 464)
    {
    	if (!World[gPlayerWorld[playerid]][worldHeavyVehicles])
    	{
    		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "O Anfitrião bloqueou os veículos pesados.");
    		return true;
    	}
    }

    if (gPlayerVehicle[playerid] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(gPlayerVehicle[playerid]);
        gPlayerVehicle[playerid] = INVALID_VEHICLE_ID;
    }

    new Float: x, Float: y, Float: z, Float: a;

    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    gPlayerVehicle[playerid] = CreateVehicle(model, x, y, z + 1.5, a, random(256), random(256), -1);
    SetVehicleVirtualWorld(gPlayerVehicle[playerid], GetPlayerVirtualWorld(playerid));
    LinkVehicleToInterior(gPlayerVehicle[playerid], GetPlayerInterior(playerid));
    PutPlayerInVehicle(playerid, gPlayerVehicle[playerid], 0);
    return true;
}

GetVehicleModelIDFromName(const vname[])
{
	for(new i = 0; i < 211; i++)
	{
		if ( strfind(g_arrVehicleNames[i], vname, true) != -1 )
			return i + 400;
	}
	return -1;
}

//-----------------------------------------------------------------------------

CMD:mundos(playerid)
{
	World_Show(playerid);
	return true;
}

CMD:mundokick(playerid, params[])
{
	if (!Player[playerid][pAdmin] && !World_IsOwner(playerid))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é o Anfitrião do mundo");
		return true;
	}

	new
		idx,
		reason[32]
	;

	if (sscanf(params, "is[32]", idx, reason))
	{
		ShowPlayerNotification(playerid, 0xFF9090FF, 5000, -1, "USO", "/mundokick [id] [motivo]");
		return true;
	}

	if (!IsPlayerConnected(idx))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "ID inválido");
		return true;
	}

	if (!IsPlayerLogged(idx))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "ID inválido");
		return true;
	}

	if (idx == playerid)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Jogador é você");
		return true;
	}

	if (Player[idx][pAdmin])
	{	
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Jogador é um admin");
		return true;
	}

	if (!World_Same(playerid, idx))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Jogador não está no seu mundo");
		return true;
	}
 
	World_SendMessage(gPlayerWorld[playerid], 0xFF5555FF, "[Mundo] %s %s kickou %s do mundo (Motivo: %s)", (World_IsOwner(playerid) ? ("Anfitrião") : ("Admin")), ReturnPlayerName(playerid), ReturnPlayerName(idx), reason);
	World_SetPlayer(idx, WORLD_PVP, true);
	return true;
}

//-----------------------------------------------------------------------------

CMD:mundoconfig(playerid)
{
	if (!Player[playerid][pAdmin] && !World_IsOwner(playerid))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é o Anfitrião do mundo");
		return true;
	}

	World_ShowConfig(playerid);
	return true;
}

CMD:mundonome(playerid, params[])
{
	if (!Player[playerid][pAdmin] && !World_IsOwner(playerid))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é o Anfitrião do mundo");
		return true;
	}

	if (!(3 <= strlen(params) <= 30))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Nome muito grande ou pequeno");
		return true;
	}

	format (World[gPlayerWorld[playerid]][worldName], 48, params);
	ShowPlayerNotification(playerid, 0x33FF33FF, 5000, -1, "MUNDO", "Nome alterado com sucesso");
	return true;
}

CMD:mundosenha(playerid, params[])
{
	if (!Player[playerid][pAdmin] && !World_IsOwner(playerid))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é o Anfitrião do mundo");
		return true;
	}

	if (strlen(params) >= 10)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Senha muito grande");
		return true;
	}

	format (World[gPlayerWorld[playerid]][worldPassword], 12, params);
	ShowPlayerNotification(playerid, 0x33FF33FF, 5000, -1, "MUNDO", "Senha alterada com sucesso");
	return true;
}

CMD:mundogravidade(playerid, params[])
{
	if (!Player[playerid][pAdmin] && !World_IsOwner(playerid))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é o Anfitrião do mundo");
		return true;
	}

	new
		Float: gravity,
		idx = gPlayerWorld[playerid];

	if (sscanf(params, "f", gravity))
	{
		ShowPlayerNotification(playerid, 0xFFFF90FF, 5000, -1, "USO", "/mundogravidade [gravidade]");
		return true;
	}

	World[idx][worldGravity] = gravity;

	World_SendMessage(idx, 0x33FF33FF, "[Mundo] %s %s alterou a gravidade para %.03f", (World_IsOwner(playerid) ? ("Anfitrião") : ("Admin")), ReturnPlayerName(playerid), gravity);

	foreach (new i : Player)
	{
		if (!IsPlayerLogged(i))
			continue;

		if (gPlayerWorld[i] != idx)
			continue;

		World_PlayerUpdate(i);
	}
	return true;
}

CMD:mundosemcolisao(playerid)
{
	if (!Player[playerid][pAdmin] && !World_IsOwner(playerid))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é o Anfitrião do mundo");
		return true;
	}

	new
		idx = gPlayerWorld[playerid]
	;

	World[idx][worldNoCollision] = !World[idx][worldNoCollision];

	World_SendMessage(idx, 0x33FF33FF, "[Mundo] %s %s %s a colisão dos veículos", (World_IsOwner(playerid) ? ("Anfitrião") : ("Admin")), ReturnPlayerName(playerid), (World[idx][worldNoCollision] ? ("desativou") : ("ativou")));

	foreach (new i : Player)
	{
		if (!IsPlayerLogged(i))
			continue;

		if (gPlayerWorld[i] != idx)
			continue;

		World_PlayerUpdate(i);
	}

	return true;
}

CMD:mundosemdanos(playerid)
{
	if (!Player[playerid][pAdmin] && !World_IsOwner(playerid))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é o Anfitrião do mundo");
		return true;
	}

	new
		idx = gPlayerWorld[playerid]
	;

	World[idx][worldDamages] = !World[idx][worldDamages];

	World_SendMessage(idx, 0x33FF33FF, "[Mundo] %s %s %s os danos entre jogadores", (World_IsOwner(playerid) ? ("Anfitrião") : ("Admin")), ReturnPlayerName(playerid), (World[idx][worldDamages] ? ("ativou") : ("desativou")));

	foreach (new i : Player)
	{
		if (!IsPlayerLogged(i))
			continue;

		if (gPlayerWorld[i] != idx)
			continue;

		World_PlayerUpdate(i);
	}

	return true;
}

CMD:mundosemveiculospesados(playerid)
{
	if (!Player[playerid][pAdmin] && !World_IsOwner(playerid))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é o Anfitrião do mundo");
		return true;
	}

	new
		idx = gPlayerWorld[playerid]
	;

	World[idx][worldHeavyVehicles] = !World[idx][worldHeavyVehicles];

	World_SendMessage(idx, 0x33FF33FF, "[Mundo] %s %s %s os veículos pesados (Hydra, Hunter, etc.)", (World_IsOwner(playerid) ? ("Anfitrião") : ("Admin")), ReturnPlayerName(playerid), (World[idx][worldHeavyVehicles] ? ("desbloqueou") : ("bloqueou")));

	foreach (new i : Player)
	{
		if (!IsPlayerLogged(i))
			continue;

		if (gPlayerWorld[i] != idx)
			continue;

		World_PlayerUpdate(i);
	}

	return true;
}

CMD:mundoteleportes(playerid)
{
	if (!Player[playerid][pAdmin] && !World_IsOwner(playerid))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é o Anfitrião do mundo");
		return true;
	}

	new
		idx = gPlayerWorld[playerid]
	;

	World[idx][worldTeleports] = !World[idx][worldTeleports];

	World_SendMessage(idx, 0x33FF33FF, "[Mundo] %s %s %s os teleportes", (World_IsOwner(playerid) ? ("Anfitrião") : ("Admin")), ReturnPlayerName(playerid), (World[idx][worldTeleports] ? ("desbloqueou") : ("bloqueou")));
	return true;
}

CMD:mundoflip(playerid)
{
	if (!Player[playerid][pAdmin] && !World_IsOwner(playerid))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é o Anfitrião do mundo");
		return true;
	}

	new
		idx = gPlayerWorld[playerid]
	;

	World[idx][worldFlip] = !World[idx][worldFlip];

	World_SendMessage(idx, 0x33FF33FF, "[Mundo] %s %s %s o flip em veículos (/F)", (World_IsOwner(playerid) ? ("Anfitrião") : ("Admin")), ReturnPlayerName(playerid), (World[idx][worldFlip] ? ("desbloqueou") : ("bloqueou")));
	return true;
}

CMD:mundonicknames(playerid)
{
	if (!Player[playerid][pAdmin] && !World_IsOwner(playerid))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é o Anfitrião do mundo");
		return true;
	}

	new
		idx = gPlayerWorld[playerid]
	;

	World[idx][worldNames] = !World[idx][worldNames];

	World_SendMessage(idx, 0x33FF33FF, "[Mundo] %s %s %s os nicknames dos jogadores", (World_IsOwner(playerid) ? ("Anfitrião") : ("Admin")), ReturnPlayerName(playerid), (World[idx][worldNames] ? ("ativou") : ("desativou")));

	foreach (new i : Player)
	{
		if (!IsPlayerLogged(i))
			continue;

		if (gPlayerWorld[i] != idx)
			continue;

		World_PlayerUpdate(i);
	}

	return true;
}

CMD:mundoicones(playerid)
{
	if (!Player[playerid][pAdmin] && !World_IsOwner(playerid))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é o Anfitrião do mundo");
		return true;
	}

	new
		idx = gPlayerWorld[playerid]
	;

	World[idx][worldMarkers] = !World[idx][worldMarkers];

	World_SendMessage(idx, 0x33FF33FF, "[Mundo] %s %s %s os ícones dos jogadores", (World_IsOwner(playerid) ? ("Anfitrião") : ("Admin")), ReturnPlayerName(playerid), (World[idx][worldMarkers] ? ("ativou") : ("desativou")));

	foreach (new i : Player)
	{
		if (!IsPlayerLogged(i))
			continue;

		if (gPlayerWorld[i] != idx)
			continue;

		World_PlayerUpdate(i);
	}

	return true;
}

CMD:mundoreparo(playerid)
{
	if (!Player[playerid][pAdmin] && !World_IsOwner(playerid))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é o Anfitrião do mundo");
		return true;
	}

	new
		idx = gPlayerWorld[playerid]
	;

	World[idx][worldRepair] = !World[idx][worldRepair];

	World_SendMessage(idx, 0x33FF33FF, "[Mundo] %s %s %s o reparo de veículos (Key: H)", (World_IsOwner(playerid) ? ("Anfitrião") : ("Admin")), ReturnPlayerName(playerid), (World[idx][worldRepair] ? ("ativou") : ("desativou")));
	return true;
}

CMD:mundonitro(playerid)
{
	if (!Player[playerid][pAdmin] && !World_IsOwner(playerid))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é o Anfitrião do mundo");
		return true;
	}

	new
		idx = gPlayerWorld[playerid]
	;

	World[idx][worldNitro] = !World[idx][worldNitro];

	World_SendMessage(idx, 0x33FF33FF, "[Mundo] %s %s %s o nitro infinito nos veículos", (World_IsOwner(playerid) ? ("Anfitrião") : ("Admin")), ReturnPlayerName(playerid), (World[idx][worldNitro] ? ("ativou") : ("desativou")));
	return true;
}

//-----------------------------------------------------------------------------

CMD:veh(playerid, const params[])
{
	if (!strlen(params))
	{
		ShowPlayerNotification(playerid, 0xFF9090FF, 5000, -1, "USO", "/veh [id/nome]");
		return true;
	}

	if (strval(params))
	{
		CreatePlayerVehicle(playerid, strval(params));
		return true;
	}
	else
	{
		new
			model = GetVehicleModelIDFromName(params);

		CreatePlayerVehicle(playerid, model);
	}

	return true;
}

CMD:f(playerid)
{
	if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é um motorista");
		return true;
	}

	if (!World[gPlayerWorld[playerid]][worldFlip])
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Flip bloqueado no mundo");
		return true;
	}

	new
		idx = GetPlayerVehicleID(playerid),
		Float: z;

	GetVehicleZAngle(idx, z);
	SetVehicleZAngle(idx, z);
	return true;
}
