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

// NOAMP Funcs

// im just throwing these funcs here, dont mind me

#pragma newdecls required

stock int GetMoney( int client ) { return clientMoney[ client ]; }
stock void AddMoney( int client, int amount) { clientMoney[ client ] += amount; }
stock void RemoveMoney( int client, int amount ) { clientMoney[ client ] -= amount; }

stock void AddSpecial( int client, int amount )
{
	int iSpecial = GetEntData( client, h_iSpecial );
	int iMaxSpecial = GetEntData( client, h_iMaxSpecial );
	
	// Already full
	if ( iSpecial == iMaxSpecial )
		return;

	iSpecial += amount;
	
	if ( iSpecial >= iMaxSpecial )
	{
		// Make sure it's capped
		iSpecial = iMaxSpecial;

		// This is done for the HUD
		Event event = CreateEvent( "player_special_full" );
		event.SetInt( "userid", GetClientUserId( client ) );
		event.Fire();
	}

	SetEntData( client, h_iSpecial, iSpecial, 4, true );
}

stock void RemoveSpecial( int client, int amount) { int i = GetEntData( client, h_iSpecial ); i -= amount; SetEntData( client, h_iSpecial, i ); }

stock void AddFrags( int client, int amount ) { int i = GetClientFrags( client ); i += amount; SetEntProp( client, Prop_Data, "m_iFrags", i ); }

stock int GetPreparationSeconds() { return preparationSecs; }

stock int GetPlayerKills( int client ) { return clientKills[ client ]; }
stock int GetPlayerLives( int client ) { return clientLives[ client ]; }
stock int GetPlayerClass( int client ) { return GetEntData( client, h_iPlayerClass ); }

stock void SetParrotSoundPitch( int pitch ) { parrotSoundPitch = pitch; }

stock int GetParrotCreatorMode() { return parrotCreatorMode; }
stock void SetParrotCreatorMode( int mode ) { parrotCreatorMode = mode; if ( IsDebug() ) { PrintToServer( "ParrotCreator mode is now %d", parrotCreatorMode ); } }

stock bool IsClient( int ent ) { if ( ent >= 1 && ent <= MAXPLAYERS ) return true; return false; }

stock int GetAliveParrots( int parrottype )
{
	char targetname[ 128 ];
	int aliveParrots = 0;
	
	int parrot = -1;
	while ( ( parrot = FindEntityByClassname( parrot, "npc_parrot" ) ) != -1 )
	{
		GetEntPropString( parrot, Prop_Data, "m_iName", targetname, sizeof( targetname ) );
		
		if ( parrottype == PARROT_ANY && StrContains( targetname, "noamp_", false ) == 0 )
			aliveParrots++;
		else if ( parrottype == PARROT_NORMAL && StrEqual( targetname, "noamp_parrot", false ) )
			aliveParrots++;
		else if ( parrottype == PARROT_GIANT && StrEqual( targetname, "noamp_giant", false ) )
			aliveParrots++;
		else if ( parrottype == PARROT_SMALL && StrEqual( targetname, "noamp_small", false ) )
			aliveParrots++;
		else if ( parrottype == PARROT_BOSS && StrEqual( targetname, "noamp_boss", false ) )
			aliveParrots++;
	}

	return aliveParrots;
}

stock int GetNextParrotCreatorMode( int currentwave, int currentcreatorwave )
{
	return parrotCreatorScheme[ currentwave ][ currentcreatorwave ];
}

stock void CheckAndKillTimer( Handle &timer, bool autoClose = false )
{
	if ( timer != INVALID_HANDLE )
	{
		KillTimer( timer, autoClose );
		timer = INVALID_HANDLE;
	}
}

stock bool IsDebug() { return GetConVarBool( cvar_debug ); }

stock bool GetRandomBool()
{
	int i = GetRandomInt( 0, 1 );
	return ( i != 0 );
}

stock void GetRandomString( int length, char[] dest )
{
	// this is crappy, but only good for corruption effect ;)
	char charlist[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	char[] str = new char[ length + 1 ];

	for ( int i = 0; i > length; i++ )
		str[ i ] = charlist[ GetRandomInt( 0, sizeof( charlist ) ) - 1 ];

	strcopy( dest, length, str );
}

stock int ExplodeTrimAndConvertStringToInt( const char[] string, const char[] split )
{
	char buffer[ 2 ][ 64 ];
	ExplodeString( string, split, buffer, 2, 64 );
	TrimString( buffer[ 1 ] );
	
	return StringToInt( buffer[ 1 ] );
}

stock float ExplodeTrimAndConvertStringToFloat( const char[] string, const char[] split )
{
	char buffer[ 2 ][ 64 ];
	ExplodeString( string, split, buffer, 2, 64 );
	TrimString( buffer[ 1 ] );
	
	return StringToFloat( buffer[ 1 ] );
}

stock void SpawnParrotAmount( int amount, int type )
{
	for ( int i = 1; i < amount; i++ )
	{
		if ( type == PARROT_NORMAL )
		{
			SpawnParrot();
		}
		else if ( type == PARROT_GIANT )
		{
			SpawnGiantParrot();
		}
		else if ( type == PARROT_SMALL )
		{
			SpawnSmallParrot();
		}
		else if ( type == PARROT_BOSS )
		{
			SpawnBossParrot( false );
		}
	}
}
