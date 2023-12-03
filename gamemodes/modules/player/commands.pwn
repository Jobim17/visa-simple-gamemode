/*
*	module: commands
*	author: *
*	last edit: 04/01/2023
*	desc: responsável pelos comandos utilitarios
*/

#include <YSI_Coding\y_hooks>

new Float:PosX[MAX_PLAYERS], 
	Float:PosY[MAX_PLAYERS], 
	Float:PosZ[MAX_PLAYERS], 
	Float:PosA[MAX_PLAYERS], 
	PosI[MAX_PLAYERS],
	gPlayerReceivedTP[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...},
	gPlayerReceivedTPAt[MAX_PLAYERS] = {0, ...},
	gPlayerTeleportCooldown[MAX_PLAYERS] = {0, ...};

//-----------------------------------------------------------------------------

public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
	printf("[CMD] %s (%i): /%s %s", ReturnPlayerName(playerid), playerid, cmd, params);

	if (!IsPlayerLogged(playerid))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 3000, -1, "ERRO", "Você deve logar para utilizar comandos.");
		return 0;
	}

	if (GetPlayerState(playerid) == PLAYER_STATE_WASTED)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 3000, -1, "ERRO", "Você não pode usar comandos estando morto.");
		return 0;
	}

	if (gPlayerInDiscordAuth[playerid])
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 3000, -1, "ERRO", "Primeiro vincule seu Discord");
		return 0;
	}

	return true;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
  	if (result == -1)
  	{
   		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Comando inexistente.~n~Digite ~r~~h~/comandos");
    	return 0;
  	}

  	return 1;
}

hook OnPlayerConnect(playerid)
{
	gPlayerReceivedTP[playerid] = INVALID_PLAYER_ID;
	gPlayerReceivedTPAt[playerid] = 0;
	gPlayerTeleportCooldown[playerid] = 0;
	return true;
}

hook OnPlayerDisconnect(playerid, reason)
{
	gPlayerReceivedTP[playerid] = INVALID_PLAYER_ID;
	gPlayerReceivedTPAt[playerid] = 0;
	gPlayerTeleportCooldown[playerid] = 0;

	foreach (new i : Player)
	{
		if (gPlayerReceivedTP[i] == playerid)
		{
			gPlayerReceivedTP[i] = INVALID_PLAYER_ID;
		}
	}
	return true;
}

//-----------------------------------------------------------------------------

alias:skin("personagem", "ms", "roupas", "roupa")
CMD:skin(playerid, params[])
{
	new
		skin
	;

	if (sscanf(params, "i", skin))
	{
		ShowPlayerNotification(playerid, 0xFFFF90FF, 5000, -1, "USO", "/skin [skin-id]");
		return true;
	}

	if (!(0 <= skin <= 311) || skin == 74)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Skin ID inválido");
		return false;
	}

	if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você precisa estar a pé");
		return false;
	}

	Player[playerid][pSkin] = skin;
	Player_SaveData(playerid);

	SetSpawnInfo(playerid, NO_TEAM, Player[playerid][pSkin], 161.5915, -2790.6873, 30.1002, 160.8168, 0, 0, 0, 0, 0, 0);
	SetPlayerSkin(playerid, Player[playerid][pSkin]);

	ShowPlayerNotification(playerid, 0x33FF33FF, 5000, -1, "INFO", "Skin alterado com sucesso!");
	return true;
}

alias:noclip("nc", "fly", "flymode")
CMD:noclip(playerid)
{
	if(IsFlyMode(playerid))
	{
		CancelFlyMode(playerid);
	}
	else 
	{
		StartFlyMode(playerid);
	}
	return true;
}

CMD:arma(playerid, params[])
{
	new
		idx
	;

	if (sscanf(params, "i", idx))
	{
		ShowPlayerNotification(playerid, 0xFFFF90FF, 5000, -1, "USO", "/arma [arma-id]");
		return true;
	}

	if (!(1 <= idx <= 46))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Arma ID inváido");
		return true;
	}

	switch (idx)
	{
		case 4, 16, 17, 18, 35..40: 
		{
			if (!Player[playerid][pAdmin])
			{
				ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Arma proibida");
				return true;
			}
		}
	}

	GivePlayerWeapon(playerid, idx, 3000);
	ShowPlayerNotification(playerid, 0x33FF33FF, 5000, -1, "INFO", "Você pegou a arma ID %i", idx);
	return true;
}


