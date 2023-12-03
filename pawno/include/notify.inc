/*
*	module: player/notify.pwn
*	author: Jobim
*	desc: Sistema de notificações (do Ghetto)
*/

#include <YSI_Coding\y_hooks>

#pragma warning disable 239

//-------------------------------------------------------------------------------------------------------

#define MAX_PLAYER_NOTIFICATION (5)

//-------------------------------------------------------------------------------------------------------

static bool: g_PlayerIsValid [MAX_PLAYERS][MAX_PLAYER_NOTIFICATION];
static PlayerText: g_PlayerTDBackground [MAX_PLAYERS][MAX_PLAYER_NOTIFICATION];
static PlayerText: g_PlayerTDHeader [MAX_PLAYERS][MAX_PLAYER_NOTIFICATION];
static PlayerText: g_PlayerTDText [MAX_PLAYERS][MAX_PLAYER_NOTIFICATION];
static PlayerText: g_PlayerTDSideBar [MAX_PLAYERS][MAX_PLAYER_NOTIFICATION];
static Timer: g_PlayerTimer [MAX_PLAYERS][MAX_PLAYER_NOTIFICATION];

//-------------------------------------------------------------------------------------------------------

timer HideNotification[10](playerid, idx)
{
	if (!IsPlayerConnected(playerid))
		return false;

	if (!(0 <= idx < MAX_PLAYER_NOTIFICATION))
		return false;

	if (!g_PlayerIsValid[playerid][idx])
		return false;

	g_PlayerIsValid[playerid][idx] = false;

	if (g_PlayerTDBackground[playerid][idx] != PlayerText: INVALID_TEXT_DRAW)
	{
		PlayerTextDrawDestroy(playerid, g_PlayerTDBackground[playerid][idx]);
		g_PlayerTDBackground[playerid][idx] = PlayerText: INVALID_TEXT_DRAW;
	}

	if (g_PlayerTDHeader[playerid][idx] != PlayerText: INVALID_TEXT_DRAW)
	{
		PlayerTextDrawDestroy(playerid, g_PlayerTDHeader[playerid][idx]);
		g_PlayerTDHeader[playerid][idx] = PlayerText: INVALID_TEXT_DRAW;
	}

	if (g_PlayerTDText[playerid][idx] != PlayerText: INVALID_TEXT_DRAW)
	{
		PlayerTextDrawDestroy(playerid, g_PlayerTDText[playerid][idx]);
		g_PlayerTDText[playerid][idx] = PlayerText: INVALID_TEXT_DRAW;
	}

	if (g_PlayerTDSideBar[playerid][idx] != PlayerText: INVALID_TEXT_DRAW)
	{
		PlayerTextDrawDestroy(playerid, g_PlayerTDSideBar[playerid][idx]);
		g_PlayerTDSideBar[playerid][idx] = PlayerText: INVALID_TEXT_DRAW;
	}

	g_PlayerTimer[playerid][idx] = Timer: -1;

	return true;
}

//-------------------------------------------------------------------------------------------------------

