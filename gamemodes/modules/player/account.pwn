/* 
*	module: player\account.pwn
*	author: Jobim 
*	desc: responsável pela conta do jogador
*/

#include <YSI_Coding\y_hooks>

//-----------------------------------------------------------------------------

forward OnPlayerRequestLogin(playerid);
forward OnPlayerDataLoaded(playerid);
forward OnPlayerAttempLogin(playerid);
forward OnPlayerAttempRegister(playerid);
forward OnPlayerLoggedIn(playerid);

//-----------------------------------------------------------------------------

static
			g_PlayerLoginAttemps[MAX_PLAYERS] = {0, ...},
	bool: 	g_PlayerIsLogged[MAX_PLAYERS] = {false, ...},
	ORM:	g_PlayerORM[MAX_PLAYERS] = {MYSQL_INVALID_ORM, ...}
;

//-----------------------------------------------------------------------------

hook OnPlayerConnect(playerid)
{
	Player_ResetData(playerid);
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDisconnect@1(playerid, reason)
{
	Player_SaveData(playerid);
	Player_ResetData(playerid);
	return Y_HOOKS_CONTINUE_RETURN_1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if (IsPlayerLogged(playerid))
	{
		Player_Spawn(playerid);
		return true;
	}

	TogglePlayerSpectating(playerid, true);
	SetPlayerVirtualWorld(playerid, cellmax);
	World_SetPlayer(playerid, -1);
	SetPlayerColor(playerid, -1);

	InterpolateCameraPos(playerid, 99.029983, -2809.879394, 37.798042, 99.029983, -2809.879394, 37.798042, 1000);
	InterpolateCameraLookAt(playerid, 103.863891, -2808.601562, 37.821437, 103.863891, -2808.601562, 37.821437, 1000);

	for (new i = 0; i < 45; i++)
	{
		SendClientMessage(playerid, -1, " ");
	}

	mysql_format(SQL_GetHandle(), global_query, sizeof global_query, "SELECT player_id FROM players WHERE player_name = '%e' LIMIT 1;", ReturnPlayerName(playerid));
	mysql_tquery(SQL_GetHandle(), global_query, "OnPlayerRequestLogin", "i", playerid);
	return true;
}

public OnPlayerRequestSpawn(playerid)
{
	return false;
}

public OnPlayerRequestLogin(playerid)
{
	if (mysql_errno(SQL_GetHandle()) != 0)
	{
		Kick(playerid);
		return false;
	}

	new
		rows = cache_num_rows();

	if (rows)
	{
		cache_get_value_name_int(0, "player_id", Player[playerid][pID]);
		Dialog_Show(playerid, Dialog_Login, DIALOG_STYLE_PASSWORD, "{FF5555}ViSA > Login", "{FFFFFF}Olá {FF5555}%s{FFFFFF}, bem-vindo(a) ao ViSA Multiplayer!\n\nEssa conta está registrada, por favor insira a senha:", "Login", "Sair", ReturnPlayerName(playerid));
	}
	else
	{
		Player[playerid][pID] = -1;
		Dialog_Show(playerid, Dialog_Register, DIALOG_STYLE_INPUT, "{FF5555}ViSA > Registro", "{FFFFFF}Olá {FF5555}%s{FFFFFF}, bem-vindo(a) ao ViSA Multiplayer!\n\nEssa conta não está registrada, crie uma senha para jogar:", "Registro", "Sair", ReturnPlayerName(playerid));
	}

	return true;
}

public OnPlayerAttempLogin(playerid)
{
	if (mysql_errno(SQL_GetHandle()) != 0)
	{
		Kick(playerid);
		return false;
	}

	new
		rows = cache_num_rows()
	;

	if (rows)
	{
		Player_LoadData(playerid);
	}
	else
	{
		g_PlayerLoginAttemps[playerid] += 1;
		Dialog_Show(playerid, Dialog_Login, DIALOG_STYLE_PASSWORD, "{FF5555}ViSA > Login", "{FF1414}ERRO: Senha inválida!\n\n{FFFFFF}Olá {FF5555}%s{FFFFFF}, bem-vindo(a) ao ViSA Multiplayer!\n\nEssa conta está registrada, por favor insira a senha:", "Login", "Sair", ReturnPlayerName(playerid));
	
		if (g_PlayerLoginAttemps[playerid] >= 3)
		{
			Kick(playerid);
		}
	}
	return true;
}

public OnPlayerAttempRegister(playerid)
{
	if (mysql_errno(SQL_GetHandle()) != 0)
	{
		Kick(playerid);
		return false;
	}

	Player[playerid][pID] = cache_insert_id();
	Player_LoadData(playerid);
	return true;
}

public OnPlayerDataLoaded(playerid)
{
	if (orm_errno(g_PlayerORM[playerid]) != ERROR_OK)
	{
		Kick(playerid);
		return true;
	}

	CallRemoteFunction("OnPlayerLoggedIn", "i", playerid);
	return true;
}

//-----------------------------------------------------------------------------

Dialog:Dialog_Login(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		Kick(playerid);
		return true;
	}

	if (!(4 <= strlen(inputtext) <= 20) || strfind(inputtext, " ") != -1)
	{
		Dialog_Show(playerid, Dialog_Login, DIALOG_STYLE_PASSWORD, "{FF5555}ViSA > Login", "{FF1414}ERRO: Senha inválida!\n\n{FFFFFF}Olá {FF5555}%s{FFFFFF}, bem-vindo(a) ao ViSA Multiplayer!\n\nEssa conta está registrada, por favor insira a senha:", "Login", "Sair", ReturnPlayerName(playerid));
		return true;
	}

	mysql_format(SQL_GetHandle(), global_query, sizeof global_query, "SELECT * FROM players WHERE player_id = %i AND player_pass = md5('%e');", Player[playerid][pID], inputtext);
	mysql_tquery(SQL_GetHandle(), global_query, "OnPlayerAttempLogin", "i", playerid);
	return true;
}

