/* 
*	module: player\admin.pwn
*	author: Jobim 
*	desc: responsável pelo sistema de mundos
*/

#include <YSI_Coding\y_hooks>

//-----------------------------------------------------------------------------

SendAdminCommand(playerid, const cmd[])
{
	if (!Player[playerid][pAdmin])
		return true;

	SendAdminMessage(0x0096FFFF, "[Admin] %s usou o comando %s", ReturnPlayerName(playerid), cmd);
	return true;
}

Admin_Permission(playerid, level)
{
	if (Player[playerid][pAdmin] < level)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não possui permissão para usar este comando.");
		return false;
	}

	return true;
}

Admin_CheckID(playerid, id, bool: perms = false)
{
	if(!IsPlayerConnected(id) || IsPlayerNPC(id))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você inseriu um ID inválido.");
		return false;	
	}

	if (!IsPlayerLogged(id))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Jogador especificado não está logado.");
		return false;
	}

	if (perms && Player[playerid][pAdmin] < 4)
	{
		if (!IsPlayerAdmin(playerid) && Player[id][pAdmin] >= Player[playerid][pAdmin] && id != playerid)
		{
			ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Jogador especificado é um admin superior.");
			return false;
		}
	}

	return true;
}

//-----------------------------------------------------------------------------

CMD:logs(playerid)
{
	if (!Admin_Permission(playerid, 1))
		return true;

	Log_ShowMenu(playerid);
	return true;
}

CMD:asay(playerid, params[])
{
	new
		msg [144]
	;

	if (!Admin_Permission(playerid, 1))
		return true;

	if (sscanf(params, "s[144]", msg))
	{
		ShowPlayerNotification(playerid, 0xFFFF90FF, 5000, -1, "USO", "/asay [mensagem]");
		return true;
	}

	strreplace(msg, "<vermelho>", "{FF0000}", true);
	strreplace(msg, "<azul>", "{009DFF}", true);
	strreplace(msg, "<verde>", "{00FF00}", true);
	strreplace(msg, "<amarelo>", "{FFFF00}", true);
	strreplace(msg, "<branco>", "{FFFFFF}", true);
	strreplace(msg, "<rosa>", "{FF33FF}", true);
	strreplace(msg, "<roxo>", "{BD30FF}", true);
	strreplace(msg, "<laranja>", "{FF9100}", true);
	strreplace(msg, "<cinza>", "{787878}", true);
	strreplace(msg, "<ciano>", "{00FFFF}", true);
	strreplace(msg, "<preto>", "{000000}", true);

	SendClientMessageToAllEx(0x00FFFFFF, "» Admin %s (%i):{FF0000} %s", ReturnPlayerName(playerid), playerid, msg);

	Log_Create("Admin CMD", "[ASAY] %s: %s", ReturnPlayerName(playerid), params);
	return true;
}

CMD:ir(playerid, params[])
{
	if (!Admin_Permission(playerid, 1))
		return true;

	new
		target;

	if (sscanf (params, "u", target))
	{
		ShowPlayerNotification(playerid, 0xFFFF90FF, 5000, -1, "USO", "/ir [id ou nome]");
		return true;
	}

	if (!Admin_CheckID(playerid, target))
		return true;

	if (GetPlayerState(target) == PLAYER_STATE_SPECTATING)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Jogador está em modo espectador.");
		return true;
	}

	if (target == playerid)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Jogador especificado é você mesmo.");
		return true;
	}

	// update
	SendAdminCommand(playerid, "IR");
	Log_Create("Admin CMD", "[IR] %s usou em %s", ReturnPlayerName(playerid), ReturnPlayerName(target));

	ShowPlayerNotification(target, 0x0096FFFF, 5000, -1, "ADMIN", "Admin %s foi até sua posição", ReturnPlayerName(playerid));
	ShowPlayerNotification(playerid, 0x0096FFFF, 5000, -1, "ADMIN", "Você foi até a posição de %s", ReturnPlayerName(target));

	new
		interior = GetPlayerInterior(target),
		world = GetPlayerVirtualWorld(target),
		Float: x, Float: y, Float: z;

	GetPlayerPos(target, x, y, z);

	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new
			idx = GetPlayerVehicleID(playerid);

		SetVehiclePos(idx, x + 1.0, y + 1.0, z + 1.0);
		SetVehicleVirtualWorld(idx, world);
		LinkVehicleToInterior(idx, interior);

		foreach (new i : VehicleOccupant(idx))
		{
			if (gPlayerWorld[i] != gPlayerWorld[target])
			{
				World_SetPlayer(i, gPlayerWorld[target], false, true, false);
			}

			SetPlayerInterior(i, interior);
		}
	}
	else
	{
		if (gPlayerWorld[playerid] != gPlayerWorld[target])
		{
			World_SetPlayer(playerid, gPlayerWorld[target], false, true, false);
		}

		SetPlayerPos(playerid, x + 1.0, y + 1.0, z + 1.0);
		SetPlayerVirtualWorld(playerid, world);
		SetPlayerInterior(playerid, interior);
	}

	return true;
}

