/* 
*	module: server\utils.pwn
*	author: Jobim 
*	desc: utilitários
*/

SendClientMessageEx(playerid, color, const msg[], va_args<>)
{
	new str[144];
	va_format(str, sizeof str, msg, va_start<3>);
	SendClientMessage(playerid, color, str);
	return true;
}

SendClientMessageToAllEx(color, const msg[], va_args<>)
{
	foreach (new i : Player)
	{
		SendClientMessageEx(i, color, msg, va_start<2>);
	}
	return true;
}

SendAdminMessage(color, const msg[], va_args<>)
{
	new
		str[256];

	va_format(str, sizeof str, msg, va_start<2>);

	foreach (new i : Player)
	{
		if (!IsPlayerLogged(i) || !Player[i][pAdmin])
			continue;

		SendClientMessage(i, color, str);
	}
	return true;
}

FormatNumber(int)
{
    new var[20];
    valstr(var, int);

    for(new X = strlen(var) - 3; X > 0; X -= 3)
        strins(var, ".", X);

    format(var, sizeof(var), "%s", var);
    return var;
} 