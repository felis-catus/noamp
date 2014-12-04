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
			if (StrEqual(sArg, "2", false) || StrEqual(sArg, "3", false) || StrEqual(sArg, "4", false))
			{
				if (GetPlayerLives(client) <= 0)
				{
					CPrintToChat(client, "{unusual}%s{red} No lives left! You can't join teams until the wave is over.", CHAT_PREFIX);
					return Plugin_Handled;
				}
			}
			
			if (StrEqual(sArg, "0", false)) // auto-assign
			{
				if (GetPlayerLives(client) <= 0)
				{
					CPrintToChat(client, "{unusual}%s{red} No lives left! You can't join teams the until wave is over.", CHAT_PREFIX);
					return Plugin_Handled;
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action:ChatListener(client, const String:command[], argc)
{
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
	return Plugin_Handled;
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
	wave = 1;
	
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
	/*
	for (new i = 1; i < MAXPLAYERS; i++)
	{
	if (clientLives[i] <= 0)
	{
	deadplayers++;
	}
	else if (!IsClientInGame(i))
	{
	deadplayers++;
	}
	}
	
	if (deadplayers == NOAMP_MAXPLAYERS)
	{
	CreateTimer(1.0, GameOver, _, TIMER_REPEAT);
	EmitSoundToAll("noamp/noamp_gameover.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
	return Plugin_Stop;
	}
	*/
	// keep checking the clients, if all players disconnect reset the game.
	new clients = 0;
	for (new i = 1; i < MaxClients; i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i))
		{
			clients++;
		}
	}
	
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
			clientSavedMoney[i] = clientMoney[i];
		}
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
	if (preparingSecs >= GetPreparationSeconds())
	{
		IsPreparing = false;
		CreateTimer(1.0, WaveThink, _, TIMER_REPEAT);
		CreateTimer(1.0, ParrotCreator, _, TIMER_REPEAT);
		preparingSecs = 0;
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
	while ((parrot = FindEntityByClassname(parrot, "npc_parrot")) != INVALID_ENT_REFERENCE) 
	{
		AcceptEntityInput(parrot, "kill");
	}
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
	EmitAmbientSound(name, entorg, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
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
	ClientCommand(client, "playgamesound player/special.wav");
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

public ResetGame(bool:gameover, bool:startgame)
{	
	IsGameStarted = false;
	IsGameOver = false;
	IsPreparing = false;
	parrotsKilled = 0;
	spawnedParrots = 0;
	giantParrotSpawned = false;
	bossParrotSpawned = false;
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
	
	waveCount = 0;
	deadplayers = 0;
	preparingSecs = 0;
	
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
		clientLives[client] = 0;
		clientKills[client] = 0;
		clientMoney[client] = clientSavedMoney[client];
		clientUpgradesMaxHP[client] = false;
		clientUpgradesMaxArmor[client] = false;
		clientUpgradesMaxSpeed[client] = false;
	}
	else
	{
		clientLives[client] = 0;
		clientKills[client] = 0;
		clientMoney[client] = 0;
		clientUpgradesMaxHP[client] = false;
		clientUpgradesMaxArmor[client] = false;
		clientUpgradesMaxSpeed[client] = false;
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
	}
}