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
#include <discord-connector>
#include <discord-cmd>
#include <foreach>
#include <streamer>
#include <YSI\y_iterate>
#include <renkler>

#define SQL_HOST "localhost"
#define SQL_USER "root"
#define SQL_PASS ""
#define SQL_DATA "ab_db"

#define function%0(%1) forward%0(%1); public%0(%1)

#define MAX_BIRLIK 100 // Maksimum oluşturulabilecek birlik sayısıdır.
#define MAX_BIRLIK 100 // Maksimum oluşturulabilecek birlik sayısıdır.

#define BIRLIK_CETE      (1)
#define BIRLIK_MAFYA     (2)
#define BIRLIK_HABER     (3)
#define BIRLIK_LEGAL     (4)
#define BIRLIK_LSPD      (5)
#define BIRLIK_LSMD      (6)
#define BIRLIK_FBI       (7)
#define BIRLIK_GOV       (8)
#define BIRLIK_TAMIRHANE (9)

#define Hata(%0,%1)    \
	SendClientMessageEx(%0, -1, "{FF0000}[HATA]: {fafafa}"%1)

#define Bilgi(%0,%1)    \
	SendClientMessageEx(%0, -1, "{33CC33}[BILGI]: {fafafa}"%1)

#define Kullanim(%0,%1)    \
	SendClientMessageEx(%0, -1, "{5762FF}[W:RP]: {fafafa}"%1)

#define Uyari(%0,%1)    \
	SendClientMessageEx(%0, -1, "{FF9900}[UYARI]: {fafafa}"%1)

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
	pFaction,
	pLSPDDuty,
	pFactionRutbe,
	pFactionDivizyon
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
new Iterator:CekilisKatilimcilar[MAX_BIRLIK]<300>;
new Birlikler[MAX_BIRLIK][BirlikData];
new BirlikRutbe[MAX_BIRLIK][15][32];
new BirlikDivizyon[MAX_BIRLIK][5][20];
new oyuncusayisi = 0;
new DCC_Channel: girislog;
new DCC_Channel: cikislog;

AntiDeAMX()
{
    new Abusivesnake[][] =
    {
        "Unarmed (Fist)",
        "Brass K"
    };
    #pragma unused Abusivesnake
}

WasteDeAMXersTime()
{
    new Abusivesnake;
    #emit load.pri Abusivesnake
    #emit stor.pri Abusivesnake
}

main()
{
	print("\n----------------------------------");
	print("[DEVELOPER]: Abusivesnake");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	girislog = DCC_FindChannelById("1123344851417710715");
	cikislog = DCC_FindChannelById("1123344851417710715");
	AntiDeAMX();
	WasteDeAMXersTime();
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);
    ShowNameTags(1);
    SetNameTagDrawDistance(45.0);
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
    ManualVehicleEngineAndLights();
	DCC_SetBotPresenceStatus(3);
	DCSayim();
	SetGameModeText("W:RP - v1.0.0");
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
	CreateDynamicPickup(1239, 23, 261.8779, 109.7122, 1004.6172, -1, 10);
	CreateDynamic3DTextLabel("{1394BF}LSPD Dolap\n{fafafa}/dolap ile acabilirsiniz.", -1, 261.8779, 109.7122, 1004.6172, 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, 10);
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
	new query[128];
	format(query, sizeof(query), "SELECT * FROM `oyuncular` WHERE Isim='%s'", ReturnName(playerid));
	mysql_tquery(mysqlC, query, "OyuncuYukle", "d", playerid);
/*	if(IsPlayerNPC(playerid)) return 1;
	if(!IsValidRoleplayName(ReturnName(playerid)))
	{
		Hata(playerid, "Isminiz roleplaye uygun degil! ( Ornek: Javier_Taylor )");
		Kick(playerid);
		return 1;
	}
	oyuncusayisi += 1;
	DCSayim();
	OyuncuGirisDC(playerid);*/
	return 1;
}

