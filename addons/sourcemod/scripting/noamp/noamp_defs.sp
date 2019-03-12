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

#define PL_VERSION "0.6a"
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

Handle cvar_enabled = INVALID_HANDLE;
Handle cvar_debug = INVALID_HANDLE;
Handle cvar_difficulty = INVALID_HANDLE;
Handle cvar_scheme = INVALID_HANDLE;
Handle cvar_ignoreprefix = INVALID_HANDLE;
Handle cvar_timelimit = INVALID_HANDLE;
Handle cvar_dmoldrules = INVALID_HANDLE;
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

char ScriptPath[ PLATFORM_MAX_PATH ];
char ParrotCreatorScriptPath[ PLATFORM_MAX_PATH ];

bool g_bIsMapLoaded = false;
bool IsCustomScheme = false;
char ParrotSpawns[ NOAMP_MAXSPAWNS+1 ][ 128 ];
char GiantParrotSpawns[ NOAMP_MAXSPAWNS+1 ][ 128 ];
char BossParrotSpawns[ NOAMP_MAXSPAWNS+1 ][ 128 ];

int clientLives[ MAXPLAYERS+1 ];
int clientMoney[ MAXPLAYERS+1 ];
int clientKills[ MAXPLAYERS+1 ];

bool clientWantsSpec[ MAXPLAYERS+1 ];
bool clientForcedSpec[ MAXPLAYERS+1 ];

int clientUpgradesMaxHP[ MAXPLAYERS+1 ];
int clientUpgradesMaxArmor[ MAXPLAYERS+1 ];
int clientUpgradesMaxSpeed[ MAXPLAYERS+1 ];

int clientMaxHPPrice[ MAXPLAYERS+1 ];
int clientMaxArmorPrice[ MAXPLAYERS+1 ];
int clientMaxSpeedPrice[ MAXPLAYERS+1 ];

int clientPowerUpFillSpecial[ MAXPLAYERS+1 ];
int clientPowerUpVultures[ MAXPLAYERS+1 ];

bool clientHasVulturesOut[ MAXPLAYERS+1 ];
bool clientAboutToKillVultures[ MAXPLAYERS+1 ];
char clientVultureTargetname[ MAXPLAYERS+1 ][ 256 ];

int clientSavedMoney[ MAXPLAYERS+1 ];
int clientSavedUpgradesMaxHP[ MAXPLAYERS+1 ];
int clientSavedUpgradesMaxArmor[ MAXPLAYERS+1 ];
int clientSavedUpgradesMaxSpeed[ MAXPLAYERS+1 ];
int clientSavedPowerUpFillSpecial[ MAXPLAYERS+1 ];
int clientSavedPowerUpVultures[ MAXPLAYERS+1 ];
int clientSavedHP[ MAXPLAYERS+1 ];
int clientSavedArmorValue[ MAXPLAYERS+1 ];
int clientSavedMaxspeed[ MAXPLAYERS+1 ];
int clientSavedDefaultSpeed[ MAXPLAYERS+1 ];

int clientLastestTeam[ MAXPLAYERS+1 ];
bool clientValuesSaved[ MAXPLAYERS+1 ];

char schemeName[ 256 ] = "null";

int parrotCreatorMode;
int parrotCreatorScheme[ NOAMP_MAXWAVES ][ NOAMP_MAXPARROTCREATOR_WAVES ];
/*new parrotCreatorDefaultScheme[1][NOAMP_MAXPARROTCREATOR_WAVES] = 
{ 
	PARROTCREATOR_NORMAL,
	PARROTCREATOR_NORMAL,
	PARROTCREATOR_SMALL,
	PARROTCREATOR_GIANTS,
	PARROTCREATOR_NORMAL
};
*/
bool parrotCreatorSpawned;

int parrotDesiredSoundPitch;

int waveParrotCount[ NOAMP_MAXWAVES ];
int waveGiantParrotCount[ NOAMP_MAXWAVES ];
int waveMaxParrots[ NOAMP_MAXWAVES ];
bool waveIsBossWave[ NOAMP_MAXWAVES ];
bool waveIsCorruptorWave[ NOAMP_MAXWAVES ];
bool waveIsFoggy[ NOAMP_MAXWAVES ];

bool baseUpgrades[ NOAMP_MAXBASEUPGRADES ];
bool baseUpgradesIsValid[ NOAMP_MAXBASEUPGRADES ];
int baseUpgradePrices[ NOAMP_MAXBASEUPGRADES ];

char RoundStartGameSounds[][] =
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

char DeadTeammateGameSounds[][] =
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

char SpookySounds[][] = 
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

char CorruptorSpeech[][] = 
{
	"noamp/corruptor/speech1.mp3",
	"noamp/corruptor/speech2.mp3",
	"noamp/corruptor/speech3.mp3",
	"noamp/corruptor/speech4.mp3"
};

int playerLives;
int maxHPPrice;
int maxArmorPrice;
int maxSpeedPrice;
int powerupFillSpecialPrice;
int powerupVulturesPrice;
int kegPrice;
int chestAward;
int preparationSecs;
float smallParrotSize;
float giantParrotSize;
float bossParrotSize;
int parrotBossHP;

int parrotsKilled;
int spawnedParrots;
//int spawnedParrots2;
int wave;
int creatorwave;
int waveCount;
//int specialOffset;
int preparingSecs;
int gameOverSecs;
int musicSecs;
//int deadplayers;

int corruptsecs;
bool soundplayed;

bool g_bIsEnabled;
bool g_bHasGameStarted;
bool HasWaveStarted;
bool IsGameOver;
bool IsPreparing;
bool IsCorrupted;
bool IsWaitingForPlayers;
bool IsLivesDisabled;
bool giantParrotSpawned;
bool bossParrotSpawned;

int parrotCurrentBossHP;
int parrotSoundPitch;
int timerSoundPitch;

int h_iSpecial;
int h_iMaxSpecial;
int h_iHealth;
int h_ArmorValue;
int h_iMaxHealth;
int h_iMaxArmor;
int h_flMaxspeed;
int h_flDefaultSpeed;
int h_iPlayerClass;
int h_iChestLastOwner = 1504; // HACK: Must be hard-coded

Handle h_TimerHUD = INVALID_HANDLE;
Handle h_TimerWaveThink = INVALID_HANDLE;
Handle h_TimerGameWin = INVALID_HANDLE;
Handle h_TimerGameOver = INVALID_HANDLE;
Handle h_TimerPreparingTime = INVALID_HANDLE;
Handle h_TimerParrotCreator = INVALID_HANDLE;
Handle h_TimerCorruption = INVALID_HANDLE;
Handle h_TimerBossMusicLooper = INVALID_HANDLE;
Handle h_TimerKillVultures = INVALID_HANDLE;
Handle h_TimerWaitingForPlayers = INVALID_HANDLE;
Handle h_TimerCorruptorThink = INVALID_HANDLE;

int timelimitSavedValue;
char temphudstr[ 128 ];
char temphudstr2[ 128 ];
