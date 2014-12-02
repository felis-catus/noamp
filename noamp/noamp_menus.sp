// NOAMP Menus

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <morecolors>

// FIXME: this whole menu thing feels... bad. there must be a better way to do these

public MainMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{
		case MenuAction_Display:
		{
			decl String:buffer[255];
			Format(buffer, sizeof(buffer), "%T", "NOAMP Menu", param1);
			
			new Handle:panel = Handle:param2;
			SetPanelTitle(panel, buffer);
		}
		
		case MenuAction_Select:
		{
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info));
			if (StrEqual(info, CHOICE1))
			{
				new Handle:upgradesmenu = CreateMenu(UpgradesMenuHandler, MENU_ACTIONS_ALL);
				SetMenuTitle(upgradesmenu, "%T", "Upgrades", LANG_SERVER);
				
				new String:choice1[64];
				new String:choice2[64];
				new String:choice3[64];
				
				Format(choice1, 64, "Max HP Increase x2: $%d", maxHPPrice);
				Format(choice2, 64, "Max Armor Increase x2: $%d", maxArmorPrice);
				Format(choice3, 64, "Max Speed Increase x2: $%d", maxSpeedPrice);
				
				AddMenuItem(upgradesmenu, CHOICE1, choice1);
				AddMenuItem(upgradesmenu, CHOICE2, choice2);
				AddMenuItem(upgradesmenu, CHOICE3, choice3);
				
				SetMenuExitButton(upgradesmenu, true);
				DisplayMenu(upgradesmenu, param1, 20);
			}
			else if (StrEqual(info, CHOICE2))
			{
				new Handle:powerupsmenu = CreateMenu(PowerupsMenuHandler, MENU_ACTIONS_ALL);
				SetMenuTitle(powerupsmenu, "%T", "Powerups", LANG_SERVER);
				
				new String:choice1[64];
				//new String:choice2[64];
				//new String:choice3[64];
				
				Format(choice1, 64, "Fill Special (%d): $%d", clientPowerUpFillSpecial[param1], powerupFillSpecialPrice);
				
				AddMenuItem(powerupsmenu, CHOICE1, choice1);
				//AddMenuItem(powerupsmenu, CHOICE2, choice2);
				//AddMenuItem(powerupsmenu, CHOICE3, choice3);
				
				SetMenuExitButton(powerupsmenu, true);
				DisplayMenu(powerupsmenu, param1, 20);
			}
			else if (StrEqual(info, CHOICE3))
			{
				new Handle:weaponsmenu = CreateMenu(WeaponsMenuHandler, MENU_ACTIONS_ALL);
				SetMenuTitle(weaponsmenu, "%T", "Weapons", LANG_SERVER);
				
				new String:choice1[64];
				
				Format(choice1, 64, "Powder Keg: $%d", kegPrice);
				
				AddMenuItem(weaponsmenu, CHOICE1, choice1);
				
				SetMenuExitButton(weaponsmenu, true);
				DisplayMenu(weaponsmenu, param1, 20);
			}
			else if (StrEqual(info, CHOICE4))
			{
				new Handle:miscmenu = CreateMenu(MiscMenuHandler, MENU_ACTIONS_ALL);
				SetMenuTitle(miscmenu, "%T", "Miscellaneous", LANG_SERVER);
				
				new String:choice1[64];
				new String:choice2[64];
				new String:choice3[64];
				new String:choice4[64];
				new String:choice5[64];
				
				Format(choice1, 64, "Restore player lives");
				Format(choice2, 64, "Fill special");
				
				AddMenuItem(miscmenu, CHOICE1, choice1);
				AddMenuItem(miscmenu, CHOICE2, choice2);
				
				SetMenuExitButton(miscmenu, true);
				DisplayMenu(miscmenu, param1, 20);
			}
			else if (StrEqual(info, CHOICE5))
			{
				new Handle:debugmenu = CreateMenu(DebugMenuHandler, MENU_ACTIONS_ALL);
				SetMenuTitle(debugmenu, "%T", "Debug", LANG_SERVER);
				
				new String:choice1[64];
				new String:choice2[64];
				new String:choice3[64];
				new String:choice4[64];
				new String:choice5[64];
				
				Format(choice1, 64, "Give me money!");
				Format(choice2, 64, "Give me all the upgrades!");
				Format(choice3, 64, "Spawn some parrots");
				Format(choice4, 64, "Spawn some GIANT parrots");
				Format(choice5, 64, "Reload wave script");
				
				AddMenuItem(debugmenu, CHOICE1, choice1);
				AddMenuItem(debugmenu, CHOICE2, choice2);
				AddMenuItem(debugmenu, CHOICE3, choice3);
				AddMenuItem(debugmenu, CHOICE4, choice4);
				AddMenuItem(debugmenu, CHOICE5, choice5);
				
				SetMenuExitButton(debugmenu, true);
				DisplayMenu(debugmenu, param1, 20);
			}
		}
		
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_DrawItem:
		{
			new style;
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info), style);
			
			return style;
		}
	}
	
	return 0;
}

public UpgradesMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{ 
		case MenuAction_Display:
		{
			decl String:buffer[255];
			Format(buffer, sizeof(buffer), "%T", "Upgrades", param1);
			
			new Handle:panel = Handle:param2;
			SetPanelTitle(panel, buffer);
		}
		
		case MenuAction_Select:
		{
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info));
			if (StrEqual(info, CHOICE1))
			{
				BuyUpgrade(param1, UPGRADE_MAXHP);
			}
			else if (StrEqual(info, CHOICE2))
			{
				BuyUpgrade(param1, UPGRADE_MAXARMOR);
			}
			else if (StrEqual(info, CHOICE3))
			{
				BuyUpgrade(param1, UPGRADE_MAXSPEED);
			}
		}
		
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_DrawItem:
		{
			new style;
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info), style);
			
			return style;
		}
	}
	
	return 0;
}

public PowerupsMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{ 
		case MenuAction_Display:
		{
			decl String:buffer[255];
			Format(buffer, sizeof(buffer), "%T", "Powerups", param1);
			
			new Handle:panel = Handle:param2;
			SetPanelTitle(panel, buffer);
		}
		
		case MenuAction_Select:
		{
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info));
			if (StrEqual(info, CHOICE1))
			{
				BuyPowerup(param1, POWERUP_FILLSPECIAL);
			}
		}
		
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_DrawItem:
		{
			new style;
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info), style);
			
			return style;
		}
	}
	
	return 0;
}

public WeaponsMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{ 
		case MenuAction_Display:
		{
			decl String:buffer[255];
			Format(buffer, sizeof(buffer), "%T", "Weapons", param1);
			
			new Handle:panel = Handle:param2;
			SetPanelTitle(panel, buffer);
		}
		
		case MenuAction_Select:
		{
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info));
			if (StrEqual(info, CHOICE1))
			{
				BuyWeapon(param1, "weapon_powderkeg");
			}
		}
		
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_DrawItem:
		{
			new style;
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info), style);
			
			return style;
		}
	}
	
	return 0;
}

public MiscMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{ 
		case MenuAction_Display:
		{
			decl String:buffer[255];
			Format(buffer, sizeof(buffer), "%T", "Miscellaneous", param1);
			
			new Handle:panel = Handle:param2;
			SetPanelTitle(panel, buffer);
		}
		
		case MenuAction_Select:
		{
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info));
			if (StrEqual(info, CHOICE1))
			{
				// TODO
				PrintToChat(param1, "Not done yet?! Get to work Felis!");
			}
			else if (StrEqual(info, CHOICE2))
			{
				FillSpecial(param1);
			}
		}
		
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_DrawItem:
		{
			new style;
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info), style);
			
			return style;
		}
	}
	
	return 0;
}

public DebugMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{ 
		case MenuAction_Display:
		{
			decl String:buffer[255];
			Format(buffer, sizeof(buffer), "%T", "Debug", param1);
			
			new Handle:panel = Handle:param2;
			SetPanelTitle(panel, buffer);
		}
		
		case MenuAction_Select:
		{
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info));
			if (StrEqual(info, CHOICE1))
			{
				ClientCommand(param1, "debug_noamp_gibemonipls");
			}
			else if (StrEqual(info, CHOICE2))
			{
				ClientCommand(param1, "debug_noamp_giballupgraeds");
			}
			else if (StrEqual(info, CHOICE3))
			{
				ClientCommand(param1, "debug_noamp_testparrotspawns");
			}
			else if (StrEqual(info, CHOICE4))
			{
				ClientCommand(param1, "debug_noamp_testgiantparrotspawns");
			}
			else if (StrEqual(info, CHOICE5))
			{
				ClientCommand(param1, "debug_noamp_reloadscript");
			}
		}
		
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_DrawItem:
		{
			new style;
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info), style);
			
			return style;
		}
	}
	
	return 0;
}

public Action:CMD_NOAMP_Menu(client, args)
{
	NOAMP_Menu(client);
	return Plugin_Handled;
}

public NOAMP_Menu(client)
{
	if (!IsClientInGame(client))
		return Plugin_Handled;
	
	new Handle:menu = CreateMenu(MainMenuHandler, MENU_ACTIONS_ALL);
	SetMenuTitle(menu, "%T", "NOAMP Menu", LANG_SERVER);
	AddMenuItem(menu, CHOICE1, "Upgrades");
	AddMenuItem(menu, CHOICE2, "Powerups");
	AddMenuItem(menu, CHOICE3, "Weapons");
	AddMenuItem(menu, CHOICE4, "Misc.");
	AddMenuItem(menu, CHOICE5, "Debug");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 20);
	
	return Plugin_Handled;
}