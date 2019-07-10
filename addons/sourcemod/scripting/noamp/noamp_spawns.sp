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

// NOAMP Spawns

/* 
* Some code borrowed from Alm's Dynamic NPC Spawner
* https://forums.alliedmods.net/showthread.php?t=133910
*/

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <morecolors>

#pragma newdecls required

public void FindSpawns()
{
	char targetname[ 128 ];
	float entorg[ 3 ];
	int count = 0;
	//int giantcount = 0;
	int bosscount = 0;
	int curSpawn = -1;

	while ( ( curSpawn = FindEntityByClassname( curSpawn, "info_target" ) ) != -1 )
	{
		GetEntPropString( curSpawn, Prop_Data, "m_iName", targetname, sizeof( targetname ) );
		
		if ( count < NOAMP_MAXSPAWNS && StrEqual( targetname, "noamp_parrotspawn" ) )
		{
			count++;
			GetEntPropVector( curSpawn, Prop_Data, "m_vecOrigin", entorg );
			Format( ParrotSpawns[ count ], 128, "%f %f %f", entorg[ 0 ], entorg[ 1 ], entorg[ 2 ] );

			if ( IsDebug() )
			{
				PrintToServer( "caught a spawn target" );
				PrintToServer( "m_vecOrigin = %s", ParrotSpawns[ count ] );
			}
		}
		else if ( bosscount < NOAMP_MAXSPAWNS && StrEqual( targetname, "noamp_boss_spawn" ) )
		{
			bosscount++;
			GetEntPropVector( curSpawn, Prop_Data, "m_vecOrigin", entorg );
			Format( BossParrotSpawns[ bosscount ], 128, "%f %f %f", entorg[ 0 ], entorg[ 1 ], entorg[ 2 ] );
			
			if ( IsDebug() )
			{
				PrintToServer( "caught a boss spawn target" );
				PrintToServer( "m_vecOrigin = %s", BossParrotSpawns[ bosscount ] );
			}
		}
		/* WTF: its actually a better idea to get rid of this and use normal spawns
		else if ( giantcount < NOAMP_MAXSPAWNS && StrEqual( targetname, "noamp_giantparrot_spawn" ) )
		{
			giantcount++;
			GetEntPropVector( curSpawn, Prop_Data, "m_vecOrigin", entorg );
			Format( GiantParrotSpawns[ giantcount ], 128, "%f %f %f", entorg[ 0 ], entorg[ 1 ], entorg[ 2 ] );
			
			if ( IsDebug() )
			{
				PrintToServer( "caught a giant parrot spawn target" );
				PrintToServer( "m_vecOrigin = %s", GiantParrotSpawns[ giantcount ] );
			}
		}
		*/
	}
}

public void ResetSpawns()
{
	for ( int i = 0; i < NOAMP_MAXSPAWNS; i++ )
	{
		ParrotSpawns[ i ] = "null";
		GiantParrotSpawns[ i ] = "null";
		BossParrotSpawns[ i ] = "null";
	}
	
	FindSpawns();
}

public int GetSpawnCount()
{
	int spawns = 0;
	for ( int i = 0; i <= NOAMP_MAXSPAWNS-1; i++ )
	{
		if ( !StrEqual( ParrotSpawns[ i ], "null", false ) )
		{
			spawns++;
		}
	}
	//char tempstring[ 4 ];
	//IntToString( spawns, tempstring, 4 );

	return spawns;
}

public int GetBossSpawnCount()
{
	int spawns = 0;
	
	for ( int i = 0; i <= NOAMP_MAXSPAWNS-1; i++ )
	{
		if ( !StrEqual( BossParrotSpawns[ i ], "null", false ) )
			spawns++;
	}
	
	return spawns;
}

