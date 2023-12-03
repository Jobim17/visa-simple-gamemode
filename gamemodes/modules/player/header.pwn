/* 
*	module: player\header.pwn
*	desc: responsável por conectar os módulos
*/

enum e_Player 
{
	pID,
	pName[MAX_PLAYER_NAME],
	pSkin,
	pColor,
	pAdmin,
	pDiscordID[DCC_ID_SIZE],
	pDiscordCode[12]
}

new Player[MAX_PLAYERS][e_Player];