Dialog:Dialog_Register(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		Kick(playerid);
		return true;
	}

	if (!(4 <= strlen(inputtext) <= 20) || strfind(inputtext, " ") != -1)
	{
		Dialog_Show(playerid, Dialog_Register, DIALOG_STYLE_INPUT, "{FF5555}ViSA > Registro", "{FF1414}ERRO: Senha inválida!\n\n{FFFFFF}Olá {FF5555}%s{FFFFFF}, bem-vindo(a) ao ViSA Multiplayer!\n\nEssa conta não está registrada, crie uma senha para jogar:", "Registro", "Sair", ReturnPlayerName(playerid));
		return true;
	}

	mysql_format(SQL_GetHandle(), global_query, sizeof global_query, "INSERT INTO players (`player_name`, `player_pass`) VALUES ('%e', md5('%e'));", ReturnPlayerName(playerid), inputtext);
	mysql_tquery(SQL_GetHandle(), global_query, "OnPlayerAttempRegister", "i", playerid);
	return true;
}

//-----------------------------------------------------------------------------

IsPlayerLogged(playerid)
{
	return g_PlayerIsLogged[playerid];
}

Player_Spawn(playerid)
{
	if (!IsPlayerConnected(playerid))
		return false;

	SetSpawnInfo(playerid, NO_TEAM, Player[playerid][pSkin], 161.5915, -2790.6873, 30.1002, 160.8168, 0, 0, 0, 0, 0, 0);

	if (IsPlayerInAnyVehicle(playerid))
	{
		new Float: x, Float: y, Float: z;
		GetPlayerPos(playerid, x, y, z);
		SetPlayerPos(playerid, x, y, z);
	}

	if (GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
	{
		TogglePlayerSpectating(playerid, false);
	}
	else
	{
		SpawnPlayer(playerid);
	}
	return true;
}

Player_ResetData(playerid)
{
	// login setup
	g_PlayerIsLogged[playerid] = false;
	g_PlayerLoginAttemps[playerid] = 0;

	// name
	GetPlayerName(playerid, Player[playerid][pName], MAX_PLAYER_NAME);

	// dummy reset
	new emptyEnum[e_Player];
	Player[playerid] = emptyEnum;
	Player[playerid][pColor] = -1;

	// orm
	g_PlayerORM[playerid] = MYSQL_INVALID_ORM;
	return true;
}

Player_SaveData(playerid)
{
	if (!IsPlayerLogged(playerid))
		return false;

	if (g_PlayerORM[playerid] == MYSQL_INVALID_ORM)
		return false;

	orm_update(g_PlayerORM[playerid]);
	return true;
}

Player_LoadData(playerid)
{
	if (IsPlayerLogged(playerid))
		return false;

	// valid orm
	if (g_PlayerORM[playerid] != MYSQL_INVALID_ORM)
	{
		orm_destroy(g_PlayerORM[playerid]);
		g_PlayerORM[playerid] = MYSQL_INVALID_ORM;
	}

	// set
	g_PlayerIsLogged[playerid] = true;

	// create 
	g_PlayerORM[playerid] = orm_create("players");
	orm_addvar_int(g_PlayerORM[playerid], Player[playerid][pID], "player_id");
	orm_addvar_string(g_PlayerORM[playerid], Player[playerid][pDiscordID], 21, "player_discord_id");
	orm_addvar_string(g_PlayerORM[playerid], Player[playerid][pDiscordCode], 12, "player_discord_code");
	orm_addvar_string(g_PlayerORM[playerid], Player[playerid][pName], MAX_PLAYER_NAME, "player_name");
	orm_addvar_int(g_PlayerORM[playerid], Player[playerid][pSkin], "player_skin");
	orm_addvar_int(g_PlayerORM[playerid], Player[playerid][pAdmin], "player_admin");
	orm_addvar_int(g_PlayerORM[playerid], Player[playerid][pColor], "player_color");
	orm_setkey(g_PlayerORM[playerid], "player_id");

	orm_load(g_PlayerORM[playerid], "OnPlayerDataLoaded", "i", playerid);
	return true;
}