public int GetRandomSpawnPoint()
{
	int nodecount = 0;
	int currentnode = 1;
	
	while ( currentnode <= GetSpawnCount() )
	{
		nodecount++;
		currentnode++;
	}
	
	if ( nodecount == 0 )
	{
		return 0;
	}
	
	int[] choosenode = new int[ nodecount + 1 ];
	
	nodecount = 0;
	currentnode = 1;
	
	while ( currentnode <= GetSpawnCount() )
	{
		nodecount++;
		choosenode[ nodecount ] = currentnode;
		currentnode++;
	}
	
	int randomnode = choosenode[ GetRandomInt( 1, nodecount ) ];
	
	return randomnode;
}

public int GetRandomBossSpawnPoint()
{
	int nodecount = 0;
	int currentnode = 1;
	int bossSpawnCount = GetBossSpawnCount();
	
	while ( currentnode <= bossSpawnCount )
	{
		nodecount++;
		currentnode++;
	}
	
	if ( nodecount == 0 )
	{
		return 0;
	}
	
	int[] choosenode = new int[ nodecount + 1 ];
	
	nodecount = 0;
	currentnode = 1;
	
	while ( currentnode <= bossSpawnCount )
	{
		nodecount++;
		choosenode[ nodecount ] = currentnode;
		currentnode++;
	}
	
	int randomnode = choosenode[ GetRandomInt( 1, nodecount ) ];
	
	return randomnode;
}

public void SpawnParrot()
{
	int randomnode = GetRandomSpawnPoint();
	
	if ( randomnode == 0 )
	{
		LogError( "No nodes, not spawning parrot." );
		return;
	}
	
	int parrot = CreateEntityByName( "npc_parrot" );
	
	char nodepoints[ 3 ][ 128 ];
	ExplodeString( ParrotSpawns[ randomnode ], " ", nodepoints, 3, 128 );
	
	float nodeorg[ 3 ];
	nodeorg[ 0 ] = StringToFloat( nodepoints[ 0 ] );
	nodeorg[ 1 ] = StringToFloat( nodepoints[ 1 ] );
	nodeorg[ 2 ] = StringToFloat( nodepoints[ 2 ] );
	
	char orgstring[ 128 ];
	char attackdamagestring[ 128 ];

	Format( orgstring, sizeof( orgstring ), "%f %f %f", nodeorg[ 0 ], nodeorg[ 1 ], nodeorg[ 2 ] );
	FloatToString( g_flNormalParrotAttackDamage, attackdamagestring, sizeof( attackdamagestring ) );
	
	DispatchKeyValue( parrot, "origin", orgstring );
	DispatchKeyValue( parrot, "attackdamage", attackdamagestring );
	DispatchSpawn( parrot );
	
	DispatchKeyValue( parrot, "targetname", "noamp_parrot" );
	
	if ( IsDebug() )
	{
		PrintToServer( "Parrot spawned at %s", orgstring );
	}

	AliveParrots.Normal++;
	AliveParrots.Total++;
}