CMD:clima(playerid, const params[])
{
	new
		weatherID;

	if (sscanf(params, "i", weatherID))
	{
		ShowPlayerNotification(playerid, 0xFFFF90FF, 5000, -1, "USO", "/clima [clima-id]");
		return true;
	}

	SetPlayerWeather(playerid, weatherID);
	ShowPlayerNotification(playerid, 0x33FF33FF, 5000, -1, "INFO", "Clima alterado para %i", weatherID);
	return 1;
}

CMD:dia(playerid)
{
	ShowPlayerNotification(playerid, 0x33FF33FF, 5000, -1, "INFO", "Tempo alterado para dia");
	SetPlayerTime(playerid, 12,0);
	return 1;
}

CMD:noite(playerid)
{
	ShowPlayerNotification(playerid, 0x33FF33FF, 5000, -1, "INFO", "Tempo alterado para noite");
	SetPlayerTime(playerid, 00,0);
	return 1;
}

CMD:tarde(playerid)
{
	ShowPlayerNotification(playerid, 0x33FF33FF, 5000, -1, "INFO", "Tempo alterado para tarde");
	SetPlayerTime(playerid, 20, 0);
	return 1;
}

CMD:tp(playerid, params[])
{
	new
		idx
	;

	if ((gettime() - gPlayerTeleportCooldown[playerid]) < 10)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Aguarde alguns segundos para teleportar-se");
		return true;
	}

	if (sscanf(params, "u", idx))
	{
		ShowPlayerNotification(playerid, 0xFF9090FF, 5000, -1, "USO", "/tp [id/nome]");
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

	if (!World_Same(playerid, idx))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Jogador não está no mesmo mundo");
		return true;
	}

	gPlayerReceivedTP[idx] = playerid;
	gPlayerReceivedTPAt[idx] = gettime();
	gPlayerTeleportCooldown[playerid] = gettime();

	va_SendClientMessage(idx, 0x33FF33FF, "[Teleporte] %s (%i) pediu para teleportar-se até você. Para aceitar: /TPA", ReturnPlayerName(playerid), playerid);
	va_SendClientMessage(playerid, 0x33FF33FF, "[Teleporte] Solicitação de teleporte enviada para %s (%i)", ReturnPlayerName(idx), idx);
	return true;
}

CMD:tpa(playerid)
{
	new
		idx = gPlayerReceivedTP[playerid]
	;

	if (idx == INVALID_PLAYER_ID)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não recebeu solicitação de teleporte");
		return true;
	}

	if ((gettime() - gPlayerReceivedTPAt[playerid]) > 30)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Solicitação de teleporte expirada");
		return true;
	}

	if (!World_Same(playerid, idx))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Jogador não está no mesmo mundo");
		return true;
	}

	new
		Float: x,
		Float: y,
		Float: z
	;

	GetPlayerPos(playerid, x, y, z);

	if (GetPlayerState(idx) == PLAYER_STATE_DRIVER)
	{
		SetVehiclePos(GetPlayerVehicleID(idx), x+1.0, y+1.0, z);
	}
	else
	{
		SetPlayerPos(idx, x + 1.0, y + 1.0, z);
	}

	GameTextForPlayer(playerid, "~g~~h~teleporte aceito!", 5000, 3);
	GameTextForPlayer(idx, "~g~~h~teleporte aceito!", 5000, 3);

	gPlayerReceivedTP[playerid] = INVALID_PLAYER_ID;
	return true;
}

CMD:jetpack(playerid)
{
	if (GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você está em um jetpack");
		return true;
	}

	if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você precisa estar a pé");
		return true;
	}

	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	ShowPlayerNotification(playerid, 0x33FF33FF, 5000, -1, "INFO", "Jetpack criado com sucesso");
	return true;
}

