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

// NOAMP Menus

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <morecolors>

#pragma newdecls required

public int MainMenuHandler( Menu menu, MenuAction action, int param1, int param2 )
{
	switch ( action )
	{
		case MenuAction_Display:
		{
			char buffer[ 255 ];
			Format( buffer, sizeof( buffer ), "%T", "NOAMP Menu", param1 );

			Panel panel = view_as< Panel >( param2 );
			panel.SetTitle( buffer );
		}
		
		case MenuAction_Select:
		{
			char info[ 32 ];
			menu.GetItem( param2, info, sizeof( info ) );

			if ( StrEqual( info, CHOICE1 ) )
			{
				Menu upgradesmenu = new Menu( UpgradesMenuHandler );
				upgradesmenu.SetTitle( "%T", "Upgrades", LANG_SERVER );
				
				char choice1[ 64 ];
				char choice2[ 64 ];
				char choice3[ 64 ];
				
				Format( choice1, sizeof( choice1 ), "Max HP Increase +20: $%d (%d)", clientMaxHPPrice[ param1 ], clientUpgradesMaxHP[ param1 ] );
				Format( choice2, sizeof( choice2 ), "Max Armor Increase +20: $%d (%d)", clientMaxArmorPrice[ param1 ], clientUpgradesMaxArmor[ param1 ] );
				Format( choice3, sizeof( choice3 ), "Max Speed Increase +20: $%d (%d)", clientMaxSpeedPrice[ param1 ], clientUpgradesMaxSpeed[ param1 ] );
				
				upgradesmenu.AddItem( CHOICE1, choice1 );
				upgradesmenu.AddItem( CHOICE2, choice2 );
				upgradesmenu.AddItem( CHOICE3, choice3 );
				
				upgradesmenu.ExitButton = true;
				upgradesmenu.ExitBackButton = true;
				
				upgradesmenu.Display( param1, 20 );
			}
			else if ( StrEqual( info, CHOICE2 ) )
			{
				Menu powerupsmenu = new Menu( PowerupsMenuHandler );
				powerupsmenu.SetTitle( "%T", "Powerups", LANG_SERVER );
				
				char choice1[ 64 ];
				char choice2[ 64 ];
				//char choice3[ 64 ];
				
				Format( choice1, sizeof( choice1 ), "Fill Special (%d): $%d", clientPowerUpFillSpecial[ param1 ], powerupFillSpecialPrice );
				Format( choice2, sizeof( choice2 ), "Vultures (%d): $%d", clientPowerUpVultures[ param1 ], powerupVulturesPrice );
				
				powerupsmenu.AddItem( CHOICE1, choice1 );
				powerupsmenu.AddItem( CHOICE2, choice2 );
				//powerupsmenu.AddItem( CHOICE3, choice3 );
				
				powerupsmenu.ExitButton = true;
				powerupsmenu.ExitBackButton = true;
				
				powerupsmenu.Display( param1, 20 );
			}
			/*else if ( StrEqual( info, CHOICE3 ) )
			{
				Menu weaponsmenu = new Menu( WeaponsMenuHandler );
				weaponsmenu.SetTitle( "%T", "Weapons", LANG_SERVER );
				
				char choice1[ 64 ];
				
				Format( choice1, sizeof( choice1 ), "Powder Keg: $%d", kegPrice );
				
				weaponsmenu.AddItem( CHOICE1, choice1 );

				weaponsmenu.ExitButton = true;
				weaponsmenu.ExitBackButton = true;
				weaponsmenu.Display( param1, 20 );
			}
			*/
			else if ( StrEqual( info, CHOICE3 ) )
			{
				Menu baseupgmenu = new Menu( BaseUpgradesMenuHandler );
				baseupgmenu.SetTitle( "%T", "Base Upgrades", LANG_SERVER );
				
				char choices[ NOAMP_MAXBASEUPGRADES ][ 128 ];
				
				CheckBaseUpgrades();
				int upgradescount = NOAMP_MAXBASEUPGRADES;
				
				for ( int i = 1; i < upgradescount; i++ )
				{
					//char buffer[ 256 ];
					Format( choices[ i ], 128, "Base Upgrade %d $%d", i, baseUpgradePrices[ i ] );
					
					char choicestr[ 64 ];
					Format( choicestr, sizeof( choicestr ), "#choice%d", i );
					
					baseupgmenu.AddItem( choicestr, choices[ i ] );
				}
				
				baseupgmenu.ExitButton = true;
				baseupgmenu.ExitBackButton = true;
				baseupgmenu.Display( param1, 20 );
			}
			else if ( StrEqual( info, CHOICE4 ) )
			{
				Menu miscmenu = new Menu( MiscMenuHandler );
				miscmenu.SetTitle( "%T", "Miscellaneou", LANG_SERVER );
				
				char choice1[ 64 ];
				//char choice2[ 64 ];
				//char choice3[ 64 ];
				//char choice4[ 64 ];
				//char choice5[ 64 ];
				
				Format( choice1, sizeof( choice1 ), "Restore player lives" );
				
				miscmenu.AddItem( CHOICE1, choice1 );
				//miscmenu.AddItem( CHOICE2, choice2 );
				
				miscmenu.ExitButton = true;
				miscmenu.ExitBackButton = true;
				miscmenu.Display( param1, 20 );
			}
			else if ( StrEqual( info, CHOICE5 ) )
			{
				Menu debugmenu = new Menu( DebugMenuHandler );
				debugmenu.SetTitle( "%T", "Debug", LANG_SERVER );
				
				char choice1[ 64 ];
				char choice2[ 64 ];
				char choice3[ 64 ];
				char choice4[ 64 ];
				char choice5[ 64 ];
				
				Format( choice1, sizeof( choice1 ), "Give me money!" );
				Format( choice2, sizeof( choice2 ), "Give me all the upgrades!" );
				Format( choice3, sizeof( choice3 ), "Spawn some parrots" );
				Format( choice4, sizeof( choice4 ), "Spawn some GIANT parrots" );
				Format( choice5, sizeof( choice5 ), "Reload wave script" );
				
				debugmenu.AddItem( CHOICE1, choice1 );
				debugmenu.AddItem( CHOICE2, choice2 );
				debugmenu.AddItem( CHOICE3, choice3 );
				debugmenu.AddItem( CHOICE4, choice4 );
				debugmenu.AddItem( CHOICE5, choice5 );
				
				debugmenu.ExitButton = true;
				debugmenu.ExitBackButton = true;
				debugmenu.Display( param1, 20 );
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
		
		case MenuAction_DrawItem:
		{
			int style;
			char info[ 32 ];
			
			menu.GetItem( param2, info, sizeof( info ), style );
			
			return style;
		}
	}
	
	return 0;
}

public int UpgradesMenuHandler( Menu menu, MenuAction action, int param1, int param2 )
{
	switch ( action )
	{ 
		case MenuAction_Display:
		{
			char buffer[ 255 ];
			Format( buffer, sizeof( buffer ), "%T", "Upgrades", param1 );
			
			Panel panel = view_as< Panel >( param2 );
			panel.SetTitle( buffer );
		}
		
		case MenuAction_Select:
		{
			char info[ 32 ];
			menu.GetItem( param2, info, sizeof( info ) );
			
			if ( StrEqual( info, CHOICE1 ) )
			{
				BuyUpgrade( param1, UPGRADE_MAXHP );
			}
			else if ( StrEqual( info, CHOICE2 ) )
			{
				BuyUpgrade( param1, UPGRADE_MAXARMOR );
			}
			else if ( StrEqual( info, CHOICE3 ) )
			{
				BuyUpgrade( param1, UPGRADE_MAXSPEED );
			}
		}
		
		case MenuAction_Cancel:
		{
			switch ( param2 )
			{
				case MenuCancel_ExitBack:
				{
					NOAMP_Menu( param1 );
				}
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
		
		case MenuAction_DrawItem:
		{
			int style;
			char info[ 32 ];
			
			menu.GetItem( param2, info, sizeof( info ), style );
			
			return style;
		}
	}
	
	return 0;
}

public int PowerupsMenuHandler( Menu menu, MenuAction action, int param1, int param2 )
{
	switch ( action )
	{ 
		case MenuAction_Display:
		{
			char buffer[ 255 ];
			Format( buffer, sizeof( buffer ), "%T", "Powerups", param1 );
			
			Panel panel = view_as< Panel >( param2 );
			panel.SetTitle( buffer );
		}
		
		case MenuAction_Select:
		{
			char info[ 32 ];
			menu.GetItem( param2, info, sizeof( info ) );
			
			if ( StrEqual( info, CHOICE1 ) )
			{
				BuyPowerup( param1, POWERUP_FILLSPECIAL );
			}
			else if ( StrEqual( info, CHOICE2 ) )
			{
				BuyPowerup( param1, POWERUP_VULTURES );
			}
		}
		
		case MenuAction_Cancel:
		{
			switch ( param2 )
			{
				case MenuCancel_ExitBack:
				{
					NOAMP_Menu( param1 );
				}
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
		
		case MenuAction_DrawItem:
		{
			int style;
			char info[ 32 ];
			
			menu.GetItem( param2, info, sizeof( info ), style );
			
			return style;
		}
	}
	
	return 0;
}

/*
public int WeaponsMenuHandler( Menu menu, MenuAction action, int param1, int param2 )
{
	switch ( action )
	{ 
		case MenuAction_Display:
		{
			char buffer[ 255 ];
			Format( buffer, sizeof( buffer ), "%T", "Weapons", param1 );
			
			Panel panel = view_as< Panel >( param2 );
			panel.SetTitle( buffer );
		}
		
		case MenuAction_Select:
		{
			char info[ 32 ];
			menu.GetItem( param2, info, sizeof( info ) );

			if ( StrEqual( info, CHOICE1 ) )
			{
				BuyWeapon( param1, "weapon_powderkeg" );
			}
		}
		
		case MenuAction_Cancel:
		{
			switch ( param2 )
			{
				case MenuCancel_ExitBack:
				{
					NOAMP_Menu( param1 );
				}
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
		
		case MenuAction_DrawItem:
		{
			int style;
			char info[ 32 ];
			
			menu.GetItem( param2, info, sizeof( info ), style );
			
			return style;
		}
	}
	
	return 0;
}
*/
public int BaseUpgradesMenuHandler( Menu menu, MenuAction action, int param1, int param2 )
{
	switch ( action )
	{ 
		case MenuAction_Display:
		{
			char buffer[ 255 ];
			Format( buffer, sizeof( buffer ), "%T", "Base Upgrades", param1 );
			
			Panel panel = view_as< Panel >( param2 );
			panel.SetTitle( buffer );
		}
		
		case MenuAction_Select:
		{
			char info[ 32 ];
			menu.GetItem( param2, info, sizeof( info ) );
			
			//char choices[ NOAMP_MAXBASEUPGRADES ][ 128 ];
			int upgradescount = NOAMP_MAXBASEUPGRADES;
			
			for ( int i = 1; i < upgradescount; i++ )
			{				
				char choicestr[ 64 ];
				Format( choicestr, 128, "#choice%d", i );
				
				if ( StrEqual( info, choicestr ) )
				{
					BuyBaseUpgrade( param1, i );
				}
			}
		}
		
		case MenuAction_Cancel:
		{
			switch ( param2 )
			{
				case MenuCancel_ExitBack:
				{
					NOAMP_Menu( param1 );
				}
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
		
		case MenuAction_DrawItem:
		{
			int style;
			char info[ 32 ];
			
			menu.GetItem( param2, info, sizeof( info ), style );
			
			return style;
		}
	}
	
	return 0;
}

public int MiscMenuHandler( Menu menu, MenuAction action, int param1, int param2 )
{
	switch ( action )
	{ 
		case MenuAction_Display:
		{
			char buffer[ 255 ];
			Format( buffer, sizeof( buffer ), "%T", "Miscellaneous", param1 );
			
			Panel panel = view_as< Panel >( param2 );
			panel.SetTitle( buffer );
		}
		
		case MenuAction_Select:
		{
			char info[ 32 ];
			menu.GetItem( param2, info, sizeof( info ) );

			if ( StrEqual( info, CHOICE1 ) )
			{
				// TODO
				PrintToChat( param1, "Not done yet?! Get to work Felis!" );
			}
		}
		
		case MenuAction_Cancel:
		{
			switch ( param2 )
			{
				case MenuCancel_ExitBack:
				{
					NOAMP_Menu( param1 );
				}
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
		
		case MenuAction_DrawItem:
		{
			int style;
			char info[ 32 ];
			
			menu.GetItem( param2, info, sizeof( info ), style );
			
			return style;
		}
	}
	
	return 0;
}

public int DebugMenuHandler( Menu menu, MenuAction action, int param1, int param2 )
{
	switch ( action )
	{ 
		case MenuAction_Display:
		{
			char buffer[ 255 ];
			Format( buffer, sizeof( buffer ), "%T", "Debug", param1 );
			
			Panel panel = view_as< Panel >( param2 );
			panel.SetTitle( buffer );
		}
		
		case MenuAction_Select:
		{
			char info[ 32 ];
			menu.GetItem( param2, info, sizeof( info ) );

			if ( StrEqual( info, CHOICE1 ) )
			{
				ClientCommand( param1, "debug_noamp_gibemonipls" );
			}
			else if ( StrEqual( info, CHOICE2 ) )
			{
				ClientCommand( param1, "debug_noamp_giballupgraeds" );
			}
			else if ( StrEqual( info, CHOICE3 ) )
			{
				ClientCommand( param1, "debug_noamp_testparrotspawns" );
			}
			else if ( StrEqual( info, CHOICE4 ) )
			{
				ClientCommand( param1, "debug_noamp_testgiantparrotspawns" );
			}
			else if ( StrEqual( info, CHOICE5 ) )
			{
				ClientCommand( param1, "debug_noamp_reloadscript" );
			}
		}
		
		case MenuAction_Cancel:
		{
			switch ( param2 )
			{
				case MenuCancel_ExitBack:
				{
					NOAMP_Menu( param1 );
				}
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
		
		case MenuAction_DrawItem:
		{
			int style;
			char info[ 32 ];
			
			menu.GetItem( param2, info, sizeof( info ), style );
			
			return style;
		}
	}
	
	return 0;
}

public Action CMD_NOAMP_Menu( int client, int args )
{
	NOAMP_Menu( client );
	return Plugin_Handled;
}

public void NOAMP_Menu( int client )
{
	if ( !IsClientInGame( client ) )
		return;
	
	if ( IsCorrupted )
	{
		CorruptionBlockAction( client );
		return;
	}
	
	Menu menu = new Menu( MainMenuHandler, MENU_ACTIONS_ALL );
	menu.SetTitle( "%T", "NOAMP Menu", LANG_SERVER );
	menu.AddItem( CHOICE1, "Upgrades" );
	menu.AddItem( CHOICE2, "Powerups" );
	//menu.AddItem( CHOICE3, "Weapons" );
	menu.AddItem( CHOICE3, "Base Upgrades" );
	menu.AddItem( CHOICE4, "Misc." );
	menu.AddItem( CHOICE5, "Debug" );
	menu.ExitButton = true;
	menu.Display( client, 20 );
}
