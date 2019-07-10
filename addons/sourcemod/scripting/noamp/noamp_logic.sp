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
#include <morecolors>

// remember to comment
//#include "noamp_defs.sp"
//#include "noamp_funcs.sp"

#pragma newdecls required

public Action ChangeTeamListener( int client, const char[] command, int argc )
{
	if ( StrEqual( command, "changeteam", false ) ) // note to self: jointeam is changeteam in pvk, dont mess up... you did that twice baka -.-
	{
		if ( !g_bIsEnabled || !g_bHasGameStarted || IsLivesDisabled )
			return Plugin_Continue;
		
		if ( client )
		{
			char sArg[ 2 ];
			
			if ( argc )
			{
				GetCmdArgString( sArg, sizeof( sArg ) );
			}
			
			// check for player lives, block join attempt if none
			if ( StrEqual( sArg, "2", false ) || StrEqual( sArg, "3", false ) || StrEqual( sArg, "4", false ) || StrEqual( sArg, "0", false ) )
			{				
				if ( clientForcedSpec[ client ] )
				{
					CPrintToChat( client, "{unusual}%s{red} You have to wait for the wave to end before joining teams!", CHAT_PREFIX );
					return Plugin_Handled;
				}
				else if ( IsPreparing && clientWantsSpec[ client ] )
				{
					// player wants to join back from spec
					clientWantsSpec[ client ] = false;
				}
				else if ( clientWantsSpec[ client ] )
				{
					CPrintToChat( client, "{unusual}%s{red} You chose to spectate this wave, you can't join teams until it's over.", CHAT_PREFIX );
					return Plugin_Handled;
				}
				else if ( GetPlayerLives( client ) <= 0 )
				{
					CPrintToChat( client, "{unusual}%s{red} No lives left! You can't join teams until the wave is over.", CHAT_PREFIX );
					return Plugin_Handled;
				}
			}
			
			if ( StrEqual( sArg, "2", false ) ) // pirates
			{
				clientLastestTeam[ client ] = TEAM_PIRATES;
			}
			if ( StrEqual( sArg, "3", false ) ) // vikings
			{
				clientLastestTeam[ client ] = TEAM_VIKINGS;
			}
			if ( StrEqual( sArg, "4", false ) ) // knights
			{
				clientLastestTeam[ client ] = TEAM_KNIGHTS;
			}
			
			if ( StrEqual( sArg, "1", false ) ) // spec
			{
				// spec autojoin wont affect the players who want to spec
				if ( !clientForcedSpec[ client ] )
				{
					clientWantsSpec[ client ] = true;
					CPrintToChat( client, "{unusual}%s{red} You chose to spectate this wave, you can't join teams until it's over.", CHAT_PREFIX );
				}
			}
		}
	}

	return Plugin_Continue;
}

public Action ChatListener( int client, const char[] command, int argc )
{
	// ignore specs
	if ( GetClientTeam( client ) <= TEAM_SPECTATOR )
		return Plugin_Continue;
	
	// this is just plain evil...
	if ( IsCorrupted )
	{
		CorruptionBlockAction( client );
		return Plugin_Handled;
	}
	
	char text[ 192 ];
	int startidx = 0;
	
	if ( GetCmdArgString( text, sizeof( text ) ) < 1 )
	{
		return Plugin_Continue;
	}
	
	if ( text[ strlen( text ) - 1 ] == '"' )
	{
		text[ strlen( text ) - 1 ] = '\0';
		startidx = 1;
	}
	
	if ( strcmp( command, "say2", false ) == 0 )
		startidx += 4;
	
	if ( strcmp( text[ startidx ], "!menu", false ) == 0 || strcmp( text[ startidx ], "/menu", false ) == 0 )
	{
		NOAMP_Menu( client );
		return Plugin_Handled;
	}
	
	// whiskeyngton dont look at this
	if ( strcmp( text[ startidx ], "fuck you felis", false ) == 0 )
	{
		PrintToChat( client, "Don't be rude. :(" );
	}
	
	return Plugin_Continue;
}