//-----------------------------------------------------------------------------

Dialog:Dialog_MainHelp(playerid, response, listitem, inputtext[])
{
	if (!response)
		return true;

	switch (listitem)
	{
		case 0: ShowHelpDialog(playerid, 1);
		case 1: ShowHelpDialog(playerid, 2);
	}
	return true;
}

Dialog:Dialog_CommandShow(playerid, response, listitem, inputtext[])
{
	if (response)
		return true;

	ShowHelpDialog(playerid, 0);
	return true;
}

ShowHelpDialog(playerid, page)
{
	if (!IsPlayerLogged(playerid))
		return false;

	switch (page)
	{
		case 1: Dialog_Show(playerid, Dialog_CommandShow, DIALOG_STYLE_MSGBOX, "{FF5555}ViSA > Comandos > Gerais", "{FF5555}@ {FFFFFF}- fala no chat global\n\n{FF5555}/veh [id/nome] -{FFFFFF} cria um veículo\n{FF5555}/arma [id] -{FFFFFF} cria uma arma\n{FF5555}/skin [id] -{FFFFFF} altera seu personagem\n{FF5555}/noclip -{FFFFFF} câmera livre\n{FF5555}/clima [id] -{FFFFFF} altera seu clima\n{FF5555}/dia -{FFFFFF} muda seu horário para dia\n{FF5555}/tarde -{FFFFFF} muda seu horário para tarde\n{FF5555}/noite -{FFFFFF} muda seu horário para noite\n{FF5555}/pintar [cor1] [cor2] {FFFFFF}- pinta um veículo\n{FF5555}/f {FFFFFF}- desvira seu veículo\n{FF5555}/cor [hex] {FFFFFF}- altera sua cor\n{FF5555}/tp [id/nome] {FFFFFF}- envia solicitação de teleporte\n{FF5555}/tpa {FFFFFF}- aceita o teleporte\n{FF5555}/jetpack {FFFFFF}- cria um jetpack", "Fechar", "Voltar");
		case 2: 
		{
			new big_str[1024];

			// Keys
			strcat (big_str, "{FF5555}H {FFFFFF}- repara um veículo\n");
			strcat (big_str, "{FF5555}NUM2 {FFFFFF}- atalho do /F\n\n");

			// Anfitrião
			strcat (big_str, "{FF5555}/Mundos {FFFFFF}- abre a lista de mundos disponíveis\n");
			strcat (big_str, "{FF5555}/MundoConfig {FFFFFF}- painel de configurações\n");
			strcat (big_str, "{FF5555}/MundoNome {FFFFFF}- altera o nome do mundo\n");
			strcat (big_str, "{FF5555}/MundoSenha {FFFFFF}- altera a senha do mundo\n");
			strcat (big_str, "{FF5555}/MundoGravidade {FFFFFF}- altera a gravidade do mundo\n");
			strcat (big_str, "{FF5555}/MundoSemColisao {FFFFFF}- (des)ativa as colisões\n");
			strcat (big_str, "{FF5555}/MundoSemDanos {FFFFFF}- (des)ativa os danos\n");
			strcat (big_str, "{FF5555}/MundoSemVeiculosPesados {FFFFFF}- (des)ativa os veículos pesados\n");
			strcat (big_str, "{FF5555}/MundoTeleportes {FFFFFF}- (des)ativa os telepores\n");
			strcat (big_str, "{FF5555}/MundoFlip {FFFFFF}- (des)ativa o flip de veículos\n");
			strcat (big_str, "{FF5555}/MundoNicknames {FFFFFF}- (des)ativa as nametags\n");
			strcat (big_str, "{FF5555}/MundoIcones {FFFFFF}- (des)ativa os ícones\n");
			strcat (big_str, "{FF5555}/MundoReparo {FFFFFF}- (des)ativa o reparo de veículos\n");
			strcat (big_str, "{FF5555}/MundoNitro {FFFFFF}- (des)ativa o nitro infinito\n");
			strcat (big_str, "{FF5555}/MundoKick {FFFFFF}- kicka um jogador do mundo");

			Dialog_Show(playerid, Dialog_CommandShow, DIALOG_STYLE_MSGBOX, "{FF5555}ViSA > Comandos > Mundos", big_str, "Fechar", "Voltar");
		}
		default: Dialog_Show(playerid, Dialog_MainHelp, DIALOG_STYLE_LIST, "{FF5555}ViSA > Comandos", "{FFFFFF}Gerais\n{FFFFFF}Mundos", "Selecionar", "Fechar");
	}
	return true;
}

