/************************************************************************
*	This file is part of NOAMP.
*
*	NOAMP is free software: you can redistribute it and/or modify
*	it under the terms of the GNU General Public License as published by
*	the Free Software Foundation, either version 3 of the License, or
*	(at your option) any later version.
*
*	NOAMP is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*	GNU General Public License for more details.
*
*	You should have received a copy of the GNU General Public License
*	along with NOAMP.  If not, see <http://www.gnu.org/licenses/>.
************************************************************************/

// NOAMP Commands

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <morecolors>

public Action:CmdTestSpawns(client, args)
{
	if (IsDebug())
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
	if (IsDebug())
	{
		for (new i = 0; i < 2; i++)
		{
			SpawnGiantParrot();
		}
	}
	else
	{
		CPrintToChat(client, "{red}Debug mode required for this command.");
	}
	
	return Plugin_Handled;
}

public Action:CmdGiveMoney(client, args)
{
	if (IsDebug())
	{
		clientMoney[client] += 10000;
	}
	else
	{
		CPrintToChat(client, "{red}Debug mode required for this command.");
	}
	
	return Plugin_Handled;
}

public Action:CmdGiveAllUpgrades(client, args)
{
	if (IsDebug())
	{
		clientUpgradesMaxHP[client] = true;
		clientUpgradesMaxArmor[client] = true;
		clientUpgradesMaxSpeed[client] = true;
	}
	else
	{
		CPrintToChat(client, "{red}Debug mode required for this command.");
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
	CPrintToChatAll("{unusual}%s{lightgreen} The server admin is resetting the game!", CHAT_PREFIX);
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
	
	if (IsDebug())
	{
		wave = iarg - 1;
		WaveFinished();
	}
	else
	{
		CPrintToChat(client, "{red}Debug mode required for this command.");
	}
	
	return Plugin_Handled;
}