// this is used as powerup activation command
public Action DropItemListener( int client, const char[] command, int argc )
{
	if ( IsCorrupted )
	{
		CorruptionBlockAction( client );
		return Plugin_Handled;
	}
	
	if ( StrEqual( command, "dropitem", false ) )
	{
		if ( !g_bIsEnabled || !g_bHasGameStarted )
			return Plugin_Continue;
		
		if ( client )
		{
			if ( clientHasVulturesOut[ client ] )
			{
				if ( clientAboutToKillVultures[ client ] )
				{
					CPrintToChat( client, "{red}Killing your vultures..." );
					clientAboutToKillVultures[ client ] = false;
					h_TimerKillVultures = CreateTimer( 0.1, KillVultures, client, TIMER_FLAG_NO_MAPCHANGE );
					return Plugin_Handled;
				}
				
				CPrintToChat( client, "{red}You already have your vultures out! Press again to kill your birds!" );
				clientAboutToKillVultures[ client ] = true;
				return Plugin_Handled;
			}
			if ( clientPowerUpFillSpecial[ client ] > 0 )
			{
				ActivatePowerup( client, POWERUP_FILLSPECIAL );
				return Plugin_Handled;
			}
			else if ( clientPowerUpVultures[ client ] > 0 )
			{
				ActivatePowerup( client, POWERUP_VULTURES );
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}

public Action HUD( Handle timer )
{
	if ( !g_bIsEnabled )
		return Plugin_Stop;
	
	int r;
	int g;
	int b;
	
	if ( IsCorrupted )
	{
		r = GetRandomInt( 0, 255 );
		g = GetRandomInt( 0, 255 );
		b = GetRandomInt( 0, 255 );
		SetHudTextParams( -1.0, -1.8, 0.3, r, g, b, 255, 0, 0.0, 0.0, 0.0 );
	}
	else if ( waveIsBossWave[ wave ] )
	{
		r = 255;
		g = 0;
		b = 0;
		SetHudTextParams( -1.0, -1.8, 0.3, r, g, b, 255, 0, 0.0, 0.0, 0.0 );
	}
	else
	{
		r = 255;
		g = 255;
		b = 255;
		SetHudTextParams( -1.0, -1.8, 0.3, r, g, b, 255, 0, 0.0, 0.0, 0.0 );
	}
	
	if ( !g_bHasGameStarted )
	{
		for ( int i = 1; i <= MaxClients; i++ )
		{
			if ( IsClientInGame( i ) && IsClientConnected( i ) )
			{
				if ( IsWaitingForPlayers )
				{
					ShowHudText( i, -1, "Game starts in %d", GetPreparationSeconds() - preparingSecs );
				}
				else
				{
					ShowHudText( i, -1, "NIGHT OF A MILLION PARROTS" );
				}
			}
		}
	}
	else
	{
		if ( !IsGameOver )
		{
			for ( int i = 1; i <= MaxClients; i++ )
			{
				if ( IsClientInGame( i ) && IsClientConnected( i ) )
				{
					if ( IsPreparing )
					{
						ShowHudText( i, -1, "Wave %d starts in %d - $%d", wave, GetPreparationSeconds() - preparingSecs, clientMoney[ i ] );
					}
					else if ( IsCorrupted )
					{
						// KtKAXi5ZvDA6hP
						GetRandomString( 5, temphudstr );
						GetRandomString( 5, temphudstr2 );
						//PrintToServer("%s, %s", temphudstr, temphudstr2);
						ShowHudText( i, -1, "BOSS WA%sE! HP: %d - $%d - Li%sI DID ITves: %d", temphudstr, GetRandomInt( 1000, 10000 ), clientMoney[ i ], temphudstr2, GetRandomInt( 0, 666 ) );
					}
					else if ( waveIsBossWave[ wave ] )
					{
						ShowHudText( i, -1, "BOSS WAVE! HP: %d - $%d - Lives: %d", parrotCurrentBossHP, clientMoney[ i ], clientLives[ i ] );
					}
					else
						ShowHudText( i, -1, "Wave %d: %d/%d - $%d - Lives: %d", wave, parrotsKilled, waveTotalParrotCount[ wave ], clientMoney[ i ], clientLives[ i ] );
				}
			}
		}
	}

	return Plugin_Continue;
}

public Action WaitingForPlayers( Handle timer )
{
	int clients = 0;
	
	for ( int i = 1; i <= MaxClients; i++ )
	{
		if ( IsClientConnected( i ) && IsClientInGame( i ) && GetClientTeam( i ) > TEAM_SPECTATOR )
		{
			clients++;
		}
	}
	
	if ( clients >= 1 )
	{
		h_TimerPreparingTime = CreateTimer( 1.0, PreparingTime, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE );
		IsWaitingForPlayers = true;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action HintMessage( Handle timer )
{
	CPrintToChatAll( "{unusual}%s{darkgoldenrod}To access the buy menu, type !menu OR bind \"noamp_menu\" to a key.", CHAT_PREFIX );
}

public void StartGame()
{
	ReadNOAMPScript();
	CPrintToChatAll( "{unusual}NIGHT OF A MILLION PARROTS %s by {hotpink}Felis", PL_VERSION );
	CPrintToChatAll( "{unusual}\"little late for halloween\"" );
	CPrintToChatAll( "{selfmade}Current scheme: %s", schemeName );
	
	g_bHasGameStarted = true;
	IsGameOver = false;
	
	for ( int i = 1; i <= MaxClients; i++ )
	{
		if ( IsClientInGame( i ) )
		{
			clientLives[ i ] = playerLives;
		}
		else
		{
			clientLives[ i ] = 0;
		}
		clientForcedSpec[ i ] = false;
	}
	
	if ( waveIsBossWave[ 1 ] )
	{
		EmitSoundToAll( NOAMP_BOSSMUSIC, SOUND_FROM_PLAYER, SNDCHAN_STREAM, SNDLEVEL_NORMAL );
		h_TimerBossMusicLooper = CreateTimer( 1.0, BossMusicLooper, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE );
	}
	
	WaveStart();
}

public Action WaveThink( Handle timer )
{
	if ( !g_bIsEnabled || !g_bHasGameStarted || IsPreparing || IsGameOver )
		return Plugin_Stop;
	
	if ( !waveIsBossWave[ wave ] )
	{
		if ( KilledParrots.Total >= waveTotalParrotCount[ wave ] )
		{
			WaveFinished();
			return Plugin_Stop;
		}
	}
	
	if ( waveIsBossWave[ wave ] )
	{
		char targetname[ 128 ];
		int curParrot = -1;
		
		while ( ( curParrot = FindEntityByClassname( curParrot, "npc_parrot" ) ) != -1 )
		{
			GetEntPropString( curParrot, Prop_Data, "m_iName", targetname, sizeof( targetname ) );
			
			if ( StrEqual( targetname, "noamp_boss" ) )
			{
				int hp = GetEntProp( curParrot, Prop_Data, "m_iHealth" );
				parrotCurrentBossHP = hp;
				
				if ( hp <= 0 )
				{
					WaveFinished();
				}
			}
		}
	}
	
	int clients = 0;
	int dead = 0;
	
	// we consider specs/unassigned as dead players...
	for ( int i = 1; i <= MaxClients; i++ )
	{
		if ( IsClientConnected( i ) && IsClientInGame( i ) )
		{
			clients++;
			if ( GetClientTeam( i ) <= TEAM_SPECTATOR )
			{
				dead++;
			}
		}
	}
	
	if ( dead >= clients && clients >= 1 )
	{
		h_TimerGameOver = CreateTimer( 1.0, GameOver, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE );
		EmitSoundToAll( "noamp/gameover.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL );
		return Plugin_Stop;
	}
	
	// keep checking the clients, if all players disconnect reset the game.	
	if ( clients == 0 )
	{
		ResetGame( false, false );
		LogAction( -1, -1, "Server is empty, resetting game for new players." );
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public void WaveFinished()
{
	PrintCenterTextAll( "Wave %d completed!", wave );

	if ( waveIsBossWave[ wave ] )
		OnBossWaveEnd();

	wave++;
	parrotsKilled = 0;
	spawnedParrots = 0;
	giantParrotSpawned = false;
	
	IsPreparing = true;
	HasWaveStarted = false;
	
	if ( wave > waveCount )
	{
		h_TimerGameWin = CreateTimer( 1.0, GameWin, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE );
		return;
	}
	
	for ( int i = 1; i <= MaxClients; i++ )
	{
		int lives = playerLives;
		
		if ( lives != 0 )
		{
			if ( clientLives[ i ] <= 0 )
			{
				if ( IsClientInGame( i ) )
				{
					CPrintToChat( i, "{unusual}%s{lightgreen} The wave has ended and your lives have been restored, join a team to get back in action!", CHAT_PREFIX );
					ClientCommand( i, "teamchange" );
				}
			}
			clientLives[ i ] = playerLives;
		}

		SaveValues( i, false );
		clientForcedSpec[ i ] = false;
	}
	
	ParrotKiller();
	VultureKiller();

	// Make sure we do this after ParrotKiller()
	KilledParrots.Small = 0;
	KilledParrots.Normal = 0;
	KilledParrots.Giant = 0;
	KilledParrots.Boss = 0;
	KilledParrots.Total = 0;
	
	EmitSoundToAll( "music/deadparrotachieved.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL );
	StopMusicAll();
	
	h_TimerPreparingTime = CreateTimer( 1.0, PreparingTime, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE );
}

public Action CorruptorThink( Handle timer )
{
	if ( IsCorrupted )
	{
		char targetname[ 128 ];
		int curParrot = -1;
		
		while ( ( curParrot = FindEntityByClassname( curParrot, "npc_parrot" ) ) != -1 )
		{
			GetEntPropString( curParrot, Prop_Data, "m_iName", targetname, sizeof( targetname ) );
			
			if ( StrEqual( targetname, "noamp_boss" ) )
				SetEntityRenderColor( curParrot, GetRandomInt( 0, 255 ), GetRandomInt( 0, 255 ), GetRandomInt( 0, 255 ), 255 );
		}
	}
	else if ( !IsCorrupted )
	{
		int rng = GetRandomInt( 1, 25 );
		if ( rng == 6 )
		{
			h_TimerCorruption = CreateTimer( 1.0, Corruption, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE );
			//ReadParrotCreatorScript(3);
		}
		
		char targetname[ 128 ];
		int curParrot = -1;

		while ( ( curParrot = FindEntityByClassname( curParrot, "npc_parrot" ) ) != -1 )
		{
			GetEntPropString( curParrot, Prop_Data, "m_iName", targetname, sizeof( targetname ) );
			
			if ( StrEqual( targetname, "noamp_boss" ) )
				SetEntityRenderColor( curParrot, 0, 0, 0, 255 );
		}
	}

	return Plugin_Continue;
}

public Action GameWin( Handle timer )
{	
	if ( gameOverSecs >= 5 )
	{
		EndGame();
	}
	
	gameOverSecs++;
	IsGameOver = true;
	PrintCenterTextAll( "The parrots have been eliminated!! Victory!" );
	return Plugin_Continue;
}

public Action GameOver( Handle timer )
{	
	if ( gameOverSecs >= 5 )
	{
		for ( int i = 1; i <= MaxClients; i++ )
		{
			if ( IsClientInGame( i ) )
			{
				ChangeClientTeam( i, clientLastestTeam[ i ] );
			}
		}
		
		gameOverSecs = 0;
		ResetGame( true, true );
		return Plugin_Stop;
	}
	
	gameOverSecs++;
	IsGameOver = true;
	PrintCenterTextAll( "Game over! Restarting wave..." );
	return Plugin_Continue;
}

public void EndGame()
{
	int game_end = CreateEntityByName( "game_end" );
	
	if ( game_end == -1 ) 
	{
		ThrowError( "Unable to create entity \"game_end\"" );
	}
	
	AcceptEntityInput( game_end, "EndGame" );
	
	// restore mp_timelimit
	SetConVarInt( cvar_timelimit, timelimitSavedValue );
}

public Action PreparingTime( Handle timer )
{
	if ( waveIsCorruptorWave[ wave ] && preparingSecs == 1 )
	{
		EmitSoundToAll( "noamp/corruptor/something.mp3", SOUND_FROM_PLAYER, SNDCHAN_STREAM, SNDLEVEL_NORMAL );
	}
	
	if ( preparingSecs == GetPreparationSeconds() - 10 )
	{
		PlayRandomSpookySound();
	}
	
	if ( preparingSecs >= GetPreparationSeconds() - 5 && preparingSecs != 0 )
	{
		if ( preparingSecs == GetPreparationSeconds() - 5 )
		{
			timerSoundPitch = 80;
		}
		else if ( preparingSecs == GetPreparationSeconds() - 4 )
		{
			timerSoundPitch = 90;
		}
		else if ( preparingSecs == GetPreparationSeconds() - 3 )
		{
			timerSoundPitch = 100;
		}
		else if ( preparingSecs == GetPreparationSeconds() - 2 )
		{
			timerSoundPitch = 110;
		}
		else if ( preparingSecs == GetPreparationSeconds() - 1 )
		{
			timerSoundPitch = 120;
		}
		else if ( preparingSecs == GetPreparationSeconds() )
		{
			timerSoundPitch = 130;
		}

		EmitSoundToAll( "noamp/timertick.wav", SOUND_FROM_PLAYER, SNDCHAN_STREAM, SNDLEVEL_NORMAL );
	}
	
	if ( preparingSecs >= GetPreparationSeconds() )
	{
		if ( !g_bHasGameStarted )
			StartGame()
		else
			WaveStart();

		return Plugin_Stop;
	}
	
	preparingSecs++;
	return Plugin_Continue;
}

public void OnBossWaveBegin()
{
	int curEnt = -1;
	char targetname[ MAX_TARGET_LENGTH ];

	while ( ( curEnt = FindEntityByClassname( curEnt, "logic_relay" ) ) != -1 )
	{
		GetEntPropString( curEnt, Prop_Data, "m_iName", targetname, sizeof( targetname ) );
		
		if ( StrContains( targetname, "onbosswavebegin", false ) == 0 )
		{
			AcceptEntityInput( curEnt, "Trigger" );
		}
	}
}

public void OnBossWaveEnd()
{
	int curEnt = -1;
	char targetname[ MAX_TARGET_LENGTH ];

	while ( ( curEnt = FindEntityByClassname( curEnt, "logic_relay" ) ) != -1 )
	{
		GetEntPropString( curEnt, Prop_Data, "m_iName", targetname, sizeof( targetname ) );
		
		if ( StrContains( targetname, "onbosswaveend", false ) == 0 )
		{
			AcceptEntityInput( curEnt, "Trigger" );
		}
	}
}

public void WaveStart()
{
	if ( waveIsCorruptorWave[ wave ] )
	{
		h_TimerCorruptorThink = CreateTimer( 1.0, CorruptorThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE );
	}
	
	if ( waveIsBossWave[ wave ] )
		OnBossWaveBegin();
	
	// check if there still are players in spectator, force them to join a team so they can't just sit there
	for ( int i = 1; i <= MaxClients; i++ )
	{
		if ( IsClientInGame( i ) && GetClientTeam( i ) == TEAM_SPECTATOR && !clientWantsSpec[ i ] ) // unless they want so...
		{
			int lives = playerLives;
			
			if ( lives != 0 )
			{
				if ( clientLives[ i ] <= 0 )
				{
					CPrintToChat( i, "{unusual}%s{lightgreen} Preparation time over, joining random team.", CHAT_PREFIX );
					ChangeClientTeam( i, GetRandomInt( TEAM_PIRATES, TEAM_KNIGHTS ) );
				}
			}
		}
		
		if ( IsClientInGame( i ) )
		{				
			int iTeam = GetEntProp( i, Prop_Data, "m_iTeamNum" );
			int iClass = GetPlayerClass( i );
			Handle datapack;
			CreateDataTimer( GetRandomFloat( 1.0, 4.0 ), RoundStartCheer, datapack );
			WritePackCell( datapack, i );
			WritePackCell( datapack, iTeam );
			WritePackCell( datapack, iClass );
		}
	}
	
	IsPreparing = false;
	HasWaveStarted = true;
	h_TimerWaveThink = CreateTimer( 0.1, WaveThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE );
	h_TimerParrotCreator = CreateTimer( 1.0, ParrotCreator, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE );
	preparingSecs = 0;
	timerSoundPitch = 100;

	if ( waveIsFoggy[ wave ] )
	{
		EnableFog();
	}
	else
	{
		DisableFog();
	}
	
	if ( waveIsBossWave[ wave ] )
	{
		EmitSoundToAll( NOAMP_BOSSMUSIC, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL );
		h_TimerBossMusicLooper = CreateTimer( 1.0, BossMusicLooper, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE );
	}
}

public Action ParrotCreator( Handle timer )
{
	if ( !g_bHasGameStarted || IsPreparing || IsGameOver )
		return Plugin_Stop;
	
	if ( waveIsBossWave[ wave ] && !bossParrotSpawned )
	{
		bossParrotSpawned = true;
		SpawnBossParrot( waveIsCorruptorWave[ wave ] );
	}

	if ( AliveParrots.Small < waveMaxSmallParrots[ wave ] && spawnedParrots != waveTotalParrotCount[ wave ] && KilledParrots.Small < waveSmallParrotCount[ wave ] )
	{
		spawnedParrots++;
		SpawnSmallParrot();
	}

	if ( AliveParrots.Normal < waveMaxNormalParrots[ wave ] && spawnedParrots != waveTotalParrotCount[ wave ] && KilledParrots.Normal < waveNormalParrotCount[ wave ] )
	{
		spawnedParrots++;
		SpawnParrot();
	}

	if ( AliveParrots.Giant < waveMaxGiantParrots[ wave ] && spawnedParrots != waveTotalParrotCount[ wave ] && KilledParrots.Giant < waveGiantParrotCount[ wave ] )
	{
		spawnedParrots++;
		SpawnGiantParrot();
	}
	
	//ParrotCreatorController();
	
	
	/*if (GetParrotCreatorMode() == PARROTCREATOR_NORMAL)
	{
		if (GetAliveParrots(PARROT_NORMAL) <= waveMaxParrots[wave])
		{
			if (spawnedParrots != waveTotalParrotCount[wave])
			{
				spawnedParrots++;
				SpawnParrot();
			}
		}
		if (spawnedParrots == waveMaxParrots[wave])
		{
			// tell the parrot controller
			parrotCreatorSpawned = true;
		}
		if (parrotDesiredSoundPitch != 0)
			SetParrotSoundPitch(parrotDesiredSoundPitch);
		else
			SetParrotSoundPitch(100);
	}
	else if (GetParrotCreatorMode() == PARROTCREATOR_GIANTS)
	{
		if (!parrotCreatorSpawned && waveGiantParrotCount[wave] != 0 && GetAliveParrots(PARROT_GIANT) < waveGiantParrotCount[wave] && spawnedParrots != waveTotalParrotCount[wave])
		{
			spawnedParrots++;
			SpawnGiantParrot();
		}
		if (spawnedParrots == waveMaxParrots[wave])
		{
			parrotCreatorSpawned = true;
		}
		if (parrotDesiredSoundPitch != 0)
			SetParrotSoundPitch(parrotDesiredSoundPitch);
		else
			SetParrotSoundPitch(85);
	}
	else if (GetParrotCreatorMode() == PARROTCREATOR_BOSS)
	{
		if (waveIsCorruptorWave[wave] && !bossParrotSpawned)
		{
			parrotCreatorSpawned = true;
			bossParrotSpawned = true;
			SpawnBossParrot(true);
		}
		else if (waveIsBossWave[wave] && !bossParrotSpawned)
		{
			parrotCreatorSpawned = true;
			bossParrotSpawned = true;
			SpawnBossParrot(false);
		}
		if (parrotDesiredSoundPitch != 0)
			SetParrotSoundPitch(parrotDesiredSoundPitch);
		else
			SetParrotSoundPitch(75);
	}
	else
	{
		// something went wrong
		SetParrotCreatorMode(PARROTCREATOR_NORMAL);
	}*/
	
	return Plugin_Continue;
}

/*public ParrotCreatorController()
{
	if ( waveIsBossWave[ wave ] )
		return;
	
	if ( parrotCreatorSpawned )
	{
		creatorwave++;
		
		if ( creatorwave >= NOAMP_MAXPARROTCREATOR_WAVES )
			creatorwave = 1;
		
		SetParrotCreatorMode( GetNextParrotCreatorMode( wave, creatorwave ) );
		//ReadParrotCreatorScript(2);
	}
}*/

public void OnCorruptionBegin()
{
	int curEnt = -1;
	char targetname[ MAX_TARGET_LENGTH ];

	while ( ( curEnt = FindEntityByClassname( curEnt, "logic_relay" ) ) != -1 )
	{
		GetEntPropString( curEnt, Prop_Data, "m_iName", targetname, sizeof( targetname ) );
		
		if ( StrContains( targetname, "oncorruptionbegin", false ) == 0 )
		{
			AcceptEntityInput( curEnt, "Trigger" );
		}
	}
}

public void OnCorruptionEnd()
{
	int curEnt = -1;
	char targetname[ MAX_TARGET_LENGTH ];

	while ( ( curEnt = FindEntityByClassname( curEnt, "logic_relay" ) ) != -1 )
	{
		GetEntPropString( curEnt, Prop_Data, "m_iName", targetname, sizeof( targetname ) );
		
		if ( StrContains( targetname, "oncorruptionend", false ) == 0 )
		{
			AcceptEntityInput( curEnt, "Trigger" );
		}
	}
}

public Action Corruption( Handle timer )
{
	// first, save current values
	for ( int i = 1; i <= MaxClients; i++ )
	{
		if ( !clientValuesSaved[ i ] )
		{
			SaveValues( i, true );
			clientValuesSaved[ i ] = true;
		}
	}
	
	if ( corruptsecs >= 10 )
	{
		for ( int i = 1; i <= MaxClients; i++ )
		{
			RestoreSavedValues( i, true );
			clientValuesSaved[ i ] = false;
		}

		OnCorruptionEnd();
		IsCorrupted = false;
		corruptsecs = 0;
		return Plugin_Stop;
	}
	
	// randomize values to create the "corruption" effect
	for ( int i = 1; i <= MaxClients; i++ )
	{
		clientMoney[ i ] = GetRandomInt( 1, 10000 );
		clientUpgradesMaxHP[ i ] = GetRandomInt( 1, 5 );
		clientUpgradesMaxArmor[ i ] = GetRandomInt( 1, 5 );
		clientUpgradesMaxSpeed[ i ] = GetRandomInt( 1, 5 );
		clientPowerUpFillSpecial[ i ] = GetRandomInt( 1, 3 );
		
		if ( IsClientInGame( i ) && IsValidEntity( i ) )
		{
			SetEntData( i, h_iHealth, GetRandomInt( 1, 200 ), 4, true );
			SetEntData( i, h_ArmorValue, GetRandomInt( 1, 200 ), 4, true );
			SetEntData( i, h_flMaxspeed, GetRandomFloat( 10.0, 300.0 ), 4, true );
			SetEntData( i, h_flDefaultSpeed, GetRandomFloat( 10.0, 300.0 ), 4, true );
		}
		
	}
	
	if ( corruptsecs <= 1 )
		EmitSoundToAll( "noamp/corruptor/corruption.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS );
	
	if ( !IsCorrupted )
		OnCorruptionBegin();
	
	IsCorrupted = true;
	corruptsecs++;

	return Plugin_Continue;
}

public void CorruptionBlockAction( int client )
{
	PrintCenterText( client, "I WON'T LET YOU." );
	int dice = GetRandomInt( 1, 6 );

	if ( dice == 6 )
		StartCorruptorSpeech();
	else
		EmitSoundToClient( client, "noamp/corruptor/glitch.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS );
}

// FIXME: lol, wtf is this
public Action BossMusicLooper( Handle timer )
{
	if ( waveIsBossWave[ wave ] )
	{
		if ( musicSecs >= 260 )
		{
			musicSecs = 0;
			EmitSoundToAll( NOAMP_BOSSMUSIC, SOUND_FROM_PLAYER, SNDCHAN_STREAM, SNDLEVEL_NORMAL );
		}
		musicSecs++;
		return Plugin_Continue;
	}

	return Plugin_Stop;
}

// thx Spirrwell
public Action RoundStartCheer( Handle timer, Handle datapack )
{
	ResetPack( datapack );
	int client = ReadPackCell( datapack );
	
	if ( !IsClientInGame( client ) || !IsPlayerAlive( client ) )
		return Plugin_Handled;
	
	int iTeam = ReadPackCell( datapack );
	int iClass = ReadPackCell( datapack );
	
	if ( iTeam >= TEAM_PIRATES && iTeam <= TEAM_KNIGHTS )
	{
		EmitAmbientGameSoundFromPlayer( client, RoundStartGameSounds[ iClass ], true );
	}

	return Plugin_Handled;
}

public void FriendDeadVoice( int client, int victim )
{
	if ( !IsClientInGame( client ) || client == victim || !IsPlayerAlive( client ) || GetClientTeam( client ) <= TEAM_SPECTATOR )
		return;
	
	int victimTeam = GetClientTeam( victim );
	int team = GetClientTeam( client );
	
	// The game already does dead teammate sound for teammates
	if ( victimTeam == team )
		return;
	
	int iClass = GetPlayerClass( client );
	
	if ( team >= TEAM_PIRATES && team <= TEAM_KNIGHTS )
	{		
		// these classes do not have dead friend lines
		if ( iClass != view_as< int >( PVK2_CLASS_SKIRMISHER ) && iClass != view_as< int >( PVK2_CLASS_HUSCARL ) && iClass != view_as< int >( PVK2_CLASS_MANATARMS ) )
		{
			EmitAmbientGameSoundFromPlayer( client, DeadTeammateGameSounds[ iClass ], true );
		}
	}
}

public void ParrotKiller()
{
	int parrot = INVALID_ENT_REFERENCE;
	int count = 0;

	while ( ( parrot = FindEntityByClassname( parrot, "npc_parrot" ) ) != INVALID_ENT_REFERENCE ) 
	{
		AcceptEntityInput( parrot, "BecomeRagdoll" ); // if this actually removes the ent... test
		count++;
	}
	if ( IsDebug() )
	{
		PrintToServer( "Killed %d parrots.", count );
	}
}

public void VultureKiller()
{
	int vulture = INVALID_ENT_REFERENCE;
	int count = 0;

	while ( ( vulture = FindEntityByClassname( vulture, "npc_vulture") ) != INVALID_ENT_REFERENCE )
	{
		AcceptEntityInput(vulture, "BecomeRagdoll");
		count++;
	}
	if ( IsDebug() )
	{
		PrintToServer( "Killed %d vultures.", count );
	}
}

public void EnableFog()
{
	int fog = INVALID_ENT_REFERENCE
	fog = FindEntityByClassname( fog, "env_fog_controller" );
	
	if ( fog == INVALID_ENT_REFERENCE )
	{
		fog = CreateEntityByName( "env_fog_controller" );
	}
	
	if ( fog != INVALID_ENT_REFERENCE ) 
	{
		DispatchKeyValue( fog, "fogenable", "1" );
		AcceptEntityInput( fog, "TurnOn" );
	}
}

public void DisableFog()
{
	int fog = INVALID_ENT_REFERENCE
	fog = FindEntityByClassname( fog, "env_fog_controller" );
	
	if ( fog == INVALID_ENT_REFERENCE )
	{
		fog = CreateEntityByName( "env_fog_controller" );
	}
	
	if ( fog != INVALID_ENT_REFERENCE )
	{
		AcceptEntityInput( fog, "TurnOff" );
	}
}

public void BuyUpgrade( int client, int upgrade )
{
	switch ( upgrade )
	{
		case UPGRADE_MAXHP:
		{
			if ( clientUpgradesMaxHP[ client ] == 5 )
			{
				CPrintToChat( client, "{red}You already have maxed this upgrade!" );
			}
			else if ( GetMoney( client ) >= clientMaxHPPrice[ client ] )
			{
				int hp = GetEntData( client, h_iMaxHealth );
				SetEntData( client, h_iMaxHealth, hp + 20, 4, true );
				SetEntData( client, h_iHealth, hp + 20, 4, true );
				
				RemoveMoney( client, clientMaxHPPrice[ client ] );
				EmitAmbientSoundFromPlayer( client, "noamp/kaching.mp3", false );
				
				clientUpgradesMaxHP[ client ]++;
				clientMaxHPPrice[ client ] += UPGRADE_PRICERAISE;
			}
			else
			{
				CPrintToChat( client, "{red}You don't have enough money! I want %d$.", clientMaxHPPrice[ client ] );
			}
		}
		case UPGRADE_MAXARMOR:
		{
			if ( clientUpgradesMaxArmor[ client ] == 5 )
			{
				CPrintToChat( client, "{red}You already have maxed this upgrade!" );
			}
			else if ( GetMoney( client ) >= clientMaxArmorPrice[ client ] )
			{
				int armor = GetEntData( client, h_iMaxArmor );
				SetEntData( client, h_iMaxArmor, armor + 20, 4, true );
				SetEntData( client, h_ArmorValue, armor + 20, 4, true );
				
				RemoveMoney( client, clientMaxArmorPrice[ client ] );
				EmitAmbientSoundFromPlayer( client, "noamp/kaching.mp3", false );
				
				clientUpgradesMaxArmor[ client ]++;
				clientMaxArmorPrice[ client ] += UPGRADE_PRICERAISE;
			}
			else
			{
				CPrintToChat(client, "{red}You don't have enough money! I want %d$.", clientMaxArmorPrice[ client ] );
			}
		}
		case UPGRADE_MAXSPEED:
		{
			if ( clientUpgradesMaxSpeed[ client ] == 5 )
			{
				CPrintToChat( client, "{red}You already have maxed this upgrade!" );
			}
			else if ( GetMoney( client ) >= clientMaxSpeedPrice[ client ] )
			{				
				float maxspeed = GetEntDataFloat( client, h_flMaxspeed );
				SetEntData( client, h_flMaxspeed, maxspeed + 20, 4, true );
				
				float defspeed = GetEntDataFloat( client, h_flDefaultSpeed );
				SetEntData( client, h_flDefaultSpeed, defspeed + 20, 4, true );
				
				RemoveMoney( client, clientMaxSpeedPrice[ client ] );
				EmitAmbientSoundFromPlayer( client, "noamp/kaching.mp3", false );
				
				clientUpgradesMaxSpeed[ client ]++;
				clientMaxSpeedPrice[ client ] += UPGRADE_PRICERAISE;
			}
			else
			{
				CPrintToChat( client, "{red}You don't have enough money! I want %d$.", clientMaxSpeedPrice[ client ] );
			}
		}
		default:
		{
			ThrowError( "Attempted to purchase unknown upgrade." );
		}
	}
}

public void BuyPowerup( int client, int powerup )
{
	switch ( powerup )
	{
		case POWERUP_FILLSPECIAL:
		{
			if ( clientPowerUpFillSpecial[ client ] >= 3 )
			{
				CPrintToChat( client, "{red}You have this powerup filled already! (3 uses)" );
			}
			else if ( GetMoney( client ) >= powerupFillSpecialPrice )
			{
				if ( clientPowerUpVultures[ client ] != 0 )
				{
					clientPowerUpVultures[ client ] = 0;
				}
				clientPowerUpFillSpecial[ client ]++;
				RemoveMoney( client, powerupFillSpecialPrice );
				EmitAmbientSoundFromPlayer( client, "noamp/kaching.mp3", false );
			}
			else
			{
				CPrintToChat( client, "{red}You don't have enough money! I want %d$.", powerupFillSpecialPrice );
			}
		}
		case POWERUP_VULTURES:
		{
			if ( clientPowerUpVultures[ client ] >= 3 )
			{
				CPrintToChat( client, "{red}You have this powerup filled already! (3 uses)" );
			}
			else if ( GetMoney( client ) >= powerupVulturesPrice )
			{
				if ( clientPowerUpFillSpecial[ client ] != 0 )
				{
					clientPowerUpFillSpecial[ client ] = 0;
				}
				clientPowerUpVultures[ client ]++;
				RemoveMoney( client, powerupVulturesPrice );
				EmitAmbientSoundFromPlayer( client, "noamp/kaching.mp3", false );
			}
			else
			{
				CPrintToChat( client, "{red}You don't have enough money! I want %d$.", powerupVulturesPrice );
			}
		}
		default:
		{
			ThrowError( "Attempted to purchase unknown powerup." );
		}
	}
}

public void ActivatePowerup( int client, int powerup )
{
	switch ( powerup )
	{
		case POWERUP_FILLSPECIAL:
		{
			FillSpecial( client );
			clientPowerUpFillSpecial[ client ]--;
			EmitAmbientSoundFromPlayer( client, "noamp/mystic.mp3", false );
		}
		case POWERUP_VULTURES:
		{
			if ( clientHasVulturesOut[ client ] )
			{
				return;
			}
			PowerupVultures( client );
			clientPowerUpVultures[ client ]--;
			EmitAmbientSoundFromPlayer( client, "noamp/mystic.mp3", false );
		}
	}
}

public void PowerupVultures( int client )
{	
	for ( int i = 0; i < 5; i++ )
	{
		SpawnVulture( client );
	}
	
	clientHasVulturesOut[ client ] = true;
	
	// save the targetname in case the player leaves the game
	char strclientname[ 128 ];
	Format( strclientname, sizeof( strclientname ), "noamp_vulture_%d", client );
	clientVultureTargetname[ client ] = strclientname;
	
	h_TimerKillVultures = CreateTimer( 30.0, KillVultures, client, TIMER_FLAG_NO_MAPCHANGE );
}

public Action KillVultures( Handle timer, int client )
{	
	// oh no! our bird owner left the game
	if ( !IsClientInGame( client ) )
	{
		KillClientVultures( client, false );
	}
	else
	{
		KillClientVultures( client, true );
	}
	clientHasVulturesOut[ client ] = false;
}

public void KillClientVultures( int client, bool isingame )
{
	int vulture = INVALID_ENT_REFERENCE;
	int count = 0;
	
	char targetname[ 256 ];
	char strclientname[ 128 ];
	char name[ 128 ];
	
	if ( !isingame )
	{
		targetname = clientVultureTargetname[ client ];
	}
	else
	{
		Format( strclientname, sizeof( strclientname ), "noamp_vulture_%d", client );
		GetClientName( client, name, sizeof( name ) );
	}
	
	while ( ( vulture = FindEntityByClassname( vulture, "npc_vulture" ) ) != INVALID_ENT_REFERENCE ) 
	{
		GetEntPropString( vulture, Prop_Data, "m_iName", targetname, sizeof( targetname ) );
		if ( StrEqual( strclientname, targetname, false ) )
		{
			AcceptEntityInput( vulture, "kill" );
			count++;
		}
	}
	if ( IsDebug() && isingame )
	{
		PrintToServer( "Killed %d vultures owned by %s", count, name );
	}
}

public void BuyBaseUpgrade( int client, int baseupgrade )
{
	for ( int i = 1; i < NOAMP_MAXBASEUPGRADES; i++ )
	{
		if ( i != baseupgrade )
			continue;
		
		else if ( i == baseupgrade )
		{
			if ( baseUpgrades[ i ] == true )
			{
				CPrintToChat( client, "{red}You already have this base upgrade!" );
			}
			else if ( GetMoney( client ) >= baseUpgradePrices[ i ] )
			{
				baseUpgrades[ i ] = true;
				ActivateBaseUpgrade( client, baseupgrade );
				
				RemoveMoney( client, baseUpgradePrices[ i ] );
				EmitAmbientSoundFromPlayer( client, "noamp/kaching.mp3", false );
			}
			else
			{
				CPrintToChat( client, "{red}You don't have enough money! I want %d$.", baseUpgradePrices[ i ] );
			}
		}
	}
}

/* 
* base upgrades in NOAMP work like this:
* mapper must block the entrance with func_brush named noamp_baseupgrade{number} eg. noamp_baseupgrade1
* this function looks for that ent and attempts to disable it so players can access the new area
* simple as that.
*/

public void ActivateBaseUpgrade( int client, int baseupgrade )
{
	int ent = INVALID_ENT_REFERENCE;
	char targetname[ 128 ];
	char targetname2[ 128 ];

	for ( int i = 1; i < NOAMP_MAXBASEUPGRADES; i++ )
	{
		while ( ( ent = FindEntityByClassname( ent, "func_brush" ) ) != INVALID_ENT_REFERENCE )
		{
			GetEntPropString( ent, Prop_Data, "m_iName", targetname, sizeof( targetname ) );
			Format( targetname2, 128, "noamp_baseupgrade%d", i );
			if ( StrEqual( targetname, targetname2, false ) )
			{
				if ( baseupgrade == i )
				{
					AcceptEntityInput( ent, "Disable" );
					if ( IsDebug() )
					{
						PrintToServer( "Disabled %s.", targetname2 );
					}
				}
			}
		}
	}
}

public void CheckBaseUpgrades()
{
	int ent = INVALID_ENT_REFERENCE;
	char targetname[ 128 ];
	char targetname2[ 128 ];

	for ( int i = 1; i < NOAMP_MAXBASEUPGRADES; i++ )
	{
		while ( ( ent = FindEntityByClassname( ent, "func_brush" ) ) != INVALID_ENT_REFERENCE )
		{
			GetEntPropString( ent, Prop_Data, "m_iName", targetname, sizeof( targetname ) );
			Format( targetname2, 128, "noamp_baseupgrade%d", i );
			if ( StrEqual( targetname, targetname2, false ) )
			{
				baseUpgradesIsValid[ i ] = true;
			}
		}
	}
}

public void EmitAmbientGameSoundFromPlayer( int ent, const char[] gameSound, bool voice )
{
	if ( voice )
	{
		float vOrigin[ 3 ];
		float vPos[ 3 ];
		float vViewOffset[ 3 ];
		GetEntPropVector( ent, Prop_Data, "m_vecAbsOrigin", vOrigin );
		GetEntPropVector( ent, Prop_Data, "m_vecViewOffset", vViewOffset );
		AddVectors( vOrigin, vViewOffset, vPos );
		EmitAmbientGameSound( gameSound, vPos, ent );
	}
	else
	{
		float entOrigin[ 3 ];
		GetEntPropVector( ent, Prop_Data, "m_vecOrigin", entOrigin );
		EmitAmbientGameSound( gameSound, entOrigin, ent );
	}
}

public void EmitAmbientSoundFromPlayer( int client, const char[] name, bool voice )
{
	if ( voice )
	{
		float vOrigin[ 3 ];
		float vPos[ 3 ];
		float vViewOffset[ 3 ];
		GetEntPropVector( client, Prop_Data, "m_vecAbsOrigin", vOrigin );
		GetEntPropVector( client, Prop_Data, "m_vecViewOffset", vViewOffset );
		AddVectors( vOrigin, vViewOffset, vPos );
		EmitAmbientSound( name, vPos, client );
	}
	else
	{
		float entorg[ 3 ];
		GetEntPropVector( client, Prop_Data, "m_vecOrigin", entorg );
		EmitAmbientSound( name, entorg, SOUND_FROM_PLAYER, SNDLEVEL_NORMAL, SND_NOFLAGS );
	}
}

public void PlayRandomSpookySound()
{
	char sample[ 64 ];
	Format( sample, sizeof( sample ), "%s", SpookySounds[ GetRandomInt( 0, 8 ) ] );
	EmitSoundToAll( sample, SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS );
}

public Action GiveMoneyToTarget( int client, int argc )
{
	char arg1[ 32 ];
	char arg2[ 32 ];
	int amount;
	GetCmdArg( 1, arg1, sizeof( arg1 ) );
	
	if ( argc >= 2 && GetCmdArg( 2, arg2, sizeof( arg2 )) )
	{
		amount = StringToInt( arg2 );
	}
	
	char target_name[ MAX_TARGET_LENGTH ];
	int target_list[ MAXPLAYERS ];
	int target_count;
	bool tn_is_ml;
	
	if ( ( target_count = ProcessTargetString( arg1, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof( target_name ), tn_is_ml ) ) <= 0 )
	{
		ReplyToTargetError( client, target_count );
		return Plugin_Handled;
	}
	
	for ( int i = 0; i < target_count; i++ )
	{
		GiveMoney( client, target_list[ i ], amount );
		LogAction( client, target_list[ i ], "\"%L\" gave money to \"%L\" (amount %d)", client, target_list[ i ], amount );
	}
	
	return Plugin_Handled;
}

public void GiveMoney( int sender, int receiver, int amount )
{
	if ( clientMoney[ sender ] >= amount )
	{
		clientMoney[ receiver ] += amount;
		clientMoney[ sender ] -= amount;
		
		char name[ 128 ];
		
		GetClientName( sender, name, sizeof( name ) );
		CPrintToChat( receiver, "{lightgreen}You received $%d from %s.", amount, name );
	}
	else
	{
		CPrintToChat( sender, "{red}You don't have enough money to do that!" );
	}
}

public void FillSpecial( int client )
{
	AddSpecial( client, 500 ); // HACK
	EmitSoundToClient( client, "player/special.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS );
}


public void StartCorruptorSpeech()
{
	// because reversed robotic voice saying secret messages is so cool
	char sample[ 64 ];
	Format( sample, sizeof( sample ), "%s", CorruptorSpeech[ GetRandomInt( 0, 3 ) ] );
	EmitSoundToAll( sample, SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS );
}

public void StopMusicAll()
{
	for ( int i = 1; i <= MaxClients; i++ )
	{
		if ( IsClientInGame( i ))
		{
			StopSound( i, SNDCHAN_STREAM, NOAMP_BOSSMUSIC );
		}
	}
}

public void ForceJoinSpec( int client )
{
	clientForcedSpec[ client ] = true;
	ClientCommand( client, "changeteam 1" );
}

public void ResetGame( bool gameover, bool startgame )
{	
	g_bHasGameStarted = false;
	HasWaveStarted = false;
	IsGameOver = false;
	IsPreparing = false;
	IsCorrupted = false;
	parrotsKilled = 0;
	spawnedParrots = 0;
	giantParrotSpawned = false;
	bossParrotSpawned = false;

	AliveParrots.Small = 0;
	AliveParrots.Normal = 0;
	AliveParrots.Giant = 0;
	AliveParrots.Boss = 0;
	AliveParrots.Total = 0;

	KilledParrots.Small = 0;
	KilledParrots.Normal = 0;
	KilledParrots.Giant = 0;
	KilledParrots.Boss = 0;
	KilledParrots.Total = 0;
	
	if ( !gameover )
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
	//deadplayers = 0;
	preparingSecs = 0;
	gameOverSecs = 0;
	musicSecs = 0;
	
	corruptsecs = 0;
	soundplayed = false;
	
	ParrotKiller();
	VultureKiller();
	ResetSpawns();
	ResetWaves();
	ResetBaseUpgrades();
	ResetParrotCreator();
	//KillTimers();
	ReadNOAMPScript();
	//ReadParrotCreatorScript(1);
	StopMusicAll();
	
	for ( int i = 1; i <= MaxClients; i++ )
	{
		if ( gameover )
			ResetClient( i, true );
		else
			ResetClient( i, false );
	}
	
	if ( startgame )
		StartGame();
}

public void ResetClient( int client, bool gameover )
{
	if ( gameover )
	{
		RestoreSavedValues( client, false );
		clientWantsSpec[ client ] = false;
		clientForcedSpec[ client ] = false;
	}
	else
	{
		clientLives[ client ] = 0;
		clientKills[ client ] = 0;
		clientMoney[ client ] = 0;
		clientUpgradesMaxHP[ client ] = 0;
		clientUpgradesMaxArmor[ client ] = 0;
		clientUpgradesMaxSpeed[ client ] = 0;
		clientMaxHPPrice[ client ] = maxHPPrice;
		clientMaxArmorPrice[ client ] = maxArmorPrice;
		clientMaxSpeedPrice[ client ] = maxSpeedPrice;
		clientPowerUpFillSpecial[ client ] = false;
		clientPowerUpVultures[ client ] = false;
		clientWantsSpec[ client ] = false;
		clientForcedSpec[ client ] = false;
		clientHasVulturesOut[ client ] = false;
		clientAboutToKillVultures[ client ] = false;
		clientValuesSaved[ client ] = false;
		clientVultureTargetname[ client ] = "";
	}
}

public void SaveValues( int client, bool corruption )
{
	if ( corruption )
	{
		clientSavedMoney[ client ] = clientMoney[ client ];
		clientSavedUpgradesMaxHP[ client ] = clientUpgradesMaxHP[ client ];
		clientSavedUpgradesMaxArmor[ client ] = clientUpgradesMaxArmor[ client ];
		clientSavedUpgradesMaxSpeed[ client ] = clientUpgradesMaxSpeed[ client ];
		clientSavedPowerUpFillSpecial[ client ] = clientPowerUpFillSpecial[ client ];
		clientSavedPowerUpVultures[ client ] = clientPowerUpVultures[ client ];
		
		if ( IsClientInGame( client ) && IsValidEntity( client ) )
		{
			clientSavedHP[ client ] = GetEntData( client, h_iHealth );
			clientSavedArmorValue[ client ] = GetEntData( client, h_ArmorValue );
			clientSavedMaxspeed[ client ] = GetEntData( client, h_flMaxspeed );
			clientSavedDefaultSpeed[ client ] = GetEntData( client, h_flDefaultSpeed );
		}
	}
	else
	{
		clientSavedMoney[ client ] = clientMoney[ client ];
		clientSavedUpgradesMaxHP[ client ] = clientUpgradesMaxHP[ client ];
		clientSavedUpgradesMaxArmor[ client ] = clientUpgradesMaxArmor[ client ];
		clientSavedUpgradesMaxSpeed[ client ] = clientUpgradesMaxSpeed[ client ];
		clientSavedPowerUpFillSpecial[ client ] = clientPowerUpFillSpecial[ client ];
		clientSavedPowerUpVultures[ client ] = clientPowerUpVultures[ client ];
	}
}

public void RestoreSavedValues( int client, bool corruption )
{
	if ( corruption )
	{
		clientMoney[ client ] = clientSavedMoney[ client ];
		clientUpgradesMaxHP[ client ] = clientSavedUpgradesMaxHP[ client ];
		clientUpgradesMaxArmor[ client ] = clientSavedUpgradesMaxArmor[ client ];
		clientUpgradesMaxSpeed[ client ] = clientSavedUpgradesMaxSpeed[ client ];
		clientPowerUpFillSpecial[ client ] = clientSavedPowerUpFillSpecial[ client ];
		
		if ( IsClientInGame( client ) && IsValidEntity( client ) )
		{
			SetEntData( client, h_iHealth, clientSavedHP[ client ], 4, true );
			SetEntData( client, h_ArmorValue, clientSavedArmorValue[ client ], 4, true);
			SetEntData( client, h_flMaxspeed, clientSavedMaxspeed[ client ], 4, true);
			SetEntData( client, h_flDefaultSpeed, clientSavedDefaultSpeed[ client ], 4, true);
		}
	}
	else
	{
		clientMoney[ client ] = clientSavedMoney[ client ];
		clientUpgradesMaxHP[ client ] = clientSavedUpgradesMaxHP[ client ];
		clientUpgradesMaxArmor[ client ] = clientSavedUpgradesMaxArmor[ client ];
		clientUpgradesMaxSpeed[ client ] = clientSavedUpgradesMaxSpeed[ client ];
		clientPowerUpFillSpecial[ client ] = clientSavedPowerUpFillSpecial[ client ];
	}
}

public void ResetWaves()
{
	for ( int i = 1; i < NOAMP_MAXWAVES; i++ )
	{
		waveSmallParrotCount[ i ] = 0;
		waveNormalParrotCount[ i ] = 0;
		waveGiantParrotCount[ i ] = 0;
		waveTotalParrotCount[ i ] = 0;
		waveMaxSmallParrots[ i ] = 0;
		waveMaxNormalParrots[ i ] = 0;
		waveMaxGiantParrots[ i ] = 0;
		//waveMaxParrots[ i ] = 0;
		waveIsBossWave[ i ] = false;
		waveIsCorruptorWave[ i ] = false;
	}
}

/*public void KillTimers()
{
	CheckAndKillTimer( h_TimerHUD );
	CheckAndKillTimer( h_TimerWaveThink );
	CheckAndKillTimer( h_TimerGameWin );
	CheckAndKillTimer( h_TimerGameOver );
	CheckAndKillTimer( h_TimerPreparingTime );
	CheckAndKillTimer( h_TimerParrotCreator );
	CheckAndKillTimer( h_TimerCorruption );
	CheckAndKillTimer( h_TimerBossMusicLooper );
	CheckAndKillTimer( h_TimerKillVultures );
	CheckAndKillTimer( h_TimerWaitingForPlayers );
	CheckAndKillTimer( h_TimerCorruptorThink );
}*/

public void ResetBaseUpgrades()
{
	for ( int i = 1; i < NOAMP_MAXBASEUPGRADES; i++ )
	{
		baseUpgrades[ i ] = false;
		baseUpgradesIsValid[ i ] = false;
		baseUpgradePrices[ i ] = 0;
	}
	
	int ent = INVALID_ENT_REFERENCE;
	char targetname[ 128 ];

	for ( int i = 1; i < NOAMP_MAXBASEUPGRADES; i++ )
	{
		while ( ( ent = FindEntityByClassname( ent, "func_brush" ) ) != INVALID_ENT_REFERENCE )
		{
			GetEntPropString( ent, Prop_Data, "m_iName", targetname, sizeof( targetname ) );
			if ( StrContains( targetname, "noamp_baseupgrade", false ) )
			{
				AcceptEntityInput( ent, "Enable" );
			}
		}
	}
	
	if ( IsDebug() )
	{
		PrintToServer( "Enabled all baseupgrades" );
	}
}

public void ResetParrotCreator()
{
	parrotCreatorMode = PARROTCREATOR_NORMAL;

	for ( int i = 1; i < NOAMP_MAXWAVES; i++ )
	{
		for ( int ii = 1; ii < NOAMP_MAXPARROTCREATOR_WAVES; ii++ )
		{
			parrotCreatorScheme[ i ][ ii ] = 0;
		}
	}

	parrotCreatorSpawned = false;
}
