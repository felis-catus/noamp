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

// NOAMP Events

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <morecolors>

/*
public Event_WaitEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsEnabled)
		return;
	
	PrintToChatAll("%s The game is starting!", CHAT_PREFIX);
	IsWaitingForPlayers = false;
	StartGame();
}
*/
public OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!HasGameStarted)
		return;
	
	new userid = GetEventInt(event, "userid");
	new client = GetClientOfUserId(userid);
	
	if (clientLives[client] <= 0)
	{
		if (IsLivesDisabled)
			return;
		
		// should not spawn, force join spec
		ForceJoinSpec(client);
	}
	else
	{
		for (new i = 1; i < 5; i++)
		{
			if (clientUpgradesMaxHP[client] == i)
			{
				new hp = GetEntData(client, h_iMaxHealth, 4);
				SetEntData(client, h_iMaxHealth, hp + 20 * i, 4, true);
				SetEntData(client, h_iHealth, hp + 20 * i, 4, true);
			}
			if (clientUpgradesMaxArmor[client] == i)
			{
				new armor = GetEntData(client, h_iMaxArmor, 4);
				SetEntData(client, h_iMaxArmor, armor + 20 * i, 4, true);
				SetEntData(client, h_ArmorValue, armor + 20 * i, 4, true);
			}
			if (clientUpgradesMaxSpeed[client] == i)
			{
				new Float:maxspeed = GetEntData(client, h_flMaxspeed, 4);
				SetEntData(client, h_flMaxspeed, maxspeed + 20 * i, 4, true);
				new Float:defspeed = GetEntData(client, h_flDefaultSpeed, 4);
				SetEntData(client, h_flDefaultSpeed, defspeed + 20 * i, 4, true);
			}
		}
		
		// TODO: remove keg from skirm
		if ( GetClientTeam( client ) == TEAM_PIRATES &&  GetPlayerClass( client ) == PVK2_CLASS_SKIRMISHER )
		{
			
		}
	}
}

public OnPlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	
}

public OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!HasGameStarted || IsLivesDisabled || IsPreparing)
		return;
	
	int victimId = GetEventInt(event, "userid");
	int victim = GetClientOfUserId( victimId );
	
	if (GetPlayerLives(victim) <= 0)
		return;
	
	clientLives[victim]--;
	
	// HACK: Force ragdoll into ghostly one, pls dont patch this devs
	//new ragdoll = GetEntPropEnt(victim, Prop_Send, "m_hRagdoll");
	//SetEntProp(ragdoll, Prop_Send, "m_iDismemberment", 11);
	
	SetEntProp(victim, Prop_Send, "m_iRagdollDismemberment", 11);
	
	// dissolve me because the particle bug is annoying, pls patch it devs
	//CreateTimer(1.5, DissolveRagdoll, victim);

	EmitSoundToAll("noamp/playerdeath.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
	FriendDeadVoice( GetRandomInt( 1, GetClientCount( true ) ), victim );
}

public OnParrotDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!HasGameStarted || IsPreparing)
		return;
	
	new attackerId = GetEventInt(event, "attacker");
	decl String:type[64];
	GetEventString(event, "type", type, sizeof(type));
	
	new attacker = GetClientOfUserId(attackerId);
	new parrotsLeft;
	
	if (StrEqual(type, "npc_parrot", false))
	{
		parrotsKilled++;
		parrotsLeft = waveParrotCount[wave] - parrotsKilled;
		
		if (attacker != 0 && IsClientInGame(attacker))
		{
			clientKills[attacker]++;
			AddMoney(attacker, 10);
			AddSpecial(attacker, 10);
			AddScore(attackerId);
			AddFrags(attacker, 1);
		}
		
		if (IsDebug())
		{
			PrintToServer("Parrots killed: %d", parrotsKilled);
			PrintToServer("Parrots left: %d", parrotsLeft);
		}
	}
}

public OnChestCapture(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!HasGameStarted)
		return;
	
	new userid = GetEventInt(event, "userid");
	new chestid = GetEventInt(event, "chestid");
	new capturer = GetClientOfUserId(userid);
	
	for (new i = 1; i < MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			AddMoney(i, chestAward);
			PrintToChat(i, "You received $%d from chest capture!", chestAward);
		}
	}
	
	AcceptEntityInput(chestid, "kill");
	
	/*
	clientMoney[capturer] += 200;
	PrintToChat(capturer, "You get $200 extra for capturing the chest!");
	*/
}

public AddScore(client)
{
	// HACK: try adding score through event; thanks Spirrwell! :3
	new Handle:event = CreateEvent("player_death", true);
	
	if (event == INVALID_HANDLE)
	{
		ThrowError("AddScore() reports: Event is invalid.");
		return Plugin_Handled;
	}
	
	SetEventInt(event, "userid", -1);
	SetEventInt(event, "attacker", client);
	SetEventBool(event, "special", false);
	SetEventBool(event, "grail", false);
	SetEventBool(event, "suiassist", false);
	SetEventBool(event, "headshot", false);
	
	FireEvent(event, true);
	
	return Plugin_Handled;
}
