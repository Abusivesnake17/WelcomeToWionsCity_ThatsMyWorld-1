#pragma compat 1
#pragma dynamic 700000

// Elleme //
#pragma warning disable 239
#pragma warning disable 214
#pragma warning disable 217
#pragma warning disable 225
#pragma warning disable 202
#pragma warning disable 219
#pragma warning disable 204
#pragma warning disable 213
#pragma warning disable 202
#pragma warning disable 201
#pragma warning disable 235
#pragma warning disable 215
#pragma warning disable 202
#pragma warning disable 203
// Elleme //

#include <a_samp>
#include <fix>
#include <a_mysql>
#include <streamer>
#include <sqlitei>
#include <sscanf2>
#include <izcmd>
#include <YSI\y_iterate>
#include <YSI\y_bit>
#include <foreach>
#include <dialogs>
#include <SKY>
#include <weapon-data>
#include <weapon-config>
#include <easyDialog>
#include <mSelection>
#include <progress2>
#include <cuffs>
#include <evi>
#include <vSyncALS>
#include <AFK>
#include <garage_block>
#include <renkler>
#include <kick-fix>
#include <physics>
#include <wristwatch>
#include <wristwatch>

#define SQL_HOST "localhost"
#define SQL_USER "root"
#define SQL_PASS ""
#define SQL_DATA "ab_db"

#define SERVER_MUZIK "https://cdn.discordapp.com/attachments/847790186183655444/1225040478878306335/Hayaller_Kurardk_MM.mp3?ex=663e015a&is=663cafda&hm=d73ec56773d30b4060bb0d049c0e3954c655c3ab1940250e32da3c479f933d42&"

#define Hata(%0,%1)    \
	SendClientMessageEx(%0, -1, "{FF0000}[HATA]: {fafafa}"%1)

#define Bilgi(%0,%1)    \
	SendClientMessageEx(%0, -1, "{33CC33}[BILGI]: {fafafa}"%1)

#define Kullanim(%0,%1)    \
	SendClientMessageEx(%0, -1, "{5762FF}[KULLANIM]: {fafafa}"%1)

#define Mesaj(%0,%1)    \
	SendClientMessageEx(%0, -1, "{3EC9F7}[MESAJ]: {fafafa}"%1)

#define function%0(%1) forward%0(%1); public%0(%1)

new MySQL:mysqlC;
new PlayerText: GirisTD[MAX_PLAYERS][1];
new pDrunkLevelLast[MAX_PLAYERS];
new MobilKullanici[MAX_PLAYERS];
new Download[MAX_PLAYERS];
new Text: WionS_Global[1];
new FPS[MAX_PLAYERS];
new FPSS[MAX_PLAYERS];
new pFPS[MAX_PLAYERS];
new Text:Fpsxd[MAX_PLAYERS];
new Text:Karanlik;

enum pData
{
	pID,
	pHesapID,
	pLevel,
	pMaske,
	pMaskeID,
	pPara,
	pSkin,
	pAdmin,
	pAdminName[24],
	pHelper,
	pHelperName[24],
	pCikisVw,
};

new PlayerData[MAX_PLAYERS][pData];

main()
{
	print("\n----------------------------------");
	print("[DEVELOPER]: Abusivesnake");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	SetGameModeText("W:RP - v1.0.0");
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); // CJ
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); // Truth

	Karanlik = TextDrawCreate(644.000000, 0.000000, "                                                                                                                             ");
	TextDrawBackgroundColor(Karanlik,255);
	TextDrawFont(Karanlik,1);
	TextDrawLetterSize(Karanlik, 0.500000, 1.000000);
	TextDrawColor(Karanlik, -1);
	TextDrawSetOutline(Karanlik,0);
	TextDrawSetProportional(Karanlik,1);
	TextDrawSetShadow(Karanlik,1);
	TextDrawUseBox(Karanlik,1);
	TextDrawBoxColor(Karanlik,255);
	TextDrawTextSize(Karanlik, -11.000000, 0.000000);
	return 1;
}

