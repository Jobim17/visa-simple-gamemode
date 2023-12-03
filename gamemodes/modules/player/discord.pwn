/*
*	module: discord
*	author: *
*	last edit: 07/01/2023
*	desc: responsável pela vinculação no Discord
*/

#include <YSI_Coding\y_hooks>

//-----------------------------------------------------------------------------

new
	bool: gPlayerInDiscordAuth[MAX_PLAYERS] = {false, ...},
	PlayerText: gPlayerDiscordTD[MAX_PLAYERS][13]
;

//-----------------------------------------------------------------------------

hook OnPlayerLoggedIn(playerid)
{
	if (!strcmp(Player[playerid][pDiscordID], "Nenhum", true))
	{
		gPlayerInDiscordAuth[playerid] = true;

		Discord_GenerateAuthCode(playerid);
		Discord_GenerateGUI(playerid);
		Player_SaveData(playerid);
	}
	else
	{
		gPlayerInDiscordAuth[playerid] = false;
		World_Show(playerid);
		SetPlayerColor(playerid, Player[playerid][pColor]);
	}
	return Y_HOOKS_CONTINUE_RETURN_1;
}

DCMD:verificar(user, channel, params[]) 
{
    if (strcmp(DCC_ReturnChannelID(channel), "1094016679278821487"))
    {
    	DCC_SendMessage(channel, ":small_red_triangle: **|** <@%s> Erro! Você não está no canal de verificação.", DCC_ReturnUserID(user));
    	return true;
    }

    new
    	idx = INVALID_PLAYER_ID,
    	name[MAX_PLAYER_NAME],
    	code[12]
    ;

    if (sscanf (params, "s[21]s[12]", name, code))
    {
    	DCC_SendMessage(channel, ":small_orange_diamond: **|** <@%s> Modo de uso: **!verificar [nickname] [código]**", DCC_ReturnUserID(user));
    	return true;
    }

    mysql_format(SQL_GetHandle(), global_query, sizeof global_query, "SELECT `player_id` FROM `players` WHERE `player_discord_id` = '%e' LIMIT 1;", DCC_ReturnUserID(user));
    mysql_query(SQL_GetHandle(), global_query);

    if (cache_num_rows())
    {
    	DCC_SendMessage(channel, ":small_red_triangle: **|** <@%s> Erro! Você possui uma conta vinculada ao seu Discord", DCC_ReturnUserID(user));
    	return true;
    }

    foreach (new i : Player)
    {
    	if (!IsPlayerLogged(i))
    		continue;

    	if (!strcmp(ReturnPlayerName(i), name, false))
    	{
    		idx = i;
    		break;
    	}
    }

    if (idx == INVALID_PLAYER_ID)
    {
    	DCC_SendMessage(channel, ":small_red_triangle: **|** <@%s> Erro! Jogador especificado não está logado no servidor", DCC_ReturnUserID(user));
    	return true;
    }

    if (strcmp(Player[idx][pDiscordID], "Nenhum"))
    {
    	DCC_SendMessage(channel, ":small_red_triangle: **|** <@%s> Erro! Jogador especificado tem um Discord vinculado", DCC_ReturnUserID(user));
    	return true;
    }

    if (IsAndroidPlayer(idx))
    {
    	DCC_SendMessage(channel, ":small_red_triangle: **|** <@%s> Erro! Servidor não está disponível para Mobiles", DCC_ReturnUserID(user));
    	return true;
    }

    if (!strcmp(Player[idx][pDiscordCode], code, false))
    {
    	gPlayerInDiscordAuth[idx] = false;

    	format (Player[idx][pDiscordID], DCC_ID_SIZE, DCC_ReturnUserID(user));
    	Player_SaveData(idx);

    	Discord_DestroyGUI(idx);
		World_Show(idx);

    	new str[32], DCC_Guild:guild = DCC_FindGuildById("1088615073955729458"), DCC_Role:role = DCC_FindRoleById("1094695818235224255");

    	format (str, sizeof str, "%i | %s", Player[idx][pID], ReturnPlayerName(idx));
    	DCC_AddGuildMemberRole(guild, user, role);
    	DCC_SetGuildMemberNickname(guild, user, str);

    	DCC_SendMessage(channel, ":sparkles: **|** <@%s> Sucesso! Sua conta foi verificada com êxito.", DCC_ReturnUserID(user));
    }
    else
    {
    	DCC_SendMessage(channel, ":small_red_triangle: **|** <@%s> Erro! Código especificado é inválido", DCC_ReturnUserID(user));
    }

    return true;
}

