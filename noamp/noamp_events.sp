// NOAMP Events

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <morecolors>

public Event_WaitEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsEnabled)
		return;
	
	PrintToChatAll("%s The game is starting!", CHAT_PREFIX);
	IsWaitingForPlayers = false;
	StartGame();
}

public OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsGameStarted)
		return;
	
	new userid = GetEventInt(event, "userid");
	new client = GetClientOfUserId(userid);
	
	RequestGroupStatus(client);
	
	if (clientLives[client] <= 0)
	{
		if (IsLivesDisabled)
			return;
		
		// should not spawn, force join spec
		ClientCommand(client, "changeteam 1");
		PrintToChat(client, "%s No lives left! You have been moved to spec.", CHAT_PREFIX);
	}
	else
	{
		if (clientUpgradesMaxHP[client] == true)
		{
			clientUpgradesMaxHP[client] = true;
			new hp = GetEntData(client, h_iMaxHealth, 4);
			SetEntData(client, h_iMaxHealth, hp * 2, 4, true);
			SetEntData(client, h_iHealth, hp * 2, 4, true);
		}
		
		if (clientUpgradesMaxArmor[client] == true)
		{
			clientUpgradesMaxArmor[client] = true;
			new armor = GetEntData(client, h_iMaxArmor, 4);
			SetEntData(client, h_iMaxArmor, armor * 2, 4, true);
			SetEntData(client, h_ArmorValue, armor * 2, 4, true);
		}
		
		if (clientUpgradesMaxSpeed[client] == true)
		{
			clientUpgradesMaxSpeed[client] = true;
			new Float:maxspeed = GetEntData(client, h_flMaxspeed, 4);
			SetEntData(client, h_flMaxspeed, maxspeed * 2.0, 4, true);
			new Float:defspeed = GetEntData(client, h_flDefaultSpeed, 4);
			SetEntData(client, h_flDefaultSpeed, defspeed * 2.0, 4, true);
		}
		
		// TODO: remove keg from skirm
		if (GetPlayerClass(client) == CLASS_SKIRMISHER)
		{
			
		}
	}
}

public OnPlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetEventInt(event, "attacker");
	new attackerid = GetClientOfUserId(attacker);
	
	if (Entity_IsPlayer(attacker))
	{
		clientOldHP[client] = GetClientHealth(client);
		//new damage = clientOldHP[client] - GetClientHealth(client);
		SetEntData(client, h_iHealth, clientOldHP[client], 4, true);
	}
}

public OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsGameStarted)
		return;
	
	if (IsLivesDisabled)
		return;
	
	if (IsPreparing)
		return;
	
	new victimId = GetEventInt(event, "userid");
	new victim = GetClientOfUserId(victimId);
	
	if (GetPlayerLives(victim) <= 0)
		return;
	
	clientLives[victim] -= 1;
	
	EmitSoundToAll("noamp/playerdeath.mp3", SOUND_FROM_PLAYER, SNDCHAN_STREAM, SNDLEVEL_NORMAL);
}

public OnParrotDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsGameStarted)
		return;
	
	if (IsPreparing)
		return;
	
	new attackerId = GetEventInt(event, "attacker");
	decl String:type[64];
	GetEventString(event, "type", type, sizeof(type));
	
	new attacker = GetClientOfUserId(attackerId);
	new attackerFrags = GetClientFrags(attacker);
	new parrotsLeft;
	
	new specialValue = GetEntData(attacker, h_iSpecial, 4);
	
	if (StrEqual(type, "npc_parrot", false))
	{
		parrotsKilled++;
		parrotsLeft = waveParrotCount[wave] - parrotsKilled;
		
		clientKills[attacker] += 1;
		clientMoney[attacker] += 10;
		
		specialValue += 10;
		SetEntData(attacker, h_iSpecial, specialValue, 4);
		
		AddScore(attackerId, 1);
		
		attackerFrags += 1;
		SetEntProp(attacker, Prop_Data, "m_iFrags", attackerFrags);
		
		if (GetConVarBool(cvar_debug))
		{
			PrintToServer("Parrots killed: %d", parrotsKilled);
			PrintToServer("Parrots left: %d", parrotsLeft);
		}
	}
}

public OnChestCapture(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsGameStarted)
		return;
	
	new userid = GetEventInt(event, "userid");
	new chestid = GetEventInt(event, "chestid");
	new capturer = GetClientOfUserId(userid);
	
	for (new i = 1; i < MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			clientMoney[i] += chestAward;
			PrintToChat(i, "You received $%d from chest capture!", chestAward);
		}
	}
	
	AcceptEntityInput(chestid, "kill");
	
	/*
	clientMoney[capturer] += 200;
	PrintToChat(capturer, "You get $200 extra for capturing the chest!");
	*/
}

public AddScore(client, amount)
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
	
	for (new i = 0; i < amount; i++)
	{
		FireEvent(event, true);
	}
	
	return Plugin_Handled;
}