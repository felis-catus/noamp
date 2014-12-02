// NOAMP Commands

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <morecolors>

public Action:CmdTestSpawns(client, args)
{
	if (GetConVarBool(cvar_debug) == true)
	{
		for (new i = 0; i < 10; i++)
		{
			SpawnParrot();
		}
	}
	else
	{
		CPrintToChat(client, "{red}Debug mode required for this command.");
	}
	
	return Plugin_Handled;
}

public Action:CmdTestGiantSpawns(client, args)
{
	if (GetConVarBool(cvar_debug) == true)
	{
		for (new i = 0; i < 2; i++)
		{
			SpawnGiantParrot();
		}
	}
	else
	{
		PrintToChat(client, "{red}Debug mode required for this command.");
	}
	
	return Plugin_Handled;
}

public Action:CmdGiveMoney(client, args)
{
	if (GetConVarBool(cvar_debug) == true)
	{
		clientMoney[client] += 10000;
	}
	else
	{
		PrintToChat(client, "{red}Debug mode required for this command.");
	}
	
	return Plugin_Handled;
}

public Action:CmdGiveAllUpgrades(client, args)
{
	if (GetConVarBool(cvar_debug) == true)
	{
		clientUpgradesMaxHP[client] = true;
		clientUpgradesMaxArmor[client] = true;
		clientUpgradesMaxSpeed[client] = true;
	}
	else
	{
		PrintToChat(client, "{red}Debug mode required for this command.");
	}
	
	return Plugin_Handled;
}

public Action:CmdStartGame(client, args)
{
	CPrintToChatAll("{unusual}%s{lightgreen} The server admin is starting the game!", CHAT_PREFIX);
	StartGame();
	
	return Plugin_Handled;
}

public Action:CmdResetGame(client, args)
{
	PrintToChatAll("{unusual}%s{lightgreen} The server admin is resetting the game!", CHAT_PREFIX);
	ResetGame(false, true);
	
	return Plugin_Handled;
}

public Action:CmdFillSpecial(client, args)
{
	FillSpecial(client);
	
	return Plugin_Handled;
}

public Action:CmdReloadKeyValues(client, args)
{
	ReadNOAMPScript();
	
	return Plugin_Handled;
}

public Action:CmdJumpToWave(client, args)
{
	new String:arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	new iarg = StringToInt(arg1);
	
	if (GetConVarBool(cvar_debug) == true)
	{
		wave = iarg;
		WaveFinished();
	}
	else
	{
		PrintToChat(client, "{red}Debug mode required for this command.");
	}
	
	return Plugin_Handled;
}