//-----------------------------------------------------------------------------

DCC_ReturnUserID(DCC_User:user)
{
	new _id[DCC_ID_SIZE];
	DCC_GetUserId(user, _id);
	return _id;
}

DCC_ReturnChannelID(DCC_Channel:channel)
{
	new _id[DCC_ID_SIZE];
	DCC_GetChannelId(channel, _id);
	return _id;
}

DCC_SendMessage(DCC_Channel:channel, const message[], va_args<>)
{
	new
		_formatted[256],
		_encoded[256]
	;

	va_format(_formatted, sizeof _formatted, message, va_start<2>);
	utf8encode(_encoded, _formatted);

	DCC_SendChannelMessage(channel, _encoded);
	return true;
}

//-----------------------------------------------------------------------------

Discord_GenerateAuthCode(playerid)
{
	if (!IsPlayerConnected(playerid))
		return false;

	format (Player[playerid][pDiscordCode], 12, Internal_ReturnCode());
	return true;
}

Internal_ReturnCode()
{
	new _str[12] = "";
	new _chars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789";

	for (new i = 0; i < 10; i++)
	{
		_str[i] = _chars[random (35)];
	}

	_str[10] = EOS;

	return _str;
}

Discord_GenerateGUI(playerid)
{
	if (!IsPlayerConnected(playerid))
		return false;

	gPlayerDiscordTD[playerid][0] = CreatePlayerTextDraw(playerid, 323.000000, 151.000000, "_");
	PlayerTextDrawFont(playerid, gPlayerDiscordTD[playerid][0], 1);
	PlayerTextDrawLetterSize(playerid, gPlayerDiscordTD[playerid][0], 0.600000, 20.850002);
	PlayerTextDrawTextSize(playerid, gPlayerDiscordTD[playerid][0], 298.500000, 120.000000);
	PlayerTextDrawSetOutline(playerid, gPlayerDiscordTD[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, gPlayerDiscordTD[playerid][0], 0);
	PlayerTextDrawAlignment(playerid, gPlayerDiscordTD[playerid][0], 2);
	PlayerTextDrawColor(playerid, gPlayerDiscordTD[playerid][0], -1);
	PlayerTextDrawBackgroundColor(playerid, gPlayerDiscordTD[playerid][0], 255);
	PlayerTextDrawBoxColor(playerid, gPlayerDiscordTD[playerid][0], 336860415);
	PlayerTextDrawUseBox(playerid, gPlayerDiscordTD[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, gPlayerDiscordTD[playerid][0], 1);
	PlayerTextDrawSetSelectable(playerid, gPlayerDiscordTD[playerid][0], 0);

	gPlayerDiscordTD[playerid][1] = CreatePlayerTextDraw(playerid, 323.000000, 155.000000, "_");
	PlayerTextDrawFont(playerid, gPlayerDiscordTD[playerid][1], 0);
	PlayerTextDrawLetterSize(playerid, gPlayerDiscordTD[playerid][1], 0.600000, 19.700004);
	PlayerTextDrawTextSize(playerid, gPlayerDiscordTD[playerid][1], 298.500000, 130.000000);
	PlayerTextDrawSetOutline(playerid, gPlayerDiscordTD[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, gPlayerDiscordTD[playerid][1], 0);
	PlayerTextDrawAlignment(playerid, gPlayerDiscordTD[playerid][1], 2);
	PlayerTextDrawColor(playerid, gPlayerDiscordTD[playerid][1], -1);
	PlayerTextDrawBackgroundColor(playerid, gPlayerDiscordTD[playerid][1], 255);
	PlayerTextDrawBoxColor(playerid, gPlayerDiscordTD[playerid][1], 336860415);
	PlayerTextDrawUseBox(playerid, gPlayerDiscordTD[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, gPlayerDiscordTD[playerid][1], 1);
	PlayerTextDrawSetSelectable(playerid, gPlayerDiscordTD[playerid][1], 0);

	gPlayerDiscordTD[playerid][2] = CreatePlayerTextDraw(playerid, 253.000000, 326.000000, "LD_BEAT:chit");
	PlayerTextDrawFont(playerid, gPlayerDiscordTD[playerid][2], 4);
	PlayerTextDrawLetterSize(playerid, gPlayerDiscordTD[playerid][2], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, gPlayerDiscordTD[playerid][2], 18.000000, 18.000000);
	PlayerTextDrawSetOutline(playerid, gPlayerDiscordTD[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, gPlayerDiscordTD[playerid][2], 0);
	PlayerTextDrawAlignment(playerid, gPlayerDiscordTD[playerid][2], 1);
	PlayerTextDrawColor(playerid, gPlayerDiscordTD[playerid][2], 336860415);
	PlayerTextDrawBackgroundColor(playerid, gPlayerDiscordTD[playerid][2], 255);
	PlayerTextDrawBoxColor(playerid, gPlayerDiscordTD[playerid][2], 50);
	PlayerTextDrawUseBox(playerid, gPlayerDiscordTD[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, gPlayerDiscordTD[playerid][2], 1);
	PlayerTextDrawSetSelectable(playerid, gPlayerDiscordTD[playerid][2], 0);

	gPlayerDiscordTD[playerid][3] = CreatePlayerTextDraw(playerid, 375.000000, 326.000000, "LD_BEAT:chit");
	PlayerTextDrawFont(playerid, gPlayerDiscordTD[playerid][3], 4);
	PlayerTextDrawLetterSize(playerid, gPlayerDiscordTD[playerid][3], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, gPlayerDiscordTD[playerid][3], 18.000000, 18.000000);
	PlayerTextDrawSetOutline(playerid, gPlayerDiscordTD[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, gPlayerDiscordTD[playerid][3], 0);
	PlayerTextDrawAlignment(playerid, gPlayerDiscordTD[playerid][3], 1);
	PlayerTextDrawColor(playerid, gPlayerDiscordTD[playerid][3], 336860415);
	PlayerTextDrawBackgroundColor(playerid, gPlayerDiscordTD[playerid][3], 255);
	PlayerTextDrawBoxColor(playerid, gPlayerDiscordTD[playerid][3], 50);
	PlayerTextDrawUseBox(playerid, gPlayerDiscordTD[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, gPlayerDiscordTD[playerid][3], 1);
	PlayerTextDrawSetSelectable(playerid, gPlayerDiscordTD[playerid][3], 0);

	gPlayerDiscordTD[playerid][4] = CreatePlayerTextDraw(playerid, 375.000000, 146.000000, "LD_BEAT:chit");
	PlayerTextDrawFont(playerid, gPlayerDiscordTD[playerid][4], 4);
	PlayerTextDrawLetterSize(playerid, gPlayerDiscordTD[playerid][4], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, gPlayerDiscordTD[playerid][4], 18.000000, 18.000000);
	PlayerTextDrawSetOutline(playerid, gPlayerDiscordTD[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, gPlayerDiscordTD[playerid][4], 0);
	PlayerTextDrawAlignment(playerid, gPlayerDiscordTD[playerid][4], 1);
	PlayerTextDrawColor(playerid, gPlayerDiscordTD[playerid][4], 336860415);
	PlayerTextDrawBackgroundColor(playerid, gPlayerDiscordTD[playerid][4], 255);
	PlayerTextDrawBoxColor(playerid, gPlayerDiscordTD[playerid][4], 50);
	PlayerTextDrawUseBox(playerid, gPlayerDiscordTD[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, gPlayerDiscordTD[playerid][4], 1);
	PlayerTextDrawSetSelectable(playerid, gPlayerDiscordTD[playerid][4], 0);

	gPlayerDiscordTD[playerid][5] = CreatePlayerTextDraw(playerid, 253.000000, 146.000000, "LD_BEAT:chit");
	PlayerTextDrawFont(playerid, gPlayerDiscordTD[playerid][5], 4);
	PlayerTextDrawLetterSize(playerid, gPlayerDiscordTD[playerid][5], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, gPlayerDiscordTD[playerid][5], 18.000000, 18.000000);
	PlayerTextDrawSetOutline(playerid, gPlayerDiscordTD[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, gPlayerDiscordTD[playerid][5], 0);
	PlayerTextDrawAlignment(playerid, gPlayerDiscordTD[playerid][5], 1);
	PlayerTextDrawColor(playerid, gPlayerDiscordTD[playerid][5], 336860415);
	PlayerTextDrawBackgroundColor(playerid, gPlayerDiscordTD[playerid][5], 255);
	PlayerTextDrawBoxColor(playerid, gPlayerDiscordTD[playerid][5], 50);
	PlayerTextDrawUseBox(playerid, gPlayerDiscordTD[playerid][5], 1);
	PlayerTextDrawSetProportional(playerid, gPlayerDiscordTD[playerid][5], 1);
	PlayerTextDrawSetSelectable(playerid, gPlayerDiscordTD[playerid][5], 0);

	gPlayerDiscordTD[playerid][6] = CreatePlayerTextDraw(playerid, 321.000000, 165.000000, "Discord");
	PlayerTextDrawFont(playerid, gPlayerDiscordTD[playerid][6], 1);
	PlayerTextDrawLetterSize(playerid, gPlayerDiscordTD[playerid][6], 0.270833, 1.150000);
	PlayerTextDrawTextSize(playerid, gPlayerDiscordTD[playerid][6], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, gPlayerDiscordTD[playerid][6], 0);
	PlayerTextDrawSetShadow(playerid, gPlayerDiscordTD[playerid][6], 0);
	PlayerTextDrawAlignment(playerid, gPlayerDiscordTD[playerid][6], 2);
	PlayerTextDrawColor(playerid, gPlayerDiscordTD[playerid][6], 1921776383);
	PlayerTextDrawBackgroundColor(playerid, gPlayerDiscordTD[playerid][6], 255);
	PlayerTextDrawBoxColor(playerid, gPlayerDiscordTD[playerid][6], 50);
	PlayerTextDrawUseBox(playerid, gPlayerDiscordTD[playerid][6], 0);
	PlayerTextDrawSetProportional(playerid, gPlayerDiscordTD[playerid][6], 1);
	PlayerTextDrawSetSelectable(playerid, gPlayerDiscordTD[playerid][6], 0);

	gPlayerDiscordTD[playerid][7] = CreatePlayerTextDraw(playerid, 323.000000, 186.000000, "_");
	PlayerTextDrawFont(playerid, gPlayerDiscordTD[playerid][7], 1);
	PlayerTextDrawLetterSize(playerid, gPlayerDiscordTD[playerid][7], 0.600000, -0.499998);
	PlayerTextDrawTextSize(playerid, gPlayerDiscordTD[playerid][7], 298.500000, 97.500000);
	PlayerTextDrawSetOutline(playerid, gPlayerDiscordTD[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, gPlayerDiscordTD[playerid][7], 0);
	PlayerTextDrawAlignment(playerid, gPlayerDiscordTD[playerid][7], 2);
	PlayerTextDrawColor(playerid, gPlayerDiscordTD[playerid][7], -1);
	PlayerTextDrawBackgroundColor(playerid, gPlayerDiscordTD[playerid][7], 255);
	PlayerTextDrawBoxColor(playerid, gPlayerDiscordTD[playerid][7], 1921776383);
	PlayerTextDrawUseBox(playerid, gPlayerDiscordTD[playerid][7], 1);
	PlayerTextDrawSetProportional(playerid, gPlayerDiscordTD[playerid][7], 1);
	PlayerTextDrawSetSelectable(playerid, gPlayerDiscordTD[playerid][7], 0);

	gPlayerDiscordTD[playerid][8] = CreatePlayerTextDraw(playerid, 321.000000, 192.000000, "Para liberar seu acesso no servidor ž necess˜rio realizar uma verificaœšo em nosso Discord");
	PlayerTextDrawFont(playerid, gPlayerDiscordTD[playerid][8], 1);
	PlayerTextDrawLetterSize(playerid, gPlayerDiscordTD[playerid][8], 0.170833, 0.850000);
	PlayerTextDrawTextSize(playerid, gPlayerDiscordTD[playerid][8], 400.000000, 96.500000);
	PlayerTextDrawSetOutline(playerid, gPlayerDiscordTD[playerid][8], 0);
	PlayerTextDrawSetShadow(playerid, gPlayerDiscordTD[playerid][8], 0);
	PlayerTextDrawAlignment(playerid, gPlayerDiscordTD[playerid][8], 2);
	PlayerTextDrawColor(playerid, gPlayerDiscordTD[playerid][8], -1);
	PlayerTextDrawBackgroundColor(playerid, gPlayerDiscordTD[playerid][8], 255);
	PlayerTextDrawBoxColor(playerid, gPlayerDiscordTD[playerid][8], 50);
	PlayerTextDrawUseBox(playerid, gPlayerDiscordTD[playerid][8], 0);
	PlayerTextDrawSetProportional(playerid, gPlayerDiscordTD[playerid][8], 1);
	PlayerTextDrawSetSelectable(playerid, gPlayerDiscordTD[playerid][8], 0);

	gPlayerDiscordTD[playerid][9] = CreatePlayerTextDraw(playerid, 323.000000, 235.000000, "_");
	PlayerTextDrawFont(playerid, gPlayerDiscordTD[playerid][9], 1);
	PlayerTextDrawLetterSize(playerid, gPlayerDiscordTD[playerid][9], 0.600000, -0.499998);
	PlayerTextDrawTextSize(playerid, gPlayerDiscordTD[playerid][9], 298.500000, 97.500000);
	PlayerTextDrawSetOutline(playerid, gPlayerDiscordTD[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, gPlayerDiscordTD[playerid][9], 0);
	PlayerTextDrawAlignment(playerid, gPlayerDiscordTD[playerid][9], 2);
	PlayerTextDrawColor(playerid, gPlayerDiscordTD[playerid][9], -1);
	PlayerTextDrawBackgroundColor(playerid, gPlayerDiscordTD[playerid][9], 255);
	PlayerTextDrawBoxColor(playerid, gPlayerDiscordTD[playerid][9], 1921776383);
	PlayerTextDrawUseBox(playerid, gPlayerDiscordTD[playerid][9], 1);
	PlayerTextDrawSetProportional(playerid, gPlayerDiscordTD[playerid][9], 1);
	PlayerTextDrawSetSelectable(playerid, gPlayerDiscordTD[playerid][9], 0);

	gPlayerDiscordTD[playerid][10] = CreatePlayerTextDraw(playerid, 321.000000, 299.000000, Player[playerid][pDiscordCode]);
	PlayerTextDrawFont(playerid, gPlayerDiscordTD[playerid][10], 1);
	PlayerTextDrawLetterSize(playerid, gPlayerDiscordTD[playerid][10], 0.270833, 1.150000);
	PlayerTextDrawTextSize(playerid, gPlayerDiscordTD[playerid][10], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, gPlayerDiscordTD[playerid][10], 0);
	PlayerTextDrawSetShadow(playerid, gPlayerDiscordTD[playerid][10], 0);
	PlayerTextDrawAlignment(playerid, gPlayerDiscordTD[playerid][10], 2);
	PlayerTextDrawColor(playerid, gPlayerDiscordTD[playerid][10], 1921776383);
	PlayerTextDrawBackgroundColor(playerid, gPlayerDiscordTD[playerid][10], 255);
	PlayerTextDrawBoxColor(playerid, gPlayerDiscordTD[playerid][10], 50);
	PlayerTextDrawUseBox(playerid, gPlayerDiscordTD[playerid][10], 0);
	PlayerTextDrawSetProportional(playerid, gPlayerDiscordTD[playerid][10], 1);
	PlayerTextDrawSetSelectable(playerid, gPlayerDiscordTD[playerid][10], 0);

	gPlayerDiscordTD[playerid][11] = CreatePlayerTextDraw(playerid, 321.000000, 287.000000, "c¦digo de verificaœšo");
	PlayerTextDrawFont(playerid, gPlayerDiscordTD[playerid][11], 2);
	PlayerTextDrawLetterSize(playerid, gPlayerDiscordTD[playerid][11], 0.166666, 0.950000);
	PlayerTextDrawTextSize(playerid, gPlayerDiscordTD[playerid][11], 400.000000, 107.000000);
	PlayerTextDrawSetOutline(playerid, gPlayerDiscordTD[playerid][11], 0);
	PlayerTextDrawSetShadow(playerid, gPlayerDiscordTD[playerid][11], 0);
	PlayerTextDrawAlignment(playerid, gPlayerDiscordTD[playerid][11], 2);
	PlayerTextDrawColor(playerid, gPlayerDiscordTD[playerid][11], -1061109685);
	PlayerTextDrawBackgroundColor(playerid, gPlayerDiscordTD[playerid][11], 255);
	PlayerTextDrawBoxColor(playerid, gPlayerDiscordTD[playerid][11], 50);
	PlayerTextDrawUseBox(playerid, gPlayerDiscordTD[playerid][11], 0);
	PlayerTextDrawSetProportional(playerid, gPlayerDiscordTD[playerid][11], 1);
	PlayerTextDrawSetSelectable(playerid, gPlayerDiscordTD[playerid][11], 0);

	gPlayerDiscordTD[playerid][12] = CreatePlayerTextDraw(playerid, 321.000000, 246.000000, "Para validar, acesse nosso Discord, em seguida v˜ atž a categoria de comunidade e utilize o canal de verificaœšo.");
	PlayerTextDrawFont(playerid, gPlayerDiscordTD[playerid][12], 1);
	PlayerTextDrawLetterSize(playerid, gPlayerDiscordTD[playerid][12], 0.170833, 0.850000);
	PlayerTextDrawTextSize(playerid, gPlayerDiscordTD[playerid][12], 400.000000, 91.500000);
	PlayerTextDrawSetOutline(playerid, gPlayerDiscordTD[playerid][12], 0);
	PlayerTextDrawSetShadow(playerid, gPlayerDiscordTD[playerid][12], 0);
	PlayerTextDrawAlignment(playerid, gPlayerDiscordTD[playerid][12], 2);
	PlayerTextDrawColor(playerid, gPlayerDiscordTD[playerid][12], -1);
	PlayerTextDrawBackgroundColor(playerid, gPlayerDiscordTD[playerid][12], 255);
	PlayerTextDrawBoxColor(playerid, gPlayerDiscordTD[playerid][12], 50);
	PlayerTextDrawUseBox(playerid, gPlayerDiscordTD[playerid][12], 0);
	PlayerTextDrawSetProportional(playerid, gPlayerDiscordTD[playerid][12], 1);
	PlayerTextDrawSetSelectable(playerid, gPlayerDiscordTD[playerid][12], 0);

	for (new i = 0; i < sizeof gPlayerDiscordTD[]; i++)
	{
		if (gPlayerDiscordTD[playerid][i] == PlayerText:INVALID_TEXT_DRAW)
			continue;

		PlayerTextDrawShow(playerid, gPlayerDiscordTD[playerid][i]);
	}
	return true;
}

Discord_DestroyGUI(playerid)
{
	for (new i = 0; i < sizeof gPlayerDiscordTD[]; i++)
	{
		if (gPlayerDiscordTD[playerid][i] == PlayerText:INVALID_TEXT_DRAW)
			continue;

		PlayerTextDrawDestroy(playerid, gPlayerDiscordTD[playerid][i]);
	}

	return true;
}