public void SpawnGiantParrot()
{	
	int randomnode = GetRandomSpawnPoint();
	
	if ( randomnode == 0 )
	{
		LogError( "No nodes, not spawning parrot." );
		return;
	}
	
	int parrot = CreateEntityByName( "npc_parrot" );
	
	char nodepoints[ 3 ][ 128 ];
	ExplodeString( ParrotSpawns[ randomnode ], " ", nodepoints, 3, 128 );
	
	float nodeorg[ 3 ];
	nodeorg[ 0 ] = StringToFloat( nodepoints[ 0 ] );
	nodeorg[ 1 ] = StringToFloat( nodepoints[ 1 ] );
	nodeorg[ 2 ] = StringToFloat( nodepoints[ 2 ] );
	
	char orgstring[ 128 ];
	char scalestring[ 128 ];
	char attackdamagestring[ 128 ];
	
	Format( orgstring, sizeof( orgstring ), "%f %f %f", nodeorg[ 0 ], nodeorg[ 1 ], nodeorg[ 2 ] );
	FloatToString( giantParrotSize, scalestring, sizeof( scalestring ) );
	FloatToString( g_flGiantParrotAttackDamage, attackdamagestring, sizeof( attackdamagestring ) );
	
	DispatchKeyValue( parrot, "origin", orgstring );
	DispatchKeyValue( parrot, "scale", scalestring );
	DispatchKeyValue( parrot, "attackdamage", attackdamagestring );

	DispatchSpawn( parrot );
	
	// FIXME: lol
	//float vecParrotMin[ 3 ] = { -15.0, -15.0, 0.0 };
	//float vecParrotMax[ 3 ] = { 15.0,  15.0, 50.0 };
	
	//ScaleVector( vecParrotMin, giantParrotSize );
	//ScaleVector( vecParrotMax, giantParrotSize );
	
	//SetEntPropVector( parrot, Prop_Send, "m_vecSpecifiedSurroundingMins", vecParrotMin );
	//SetEntPropVector( parrot, Prop_Send, "m_vecSpecifiedSurroundingMaxs", vecParrotMax );
	
	//float scalevalue = giantParrotSize;
	//SetEntPropFloat( parrot, Prop_Send, "m_flModelScale", scalevalue );
	
	SetEntProp( parrot, Prop_Data, "m_iHealth", 100 );
	DispatchKeyValue( parrot, "targetname", "noamp_giant" );
	
	if ( IsDebug() )
	{
		PrintToServer( "Giant parrot spawned at %s", orgstring );
	}

	AliveParrots.Giant++;
	AliveParrots.Total++;
}

public void SpawnSmallParrot()
{	
	int randomnode = GetRandomSpawnPoint();
	
	if ( randomnode == 0 )
	{
		LogError( "No nodes, not spawning parrot." );
		return;
	}
	
	int parrot = CreateEntityByName( "npc_parrot" );
	
	char nodepoints[ 3 ][ 128 ];
	ExplodeString( ParrotSpawns[ randomnode ], " ", nodepoints, 3, 128 );
	
	float nodeorg[ 3 ];
	nodeorg[ 0 ] = StringToFloat( nodepoints[ 0 ] );
	nodeorg[ 1 ] = StringToFloat( nodepoints[ 1 ]);
	nodeorg[ 2 ] = StringToFloat( nodepoints[ 2 ] );
	
	char orgstring[ 128 ];
	char scalestring[ 128 ];
	char attackdamagestring[ 128 ];
	
	Format( orgstring, sizeof( orgstring ), "%f %f %f", nodeorg[0  ], nodeorg[1  ], nodeorg[ 2 ] );
	FloatToString( smallParrotSize, scalestring, sizeof( scalestring ) );
	FloatToString( g_flSmallParrotAttackDamage, attackdamagestring, sizeof( attackdamagestring ) );
	
	DispatchKeyValue( parrot, "origin", orgstring );
	DispatchKeyValue( parrot, "scale", scalestring );
	DispatchKeyValue( parrot, "attackdamage", attackdamagestring );
	DispatchSpawn( parrot );
	
	// FIXME: lol
	//float vecParrotMin[ 3 ] = { -15.0, -15.0, 0.0 };
	//float vecParrotMax[ 3 ] = { 15.0,  15.0, 50.0 };
	
	//ScaleVector( vecParrotMin, smallParrotSize );
	//ScaleVector( vecParrotMax, smallParrotSize );
	
	//SetEntPropVector( parrot, Prop_Send, "m_vecSpecifiedSurroundingMins", vecParrotMin );
	//SetEntPropVector( parrot, Prop_Send, "m_vecSpecifiedSurroundingMaxs", vecParrotMax );
	
	//float scalevalue = smallParrotSize;
	//SetEntPropFloat( parrot, Prop_Send, "m_flModelScale", scalevalue );
	
	DispatchKeyValue( parrot, "targetname", "noamp_small" );
	
	if ( IsDebug() )
	{
		PrintToServer( "Small parrot spawned at %s", orgstring );
	}

	AliveParrots.Small++;
	AliveParrots.Total++;
}

