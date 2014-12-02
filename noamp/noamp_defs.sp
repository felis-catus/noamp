// NOAMP Definitions and stuff like that

#define PL_VERSION "0.4"
#define SERVER_TAG "noamp"
#define CHAT_PREFIX "[NOAMP]"

#define NOAMP_MAXPLAYERS 6
#define NOAMP_MAXWAVES 32
#define NOAMP_BOSSMUSIC "noamp/music/corruptor.mp3"
#define STEAM_GROUP_ID 6185427

#define UPGRADE_MAXHP 1
#define UPGRADE_MAXARMOR 2
#define UPGRADE_MAXSPEED 3

#define POWERUP_FILLSPECIAL 1

#define CHOICE1 "#choice1"
#define CHOICE2 "#choice2"
#define CHOICE3 "#choice3"
#define CHOICE4 "#choice4"
#define CHOICE5 "#choice5"
#define CHOICE6 "#choice6"

#define CLASS_SKIRMISHER 	0
#define CLASS_CAPTAIN 		1
#define CLASS_SHARPSHOOTER 	2
#define CLASS_BERSERKER 	3
#define CLASS_HUSCARL 		4
#define CLASS_GESTIR 		5
#define CLASS_HEAVYKNIGHT 	6
#define CLASS_ARCHER 		7
#define CLASS_MANATARMS 	8

new Handle:cvar_enabled;
new Handle:cvar_debug;
new Handle:cvar_difficulty;
new Handle:cvar_ignoreprefix;
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
new String:ParrotSpawns[1001][128];
new String:GiantParrotSpawns[1001][128];
new String:BossParrotSpawns[1001][128];

new clientLives[MAXPLAYERS+1];
new clientMoney[MAXPLAYERS+1];
new clientSavedMoney[MAXPLAYERS+1];
new clientKills[MAXPLAYERS+1];

new clientOldHP[MAXPLAYERS+1];

new bool:clientUpgradesMaxHP[MAXPLAYERS+1];
new bool:clientUpgradesMaxArmor[MAXPLAYERS+1];
new bool:clientUpgradesMaxSpeed[MAXPLAYERS+1];
new bool:clientSpecialPerks[MAXPLAYERS+1];

new clientPowerUpFillSpecial[MAXPLAYERS+1];

new String:schemeName[256];

new waveParrotCount[NOAMP_MAXWAVES+1];
new waveGiantParrotCount[NOAMP_MAXWAVES+1];
new waveMaxParrots[NOAMP_MAXWAVES+1];
new bool:waveIsBossWave[NOAMP_MAXWAVES+1];

new playerLives;
new maxHPPrice;
new maxArmorPrice;
new maxSpeedPrice;
new powerupFillSpecialPrice;
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
new preparingSecs;
new gameOverSecs;
new hudSecs;
new musicSecs;
new deadplayers;

new bool:IsEnabled;
new bool:IsGameStarted;
new bool:IsGameOver;
new bool:IsPreparing;
new bool:IsWaitingForPlayers;
new bool:IsLivesDisabled;
new bool:giantParrotSpawned;
new bool:bossParrotSpawned;

new parrotCurrentBossHP;
new parrotSoundPitch;

new Handle:hGiveNamedItem;
new Handle:hWeapon_Equip;
new Handle:hGiveAmmo;
new Handle:hRemoveAllItems;

new h_iSpecial;
new h_iHealth;
new h_ArmorValue;
new h_iMaxHealth;
new h_iMaxArmor;
new h_flMaxspeed;
new h_flDefaultSpeed;
new h_iPlayerClass;
new h_flModelScale;

/* if there ever is a use for these
static const class_default_properties[9][3] = 
{
{ 100 , 90  }, // skirmisher
{ 125 , 150 }, // captain
{ 100 , 80  }, // sharpshooter
{ 175 , 100 }, // berserker
{ 130 , 160 }, // huscarl
{ 115 , 120 }, // gestir
{ 125 , 200 }, // heavy knight
{ 100 , 80  }, // archer
{ 105 , 130  } // man at arms
};

static const Float:class_default_speeds[9] = 
{
260.0, // skirmisher
210.0, // captain
210.0, // sharpshooter
220.0, // berserker
200.0, // huscarl
210.0, // gestir
190.0, // heavy knight
210.0, // archer
225.0  // man at arms
};
*/