CMD:trazer(playerid, params[])
{
	if (!Admin_Permission(playerid, 1))
		return true;

	new
		target;

	if (sscanf (params, "u", target))
	{
		ShowPlayerNotification(playerid, 0xFFFF90FF, 5000, -1, "USO", "/trazer [id ou nome]");
		return true;
	}

	if (!Admin_CheckID(playerid, target, true))
		return true;

	if (GetPlayerState(target) == PLAYER_STATE_SPECTATING)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Jogador está em modo espectador.");
		return true;
	}

	if (target == playerid)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Jogador especificado é você mesmo.");
		return true;
	}

	// update
	SendAdminCommand(playerid, "TRAZER");
	Log_Create("Admin CMD", "[TRAZER] %s usou em %s", ReturnPlayerName(playerid), ReturnPlayerName(target));

	ShowPlayerNotification(target, 0x0096FFFF, 5000, -1, "ADMIN" "Admin %s lhe trouxe à posição dele", ReturnPlayerName(playerid));
	ShowPlayerNotification(playerid, 0x0096FFFF, 5000, -1, "ADMIN", "Você trouxe %s até sua posição", ReturnPlayerName(target));

	new
		interior = GetPlayerInterior(playerid),
		world = GetPlayerVirtualWorld(playerid),
		Float: x, Float: y, Float: z;

	GetPlayerPos(playerid, x, y, z);

	if (GetPlayerState(target) == PLAYER_STATE_DRIVER)
	{
		new
			idx = GetPlayerVehicleID(target);

		SetVehiclePos(idx, x + 1.0, y + 1.0, z + 1.0);
		SetVehicleVirtualWorld(idx, world);
		LinkVehicleToInterior(idx, interior);

		foreach (new i : VehicleOccupant(idx))
		{
			if (gPlayerWorld[i] != gPlayerWorld[playerid])
			{
				World_SetPlayer(i, gPlayerWorld[playerid], false, true, false);
			}

			SetPlayerInterior(i, interior);
		}
	}
	else
	{
		SetPlayerPos(target, x + 1.0, y + 1.0, z + 1.0);

		if (gPlayerWorld[target] != gPlayerWorld[playerid])
		{
			World_SetPlayer(target, gPlayerWorld[playerid], false, true, false);
		}

		SetPlayerInterior(target, interior);
	}

	return true;
}

CMD:delcar(playerid, params[])
{
	if (!Admin_Permission(playerid, 1))
		return true;

	new
		vehicle
	;

	if (sscanf(params, "i", vehicle))
	{
		ShowPlayerNotification(playerid, 0xFFFF90FF, 5000, -1, "USO", "/delcar [v-id]");
		return true;
	}

	if (!(1 <= vehicle <= 2000))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Veículo ID inválido");
		return true;
	}

	foreach (new i : Player)
	{
		if (gPlayerVehicle[i] == vehicle)
		{
			DestroyVehicle(gPlayerVehicle[i]);
			gPlayerVehicle[i] = INVALID_VEHICLE_ID;

			SendAdminCommand(playerid, "DELCAR");
			Log_Create("Admin CMD", "[DELCAR] %s usou no veículo de %s", ReturnPlayerName(playerid), ReturnPlayerName(i));
			ShowPlayerNotification(playerid, 0x0096FFFF, 5000, -1, "ADMIN", "Veículo ID %i destruído (Dono: %s)", vehicle, ReturnPlayerName(i));
			vehicle = -1;
			break;
		}
	}

	if (vehicle != -1)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Veículo inválido ou não encontrado");
	}

	return true;
}

timer KickDelay[300](playerid)
{
	return Kick(playerid);
}

CMD:kick(playerid, params[])
{
	if (!Admin_Permission(playerid, 1))
		return true;

	new
		target,
		reason[32];

	if (sscanf (params, "us[32]", target, reason))
	{
		ShowPlayerNotification(playerid, 0xFFFF90FF, 5000, -1, "USO", "/kick [id] [motivo]");
		return true;
	}

	if (!Admin_CheckID(playerid, target, true))
		return true;

	if (!(2 <= strlen(reason) <= 25))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Motivo muito grande");
		return true;
	}

	SendAdminCommand(playerid, "KICK");
	Log_Create("Kickados", "%s kickou %s (Motivo: %s)", ReturnPlayerName(playerid), ReturnPlayerName(target), reason);
	SendClientMessageToAllEx(0xFF1414FF, "[Admin] %s kickou %s (Motivo: %s)", ReturnPlayerName(playerid), ReturnPlayerName(target), reason);

	Dialog_Show(target, Null, DIALOG_STYLE_MSGBOX, "{FF1414}Kickado", "{FF1414}Você foi kickado do servidor!\n\n{FFFFFF}Conta: {FF1414}%s\n{FFFFFF}Admin: {FF1414}%s\n{FFFFFF}Motivo: {FF1414}%s", "Fechar", "", ReturnPlayerName(target), ReturnPlayerName(playerid), reason);
	defer KickDelay(target);
	return true;
}

// Nível 4
CMD:setadmin(playerid, params[])
{
	if (!Admin_Permission(playerid, 4))
		return true;

	new
		target,
		level;

	if (sscanf (params, "ui", target, level))
	{
		ShowPlayerNotification(playerid, 0xFFFF90FF, 5000, -1, "USO", "/setadmin [id/nome] [nível]");
		return true;
	}

	if (!Admin_CheckID(playerid, target))
		return true;

	if (!(0 <= level <= 4))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você inseriu um nível admin inválido.");
		return true;
	}

	// set
	SendAdminCommand(playerid, "SETADMIN");

	Log_Create("Admin SET", "%s mudou o nível de %s (%i -> %i)", ReturnPlayerName(playerid), ReturnPlayerName(target), Player[target][pAdmin], level);

	ShowPlayerNotification(playerid, 0x0096FFFF, 5000, -1, "ADMIN", "Você definiu o nível admin de %s para %i.", Player[target][pName], level);
	ShowPlayerNotification(target, 0x0096FFFF, 5000, 1057, "ADMIN", "Admin %s definiu seu nível admin para %i.", Player[playerid][pName], level);

	Player[target][pAdmin] = level;
	Player_SaveData(target);
	return true;
}