public void SpawnBossParrot( bool corruptor )
{	
	int randomnode = GetRandomBossSpawnPoint();
	
	if ( randomnode == 0 )
	{
		LogError( "No nodes, not spawning parrot." );
		return;
	}
	
	int parrot = CreateEntityByName( "npc_parrot" );
	
	char nodepoints[ 3 ][ 128 ];
	ExplodeString( BossParrotSpawns[ randomnode ], " ", nodepoints, 3, 128 );
	
	float nodeorg[ 3 ];
	nodeorg[ 0 ] = StringToFloat( nodepoints[ 0 ] );
	nodeorg[ 1 ] = StringToFloat( nodepoints[ 1 ] );
	nodeorg[ 2 ] = StringToFloat( nodepoints[ 2 ] );
	
	char orgstring[ 128 ];
	char scalestring[ 128 ];
	char attackdamagestring[ 128 ];
	
	Format( orgstring, sizeof( orgstring ), "%f %f %f", nodeorg[ 0 ], nodeorg[ 1 ], nodeorg[ 2 ] );
	FloatToString( bossParrotSize, scalestring, sizeof( scalestring ) );
	FloatToString( g_flBossParrotAttackDamage, attackdamagestring, sizeof( attackdamagestring ) );
	
	DispatchKeyValue( parrot, "origin", orgstring );
	DispatchKeyValue( parrot, "scale", scalestring );
	DispatchKeyValue( parrot, "attackdamage", attackdamagestring );
	DispatchSpawn( parrot );
	
	// FIXME: lol
	//float vecParrotMin[ 3 ] = { -15.0, -15.0, 0.0 };
	//float vecParrotMax[ 3 ] = { 15.0,  15.0, 50.0 };
	
	//ScaleVector( vecParrotMin, giantParrotSize );
	//ScaleVector( vecParrotMax, giantParrotSize );
	
	//SetEntPropVector( parrot, Prop_Send, "m_vecSpecifiedSurroundingMins", vecParrotMin );
	//SetEntPropVector( parrot, Prop_Send, "m_vecSpecifiedSurroundingMaxs", vecParrotMax );
	
	//float scalevalue = bossParrotSize;
	//SetEntPropFloat( parrot, Prop_Send, "m_flModelScale", scalevalue );
	
	SetEntProp( parrot, Prop_Data, "m_iHealth", parrotBossHP );
	DispatchKeyValue( parrot, "targetname", "noamp_boss" );
	
	if ( corruptor )
	{
		// blak brid
		SetEntityRenderColor( parrot, 0, 0, 0, 255 );
	}
	
	if ( IsDebug() )
	{
		PrintToServer( "Boss parrot spawned at %s", orgstring );
	}

	AliveParrots.Boss++;
	AliveParrots.Total++;
}

public void SpawnVulture( int client )
{
	int vulture = CreateEntityByName( "npc_vulture" );
	
	float entorg[ 3 ];
	GetEntPropVector( client, Prop_Data, "m_vecOrigin", entorg );
	
	char orgstring[ 128 ];
	Format( orgstring, sizeof( orgstring ), "%f %f %f", entorg[ 0 ], entorg[ 1 ], entorg[ 2 ] );
	
	// left or right?
	int rand = GetRandomInt( 1, 2 );
	if ( rand == 1 )
		entorg[ 1 ] = 20.0;
	else if ( rand == 2 )
		entorg[ 1 ] = -20.0;
	
	DispatchKeyValue( vulture, "origin", orgstring );
	DispatchSpawn( vulture );
	
	char targetname[ 128 ];
	Format( targetname, sizeof( targetname ), "noamp_vulture_%d", client );
	
	DispatchKeyValue( vulture, "targetname", targetname );
}