public OnGameModeExit()
{
    TextDrawHideForAll(Karanlik);
	TextDrawDestroy(Karanlik);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	WionS_Global[0] = TextDrawCreate(311.000, 433.000, "WionS Roleplay");
	TextDrawLetterSize(WionS_Global[0], 0.300, 1.500);
	TextDrawAlignment(WionS_Global[0], 2);
	TextDrawColor(WionS_Global[0], 1466105855);
	TextDrawUseBox(WionS_Global[0], 1);
	TextDrawBoxColor(WionS_Global[0], 150);
	TextDrawSetShadow(WionS_Global[0], 0);
	TextDrawSetOutline(WionS_Global[0], 1);
	TextDrawBackgroundColor(WionS_Global[0], 255);
	TextDrawFont(WionS_Global[0], 2);
	TextDrawSetProportional(WionS_Global[0], 1);

	Fpsxd[playerid] = TextDrawCreate(569.882446, 1.749999, "~b~~h~~h~FPS: ~w~100 ~b~~h~~h~PING: ~w~10000");
	TextDrawLetterSize(Fpsxd[playerid], 0.155882, 1.034166);
	TextDrawAlignment(Fpsxd[playerid], 1);
	TextDrawColor(Fpsxd[playerid], -1);
	TextDrawSetShadow(Fpsxd[playerid], 0);
	TextDrawSetOutline(Fpsxd[playerid], 1);
	TextDrawBackgroundColor(Fpsxd[playerid], 51);
	TextDrawFont(Fpsxd[playerid], 2);
	TextDrawSetProportional(Fpsxd[playerid], 1);

	pDrunkLevelLast[playerid] = 0;
 	pFPS[playerid] = 0;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(GetPVarInt(playerid, "Kayit") == 1)
	{
	    SetPVarInt(playerid, "Kayit", 0);
	    SetPVarInt(playerid, "Logged",1);
	    SetPVarInt(playerid, "GirisYapti", 1);
		SetPlayerColor(playerid,COLOR_WHITE);
		TogglePlayerSpectating(playerid, false);
		SetPlayerInterior(playerid,0);
		SetPlayerVirtualWorld(playerid,0);
		SetPlayerSkin(playerid, PlayerData[playerid][pSkin]);
		SetCameraBehindPlayer(playerid);
		PlayerData[playerid][pLevel] = 1;
		SetPlayerScore(playerid, PlayerData[playerid][pLevel]);
		PlayerData[playerid][pPara] = 1000;
		GivePlayerMoney(playerid, PlayerData[playerid][pPara]);
		format(PlayerData[playerid][pAdminName], 24, "Yok");
		PlayerData[playerid][pAdmin] = 0;
		PlayerData[playerid][pHelper] = 0;
		PlayerData[playerid][pCikisVw] = 0;
		SetPlayerVirtualWorld(playerid, PlayerData[playerid][pCikisVw]);
		Mesaj(playerid,"Karakteriniz oluşturuldu, yardıma ihtiyacınız olduğunda (/destek) komutunu kullanabilirsiniz.");
		Mesaj(playerid, "İyi roller dileriz.");
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	TextDrawShowForPlayer(playerid, Fpsxd[playerid]);
	TextDrawShowForPlayer(playerid, WionS_Global[0]);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	new String[128];
	new FPSSS = GetPlayerDrunkLevel(playerid), fps; if (FPSSS < 100) { SetPlayerDrunkLevel(playerid, 2000); } else { if (FPSSS != FPSS[playerid]) { fps = FPSS[playerid] - FPSSS; if (fps > 0 && fps < 200) FPS[playerid] = fps; FPSS[playerid] = FPSSS; } }
	format(String, sizeof(String), "~b~~h~~h~Fps: ~w~%d ~y~- ~b~~h~~h~Ping: ~w~%d",FPS[playerid], GetPlayerPing(playerid));
	TextDrawSetString(Fpsxd[playerid], String);
	new keys, ud, lr, drunknew;
 	GetPlayerKeys(playerid, keys, ud, lr);
    drunknew = GetPlayerDrunkLevel(playerid);
	if(GetPlayerWeapon(playerid) == 16)
	{
		AdminMessage(COLOR_LIGHTRED, "CheatLog: %s (%d), Silah hilesi kullanmaya calisti, sunucudan atildi. (CODE: 2)", ReturnName(playerid, 0), playerid);
	    Kick(playerid);
	    return 0;
    }
        if(drunknew < 100) 
		{
        	SetPlayerDrunkLevel(playerid, 2000);
    	}
	else
	{
        if(pDrunkLevelLast[playerid] != drunknew)
		{
            new wfps = pDrunkLevelLast[playerid] - drunknew;
            if((wfps > 0) && (wfps < 200)) pFPS[playerid] = wfps;
            pDrunkLevelLast[playerid] = drunknew;
        }
    }
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnPlayerPrepareDeath(playerid, animlib[32], animname[32], &anim_lock, &respawn_time)
{
	if(GetPVarInt(playerid, "GozBaglandi") == 1)
	{
	    SetPVarInt(playerid, "GozBaglandi", 0);
	    TextDrawHideForPlayer(playerid, Karanlik);
	}
	return 1;
}

//   --   [STOCKLAR]   --   //

stock SendClientMessageEx(playerid, color, const text[], {Float, _}:...)
{
	static args, str[144];
	if((args = numargs()) == 3)
	{
	    SendClientMessage(playerid, color, text);
	}
	else
	{
		while(--args >= 3)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit PUSH.S 8
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4
		SendClientMessage(playerid, color, str);
		#emit RETN
	}
	return 1;
}

//  --  [KOMUTLAR]  --  //

CMD:fps(playerid)
{
    if(!OyundaDegil(playerid)) return Hata(playerid, "Oyunda degilsiniz veya giris yapmamissiniz!");
    new fps = FPS[playerid];
	Bilgi(playerid, "Anlik FPS degeriniz: %d", fps);
    return 1;
}

CMD:anlik(playerid)
{
    if(!OyundaDegil(playerid)) return Hata(playerid, "Oyunda degilsiniz veya giris yapmamissiniz!");
    new vw = GetPlayerVirtualWorld(playerid), fps = FPS[playerid], ping = GetPlayerPing(playerid);
	Bilgi(playerid, "Anlik virtual worldunuz: %d - FPS degeriniz: %d - Ping degeriniz: %d", vw, fps, ping);
	return 1;
}

CMD:id(playerid, params[])
{
	new szMessage[128],szName[MAX_PLAYER_NAME],iTarget,iSuccess;
	if(isnull(params)) return Kullanim(playerid,"/id [Oyuncu ID/Isim]");
	foreach(Player, i)
	{
		GetPlayerName(i, szName, sizeof(szName));
		if(strfind(szName, params, true) != -1)
		{
			format(szMessage, sizeof(szMessage), "ID: %d | Isim: %s | Level: %d | Ping: %d | FPS: %d", i, ReturnName(i, 0),  PlayerData[i][pLevel], GetPlayerPing(i), FPS[i]);
			SendClientMessage(playerid, COLOR_WHITE, szMessage);
			iSuccess ++;
		}
	}
	if(iSuccess == 0)
	{
		if(!sscanf(params, "u", iTarget))
		{
			if(IsPlayerConnected(iTarget))
			{
				format(szMessage, sizeof(szMessage), "ID: %d | Isim: %s | Level: %d | Ping: %d | FPS: %d", iTarget, ReturnName(iTarget, 0),  PlayerData[iTarget][pLevel], GetPlayerPing(iTarget), FPS[iTarget]);
				SendClientMessage(playerid, COLOR_WHITE, szMessage);
				iSuccess ++;
			}
		}
	}
	if(iSuccess == 0) Hata(playerid, "Gecersiz kullanici belirlendi!");
	return 1;
}

CMD:ssmod(playerid)
{
    if(!OyundaDegil(playerid)) return 1;
    if(GetPVarInt(playerid, "ssmod") == 0)
	{
	    SetPVarInt(playerid, "ssmod", 1);
	    TextDrawShowForPlayer(playerid, Karanlik);
	}
	else
	{
	    DeletePVar(playerid, "ssmod");
     	TextDrawHideForPlayer(playerid, Karanlik);
	}
	return 1;
}

//  --  [STOCKLAR]  --  //

stock BilgiTemizle(playerid)
{
 	SetPVarInt(playerid, "ssmod", 0);
 	TextDrawHideForPlayer(playerid, Karanlik);
}

ReturnName(playerid, underscore=1)
{
	static name[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, name, sizeof(name));
	if (!underscore)
	{
	    for (new i = 0, len = strlen(name); i < len; i ++)
		{
	        if (name[i] == '_') name[i] = ' ';
		}
	}
	if (PlayerData[playerid][pMaske]) format(name, sizeof(name), "Gizli #%d", PlayerData[playerid][pMaskeID]);
	return name;
}

stock OyundaDegil(playerid)
{
	if(!IsPlayerConnected(playerid) || GetPVarInt(playerid, "Logged") == 0)
	{
	    return 0;
	}
	return 1;
}

stock AdminMessage(color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 8)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 8); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        foreach (new i : Player)
		{
			if (PlayerData[i][pAdmin] >= 1)
			{
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
    foreach (new i : Player)
	{
		if (PlayerData[i][pAdmin] >= 1)
		{
			SendClientMessage(i, color, str);
		}
	}
	return 1;
}