hook OnPlayerConnect(playerid)
{
	for (new i = 0; i < MAX_PLAYER_NOTIFICATION; i++)
	{
		g_PlayerIsValid[playerid][i] = false;
		g_PlayerTDBackground[playerid][i] = PlayerText: INVALID_TEXT_DRAW;
		g_PlayerTDHeader[playerid][i] = PlayerText: INVALID_TEXT_DRAW;
		g_PlayerTDText[playerid][i] = PlayerText: INVALID_TEXT_DRAW;
		g_PlayerTDSideBar[playerid][i] = PlayerText: INVALID_TEXT_DRAW;

		g_PlayerTimer[playerid][i] = Timer: -1;
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	for (new i = 0; i < MAX_PLAYER_NOTIFICATION; i++)
	{
		g_PlayerIsValid[playerid][i] = false;

		if (g_PlayerTDBackground[playerid][i] != PlayerText: INVALID_TEXT_DRAW)
		{
			PlayerTextDrawDestroy(playerid, g_PlayerTDBackground[playerid][i]);
			g_PlayerTDBackground[playerid][i] = PlayerText: INVALID_TEXT_DRAW;
		}

		if (g_PlayerTDHeader[playerid][i] != PlayerText: INVALID_TEXT_DRAW)
		{
			PlayerTextDrawDestroy(playerid, g_PlayerTDHeader[playerid][i]);
			g_PlayerTDHeader[playerid][i] = PlayerText: INVALID_TEXT_DRAW;
		}

		if (g_PlayerTDText[playerid][i] != PlayerText: INVALID_TEXT_DRAW)
		{
			PlayerTextDrawDestroy(playerid, g_PlayerTDText[playerid][i]);
			g_PlayerTDText[playerid][i] = PlayerText: INVALID_TEXT_DRAW;
		}

		if (g_PlayerTDSideBar[playerid][i] != PlayerText: INVALID_TEXT_DRAW)
		{
			PlayerTextDrawDestroy(playerid, g_PlayerTDSideBar[playerid][i]);
			g_PlayerTDSideBar[playerid][i] = PlayerText: INVALID_TEXT_DRAW;
		}

		if (Timer_IsRunning(g_PlayerTimer[playerid][i]))
		{
			stop g_PlayerTimer[playerid][i];
		}
	}

	return true;
}

//-------------------------------------------------------------------------------------------------------

ShowPlayerNotification(playerid, color, time, sound, const header[], const message[], va_args<>)
{
	if (!IsPlayerConnected(playerid))
		return false;

	new
		idx = Internal_GetFreeID(playerid)
	;

	if (idx == -1)
	{
		return true;
	}

	// clear
	g_PlayerIsValid[playerid][idx] = true;

	if (g_PlayerTDBackground[playerid][idx] != PlayerText: INVALID_TEXT_DRAW)
	{
		PlayerTextDrawDestroy(playerid, g_PlayerTDBackground[playerid][idx]);
		g_PlayerTDBackground[playerid][idx] = PlayerText: INVALID_TEXT_DRAW;
	}

	if (g_PlayerTDHeader[playerid][idx] != PlayerText: INVALID_TEXT_DRAW)
	{
		PlayerTextDrawDestroy(playerid, g_PlayerTDHeader[playerid][idx]);
		g_PlayerTDHeader[playerid][idx] = PlayerText: INVALID_TEXT_DRAW;
	}

	if (g_PlayerTDText[playerid][idx] != PlayerText: INVALID_TEXT_DRAW)
	{
		PlayerTextDrawDestroy(playerid, g_PlayerTDText[playerid][idx]);
		g_PlayerTDText[playerid][idx] = PlayerText: INVALID_TEXT_DRAW;
	}

	if (g_PlayerTDSideBar[playerid][idx] != PlayerText: INVALID_TEXT_DRAW)
	{
		PlayerTextDrawDestroy(playerid, g_PlayerTDSideBar[playerid][idx]);
		g_PlayerTDSideBar[playerid][idx] = PlayerText: INVALID_TEXT_DRAW;
	}

	// create
	g_PlayerTDBackground[playerid][idx] = CreatePlayerTextDraw(playerid, 591.000000, (394.000000 - (40.0 * idx)), "_");
	PlayerTextDrawFont(playerid, g_PlayerTDBackground[playerid][idx], 1);
	PlayerTextDrawLetterSize(playerid, g_PlayerTDBackground[playerid][idx], 0.600000, 3.650002);
	PlayerTextDrawTextSize(playerid, g_PlayerTDBackground[playerid][idx], 298.500000, 85.000000);
	PlayerTextDrawSetOutline(playerid, g_PlayerTDBackground[playerid][idx], 1);
	PlayerTextDrawSetShadow(playerid, g_PlayerTDBackground[playerid][idx], 0);
	PlayerTextDrawAlignment(playerid, g_PlayerTDBackground[playerid][idx], 2);
	PlayerTextDrawColor(playerid, g_PlayerTDBackground[playerid][idx], -1);
	PlayerTextDrawBackgroundColor(playerid, g_PlayerTDBackground[playerid][idx], 255);
	PlayerTextDrawBoxColor(playerid, g_PlayerTDBackground[playerid][idx], 336860415);
	PlayerTextDrawUseBox(playerid, g_PlayerTDBackground[playerid][idx], 1);
	PlayerTextDrawSetProportional(playerid, g_PlayerTDBackground[playerid][idx], 1);
	PlayerTextDrawSetSelectable(playerid, g_PlayerTDBackground[playerid][idx], 0);
	PlayerTextDrawShow(playerid, g_PlayerTDBackground[playerid][idx]);

	g_PlayerTDSideBar[playerid][idx] = CreatePlayerTextDraw(playerid, 547.500000, (394.000000 - (40.0 * idx)), "_");
	PlayerTextDrawFont(playerid, g_PlayerTDSideBar[playerid][idx], 1);
	PlayerTextDrawLetterSize(playerid, g_PlayerTDSideBar[playerid][idx], 0.600000, 3.650002);
	PlayerTextDrawTextSize(playerid, g_PlayerTDSideBar[playerid][idx], 295.500000, -1.500000);
	PlayerTextDrawSetOutline(playerid, g_PlayerTDSideBar[playerid][idx], 1);
	PlayerTextDrawSetShadow(playerid, g_PlayerTDSideBar[playerid][idx], 0);
	PlayerTextDrawAlignment(playerid, g_PlayerTDSideBar[playerid][idx], 2);
	PlayerTextDrawColor(playerid, g_PlayerTDSideBar[playerid][idx], -1);
	PlayerTextDrawBackgroundColor(playerid, g_PlayerTDSideBar[playerid][idx], 255);
	PlayerTextDrawBoxColor(playerid, g_PlayerTDSideBar[playerid][idx], SetColorAlpha(color, 0xFF));
	PlayerTextDrawUseBox(playerid, g_PlayerTDSideBar[playerid][idx], 1);
	PlayerTextDrawSetProportional(playerid, g_PlayerTDSideBar[playerid][idx], 1);
	PlayerTextDrawSetSelectable(playerid, g_PlayerTDSideBar[playerid][idx], 0);
	PlayerTextDrawShow(playerid, g_PlayerTDSideBar[playerid][idx]);

	new
		_text[256];

	va_format (_text, sizeof _text, message, va_start<6>);
	Internal_FixString (_text);

	g_PlayerTDText[playerid][idx] = CreatePlayerTextDraw(playerid, 554.000000, (406.000000 - (40.0 * idx)), _text);
	PlayerTextDrawFont(playerid, g_PlayerTDText[playerid][idx], 1);
	PlayerTextDrawLetterSize(playerid, g_PlayerTDText[playerid][idx], 0.166666, 0.750000);
	PlayerTextDrawTextSize(playerid, g_PlayerTDText[playerid][idx], 632.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, g_PlayerTDText[playerid][idx], 0);
	PlayerTextDrawSetShadow(playerid, g_PlayerTDText[playerid][idx], 0);
	PlayerTextDrawAlignment(playerid, g_PlayerTDText[playerid][idx], 1);
	PlayerTextDrawColor(playerid, g_PlayerTDText[playerid][idx], -1061109505);
	PlayerTextDrawBackgroundColor(playerid, g_PlayerTDText[playerid][idx], 255);
	PlayerTextDrawBoxColor(playerid, g_PlayerTDText[playerid][idx], 50);
	PlayerTextDrawUseBox(playerid, g_PlayerTDText[playerid][idx], 0);
	PlayerTextDrawSetProportional(playerid, g_PlayerTDText[playerid][idx], 1);
	PlayerTextDrawSetSelectable(playerid, g_PlayerTDText[playerid][idx], 0);
	PlayerTextDrawShow(playerid, g_PlayerTDText[playerid][idx]);

	format (_text, sizeof _text, header);
	Internal_FixString(_text);

	g_PlayerTDHeader[playerid][idx] = CreatePlayerTextDraw(playerid, 554.000000, (396.000000 - (40.0 * idx)), _text);
	PlayerTextDrawFont(playerid, g_PlayerTDHeader[playerid][idx], 1);
	PlayerTextDrawLetterSize(playerid, g_PlayerTDHeader[playerid][idx], 0.166666, 0.750000);
	PlayerTextDrawTextSize(playerid, g_PlayerTDHeader[playerid][idx], 632.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, g_PlayerTDHeader[playerid][idx], 0);
	PlayerTextDrawSetShadow(playerid, g_PlayerTDHeader[playerid][idx], 0);
	PlayerTextDrawAlignment(playerid, g_PlayerTDHeader[playerid][idx], 1);
	PlayerTextDrawColor(playerid, g_PlayerTDHeader[playerid][idx], -1);
	PlayerTextDrawBackgroundColor(playerid, g_PlayerTDHeader[playerid][idx], 255);
	PlayerTextDrawBoxColor(playerid, g_PlayerTDHeader[playerid][idx], 50);
	PlayerTextDrawUseBox(playerid, g_PlayerTDHeader[playerid][idx], 0);
	PlayerTextDrawSetProportional(playerid, g_PlayerTDHeader[playerid][idx], 1);
	PlayerTextDrawSetSelectable(playerid, g_PlayerTDHeader[playerid][idx], 0);
	PlayerTextDrawShow(playerid, g_PlayerTDHeader[playerid][idx]);

	if (sound != -1)
	{
		PlayerPlaySound(playerid, sound, 0.0, 0.0, 0.0);
	}

	g_PlayerTimer[playerid][idx] = defer HideNotification[time](playerid, idx);
	return true;
}

//-------------------------------------------------------------------------------------------------------

static Internal_GetFreeID(playerid)
{
	if (!IsPlayerConnected(playerid))
		return false;

	new
		idx = -1;

	for (new i = 0; i < MAX_PLAYER_NOTIFICATION; i++)
	{
		if (g_PlayerIsValid[playerid][i] && Timer_IsRunning(g_PlayerTimer[playerid][i]))
			continue;

		idx = i;
		break;
	}

	return idx;
}

static Internal_FixCharacter(chr) 
{
    switch (chr) 
    {
        case 161: return 94;
        case 176: return 124;
        case 192: return 128;
        case 193: return 129;
        case 194: return 130;
        case 196: return 131;
        case 198: return 132;
        case 199: return 133;
        case 200: return 134;
        case 201: return 135;
        case 202: return 136;
        case 203: return 137;
        case 204: return 138;
        case 205: return 139;
        case 206: return 140;
        case 207: return 141;
        case 210: return 142;
        case 211: return 143;
        case 212: return 144;
        case 213: return 144;
        case 214: return 145;
        case 217: return 146;
        case 218: return 147;
        case 219: return 148;
        case 220: return 149;
        case 223: return 150;
        case 224: return 151;
        case 225: return 152;
        case 226: return 153;
        case 228: return 154;
        case 230: return 155;
        case 231: return 156;
        case 232: return 157;
        case 233: return 158;
        case 234: return 159;
        case 235: return 160;
        case 236: return 161;
        case 237: return 162;
        case 238: return 163;
        case 239: return 164;
        case 242: return 165;
        case 243: return 166;
        case 244: return 167;
        case 245: return 167;
        case 246: return 168;
        case 249: return 169;
        case 250: return 170;
        case 251: return 171;
        case 252: return 172;
        case 209: return 173;
        case 241: return 174;
        case 191: return 175;
        case 227: return 154;
        case 195: return 138;
    }
    return chr;
}

static Internal_FixString(str[]) 
{
    new i = 0;

    while (str[i] != '\0') 
    {
        str[i] = Internal_FixCharacter(str[i]);
        i++;
    }
    return i+1;
}

SetColorAlpha(color, alpha)
{
	return (color & ~0xff) | alpha;
}