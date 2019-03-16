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

#pragma newdecls required

/*
public void Event_WaitEnd( Handle event, const char[] name, bool dontBroadcast )
{
	if ( !g_bIsEnabled )
		return;
	
	PrintToChatAll( "%s The game is starting!", CHAT_PREFIX );
	IsWaitingForPlayers = false;
	StartGame();
}
*/
public void OnPlayerSpawn( Event event, const char[] name, bool dontBroadcast )
{
	if ( !g_bHasGameStarted )
		return;
	
	int userid = GetEventInt( event, "userid" );
	int client = GetClientOfUserId( userid );
	
	if ( clientLives[ client ] <= 0 )
	{
		if ( IsLivesDisabled )
			return;
		
		// should not spawn, force join spec
		ForceJoinSpec( client );
	}
	else
	{
		for ( int i = 1; i < 5; i++ )
		{
			if ( clientUpgradesMaxHP[ client ] == i )
			{
				int hp = GetEntData( client, h_iMaxHealth, 4 );
				SetEntData( client, h_iMaxHealth, hp + 20 * i, 4, true );
				SetEntData( client, h_iHealth, hp + 20 * i, 4, true );
			}
			if ( clientUpgradesMaxArmor[ client ] == i )
			{
				int armor = GetEntData( client, h_iMaxArmor, 4 );
				SetEntData( client, h_iMaxArmor, armor + 20 * i, 4, true );
				SetEntData( client, h_ArmorValue, armor + 20 * i, 4, true );
			}
			if ( clientUpgradesMaxSpeed[ client ] == i )
			{
				float maxspeed = GetEntDataFloat( client, h_flMaxspeed );
				SetEntData( client, h_flMaxspeed, maxspeed + 20 * i, 4, true );
				float defspeed = GetEntDataFloat( client, h_flDefaultSpeed );
				SetEntData( client, h_flDefaultSpeed, defspeed + 20 * i, 4, true );
			}
		}
		
		// TODO: remove keg from skirm
		if ( GetClientTeam( client ) == TEAM_PIRATES &&  GetPlayerClass( client ) == view_as< int >( PVK2_CLASS_SKIRMISHER ) )
		{
			
		}
	}
	
	return;
}

public void OnPlayerHurt( Event event, const char[] name, bool dontBroadcast )
{
}

public void OnPlayerDeath( Event event, const char[] name, bool dontBroadcast )
{
	if ( !g_bHasGameStarted || IsLivesDisabled || IsPreparing )
		return;
	
	int victimId = GetEventInt( event, "userid" );
	int victim = GetClientOfUserId( victimId );
	
	if ( GetPlayerLives( victim ) <= 0 )
		return;
	
	clientLives[ victim ]--;
	
	// HACK: Force ragdoll into ghostly one, pls dont patch this devs	
	SetEntProp( victim, Prop_Send, "m_iRagdollDismemberment", 11 );

	EmitSoundToAll( "noamp/playerdeath.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL );
	FriendDeadVoice( GetRandomInt( 1, GetClientCount( true ) ), victim );
}

public void OnEntityKilled( Event event, const char[] name, bool dontBroadcast )
{
	if ( !g_bHasGameStarted || IsPreparing )
		return;
	
	int iVictim = event.GetInt( "entindex_killed" );
	int iAttacker = event.GetInt( "entindex_attacker" );
	int iAttackerId = GetClientOfUserId( iAttacker );

	if ( IsValidEntity( iVictim ) )
	{
		char clsname[ 64 ];
		char targetname[ MAX_TARGET_LENGTH ];

		GetEntityClassname( iVictim, clsname, sizeof( clsname ) );

		if ( StrEqual( clsname, "npc_parrot", false ) )
		{
			GetEntPropString( iVictim, Prop_Data, "m_iName", targetname, sizeof( targetname ) );

			if ( StrContains( targetname, "noamp_", false ) == 0 )
			{
				parrotsKilled++;
				int parrotsLeft = waveTotalParrotCount[ wave ] - parrotsKilled;
		
				if ( iAttacker != 0 && IsClientInGame( iAttacker ) )
				{
					clientKills[ iAttacker ]++;
					AddMoney( iAttacker, 10 );
					AddSpecial( iAttacker, 10 );
					AddScore( iAttackerId );
					AddFrags( iAttacker, 1 );
				}
				
				if ( IsDebug() )
				{
					PrintToServer( "Parrots killed: %d", parrotsKilled );
					PrintToServer( "Parrots left: %d", parrotsLeft );
				}

				if ( StrEqual( targetname, "noamp_small", false ) )
				{
					AliveParrots.Small--;
					KilledParrots.Small++;
				}
				else if ( StrEqual( targetname, "noamp_parrot", false ) )
				{
					AliveParrots.Normal--;
					KilledParrots.Normal++;
				}
				else if ( StrEqual( targetname, "noamp_giant", false ) )
				{
					AliveParrots.Giant--;
					KilledParrots.Giant++;
				}
				else if ( StrEqual( targetname, "noamp_boss", false ) )
				{
					AliveParrots.Boss--;
					KilledParrots.Boss++;
				}
				
				AliveParrots.Total--;
				KilledParrots.Total++;
			}
		}
	}
}

/*public void OnParrotDeath( Event event, const char[] name, bool dontBroadcast )
{
	if ( !g_bHasGameStarted || IsPreparing )
		return;
	
	int attackerId = GetEventInt( event, "attacker" );

	char type[ 64 ];
	GetEventString( event, "type", type, sizeof( type ) );
	
	int attacker = GetClientOfUserId( attackerId );
	int parrotsLeft;
	
	if ( StrEqual( type, "npc_parrot", false ) )
	{
		parrotsKilled++;
		parrotsLeft = waveTotalParrotCount[ wave ] - parrotsKilled;
		
		if ( attacker != 0 && IsClientInGame( attacker ) )
		{
			clientKills[ attacker ]++;
			AddMoney( attacker, 10 );
			AddSpecial( attacker, 10 );
			AddScore( attackerId );
			AddFrags( attacker, 1 );
		}
		
		if ( IsDebug() )
		{
			PrintToServer( "Parrots killed: %d", parrotsKilled );
			PrintToServer( "Parrots left: %d", parrotsLeft );
		}
	}
}*/

public void OnStartTouchChestZone( int ent, int other )
{
	if ( !IsValidEntity( ent ) || !IsValidEntity( other ) )
		return;
	
	char buffer[ 64 ];
	GetEntityClassname( other, buffer, sizeof( buffer ) );
	
	if ( StrEqual( buffer, "weapon_chest" ) )
	{
		for ( int i = 1; i <= MaxClients; i++ )
		{
			if ( IsClientInGame( i ) )
			{
				AddMoney( i, chestAward );
				PrintToChat( i, "You received $%d from chest capture!", chestAward );
			}
		}
		
		AcceptEntityInput( other, "kill" );
	}
}

public void AddScore( int client )
{
	// HACK: try adding score through event; thanks Spirrwell! :3
	Handle event = CreateEvent( "player_death", true );
	
	if ( event == INVALID_HANDLE )
	{
		ThrowError( "AddScore() reports: Event is invalid." );
		return;
	}
	
	SetEventInt( event, "userid", -1 );
	SetEventInt( event, "attacker", client );
	SetEventBool( event, "special", false );
	SetEventBool( event, "grail", false );
	SetEventBool( event, "suiassist", false );
	SetEventBool( event, "headshot", false );
	
	FireEvent( event, true );
}
