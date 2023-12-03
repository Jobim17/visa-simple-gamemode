/* 
*	module: server\sql.pwn
*	author: Jobim 
*	desc: responsável pela conexão ao servidor MySQL
*/

#include <YSI_Coding\y_hooks>

//-----------------------------------------------------------------------------

static MySQL: gConnectionHandle = MYSQL_INVALID_HANDLE;

new global_query[612] = "";

//-----------------------------------------------------------------------------

hook OnGameModeInit()
{
	#if defined LOCALHOST
		gConnectionHandle = mysql_connect("localhost", "root", "", "visamp");
	#else
		gConnectionHandle = mysql_connect("localhost", "root", "", "visamp");
	#endif

	if (gConnectionHandle == MYSQL_INVALID_HANDLE || mysql_errno(gConnectionHandle) != 0)
	{
		SendRconCommand("password afiodyf87wrhjsasfba");

		printf("** ATENÇÃO: [mysql] Não foi possível conectar ao banco de dados (erro: %i)", mysql_errno(gConnectionHandle));
		return Y_HOOKS_BREAK_RETURN_0;
	}
	else
	{
		SendRconCommand("password 0");

		print("[mysql] Banco de dados conectado com sucesso!");
		InternalSQL_CheckTables();
		
		mysql_set_charset("latin1"); // suportar caracteres (ã, á, ...)
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnGameModeExit()
{
	if (gConnectionHandle != MYSQL_INVALID_HANDLE) 
	{
		mysql_close(gConnectionHandle);
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

//-----------------------------------------------------------------------------

MySQL:SQL_GetHandle()
{
	return gConnectionHandle;
}

InternalSQL_CheckTables()
{
	mysql_tquery(SQL_GetHandle(), "CREATE TABLE IF NOT EXISTS `players`(player_id int NOT NULL AUTO_INCREMENT PRIMARY KEY);");
	mysql_tquery(SQL_GetHandle(), "ALTER TABLE `players` ADD IF NOT EXISTS (player_name varchar(21) NOT NULL default 'N/A')");
	mysql_tquery(SQL_GetHandle(), "ALTER TABLE `players` ADD IF NOT EXISTS (player_pass varchar(129) NOT NULL default 'N/A')");
	mysql_tquery(SQL_GetHandle(), "ALTER TABLE `players` ADD IF NOT EXISTS (player_skin int(11) NOT NULL default '26')");
	mysql_tquery(SQL_GetHandle(), "ALTER TABLE `players` ADD IF NOT EXISTS (player_color int(11) NOT NULL default '-1')");
	mysql_tquery(SQL_GetHandle(), "ALTER TABLE `players` ADD IF NOT EXISTS (player_admin int(11) NOT NULL default '0')");
	mysql_tquery(SQL_GetHandle(), "ALTER TABLE `players` ADD IF NOT EXISTS (player_discord_code varchar(12) NOT NULL default 'Nenhum')");
	mysql_tquery(SQL_GetHandle(), "ALTER TABLE `players` ADD IF NOT EXISTS (player_discord_id varchar(21) NOT NULL default 'Nenhum')");

	mysql_tquery(
		SQL_GetHandle(),
		"CREATE TABLE IF NOT EXISTS `logs` (log_id int NOT NULL PRIMARY KEY AUTO_INCREMENT);");

	mysql_tquery(SQL_GetHandle(), "ALTER TABLE logs ADD COLUMN IF NOT EXISTS (`log_type` varchar(24) default NULL)");
	mysql_tquery(SQL_GetHandle(), "ALTER TABLE logs ADD COLUMN IF NOT EXISTS (`log_text` varchar(128) default NULL)");
	mysql_tquery(SQL_GetHandle(), "ALTER TABLE logs ADD COLUMN IF NOT EXISTS (`log_date` varchar(32) default NULL)");
	mysql_tquery(SQL_GetHandle(), "ALTER TABLE logs ADD COLUMN IF NOT EXISTS (`log_time` int(16) default 0)");
	return true;
}
