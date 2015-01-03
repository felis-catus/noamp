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

// NOAMP Definitions and stuff like that

#define PL_VERSION "0.5"
#define SERVER_TAG "noamp"
#define CHAT_PREFIX "[NOAMP]"

#define NOAMP_MAXPLAYERS 6
#define NOAMP_MAXWAVES 32
#define NOAMP_MAXSPAWNS 257
#define NOAMP_MAXBASEUPGRADES 12
#define NOAMP_BOSSMUSIC "noamp/music/corruptor.mp3"
#define NOAMP_BOSSMUSIC2 "noamp/music/corruptor2.mp3"
#define STEAM_GROUP_ID 6185427

#define UPGRADE_MAXHP 1
#define UPGRADE_MAXARMOR 2
#define UPGRADE_MAXSPEED 3

#define POWERUP_FILLSPECIAL 1
#define POWERUP_VULTURES 2

#define BASEUPGRADE1 1

#define CHOICE1 "#choice1"
#define CHOICE2 "#choice2"
#define CHOICE3 "#choice3"
#define CHOICE4 "#choice4"
#define CHOICE5 "#choice5"
#define CHOICE6 "#choice6"


#define TEAM_SPECTATOR 1
#define TEAM_PIRATES 2
#define TEAM_VIKINGS 3
#define TEAM_KNIGHTS 4

#define CLASS_SKIRMISHER 	0
#define CLASS_CAPTAIN 		1
#define CLASS_SHARPSHOOTER 	2
#define CLASS_BERSERKER 	3
#define CLASS_HUSCARL 		4
#define CLASS_GESTIR 		5
#define CLASS_HEAVYKNIGHT 	6
#define CLASS_ARCHER 		7
#define CLASS_MANATARMS 	8

#define MAXCLASSES 10

new Handle:cvar_enabled;
new Handle:cvar_debug;
new Handle:cvar_difficulty;
new Handle:cvar_scheme;
new Handle:cvar_ignoreprefix;
new Handle:cvar_timelimit;
/*
new Handle:cvar_lives;
new Handle:cvar_maxhpprice;
new Handle:cvar_maxarmorprice;
new Handle:cvar_maxspeedprice;
new Handle:cvar_kegprice;
new Handle:cvar_chestaward;
new Handle:cvar_preparationsecs;
new Handle:cvar_giantparrotsize;
new Handle:cvar_bossparrotsize;
*/

new String:KVPath[PLATFORM_MAX_PATH];

new bool:IsMapLoaded = false;
new bool:IsCustomScheme = false;
new String:ParrotSpawns[NOAMP_MAXSPAWNS][128];
new String:GiantParrotSpawns[NOAMP_MAXSPAWNS][128];
new String:BossParrotSpawns[NOAMP_MAXSPAWNS][128];

new clientLives[MAXPLAYERS+1];
new clientMoney[MAXPLAYERS+1];
new clientKills[MAXPLAYERS+1];

new bool:clientWantsSpec[MAXPLAYERS+1];
new bool:clientForcedSpec[MAXPLAYERS+1];

new bool:clientUpgradesMaxHP[MAXPLAYERS+1];
new bool:clientUpgradesMaxArmor[MAXPLAYERS+1];
new bool:clientUpgradesMaxSpeed[MAXPLAYERS+1];

new clientPowerUpFillSpecial[MAXPLAYERS+1];
new clientPowerUpVultures[MAXPLAYERS+1];

new bool:clientHasVulturesOut[MAXPLAYERS+1];

new clientSavedMoney[MAXPLAYERS+1];
new bool:clientSavedUpgradesMaxHP[MAXPLAYERS+1];
new bool:clientSavedUpgradesMaxArmor[MAXPLAYERS+1];
new bool:clientSavedUpgradesMaxSpeed[MAXPLAYERS+1];
new clientSavedPowerUpFillSpecial[MAXPLAYERS+1];
new clientSavedPowerUpVultures[MAXPLAYERS+1];
new clientSavedHP[MAXPLAYERS+1];
new clientSavedArmorValue[MAXPLAYERS+1];
new clientSavedMaxspeed[MAXPLAYERS+1];
new clientSavedDefaultSpeed[MAXPLAYERS+1];

new String:schemeName[256] = "null";

new waveParrotCount[NOAMP_MAXWAVES];
new waveGiantParrotCount[NOAMP_MAXWAVES];
new waveMaxParrots[NOAMP_MAXWAVES];
new bool:waveIsBossWave[NOAMP_MAXWAVES];
new bool:waveIsCorruptorWave[NOAMP_MAXWAVES];
new bool:waveIsFoggy[NOAMP_MAXWAVES];

new bool:baseUpgrades[NOAMP_MAXBASEUPGRADES];
new baseUpgradePrices[NOAMP_MAXBASEUPGRADES];

new numSoundsClasses[MAXCLASSES] = 
{
	6, //Skirmisher
	6, //Captain
	9, //Sharpshooter
	4, //Berserker
	6, //Huscarl
	5, //Gestir
	4, //Heavy Knight
	5, //Archer
	4  //Man-At-Arms
};

new const String:RoundStartSounds[][] = 
{
	"player/pirates/skirm/p_skirm-roundstartcheerup",	//Skirmisher
	"player/pirates/captain/p_captain-roundstart",		//Captain
	"player/pirates/sharp/p_sharp-roundstartcheerup",	//Sharpshooter
	"player/vikings/berserker/v_zerk-roundstartcheer",	//Berserker
	"player/vikings/huscarl/v_husc_roundstartcheer",	//Huscarl
	"player/vikings/gestir/v_gesti_roundstartcheer",	//Gestir
	"player/knights/heavyknight/k_hk-roundstartcheer",	//Heavy Knight
	"player/knights/archer/k_arche-roundstartcheer",	//Archer
	"player/knights/manatarms/k_manat-roundstartcheer"	//Man-At-Arms
};

new playerLives;
new maxHPPrice;
new maxArmorPrice;
new maxSpeedPrice;
new powerupFillSpecialPrice;
new powerupVulturesPrice;
new kegPrice;
new chestAward;
new preparationSecs;
new Float:giantParrotSize;
new Float:bossParrotSize;
new parrotBossHP;

new parrotsKilled;
new spawnedParrots;
new wave;
new waveCount;
new specialOffset;
new hudSecs;
new preparingSecs;
new gameOverSecs;
new musicSecs;
new deadplayers;
new bool:msgshown[MAXPLAYERS+1];

new corruptsecs;
new bool:soundplayed;
new bool:valuesSaved;

new bool:IsEnabled;
new bool:HasGameStarted;
new bool:HasWaveStarted;
new bool:IsGameOver;
new bool:IsPreparing;
new bool:IsCorrupted;
new bool:IsWaitingForPlayers;
new bool:IsLivesDisabled;
new bool:giantParrotSpawned;
new bool:bossParrotSpawned;

new parrotCurrentBossHP;
new parrotSoundPitch;
new timerSoundPitch;

new h_iSpecial;
new h_iHealth;
new h_ArmorValue;
new h_iMaxHealth;
new h_iMaxArmor;
new h_flMaxspeed;
new h_flDefaultSpeed;
new h_iPlayerClass;

new timelimitSavedValue;