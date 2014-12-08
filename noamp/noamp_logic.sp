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

// NOAMP Game Logic

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <morecolors>

public Action:ChangeTeamListener(client, const String:command[], argc)
{
	if (StrEqual(command, "changeteam", false)) // note to self: jointeam is changeteam in pvk, dont mess up... you did that twice baka -.-
	{
		if (!IsEnabled)
			return Plugin_Continue;
		
		if (!IsGameStarted)
			return Plugin_Continue;
		
		if (IsLivesDisabled)
			return Plugin_Continue;
		
		if (client)
		{
			new String:sArg[2];
			
			if (argc)
			{
				GetCmdArgString(sArg, sizeof(sArg));
			}
			
			// check for player lives, block join attempt if none
			if (StrEqual(sArg, "2", false) || StrEqual(sArg, "3", false) || StrEqual(sArg, "4", false) || StrEqual(sArg, "0", false))
			{
				if (!IsGameStarted)
					return Plugin_Continue;
				
				if (clientForcedSpec[client])
				{
					CPrintToChat(client, "{unusual}%s{red} You have to wait for the wave to end before joining teams!", CHAT_PREFIX);
					return Plugin_Handled;
				}
				else if (IsPreparing && clientWantsSpec[client])
				{
					// player wants to join back from spec
					clientWantsSpec[client] = false;
				}
				else if (clientWantsSpec[client])
				{
					CPrintToChat(client, "{unusual}%s{red} You chose to spectate this wave, you can't join teams until it's over.", CHAT_PREFIX);
					return Plugin_Handled;
				}
				else if (GetPlayerLives(client) <= 0)
				{
					CPrintToChat(client, "{unusual}%s{red} No lives left! You can't join teams until the wave is over.", CHAT_PREFIX);
					return Plugin_Handled;
				}
			}
			
			if (StrEqual(sArg, "1", false)) // spec
			{
				if (!IsGameStarted)
					return Plugin_Continue;
				
				// spec autojoin wont affect the players who want to spec
				if (!clientForcedSpec[client])
				{
					clientWantsSpec[client] = true;
					CPrintToChat(client, "{unusual}%s{red} You chose to spectate this wave, you can't join teams until it's over.", CHAT_PREFIX);
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action:ChatListener(client, const String:command[], argc)
{
	// this is just plain evil...
	if (IsCorrupted)
	{
		CorruptionBlockAction(client);
		return Plugin_Handled;
	}
	
	decl String:text[192];
	new startidx = 0;
	
	if (GetCmdArgString(text, sizeof(text)) < 1)
	{
		return Plugin_Continue;
	}
	
	if (text[strlen(text)-1] == '"')
	{
		text[strlen(text)-1] = '\0';
		startidx = 1;
	}
	
	if (strcmp(command, "say2", false) == 0)
		startidx += 4;
	
	if (strcmp(text[startidx], "!menu", false) == 0 || strcmp(text[startidx], "/menu", false) == 0)
	{
		NOAMP_Menu(client);
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action:DropItemListener(client, const String:command[], argc)
{
	if (IsCorrupted)
	{
		CorruptionBlockAction(client);
		return Plugin_Handled;
	}
	
	if (StrEqual(command, "dropitem", false))
	{
		if (!IsEnabled)
			return Plugin_Continue;
		
		if (!IsGameStarted)
			return Plugin_Continue;
		
		if (client)
		{
			if (clientPowerUpFillSpecial[client] > 0)
			{
				ActivatePowerup(client, POWERUP_FILLSPECIAL);
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}

public Action:HUD(Handle:timer)
{
	if (!IsEnabled)
		return Plugin_Stop;
	
	if (waveIsBossWave[wave])
	{
		SetHudTextParams(-1.0, -1.8, 0.3, 255, 0, 0, 255, 0, 0.0, 0.0, 0.0);
	}
	else
	{
		SetHudTextParams(-1.0, -1.8, 0.3, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
	}
	
	if (!IsGameStarted)
	{
		for (new i = 1; i < MaxClients; i++)
		{
			if (IsClientInGame(i) && IsClientConnected(i))
			{
				ShowHudText(i, -1, "NIGHT OF A MILLION PARROTS");
			}
		}
	}
	else
	{
		if (!IsGameOver)
		{
			for (new i = 1; i < MaxClients; i++)
			{
				if (IsClientInGame(i) && IsClientConnected(i))
				{
					if (IsPreparing)
					{
						ShowHudText(i, -1, "Wave %d starts in %d - $%d", wave, GetPreparationSeconds() - preparingSecs, clientMoney[i]);
					}
					else if (IsCorrupted)
					{
						// KtKAXi5ZvDA6hP
						new String:temphudstr[128];
						new String:temphudstr2[128];
						GetRandomString(5, temphudstr);
						GetRandomString(3, temphudstr2);
						ShowHudText(i, -1, "BOSS WA%sE! HP: %d - $%d - Li%sI DID ITves: %d", temphudstr, GetRandomInt(1000, 10000), clientMoney[i], temphudstr2, GetRandomInt(0, 666));
					}
					else if (waveIsBossWave[wave])
					{
						ShowHudText(i, -1, "BOSS WAVE! HP: %d - $%d - Lives: %d", parrotCurrentBossHP, clientMoney[i], clientLives[i]);
					}
					else
					ShowHudText(i, -1, "Wave %d: %d/%d - $%d - Lives: %d", wave, parrotsKilled, waveParrotCount[wave], clientMoney[i], clientLives[i]);
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public StartGame()
{
	ReadNOAMPScript();
	CPrintToChatAll("{unusual}NIGHT OF A MILLION PARROTS %s by {hotpink}Felis", PL_VERSION);
	CPrintToChatAll("{unusual}little late for halloween");
	CPrintToChatAll("{selfmade}Current scheme: %s", schemeName);
	
	IsGameStarted = true;
	IsGameOver = false;
	
	for (new i = 1; i < MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			clientLives[i] = playerLives;
		}
		else
		{
			clientLives[i] = 0;
		}
	}
	
	if (waveIsBossWave[1])
	{
		EmitSoundToAll(NOAMP_BOSSMUSIC, SOUND_FROM_PLAYER, SNDCHAN_STREAM, SNDLEVEL_NORMAL);
		CreateTimer(1.0, BossMusicLooper, _, TIMER_REPEAT);
	}
	
	CreateTimer(0.1, WaveThink, _, TIMER_REPEAT);
	CreateTimer(1.0, ParrotCreator, _, TIMER_REPEAT);
}

public Action:WaveThink(Handle:timer)
{
	if (!IsEnabled)
		return Plugin_Stop;
	
	if (!IsGameStarted)
		return Plugin_Stop;
	
	if (IsPreparing)
		return Plugin_Stop;
	
	if (IsGameOver)
		return Plugin_Stop;
	
	if (!waveIsBossWave[wave])
	{
		if (parrotsKilled >= waveParrotCount[wave])
		{
			WaveFinished();
			return Plugin_Stop;
		}
		parrotSoundPitch = 100;
	}
	
	if (waveIsBossWave[wave])
	{
		decl String:targetname[128];
		for (new i = 0; i < 3000; i++)
		{
			if (IsValidEdict(i) && IsValidEntity(i))
			{
				GetEntPropString(i, Prop_Data, "m_iName", targetname, sizeof(targetname));
				
				if (StrEqual(targetname, "noamp_boss"))
				{
					new hp = GetEntProp(i, Prop_Data, "m_iHealth", 4);
					parrotCurrentBossHP = hp;
					
					if (hp <= 0)
					{
						WaveFinished();
					}
				}
			}	
		}
		parrotSoundPitch = 75;
	}
	
	if (waveIsCorruptorWave[wave])
	{
		if (!IsCorrupted)
		{
			new rng;
			rng = GetRandomInt(1, 100);
			if (rng == 6)
			{
				CreateTimer(1.0, Corruption, _, TIMER_REPEAT);
			}
		}
	}
	
	new clients = 0;
	new dead = 0;
	
	for (new i = 1; i < NOAMP_MAXPLAYERS; i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i))
		{
			clients++;
			if (GetClientTeam(i) == 1)
			{
				dead++;
			}
		}
	}
	
	if (dead >= clients && clients >= 1)
	{
		CreateTimer(1.0, GameOver, _, TIMER_REPEAT);
		EmitSoundToAll("noamp/noamp_gameover.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
		return Plugin_Stop;
	}
	
	// keep checking the clients, if all players disconnect reset the game.	
	if (clients == 0)
	{
		ResetGame(false, false);
		LogAction(-1, -1, "Server is empty, resetting game for new players.");
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public WaveFinished()
{
	PrintCenterTextAll("Wave %d completed!", wave);
	wave++;
	parrotsKilled = 0;
	spawnedParrots = 0;
	giantParrotSpawned = false;
	
	IsPreparing = true;
	
	if (wave > waveCount)
	{
		CreateTimer(1.0, GameWin, _, TIMER_REPEAT);
		return;
	}
	
	for (new i = 1; i < MaxClients; i++)
	{
		new lives = playerLives;
		
		if (lives != 0)
		{
			if (clientLives[i] <= 0)
			{
				if (IsClientInGame(i))
				{
					CPrintToChat(i, "{unusual}%s{lightgreen} The wave has ended and your lives have been restored, join a team to get back in action!", CHAT_PREFIX);
					ClientCommand(i, "teamchange");
				}
			}
			clientLives[i] = playerLives;
		}
		SaveValues(i, false);
		clientForcedSpec[i] = false;
	}
	
	ParrotKiller();
	
	EmitSoundToAll("music/deadparrotachieved.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
	StopMusicAll();
	
	CreateTimer(1.0, PreparingTime, _, TIMER_REPEAT);
}

public Action:GameWin(Handle:timer)
{
	if (gameOverSecs >= 5)
	{
		new game_end = CreateEntityByName("game_end");
		
		if (game_end == -1) 
		{
			ThrowError("Unable to create entity \"game_end\"");
		}
		
		AcceptEntityInput(game_end, "EndGame");
		return Plugin_Stop;
	}
	
	gameOverSecs++;
	IsGameOver = true;
	PrintCenterTextAll("The parrots have been eliminated!! Victory!");
	return Plugin_Continue;
}

public Action:GameOver(Handle:timer)
{
	if (gameOverSecs >= 5)
	{
		for (new i = 1; i < MaxClients; i++)
		{
			new rng = GetRandomInt(1, 3);
			decl String:buffer[32];
			Format(buffer, 32, "changeteam %d", rng);
			ClientCommand(i, buffer);
		}
		gameOverSecs = 0;
		ResetGame(true, true);
		return Plugin_Stop;
	}
	
	gameOverSecs++;
	IsGameOver = true;
	PrintCenterTextAll("Game over! Restarting wave...");
	return Plugin_Continue;
}

public Action:PreparingTime(Handle:timer)
{
	if (waveIsCorruptorWave[wave] && preparingSecs == 1)
	{
		EmitSoundToAll("noamp/corruptor/something.mp3", SOUND_FROM_PLAYER, SNDCHAN_STREAM, SNDLEVEL_NORMAL);
	}
	
	if (preparingSecs >= GetPreparationSeconds() - 5 && preparingSecs != 0)
	{
		if (preparingSecs == GetPreparationSeconds() - 5)
		{
			timerSoundPitch = 80;
		}
		else if (preparingSecs == GetPreparationSeconds() - 4)
		{
			timerSoundPitch = 90;
		}
		else if (preparingSecs == GetPreparationSeconds() - 3)
		{
			timerSoundPitch = 100;
		}
		else if (preparingSecs == GetPreparationSeconds() - 2)
		{
			timerSoundPitch = 110;
		}
		else if (preparingSecs == GetPreparationSeconds() - 1)
		{
			timerSoundPitch = 120;
		}
		else if (preparingSecs == GetPreparationSeconds() - 1)
		{
			timerSoundPitch = 130;
		}
		EmitSoundToAll("noamp/timertick.wav", SOUND_FROM_PLAYER, SNDCHAN_STREAM, SNDLEVEL_NORMAL);
	}
	
	if (preparingSecs >= GetPreparationSeconds())
	{
		// check if there still are players in spectator, force them to join a team so they can't just sit there
		for (new i = 1; i < MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == 1 && clientWantsSpec[i] == false) // unless they want so...
			{
				new lives = playerLives;
				
				if (lives != 0)
				{
					if (clientLives[i] <= 0)
					{
						CPrintToChat(i, "{unusual}%s{lightgreen} Preparation time over, joining random team.", CHAT_PREFIX);
						new rng = GetRandomInt(1, 3);
						decl String:buffer[32];
						Format(buffer, 32, "changeteam %d", rng);
						ClientCommand(i, buffer);
					}
				}
			}
		}
		
		IsPreparing = false;
		CreateTimer(1.0, WaveThink, _, TIMER_REPEAT);
		CreateTimer(1.0, ParrotCreator, _, TIMER_REPEAT);
		preparingSecs = 0;
		timerSoundPitch = 100;
		/*
		if (waveIsFoggy[wave])
		{
			EnableFog();
		}
		else
		{
			DisableFog();
		}
		*/
		if (waveIsBossWave[wave])
		{
			EmitSoundToAll(NOAMP_BOSSMUSIC, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			CreateTimer(1.0, BossMusicLooper, _, TIMER_REPEAT);
		}
		return Plugin_Stop;
	}
	
	preparingSecs++;
	return Plugin_Continue;
}

public Action:ParrotCreator(Handle:timer)
{
	if (!IsGameStarted)
		return Plugin_Stop;
	
	if (IsPreparing)
		return Plugin_Stop;
	
	if (IsGameOver)
		return Plugin_Stop;
	
	decl String:entclass[128];
	new aliveParrots = 0;
	new aliveGiantParrots = 0;
	
	for (new i = 0; i < 3000; i++)
	{
		if (IsValidEdict(i) && IsValidEntity(i))
		{
			GetEdictClassname(i, entclass, 128);
			
			if (StrEqual(entclass, "npc_parrot", false))
			{
				aliveParrots++;
			}
		}
	}
	
	decl String:targetname[128];
	for (new i = 0; i < 3000; i++)
	{
		if (IsValidEdict(i) && IsValidEntity(i))
		{
			GetEntPropString(i, Prop_Data, "m_iName", targetname, sizeof(targetname));
			
			if (StrEqual(targetname, "noamp_giant"))
			{
				aliveGiantParrots++;
			}
		}
	}
	
	if (waveIsBossWave[wave] && !bossParrotSpawned)
	{
		bossParrotSpawned = true;
		SpawnBossParrot();
	}
	
	if (aliveParrots < waveMaxParrots[wave])
	{
		if (spawnedParrots != waveParrotCount[wave])
		{
			spawnedParrots++;
			SpawnParrot();
		}
	}
	
	if (waveGiantParrotCount[wave] != 0 && aliveGiantParrots < waveGiantParrotCount[wave] && !waveIsBossWave[wave] && giantParrotSpawned == false && spawnedParrots != waveParrotCount[wave])
	{
		giantParrotSpawned = true;
		spawnedParrots++;
		SpawnGiantParrot();
	}
	
	return Plugin_Continue;
}

public Action:Corruption(Handle:timer)
{
	// first, save current values
	if (!valuesSaved)
	{
		for (new i = 1; i < MaxClients; i++)
		{
			SaveValues(i, true);
			valuesSaved = true;
		}
	}
	
	if (corruptsecs >= 10)
	{
		for (new i = 1; i < MaxClients; i++)
		{
			RestoreSavedValues(i, true);
		}
		IsCorrupted = false;
		corruptsecs = 0;
		return Plugin_Stop;
	}
	
	// randomize values to create the "corruption" effect
	for (new i = 1; i < MaxClients; i++)
	{
		clientMoney[i] = GetRandomInt(1, 10000);
		clientUpgradesMaxHP[i] = GetRandomBool();
		clientUpgradesMaxArmor[i] = GetRandomBool();
		clientUpgradesMaxSpeed[i] = GetRandomBool();
		clientPowerUpFillSpecial[i] = GetRandomInt(1, 3);
		
		if (IsClientInGame(i) && IsValidEntity(i))
		{
			SetEntData(i, h_iHealth, GetRandomInt(1, 200), 4, true);
			SetEntData(i, h_ArmorValue, GetRandomInt(1, 200), 4, true);
			SetEntData(i, h_flMaxspeed, GetRandomFloat(10.0, 300.0), 4, true);
			SetEntData(i, h_flDefaultSpeed, GetRandomFloat(10.0, 300.0), 4, true);
		}
		
	}
	
	if (corruptsecs == 1)
		EmitSoundToAll("noamp/corruptor/corruption.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS);
	
	IsCorrupted = true;
	corruptsecs++;
	return Plugin_Continue;
}

public CorruptionBlockAction(client)
{
	PrintCenterText(client, "I WON'T LET YOU.");
	EmitSoundToClient(client, "noamp/corruptor/glitch.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS);
}

stock GetRandomBool()
{
	new i = GetRandomInt(0, 1);
	if (i == 0)
		return false;
	else
	return true;
}

public GetRandomString(length, String:dest[])
{
	// this is crappy, but only good for corruption effect ;)
	decl String:charlist[64] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	
	decl String:str[length + 1];
	for (new i = 0; i > length; i++)
	{
		str[i] = charlist[GetRandomInt(0, sizeof(charlist)) - 1];
	}
	strcopy(dest, 256, str);
}

// FIXME: lol, wtf is this
public Action:BossMusicLooper(Handle:timer)
{
	if (waveIsBossWave[wave])
	{
		if (musicSecs >= 273)
		{
			musicSecs = 0;
			EmitSoundToAll(NOAMP_BOSSMUSIC, SOUND_FROM_PLAYER, SNDCHAN_STREAM, SNDLEVEL_NORMAL);
		}
		musicSecs++;
		return Plugin_Continue;
	}
	else
	return Plugin_Stop;
}

public Action:DissolveRagdoll(Handle:timer, any:client)
{
	if (!IsValidEntity(client))
		return;
	
	new hRagdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	
	if (hRagdoll < 0)
	{
		ThrowError("Couldn't get the player's ragdoll.\n");
		return;
	}
	
	decl String:dName[32], String:dType[32];
	Format(dName, sizeof(dName), "dis_%d", client);
	Format(dType, sizeof(dType), "%d", 0);
	
	new ent = CreateEntityByName("env_entity_dissolver");
	if (ent > 0)
	{
		DispatchKeyValue(hRagdoll, "targetname", dName);
		DispatchKeyValue(ent, "dissolvetype", dType);
		DispatchKeyValue(ent, "target", dName);
		AcceptEntityInput(ent, "Dissolve");
		AcceptEntityInput(ent, "kill");
	}
}

public ParrotKiller()
{
	new parrot = INVALID_ENT_REFERENCE;
	new count = 0;
	while ((parrot = FindEntityByClassname(parrot, "npc_parrot")) != INVALID_ENT_REFERENCE) 
	{
		AcceptEntityInput(parrot, "BecomeRagdoll");
		AcceptEntityInput(parrot, "kill");
		count++;
	}
	if (GetConVarBool(cvar_debug))
	{
		PrintToServer("Killed %d parrots.", count);
	}
}

public EnableFog()
{
	new fog = FindEntityByClassname(fog, "env_fog_controller");

	if (fog == -1) 
	{
		fog = CreateEntityByName("env_fog_controller");
	}
	
	AcceptEntityInput(fog, "TurnOn");
}

public DisableFog()
{
	new fog = FindEntityByClassname(fog, "env_fog_controller");
	
	if (fog == -1) 
	{
		fog = CreateEntityByName("env_fog_controller");
	}
	
	AcceptEntityInput(fog, "TurnOff");
}

public BuyUpgrade(client, upgrade)
{
	switch (upgrade)
	{
		case UPGRADE_MAXHP:
		{
			if (clientUpgradesMaxHP[client] == true)
			{
				CPrintToChat(client, "{red}You already have this upgrade!");
			}
			else if (clientMoney[client] >= maxHPPrice)
			{
				clientUpgradesMaxHP[client] = true;
				new hp = GetEntData(client, h_iMaxHealth, 4);
				SetEntData(client, h_iMaxHealth, hp * 2, 4, true);
				SetEntData(client, h_iHealth, hp * 2, 4, true);
				
				clientMoney[client] -= maxHPPrice;
				PlayAmbientSoundFromPlayer(client, "noamp/kaching.mp3");
			}
			else
			{
				CPrintToChat(client, "{red}You don't have enough money! I want %d$.", maxHPPrice);
			}
		}
		case UPGRADE_MAXARMOR:
		{
			if (clientUpgradesMaxArmor[client] == true)
			{
				CPrintToChat(client, "{red}You already have this upgrade!");
			}
			else if (clientMoney[client] >= maxArmorPrice)
			{
				clientUpgradesMaxArmor[client] = true;
				new armor = GetEntData(client, h_iMaxArmor, 4);
				SetEntData(client, h_iMaxArmor, armor * 2, 4, true);
				SetEntData(client, h_ArmorValue, armor * 2, 4, true);
				
				clientMoney[client] -= maxArmorPrice;
				PlayAmbientSoundFromPlayer(client, "noamp/kaching.mp3");
			}
			else
			{
				CPrintToChat(client, "{red}You don't have enough money! I want %d$.", maxArmorPrice);
			}
		}
		case UPGRADE_MAXSPEED:
		{
			if (clientUpgradesMaxSpeed[client] == true)
			{
				CPrintToChat(client, "{red}You already have this upgrade!");
			}
			else if (clientMoney[client] >= maxSpeedPrice)
			{
				clientUpgradesMaxSpeed[client] = true;
				
				new Float:maxspeed = GetEntData(client, h_flMaxspeed, 4);
				SetEntData(client, h_flMaxspeed, maxspeed * 2.0, 4, true);
				
				new Float:defspeed = GetEntData(client, h_flDefaultSpeed, 4);
				SetEntData(client, h_flDefaultSpeed, defspeed * 2.0, 4, true);
				
				clientMoney[client] -= maxSpeedPrice;
				PlayAmbientSoundFromPlayer(client, "noamp/kaching.mp3");
			}
			else
			{
				CPrintToChat(client, "{red}You don't have enough money! I want %d$.", maxSpeedPrice);
			}
		}
		default:
		{
			ThrowError("Attempted to purchase unknown upgrade.");
		}
	}
}

public BuyPowerup(client, powerup)
{
	switch (powerup)
	{
		case POWERUP_FILLSPECIAL:
		{
			if (clientPowerUpFillSpecial[client] >= 3)
			{
				CPrintToChat(client, "{red}You have this powerup filled already! (3 uses)");
			}
			else if (clientMoney[client] >= powerupFillSpecialPrice)
			{
				clientPowerUpFillSpecial[client]++;
				clientMoney[client] -= powerupFillSpecialPrice;
				PlayAmbientSoundFromPlayer(client, "noamp/kaching.mp3");
			}
			else
			{
				CPrintToChat(client, "{red}You don't have enough money! I want %d$.", powerupFillSpecialPrice);
			}
		}
		default:
		{
			ThrowError("Attempted to purchase unknown powerup.");
		}
	}
}

public ActivatePowerup(client, powerup)
{
	switch (powerup)
	{
		case POWERUP_FILLSPECIAL:
		{
			FillSpecial(client);
			clientPowerUpFillSpecial[client]--;
			PlayAmbientSoundFromPlayer(client, "noamp/mystic.mp3");
		}
	}
}

public PlayAmbientSoundFromPlayer(client, String:name[256])
{
	decl Float:entorg[3];
	new index = GetClientOfUserId(client);
	GetEntPropVector(index, Prop_Data, "m_vecOrigin", entorg);
	EmitAmbientSound(name, entorg, SOUND_FROM_WORLD, SNDLEVEL_NORMAL, SND_NOFLAGS);
}

public Action:GiveMoneyToTarget(client, args)
{
	new String:arg1[32];
	new String:arg2[32];
	new amount;
	GetCmdArg(1, arg1, sizeof(arg1));
	
	if (args >= 2 && GetCmdArg(2, arg2, sizeof(arg2)))
	{
		amount = StringToInt(arg2);
	}
	
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
	
	if ((target_count = ProcessTargetString(arg1, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (new i = 0; i < target_count; i++)
	{
		GiveMoney(client, target_list[i], amount);
		LogAction(client, target_list[i], "\"%L\" gave money to \"%L\" (amount %d)", client, target_list[i], amount);
	}
	
	return Plugin_Handled;
}

public GiveMoney(sender, receiver, amount)
{
	if (clientMoney[sender] >= amount)
	{
		clientMoney[receiver] += amount;
		clientMoney[sender] -= amount;
		
		new String:name[128];
		GetClientName(sender, name, 128);
		
		CPrintToChat(receiver, "{lightgreen}You received $%d from %s.", amount, name);
	}
	else
	{
		CPrintToChat(sender, "{red}You don't have enough money to do that!");
	}
}

public BuyWeapon(client, const String:weapon[])
{
	if (StrEqual(weapon, "weapon_powderkeg", false))
	{
		if (clientMoney[client] >= kegPrice)
		{
			Client_GiveWeaponAndAmmo(client, weapon, true, 1, -1, -1, -1);
			clientMoney[client] -= kegPrice;
		}
		else
		{
			CPrintToChat(client, "{red}You don't have enough money! I want %d$.", kegPrice);
		}
	}
	else
	{
		LogError("NOAMP ERROR: Attempted to buy unknown weapon %s. You need to define the weapon in BuyWeapon() first.", weapon);
	}
}

public FillSpecial(client)
{
	SetEntData(client, h_iSpecial, 500, 4);
	EmitSoundToClient(client, "player/special.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS);
}

public GetPreparationSeconds()
{
	new secs = preparationSecs;
	
	if (secs != 0)
		return secs;
	else
	return 0;
}

public GetPlayerKills(client)
{
	return clientKills[client];
}

public GetPlayerLives(client)
{
	return clientLives[client];
}

public GetPlayerMoney(client)
{
	return clientMoney[client];
}

public GetPlayerClass(client)
{
	return GetEntData(client, h_iPlayerClass, 4);
}

public StopMusicAll()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			StopSound(i, SNDCHAN_STREAM, NOAMP_BOSSMUSIC);
		}
	}
}

public ForceJoinSpec(client)
{
	clientForcedSpec[client] = true;
	ClientCommand(client, "changeteam 1");
}

public ResetGame(bool:gameover, bool:startgame)
{	
	IsGameStarted = false;
	IsGameOver = false;
	IsPreparing = false;
	IsCorrupted = false;
	parrotsKilled = 0;
	spawnedParrots = 0;
	giantParrotSpawned = false;
	bossParrotSpawned = false;
	
	if (!gameover)
		wave = 1;
	
	playerLives = 0;
	maxHPPrice = 0;
	maxArmorPrice = 0;
	maxSpeedPrice = 0;
	kegPrice = 0;
	chestAward = 0;
	preparationSecs = 0;
	giantParrotSize = 0.0;
	bossParrotSize = 0.0;
	powerupFillSpecialPrice = 0;
	
	waveCount = 0;
	deadplayers = 0;
	preparingSecs = 0;
	gameOverSecs = 0;
	musicSecs = 0;
	
	corruptsecs = 0;
	soundplayed = false;
	valuesSaved = false;
	
	ParrotKiller();
	ResetSpawns();
	ResetWaves();
	ReadNOAMPScript();
	StopMusicAll();
	
	for (new i = 1; i < MaxClients; i++)
	{
		if (gameover)
			ResetClient(i, true);
		else
		ResetClient(i, false);
	}
	
	if (startgame)
		StartGame();
}

public ResetClient(client, bool:gameover)
{
	if (gameover)
	{
		RestoreSavedValues(client, false);
		clientWantsSpec[client] = false;
		clientForcedSpec[client] = false;
	}
	else
	{
		clientLives[client] = 0;
		clientKills[client] = 0;
		clientMoney[client] = 0;
		clientUpgradesMaxHP[client] = false;
		clientUpgradesMaxArmor[client] = false;
		clientUpgradesMaxSpeed[client] = false;
		clientWantsSpec[client] = false;
		clientForcedSpec[client] = false;
	}
}

public SaveValues(client, bool:corruption)
{
	if (corruption)
	{
		clientSavedMoney[client] = clientMoney[client];
		clientSavedUpgradesMaxHP[client] = clientUpgradesMaxHP[client];
		clientSavedUpgradesMaxArmor[client] = clientUpgradesMaxArmor[client];
		clientSavedUpgradesMaxSpeed[client] = clientUpgradesMaxSpeed[client];
		clientSavedPowerUpFillSpecial[client] = clientPowerUpFillSpecial[client];
		
		if (IsClientInGame(client) && IsValidEntity(client))
		{
			clientSavedHP[client] = GetEntData(client, h_iHealth, 4);
			clientSavedArmorValue[client] = GetEntData(client, h_ArmorValue, 4);
			clientSavedMaxspeed[client] = GetEntData(client, h_flMaxspeed, 4);
			clientSavedDefaultSpeed[client] = GetEntData(client, h_flDefaultSpeed, 4);
		}
	}
	else
	{
		clientSavedMoney[client] = clientMoney[client];
		clientSavedUpgradesMaxHP[client] = clientUpgradesMaxHP[client];
		clientSavedUpgradesMaxArmor[client] = clientUpgradesMaxArmor[client];
		clientSavedUpgradesMaxSpeed[client] = clientUpgradesMaxSpeed[client];
		clientSavedPowerUpFillSpecial[client] = clientPowerUpFillSpecial[client];
	}
}

public RestoreSavedValues(client, bool:corruption)
{
	if (corruption)
	{
		clientMoney[client] = clientSavedMoney[client];
		clientUpgradesMaxHP[client] = clientSavedUpgradesMaxHP[client];
		clientUpgradesMaxArmor[client] = clientSavedUpgradesMaxArmor[client];
		clientUpgradesMaxSpeed[client] = clientSavedUpgradesMaxSpeed[client];
		clientPowerUpFillSpecial[client] = clientSavedPowerUpFillSpecial[client];
		
		if (IsClientInGame(client) && IsValidEntity(client))
		{
			SetEntData(client, h_iHealth, clientSavedHP[client], 4, true);
			SetEntData(client, h_ArmorValue, clientSavedArmorValue[client], 4, true);
			SetEntData(client, h_flMaxspeed, clientSavedMaxspeed[client], 4, true);
			SetEntData(client, h_flDefaultSpeed, clientSavedDefaultSpeed[client], 4, true);
		}
	}
	else
	{
		clientMoney[client] = clientSavedMoney[client];
		clientUpgradesMaxHP[client] = clientSavedUpgradesMaxHP[client];
		clientUpgradesMaxArmor[client] = clientSavedUpgradesMaxArmor[client];
		clientUpgradesMaxSpeed[client] = clientSavedUpgradesMaxSpeed[client];
		clientPowerUpFillSpecial[client] = clientSavedPowerUpFillSpecial[client];
	}
}

public ResetWaves()
{
	for (new i = 1; i < NOAMP_MAXWAVES; i++)
	{
		waveParrotCount[i] = 0;
		waveGiantParrotCount[i] = 0;
		waveMaxParrots[i] = 0;
		waveIsBossWave[i] = false;
		waveIsCorruptorWave[i] = false;
	}
}