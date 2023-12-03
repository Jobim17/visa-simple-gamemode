/*
*	module: logs
*	author: *
*	last edit: 11/02/2023
*	desc: logs do servidor
*/

#include <YSI_Coding\y_hooks>

//-----------------------------------------------------------------------------

static const g_LogTypes[][] = {

	"Admin SET",
	"Admin CMD",
	"Kickados"
};

//-----------------------------------------------------------------------------

Log_Create(const type[], const text[], va_args<>)
{
	new
		_text[128],
		_day, _month, _year,
		_hour, _minute;

	getdate(_year, _month, _day);
	gettime(_hour, _minute);

	va_format(_text, sizeof _text, text, va_start<2>);

	mysql_format (SQL_GetHandle(), global_query, sizeof global_query, "INSERT INTO `logs` (`log_type`, `log_text`, `log_date`, `log_time`) VALUES ('%e', '%e', '%02d/%02d/%04d %02d:%02d', '%i')", type, _text, _day, _month, _year, _hour, _minute, gettime());
	mysql_tquery (SQL_GetHandle(), global_query);
	return true;
}

Log_Show(playerid, const type[])
{
	if (!IsPlayerConnected(playerid))
		return false;

	if (!Player[playerid][pAdmin])
		return false;

	mysql_format (SQL_GetHandle(), global_query, sizeof global_query, "SELECT * FROM logs WHERE log_type = '%e' ORDER BY log_time DESC LIMIT 20;", type);
	mysql_tquery (SQL_GetHandle(), global_query, "OnFoundLog", "i", playerid);	
	return true;
}

Log_ShowMenu(playerid)
{
	if (!IsPlayerConnected(playerid))
		return false;

	if (!Player[playerid][pAdmin])
		return false;

	new
		tmpStr[128],
		count,
		bigStr[2056];

	format (bigStr, sizeof bigStr, "{FFFFFF}Log\t{FFFFFF}Registros\n");

	for (new i = 0; i < sizeof g_LogTypes; i++)
	{
		mysql_format (SQL_GetHandle(), global_query, sizeof global_query, "SELECT COUNT(log_id) AS registred_logs FROM `logs` WHERE `log_type` = '%e';", g_LogTypes[i]);
		mysql_query (SQL_GetHandle(), global_query);

		cache_get_value_name_int(0, "registred_logs", count);

		format (tmpStr, sizeof tmpStr, "{FFFFFF}%s\t{FFFFFF}%s\n", g_LogTypes[i], FormatNumber(count));
		strcat (bigStr, tmpStr);
	}

	Dialog_Show(playerid, LogMenu, DIALOG_STYLE_TABLIST_HEADERS, "{2AA8E7}Logs", bigStr, "Selecionar", "Fechar");
	return true;
}

//-----------------------------------------------------------------------------

Dialog:LogMenu(playerid, response, listitem, inputtext[])
{
	if (!response)
		return true;

	Log_Show(playerid, g_LogTypes[listitem]);
	return true;
}

//-----------------------------------------------------------------------------

forward OnFoundLog(playerid);
public OnFoundLog(playerid)
{
	if (!IsPlayerConnected(playerid))
		return false;

	if (!Player[playerid][pAdmin])
		return false;

	if (!cache_num_rows())
	{
		ShowPlayerNotification(playerid, 0xFF0000FF, 5000, -1, "ERRO", "Nenhum resultado obtido");
		return true;
	}

	new
		_logDate[32],
		_logText[128],
		_tmpStr[256],
		_bigString[4096];

	format (_bigString, sizeof _bigString, "{FFFF00}Resultados (máx: 20) em ordem decrescente de data e hora\n\n{FFFFFF}");

	for (new i = 0; i < cache_num_rows(); i++)
	{
		cache_get_value_name(i, "log_date", _logDate);
		cache_get_value_name(i, "log_text", _logText);

		format (_tmpStr, sizeof _tmpStr, "{C0C0C0}[%s]{FFFFFF} %s\n", _logDate, _logText);
		strcat (_bigString, _tmpStr);
	}

	Dialog_Show(playerid, Null, DIALOG_STYLE_MSGBOX, "{FF0000}Log", _bigString, "Fechar", "");
	return true;
}