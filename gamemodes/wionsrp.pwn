/*
	WionS Roleplay.
	Kodlama Baslangic: 03.05.2024
	Developer: Abusivesnake & Cyrus
*/

#pragma compat 1
#pragma dynamic 700000

// Ellemeyiniz //
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
// Ellemeyiniz //

#include <a_samp>
#include <a_mysql>
#include <izcmd>
#include <sscanf2>
#include <easyDialog>

#define SQL_HOST "localhost"
#define SQL_USER "root"
#define SQL_PASS ""
#define SQL_DATA "ab_db"

#define MAX_BIRLIK 100 // Maksimum oluşturulabilecek birlik sayısıdır.

#define BIRLIK_CETE 1
#define BIRLIK_MAFYA 2
#define BIRLIK_HABER 3
#define BIRLIK_LEGAL 4
#define BIRLIK_LSPD 5
#define BIRLIK_LSMD 6
#define BIRLIK_FBI 7
#define BIRLIK_GOV 8

#define Hata(%0,%1)    \
	SendClientMessageEx(%0, -1, "{FF0000}[HATA]: {fafafa}"%1)

new MySQL:mysqlC;

enum pData
{
	pID,
	pHesapID,
	pYas,
	pCinsiyet,
	pTen,
	pGozRengi[24],
	pSacRengi[24],
	pAdmin,
	pAdminName[24],
	pHelper,
	pHelperName[24],
	pMask,
	pMaskID,
	pFaction
};

new PlayerData[MAX_PLAYERS][pData];

enum BirlikData
{
	birlikID,
	birlikExists,
	birlikAd[32],
	birlikColor,
	birlikTip,
	birlikRutbeler,
	birlikOnaylar[5],
	birlikYetkilendirme[8],
	birlikDuyuru[128],
	birlikKasaPara,
	OOCDurum,
	yayinDurum,
	yayinTipi,
	ReklamAlimi,
	ReklamUcreti,
	ReklamSayisi,
	bool:CekilisBasladi,
	cekilisOdul,
	Text3D:reklamLabel,
	reklamPickup,
	Float:reklamPos[3],
	yayinNumara
};

new Birlikler[MAX_BIRLIK][BirlikData];
new BirlikRutbe[MAX_BIRLIK][15][32];
new BirlikDivizyon[MAX_BIRLIK][5][20];

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
	AddPlayerClass(1, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0); // Truth
	printf("[MySQL]: Veritabani baglantisi kuruluyor...");
	mysqlC = mysql_connect(SQL_HOST, SQL_USER, SQL_PASS, SQL_DATA);
	if(mysql_errno(mysqlC) == 0)
	{
		printf("[MySQL]: Veritabani baglantisi basarili!");
	}
	else
	{
		printf("[MySQL]: Veritabani baglantisi basarisiz!");
	}
	return 1;
}

public OnGameModeExit()
{
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
	if(IsPlayerNPC(playerid)) return 1;
	if(!IsValidRoleplayName(ReturnName(playerid)))
	{
		Hata(playerid, "Isminiz roleplaye uygun degil! ( Ornek: Javier_Taylor )");
		Kick(playerid);
		return 1;
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
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

//  --  [STOCKLAR]  --  //

stock IsValidRoleplayName(const name[]) 
{
	if(!name[0] || strfind(name, "_") == -1) return 0;
	else for(new i = 0, len = strlen(name); i != len; i ++) 
	{
	    if((i == 0) && (name[i] < 'A' || name[i] > 'Z')) return 0;
		else if((i != 0 && i < len  && name[i] == '_') && (name[i + 1] < 'A' || name[i + 1] > 'Z')) return 0;
		else if((name[i] < 'A' || name[i] > 'Z') && (name[i] < 'a' || name[i] > 'z') && name[i] != '_' && name[i] != '.') return 0;
	}
	return 1;
}

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

stock GetFactionType(playerid)
{
	if(PlayerData[playerid][pFaction] == -1) return 0;
	return (Birlikler[PlayerData[playerid][pFaction]][birlikTip]);
}

stock factcolor(tip)
{
	new color[52];
	if(tip == BIRLIK_LSPD) format(color, sizeof(color), "8B91FF");
	else if(tip == BIRLIK_LSMD) format(color, sizeof(color), "FF3F6F");
	else if(tip == BIRLIK_GOV) format(color, sizeof(color), "D9B7D8");
	else if(tip == BIRLIK_FBI) format(color, sizeof(color), "4427FF");
	else format(color, sizeof(color), "FAFAFA");
	return color;
}

stock GetFactionColor(playerid)
{
	new scolor[52];
	format(scolor, sizeof(scolor), "%s", factcolor(Birlikler[PlayerData[playerid][pFaction]][birlikTip]));
	return scolor;
}

ReturnName(playerid, underscore=1)
{
	static name[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, name, sizeof(name));
	if(!underscore) 
	{
	    for(new i = 0, len = strlen(name); i < len; i ++) 
		{
	        if (name[i] == '_') name[i] = ' ';
		}
	}
	if(PlayerData[playerid][pMask]) format(name, sizeof(name), "Gizli (%d)", PlayerData[playerid][pMaskID]);
	return name;
}

stock olusumetiket(fac)
{
	new fact[512];
	if (fac == BIRLIK_LSPD)
	{
		format(fact, sizeof(fact), "@lspd");
	}
	else if (fac == BIRLIK_LSMD)
	{
		format(fact, sizeof(fact), "@lsfmd");
	}
	else if (fac == BIRLIK_FBI)
	{
		format(fact, sizeof(fact), "@fbi");
	}
	else if (fac == BIRLIK_GOV)
	{
		format(fact, sizeof(fact), "@gov");
	}
	else if (fac == BIRLIK_HABER)
	{
		format(fact, sizeof(fact), "@tv");
	}
	else
	{
		format(fact, sizeof(fact), "@birlik");
	}
	return fact;
}

//  --  [KOMUTLAR]  --  //

CMD:dolap(playerid, params[])
{
	if(GetFactionType(playerid) == BIRLIK_LSPD)
	{
		if(!IsPlayerInRangeOfPoint(playerid, 5.0, 1490.451049, -1070.520263, 1025.005859)) return Hata(playerid, "Dolaba yeterince yakın değilsiniz!");
		new baslik[512], string[1050];
		format(baslik, sizeof(baslik), "{%s}(%s){fafafa}", GetFactionColor(playerid), olusumetiket(Birlikler[PlayerData[playerid][pFaction]][birlikTip]));
		format(string, sizeof(string), "{%s}» {FFFFFF}İşbaşı\n{%s}» {FFFFFF}Üniformalar\n{%s}» {FFFFFF}Ekipmanlar\n{FF0000}» {FFFFFF}Silah Sıfırla", GetFactionColor(playerid), GetFactionColor(playerid), GetFactionColor(playerid));
		Dialog_Show(playerid,LSPDDolap,DIALOG_STYLE_LIST, baslik, string, "Onayla", "Kapat");
	}
	return 1;
}