function OyuncuYukle(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(!rows)
	{
		Dialog_Show(playerid, Kayit, DIALOG_STYLE_INPUT, "{5762FF}WionS Roleplay - Kayit", "{fafafa}Sunucumuza hos geldiniz!\n\n{FF9900}Karakter Adi: {fafafa}%s\n\n{FF9900}IP Adresiniz: {fafafa}%s\n\n{fafafa}Kaydolmak icin sifrenizi giriniz: ", ReturnName(playerid, 0), GetIP(playerid));
	}
	else
	{
		Dialog_Show(playerid, Giris, DIALOG_STYLE_PASSWORD, "{5762FF}WionS Roleplay - Giris", "{fafafa}Sunucumuza tekrardan hos geldiniz!\n\n{FF9900}Karakter Adi: {fafafa}%s\n\n{FF9900}IP Adresiniz: {fafafa}%s\n\n{fafafa}Giris yapmak icin sifrenizi giriniz: ", ReturnName(playerid, 0), GetIP(playerid));
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
   	if(!IsPlayerNPC(playerid))
   	{
	   	new sebep[30];
	   	switch(reason)
	   	{
			case 0: sebep = "baglantisi koptu";
			case 1: sebep = "kendi istegiyle";
			case 2: sebep = "kick/ban";
			default: sebep = "Bilinmiyor";
	   	}
	   	SendNearbyMessage(playerid, 10.0, 0xAFAFAFFF, "%s sunucudan ayrildi. (%s)", ReturnName(playerid, 0), sebep);
		oyuncusayisi -= 1;
		DCSayim();
		OyuncuCikisDC(playerid);
   	}
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

stock Birlik_Olustur(birlikisim[],tip)
{
    for (new i = 0; i != MAX_BIRLIK; i ++) if (!Birlikler[i][birlikExists])
    {
        Birlikler[i][birlikExists] = true;
        format(Birlikler[i][birlikAd],32,birlikisim);
        Birlikler[i][birlikDuyuru][0] = '\0';
        if(tip != 3) Birlikler[i][birlikColor] = 0xFFFFFF00;
        else Birlikler[i][birlikColor] = 0x9ACD32FF;
        Birlikler[i][birlikTip] = tip;
        switch(tip)
        {
            case 1..4: Birlikler[i][birlikRutbeler] = 6;
            default: Birlikler[i][birlikRutbeler] = 12;
        }
        Birlikler[i][birlikKasaPara] = 0;
        Birlikler[i][birlikOnaylar][0] = 0;
        Birlikler[i][birlikOnaylar][1] = 0;
        Birlikler[i][birlikOnaylar][2] = 0;
        Birlikler[i][birlikOnaylar][3] = 0;
        Birlikler[i][birlikOnaylar][4] = 0;
        Birlikler[i][OOCDurum] = 1;
        Birlikler[i][birlikYetkilendirme][0] = Birlikler[i][birlikRutbeler]-1; // Üye Alma
        Birlikler[i][birlikYetkilendirme][1] = Birlikler[i][birlikRutbeler]-1; // Üye Atma
        Birlikler[i][birlikYetkilendirme][2] = Birlikler[i][birlikRutbeler]-2; // Rütbe Değiştirme
        Birlikler[i][birlikYetkilendirme][3] = Birlikler[i][birlikRutbeler]-2; // Divizyon Değiştirme
        Birlikler[i][birlikYetkilendirme][4] = Birlikler[i][birlikRutbeler]-3; // Araçları Spawnlama
        Birlikler[i][birlikYetkilendirme][5] = Birlikler[i][birlikRutbeler]-3; // Birlik OOC Chat Kapatma
        Birlikler[i][birlikYetkilendirme][6] = Birlikler[i][birlikRutbeler]; // Birlik Kasasından Para Alma
        Birlikler[i][birlikYetkilendirme][7] = 1; // Ajans Ayarları Seviyesi
        Birlikler[i][yayinDurum] = 1;
        Birlikler[i][yayinTipi] = 0;
        Birlikler[i][ReklamAlimi] = 0;
        Birlikler[i][ReklamUcreti] = 0;
        Birlikler[i][ReklamSayisi] = 0;
        Birlikler[i][CekilisBasladi] = false;
        Birlikler[i][cekilisOdul] = 0;
        Birlikler[i][reklamPos][0] = 0.0;
        Birlikler[i][reklamPos][1] = 0.0;
        Birlikler[i][reklamPos][2] = 0.0;
        if(IsValidDynamicPickup(Birlikler[i][reklamPickup])) DestroyDynamicPickup(Birlikler[i][reklamPickup]);
        if(IsValidDynamic3DTextLabel(Birlikler[i][reklamLabel])) DestroyDynamic3DTextLabel(Birlikler[i][reklamLabel]);
        for (new j = 0; j < 15; j ++)
        {
            if(j < 5)
            {
                format(BirlikDivizyon[i][j],20,"Birim %d",j+1);
            }
            format(BirlikRutbe[i][j],32,"Rutbe %d",j+1);
        }
        mysql_tquery(mysqlC, "INSERT INTO `birlikler` (`bRutbeler`) VALUES(10)", "OnFactionCreated", "d", i);
        return i;
    }
    return -1;
}

stock Birlik_Sil(factionid)
{
	if(factionid != -1 && Birlikler[factionid][birlikExists])
	{
	    new string[150];
		format(string, sizeof(string), "DELETE FROM `birlikler` WHERE `bid` = '%d'",Birlikler[factionid][birlikID]);
		mysql_query(mysqlC, string, false);
		format(string, sizeof(string), "UPDATE `oyuncular` SET `Birlik` = '-1',`BirlikRutbe` = '0',`BirlikDivizyon` = '0' WHERE `Birlik` = '%d'", factionid);
		mysql_query(mysqlC, string, false);
 		foreach (new i : Player)
		{
			if(PlayerData[i][pFaction] == factionid) 
			{
		    	PlayerData[i][pFaction] = -1;
		    	PlayerData[i][pFactionRutbe] = 0;
		    	PlayerData[i][pFactionDivizyon] = 0;
			}
		}
        if(IsValidDynamicPickup(Birlikler[factionid][reklamPickup])) DestroyDynamicPickup(Birlikler[factionid][reklamPickup]);
        if(IsValidDynamic3DTextLabel(Birlikler[factionid][reklamLabel])) DestroyDynamic3DTextLabel(Birlikler[factionid][reklamLabel]);
	    Birlikler[factionid][birlikExists] = false;
	    Birlikler[factionid][birlikTip] = 0;
	    Birlikler[factionid][birlikID] = 0;
	    Iter_Clear(CekilisKatilimcilar[factionid]);
	}
	return 1;
}

stock GetIP(playerid)
{
	static ip[16];
	GetPlayerIp(playerid, ip, sizeof(ip));
	return ip;
}

stock IsPlayerNearPlayer(playerid, targetid, Float:radius)
{
	static Float:fX, Float:fY, Float:fZ;
	GetPlayerPos(targetid, fX, fY, fZ);
	return (GetPlayerInterior(playerid) == GetPlayerInterior(targetid) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(targetid)) && IsPlayerInRangeOfPoint(playerid, radius, fX, fY, fZ);
}

stock SendNearbyMessage(playerid, Float:radius, color, const str[], {Float,_}:...)
{
	static args, start, end, string[144];
	#emit LOAD.S.pri 8
	#emit STOR.pri args
	if(args > 16)
	{
		#emit ADDR.pri str
		#emit STOR.pri start
	    for(end = start + (args - 16); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string
		#emit LOAD.S.pri 8
		#emit CONST.alt 4
		#emit SUB
		#emit PUSH.pri
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4
        foreach (new i : Player)
		{
			if(IsPlayerNearPlayer(i, playerid, radius)) 
			{
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
 	foreach (new i : Player)
	{
		if(IsPlayerNearPlayer(i, playerid, radius)) 
		{
			SendClientMessage(i, color, str);
		}
	}
	return 1;
}

stock trcar(car[])
{
	new tmp[300];
	set(tmp,car);
	tmp=strreplace("ğ", "ÄŸ",tmp);
	tmp=strreplace("|", "",tmp);
	tmp=strreplace("Ğ", "ÄŸ",tmp);
	tmp=strreplace("ş", "ÅŸ",tmp);
	tmp=strreplace("Ş", "ÅŸ",tmp);
	tmp=strreplace("ı", "Ä±",tmp);
	tmp=strreplace("I", "I",tmp);
	tmp=strreplace("İ", "Ä°",tmp);
	tmp=strreplace("ö", "Ã¶",tmp);
	tmp=strreplace("Ö", "Ã–",tmp);
	tmp=strreplace("ç", "Ã§",tmp);
	tmp=strreplace("Ç", "Ã‡",tmp);
	tmp=strreplace("ü", "Ã¼",tmp);
	tmp=strreplace("Ü", "Ãœ",tmp);
	return tmp;
}

stock set(dest[],source[]) 
{
	new count = strlen(source);
	new i=0;
	for(i=0;i<count;i++) 
	{
		dest[i]=source[i];
	}
	dest[count]=0;
}

stock strreplace(trg[],newstr[],src[]) 
{
    new f=0;
    new s1[256];
    new tmp[256];
    format(s1,sizeof(s1),"%s",src);
    f = strfind(s1,trg);
    tmp[0]=0;
    while(f>=0) 
	{
        strcat(tmp,ret_memcpy(s1, 0, f));
        strcat(tmp,newstr);
        format(s1,sizeof(s1),"%s",ret_memcpy(s1, f+strlen(trg), strlen(s1)-f));
        f = strfind(s1,trg);
    }
    strcat(tmp,s1);
    return tmp;
}

ret_memcpy(source[],index=0,numbytes) 
{
	new tmp[256];
	new i=0;
	tmp[0]=0;
	if(index>=strlen(source)) return tmp;
	if(numbytes+index>=strlen(source)) numbytes=strlen(source)-index;
	if(numbytes<=0) return tmp;
	for(i=index;i<numbytes+index;i++) 
	{
		tmp[i-index]=source[i];
		if (source[i]==0) return tmp;
	}
	tmp[numbytes]=0;
	return tmp;
}

stock OyuncuCikisDC(playerid)
{
	static date[36];
	getdate(date[2], date[1], date[0]);
	gettime(date[3], date[4], date[5]);
 	new fark = 3;
	new date3 = date[3]-fark;
	if(date3 == -3) { date3 = 21, date[0]--; }
	if(date3 == -2) { date3 = 22, date[0]--; }
	if(date3 == -1) { date3 = 23, date[0]--; }
	new DCC_Embed:embed = DCC_CreateEmbed(trcar("WionS Roleplay Oyuncu Cıkış Bilgileri"));
	new paralogs[200];
	format(paralogs, sizeof(paralogs), "%s adlı oyuncu sunucudan çıkış yaptı! ( %d / 200 )", ReturnName(playerid, 0), oyuncusayisi);
	DCC_SetEmbedColor(embed, 16711680);
	DCC_SetEmbedDescription(embed, trcar(paralogs));
	format(date, sizeof(date), "%d-%02d-%02dT%02d:%02d:%02d.000Z", date[2], date[1], date[0], date3, date[4], date[5]);
    DCC_SetEmbedTimestamp(embed, date);
	DCC_SetEmbedImage(embed, "https://cdn.discordapp.com/attachments/1203403170965885019/1230586874788315279/WR1.png?ex=6633dc56&is=66216756&hm=ee31f1bba791ff9e4708331859aacaa8d17baf5d1630a1f8256670d60b9135ad&");
	DCC_SetEmbedThumbnail(embed, "https://images-ext-1.discordapp.net/external/_GpMY4Vk4yugEWN369cmlJXhIKhRImM8hHX4GxfMOTI/https/cdn.discordapp.com/icons/1034900389440540702/a_e9e3585d09c2b0be77d780024027c8b2.gif?width=96&height=96");
	DCC_SendChannelEmbedMessage(cikislog, embed);
}

stock OyuncuGirisDC(playerid)
{
	static date[36];
	getdate(date[2], date[1], date[0]);
	gettime(date[3], date[4], date[5]);
 	new fark = 3;
	new date3 = date[3]-fark;
	if(date3 == -3) { date3 = 21, date[0]--; }
	if(date3 == -2) { date3 = 22, date[0]--; }
	if(date3 == -1) { date3 = 23, date[0]--; }
	new DCC_Embed:embed = DCC_CreateEmbed(trcar("WionS Roleplay Oyuncu Giriş Bilgileri"));
	DCC_SetEmbedImage(embed, "https://cdn.discordapp.com/attachments/1203403170965885019/1230586874788315279/WR1.png?ex=6633dc56&is=66216756&hm=ee31f1bba791ff9e4708331859aacaa8d17baf5d1630a1f8256670d60b9135ad&");
	new paralogs[200];
	format(paralogs, sizeof(paralogs), "%s adlı oyuncu sunucuya giriş yaptı ( %d / 200 )", ReturnName(playerid, 0), oyuncusayisi);
	DCC_SetEmbedColor(embed, 3066993);
	DCC_SetEmbedDescription(embed, trcar(paralogs));
	format(date, sizeof(date), "%d-%02d-%02dT%02d:%02d:%02d.000Z", date[2], date[1], date[0], date3, date[4], date[5]);
    DCC_SetEmbedTimestamp(embed, date);
	DCC_SetEmbedThumbnail(embed, "https://images-ext-1.discordapp.net/external/_GpMY4Vk4yugEWN369cmlJXhIKhRImM8hHX4GxfMOTI/https/cdn.discordapp.com/icons/1034900389440540702/a_e9e3585d09c2b0be77d780024027c8b2.gif?width=96&height=96");
	DCC_SendChannelEmbedMessage(girislog, embed);
}

stock DCSayim()
{
    new string[32];
 	format(string, sizeof(string), "(%d/200) Oyuncu", oyuncusayisi);
 	DCC_SetBotActivity(string);
}

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
	else if(fac == BIRLIK_TAMIRHANE)
	{
		format(fact, sizeof(fact), "@mec");
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
		if(!IsPlayerInRangeOfPoint(playerid, 5.0, 261.8779, 109.7122, 1004.6172)) return Hata(playerid, "Dolaba yeterince yakın değilsiniz!");
		new baslik[512], string[1050];
		format(baslik, sizeof(baslik), "{%s}(%s){fafafa}", GetFactionColor(playerid), olusumetiket(Birlikler[PlayerData[playerid][pFaction]][birlikTip]));
		format(string, sizeof(string), "{%s}» {FFFFFF}Isbasi\n{%s}» {FFFFFF}Uniformalar\n{%s}» {FFFFFF}Ekipmanlar\n{FF0000}» {FFFFFF}Silah Sifirla", GetFactionColor(playerid), GetFactionColor(playerid), GetFactionColor(playerid));
		Dialog_Show(playerid, LSPDDolap, DIALOG_STYLE_LIST, baslik, string, "Onayla", "Kapat");
	}
	return 1;
}

Dialog:LSPDDolap(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				if(PlayerData[playerid][pLSPDDuty] == 1)
				{
					PlayerData[playerid][pLSPDDuty] = 0;
					Bilgi(playerid, "(%s) Isbasindan ciktiniz!", olusumetiket(Birlikler[PlayerData[playerid][pFaction]][birlikTip]));
				}
				else
				{
					PlayerData[playerid][pLSPDDuty] = 1;
					Bilgi(playerid, "(%s) Isbasina gectiniz!", olusumetiket(Birlikler[PlayerData[playerid][pFaction]][birlikTip]));
				}
			}
		}
	}
	return 1;
}

stock YetkinizYok(playerid) return Hata(playerid, "Bu komutu kullanabilmek icin yeterli yetkiniz yok!");

CMD:gotopos(playerid,params[])
{
	new intid,Float:pos[3];
	if(!IsPlayerAdmin(playerid)) return YetkinizYok(playerid);
	if(sscanf(params,"ifff", intid, pos[0], pos[1], pos[2])) return Kullanim(playerid,"/gotopos [INT ID] [X] [Y] [Z]");
	SetPlayerInterior(playerid, intid);
	SetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	return 1;
}

CMD:birlikolustur(playerid,params[])
{
	new id = -1,type,name[32],str[50], lid;
	if(PlayerData[playerid][pAdmin] < 4) return YetkinizYok(playerid);
	if(sscanf(params, "ds[32]", type, name))
	{
	    Kullanim(playerid,"/birlikolustur [Tip] [Isim]");
     	SendClientMessage(playerid, COLOR_YELLOW, "[TİP]:{FFFFFF}1: Cete 2: Mafya 3: Yayın Ajansi 4: Legal 5: LSPD 6: LSFMD 7: FBI 8: GOV 9: Mekanik");
   		return 1;
	}
	if(type < 1 || type > 9) return Hata(playerid,"Tip 1 ile 9 arasinda olmalidir!");
	id = Birlik_Olustur(name, type);
	if(id == -1) return Hata(playerid,"Sunucu maksimum birlik sayisina ulasmistir!");
	Bilgi(playerid,"Birlik olusturuldu, ID: %d",id);
	return 1;
}

CMD:birliksil(playerid, params[])
{
	static id = 0;
    if(PlayerData[playerid][pAdmin] < 4) return YetkinizYok(playerid);
	if(sscanf(params, "d", id)) return Kullanim(playerid, "/birliksil [Birlik ID]");
	if((id < 0 || id >= MAX_BIRLIK) || !Birlikler[id][birlikExists]) return Hata(playerid, "Gecersiz ID!");
	Birlik_Sil(id);
	Uyari(playerid, "Birlik ID %d silindi.", id);
	return 1;
}