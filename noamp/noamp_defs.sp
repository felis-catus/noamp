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

#define PL_VERSION "0.5a"
#define SERVER_TAG "noamp"
#define CHAT_PREFIX "[NOAMP]"

#define NOAMP_MAXPLAYERS 6
#define NOAMP_MAXWAVES 32
#define NOAMP_MAXSPAWNS 256
#define NOAMP_MAXBASEUPGRADES 6
#define NOAMP_MAXPARROTCREATOR_WAVES 6
#define NOAMP_BOSSMUSIC "noamp/music/corruptor.mp3"
#define STEAM_GROUP_ID 6185427

#define UPGRADE_MAXHP 1
#define UPGRADE_MAXARMOR 2
#define UPGRADE_MAXSPEED 3

#define UPGRADE_PRICERAISE 50

#define POWERUP_FILLSPECIAL 1
#define POWERUP_VULTURES 2

#define BASEUPGRADE1 1

#define PARROT_NORMAL 1
#define PARROT_GIANT 2
#define PARROT_SMALL 3
#define PARROT_BOSS 4

#define PARROTCREATOR_NORMAL 1
#define PARROTCREATOR_GIANTS 2
#define PARROTCREATOR_SMALL 3
#define PARROTCREATOR_BOSS 4

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

enum PlayerClass_t
{
	PVK2_CLASS_SKIRMISHER = 0,
	PVK2_CLASS_CAPTAIN,
	PVK2_CLASS_SHARPSHOOTER,

	PVK2_CLASS_BERSERKER,
	PVK2_CLASS_HUSCARL,
	PVK2_CLASS_GESTIR,
	PVK2_CLASS_BONDI,

	PVK2_CLASS_HEAVYKNIGHT,
	PVK2_CLASS_ARCHER,
	PVK2_CLASS_MANATARMS,

	PVK2_NUM_CLASSES,
	PVK2_CLASS_INVALID = -1
}

#define NUM_CLASSES_PIRATES 3
#define NUM_CLASSES_VIKINGS 4
#define NUM_CLASSES_KNIGHTS 3

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

new String:ScriptPath[PLATFORM_MAX_PATH];
new String:ParrotCreatorScriptPath[PLATFORM_MAX_PATH];

new bool:IsMapLoaded = false;
new bool:IsCustomScheme = false;
new String:ParrotSpawns[NOAMP_MAXSPAWNS+1][128];
new String:GiantParrotSpawns[NOAMP_MAXSPAWNS+1][128];
new String:BossParrotSpawns[NOAMP_MAXSPAWNS+1][128];

new clientLives[MAXPLAYERS+1];
new clientMoney[MAXPLAYERS+1];
new clientKills[MAXPLAYERS+1];

new bool:clientWantsSpec[MAXPLAYERS+1];
new bool:clientForcedSpec[MAXPLAYERS+1];

new clientUpgradesMaxHP[MAXPLAYERS+1];
new clientUpgradesMaxArmor[MAXPLAYERS+1];
new clientUpgradesMaxSpeed[MAXPLAYERS+1];

new clientMaxHPPrice[MAXPLAYERS+1];
new clientMaxArmorPrice[MAXPLAYERS+1];
new clientMaxSpeedPrice[MAXPLAYERS+1];

new clientPowerUpFillSpecial[MAXPLAYERS+1];
new clientPowerUpVultures[MAXPLAYERS+1];

new bool:clientHasVulturesOut[MAXPLAYERS+1];
new bool:clientAboutToKillVultures[MAXPLAYERS+1];
new String:clientVultureTargetname[MAXPLAYERS+1][256];

new clientSavedMoney[MAXPLAYERS+1];
new clientSavedUpgradesMaxHP[MAXPLAYERS+1];
new clientSavedUpgradesMaxArmor[MAXPLAYERS+1];
new clientSavedUpgradesMaxSpeed[MAXPLAYERS+1];
new clientSavedPowerUpFillSpecial[MAXPLAYERS+1];
new clientSavedPowerUpVultures[MAXPLAYERS+1];
new clientSavedHP[MAXPLAYERS+1];
new clientSavedArmorValue[MAXPLAYERS+1];
new clientSavedMaxspeed[MAXPLAYERS+1];
new clientSavedDefaultSpeed[MAXPLAYERS+1];

new clientLastestTeam[MAXPLAYERS+1];
new bool:clientValuesSaved[MAXPLAYERS+1];

new String:schemeName[256] = "null";