//-----------------------------------------------------------------------------

CMD:comandos(playerid)
{
	ShowHelpDialog(playerid, 0);
	return true;
}

//-----------------------------------------------------------------------------

CMD:pintar(playerid, params[])
{
	if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você não é um motorista");
		return true;
	}

	new
		color1,
		color2
	;

	if (sscanf(params, "iI(0)", color1, color2))
	{
		ShowPlayerNotification(playerid, 0xFFFF90FF, 5000, -1, "USO", "/pintar [cor] [cor]");
		return true;
	}

	if (!(0 <= color1 <= 255) || !(0 <= color2 <= 255))
	{
		ShowPlayerNotification(playerid, 0xFF5555FF, 5000, -1, "ERRO", "Você inseriu uma cor inválida");
		return true;
	}

	new idx = GetPlayerVehicleID(playerid);
	ChangeVehicleColor(idx, color1, color2);
	return true;
}

//-----------------------------------------------------------------------------

CMD:sp(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		GetVehiclePos(GetPlayerVehicleID(playerid), PosX[playerid], PosY[playerid], PosZ[playerid]);
		GetVehicleZAngle(GetPlayerVehicleID(playerid), PosA[playerid]);
	} else {
		GetPlayerPos(playerid, PosX[playerid], PosY[playerid], PosZ[playerid]);
		GetPlayerFacingAngle(playerid, PosA[playerid]);
		PosI[playerid] = (GetPlayerInterior(playerid));
	}
	ShowPlayerNotification(playerid, 0x33FF33FF, 5000, -1, "INFO", "Você salvou a posição, para voltar use {f00c0c}/irp.");
	PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
	return 1;
}

//-----------------------------------------------------------------------------

CMD:irp(playerid)
{
	if (!floatsqroot(PosX[playerid]+PosY[playerid]+PosZ[playerid]))
	{
		return ShowPlayerNotification(playerid, 0xFF5555FF, 3000, -1, "ERRO", "Você não tem nenhuma posiç.");
	}
	else
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), PosX[playerid], PosY[playerid], PosZ[playerid]);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), PosA[playerid]);
			
			SetCameraBehindPlayer(playerid);
			LinkVehicleToInterior(GetPlayerVehicleID(playerid), PosI[playerid]);

			ShowPlayerNotification(playerid, 0x33FF33FF, 5000, -1, "INFO", "Posição recarregada com sucesso!");
			PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
		}
		else
		{
			SetPlayerPos(playerid, PosX[playerid], PosY[playerid], PosZ[playerid]);
			SetPlayerFacingAngle(playerid, PosA[playerid]);
			SetCameraBehindPlayer(playerid);
		}
		SetPlayerInterior(playerid, PosI[playerid]);
	}
	return 1;
}

alias:cor("hmc", "hex", "color", "colour")
CMD:cor(playerid, params[])
{
	if (strlen(params) != 6)
	{
		ShowPlayerNotification(playerid, 0xFFFF90FF, 5000, -1, "USO", "/cor [cor-hex]~n~Acesse: www.colorpicker.com");
		return true;
	}

	format (params, 12, "0x%sFF", params);

	new
		color = -1;

	sscanf (params, "x", color);

	Player[playerid][pColor] = color;
	SetPlayerColor(playerid, color);
	Player_SaveData(playerid);
	World_PlayerUpdate(playerid);

	ShowPlayerNotification(playerid, color, 5000, -1, "Informação", "Cor alterada com sucesso.");
	return true;
}