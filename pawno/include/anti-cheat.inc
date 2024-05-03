#include <anticheat\rAgc>//Anti gun cheats -Rogue
#include <anticheat\FLaggers>//Lag spike\desnyc detector- Rogue
#include <anticheat\Opba>//Anti airbreak\teleport - Rogue
#include <anticheat\rAct>//Anti car trolls - Rogue
#include <anticheat\AntiJC>//Anti jetpack cheats- Rogue
#include <anticheat\rEac>//Anti carswing\particlespam - Lorenc_
#include <anticheat\rAmc>//Anti money cheats- Rogue
#include <anticheat\rAGM>//Anti godmode -Rogue
#include <anticheat\AntiFC>//Anti fake clients - Rogue
#include <anticheat\rAsc>//Anti speed cheats- Rogue
#include <anticheat\rVM>//Anti illegal car mods -Emmet_
#include <anticheat\rAcs>//Anti car spam - Rogue
#include <anticheat\AntiSpam>//Anti chat spam- Rogue
#include <anticheat\AntiSba>//Anti slide bug abuse- Rogue

#if !defined FILTERSCRIPT 

#if defined RogueAC_OnGameModeInit
	forward RogueAC_OnGameModeInit();
#endif

public OnGameModeInit()
{
	printf("» Anticheat baþarýyla yüklendi.", 1);

	#if defined RogueAC_OnGameModeInit
		return RogueAC_OnGameModeInit();
	#else
		return 1;
	#endif
}

#if defined _ALS_OnGameModeInit
  #undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif

#define OnGameModeInit RogueAC_OnGameModeInit

#endif
