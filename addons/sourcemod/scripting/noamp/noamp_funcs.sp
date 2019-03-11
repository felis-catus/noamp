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

stock GetMoney(client) { return clientMoney[client]; }
stock AddMoney(client, amount) { clientMoney[client] += amount; }
stock RemoveMoney(client, amount) { clientMoney[client] -= amount; }

stock AddSpecial(client, amount) { new i = GetEntData(client, h_iSpecial, 4); i += amount; SetEntData(client, h_iSpecial, i, 4); }
stock RemoveSpecial(client, amount) { new i = GetEntData(client, h_iSpecial, 4); i -= amount; SetEntData(client, h_iSpecial, i, 4); }

stock AddFrags(client, amount) { new i = GetClientFrags(client); i += amount; SetEntProp(client, Prop_Data, "m_iFrags", i); }

stock GetPreparationSeconds() { return preparationSecs; }

stock GetPlayerKills(client) { return clientKills[client]; }
stock GetPlayerLives(client) { return clientLives[client]; }
stock GetPlayerClass(client) { return GetEntData(client, h_iPlayerClass, 4); } // NOTE: +1 cuz weird enums

stock SetParrotSoundPitch(pitch) { parrotSoundPitch = pitch; }

stock GetParrotCreatorMode() { return parrotCreatorMode; }
stock SetParrotCreatorMode(mode) { parrotCreatorMode = mode; if (IsDebug()) { PrintToServer("ParrotCreator mode is now %d", parrotCreatorMode); } }

stock GetAliveParrots(parrottype)
{
	decl String:entclass[128];
	decl String:targetname[128];
	new aliveParrots = 0;
	
	for (new i = 0; i < 3000; i++)
	{
		if (IsValidEdict(i) && IsValidEntity(i))
		{
			if (parrottype == PARROT_NORMAL)
			{
				GetEdictClassname(i, entclass, 128);
				if (StrEqual(entclass, "npc_parrot", false))
				{
					aliveParrots++;
				}
			}
			else if (parrottype == PARROT_GIANT)
			{
				GetEntPropString(i, Prop_Data, "m_iName", targetname, sizeof(targetname));
				if (StrEqual(targetname, "noamp_giant"))
				{
					aliveParrots++;
				}
			}
			else if (parrottype == PARROT_SMALL)
			{
				GetEntPropString(i, Prop_Data, "m_iName", targetname, sizeof(targetname));
				if (StrEqual(targetname, "noamp_small"))
				{
					aliveParrots++;
				}
			}
			else if (parrottype == PARROT_BOSS)
			{
				GetEntPropString(i, Prop_Data, "m_iName", targetname, sizeof(targetname));
				if (StrEqual(targetname, "noamp_boss"))
				{
					aliveParrots++;
				}
			}
		}
	}
	
	return aliveParrots;
}

stock GetNextParrotCreatorMode(currentwave, currentcreatorwave)
{
	return parrotCreatorScheme[currentwave][currentcreatorwave];
}

stock CheckAndKillTimer(&Handle:timer, bool:autoClose = false) 
{
	if (timer != INVALID_HANDLE)
	{
		KillTimer(timer, autoClose);
		timer = INVALID_HANDLE;
	}
}

stock bool:IsDebug() { return GetConVarBool(cvar_debug); }

stock GetRandomBool()
{
	new i = GetRandomInt(0, 1);
	if (i == 0)
		return false;
	else
	return true;
}

stock GetRandomString(length, String:dest[])
{
	// this is crappy, but only good for corruption effect ;)
	decl String:charlist[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	
	decl String:str[length + 1];
	for (new i = 0; i > length; i++)
	{
		str[i] = charlist[GetRandomInt(0, sizeof(charlist)) - 1];
	}
	strcopy(dest, length, str);
}

stock ExplodeTrimAndConvertStringToInt( const String:string[], const String:split[] )
{
	char buffer[ 2 ][ 64 ];
	ExplodeString( string, split, buffer, 2, 64 );
	TrimString( buffer[ 1 ] );
	
	return StringToInt( buffer[ 1 ] );
}

stock float ExplodeTrimAndConvertStringToFloat( const String:string[], const String:split[] )
{
	char buffer[ 2 ][ 64 ];
	ExplodeString( string, split, buffer, 2, 64 );
	TrimString( buffer[ 1 ] );
	
	return StringToFloat( buffer[ 1 ] );
}

stock SpawnParrotAmount(amount, type)
{
	for (new i = 1; i < amount; i++)
	{
		if (type == PARROT_NORMAL)
		{
			SpawnParrot();
		}
		else if (type == PARROT_GIANT)
		{
			SpawnGiantParrot();
		}
		else if (type == PARROT_SMALL)
		{
			SpawnSmallParrot();
		}
		else if (type == PARROT_BOSS)
		{
			SpawnBossParrot(false);
		}
	}
}