new parrotCreatorMode;
new parrotCreatorScheme[NOAMP_MAXWAVES][NOAMP_MAXPARROTCREATOR_WAVES];
/*new parrotCreatorDefaultScheme[1][NOAMP_MAXPARROTCREATOR_WAVES] = 
{ 
	PARROTCREATOR_NORMAL,
	PARROTCREATOR_NORMAL,
	PARROTCREATOR_SMALL,
	PARROTCREATOR_GIANTS,
	PARROTCREATOR_NORMAL
};
*/
new bool:parrotCreatorSpawned;

new parrotDesiredSoundPitch;

new waveParrotCount[NOAMP_MAXWAVES];
new waveGiantParrotCount[NOAMP_MAXWAVES];
new waveMaxParrots[NOAMP_MAXWAVES];
new bool:waveIsBossWave[NOAMP_MAXWAVES];
new bool:waveIsCorruptorWave[NOAMP_MAXWAVES];
new bool:waveIsFoggy[NOAMP_MAXWAVES];

new bool:baseUpgrades[NOAMP_MAXBASEUPGRADES];
new bool:baseUpgradesIsValid[NOAMP_MAXBASEUPGRADES];
new baseUpgradePrices[NOAMP_MAXBASEUPGRADES];

new const String:RoundStartGameSounds[][] =
{
	"Skirmisher.RoundStart",	// Skirmisher
	"Captain.RoundStart",		// Captain
	"Sharpshooter.RoundStart",	// Sharpshooter
	"Berserker.RoundStart",		// Berserker
	"Huscarl.RoundStart",		// Huscarl
	"Gestir.RoundStart",		// Gestir
	"Bondi.RoundStart",			// Bondi
	"HeavyKnight.RoundStart",	// Heavy Knight
	"Archer.RoundStart",		// Archer
	"ManAtArms.RoundStart"		// Man-At-Arms
}

new const String:DeadTeammateGameSounds[][] =
{
	"Skirmisher.DeadTeamMate",		// Skirmisher (None)
	"Captain.DeadTeamMate",			// Captain
	"Sharpshooter.DeadTeamMate",	// Sharpshooter
	"Berserker.DeadTeamMate",		// Berserker
	"Huscarl.DeadTeamMate",			// Huscarl (None)
	"Gestir.DeadTeamMate",			// Gestir
	"Bondi.DeadTeamMate",			// Bondi
	"HeavyKnight.DeadTeamMate",		// Heavy Knight
	"Archer.DeadTeamMate",			// Archer
	"ManAtArms.DeadTeamMate"		// Man-At-Arms (None)
};

new const String:SpookySounds[][] = 
{
	"ambient/creatures/town_moan1.wav",
	"ambient/creatures/town_scared_breathing1.wav",
	"ambient/creatures/town_scared_breathing2.wav",
	"ambient/creatures/town_scared_sob1.wav",
	"ambient/creatures/town_scared_sob2.wav",
	"ambient/machines/combine_terminal_idle1.wav",
	"ambient/machines/combine_terminal_idle2.wav",
	"ambient/machines/combine_terminal_idle3.wav",
	"ambient/machines/combine_terminal_idle4.wav"
};

new const String:CorruptorSpeech[][] = 
{
	"noamp/corruptor/speech1.mp3",
	"noamp/corruptor/speech2.mp3",
	"noamp/corruptor/speech3.mp3",
	"noamp/corruptor/speech4.mp3"
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
new Float:smallParrotSize;
new Float:giantParrotSize;
new Float:bossParrotSize;
new parrotBossHP;

new parrotsKilled;
new spawnedParrots;
new spawnedParrots2;
new wave;
new creatorwave;
new waveCount;
new specialOffset;
new preparingSecs;
new gameOverSecs;
new musicSecs;
new deadplayers;

new corruptsecs;
new bool:soundplayed;

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

new Handle:h_TimerHUD = INVALID_HANDLE;
new Handle:h_TimerWaveThink = INVALID_HANDLE;
new Handle:h_TimerGameWin = INVALID_HANDLE;
new Handle:h_TimerGameOver = INVALID_HANDLE;
new Handle:h_TimerPreparingTime = INVALID_HANDLE;
new Handle:h_TimerParrotCreator = INVALID_HANDLE;
new Handle:h_TimerCorruption = INVALID_HANDLE;
new Handle:h_TimerBossMusicLooper = INVALID_HANDLE;
new Handle:h_TimerKillVultures = INVALID_HANDLE;
new Handle:h_TimerWaitingForPlayers = INVALID_HANDLE;
new Handle:h_TimerCorruptorThink = INVALID_HANDLE;

new timelimitSavedValue;
new String:temphudstr[128];
new String:temphudstr2[128];
