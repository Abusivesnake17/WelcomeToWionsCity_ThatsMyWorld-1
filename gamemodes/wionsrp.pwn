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
#include <foreach>
#include <streamer>
#include <YSI\y_iterate>
#include <renkler>
#include <weapon-config>

#define SQL_HOST "localhost"
#define SQL_USER "root"
#define SQL_PASS ""
#define SQL_DATA "ab_db"

#define function%0(%1) forward%0(%1); public%0(%1)

#define MAX_BIRLIK 100 // Maksimum olusturulabilecek birlik sayisidir.
#define MAX_BIRLIK 100 // Maksimum olusturulabilecek birlik sayisidir.
#define MAX_ARAC 1200 // Maksimum olusturulabilecek araci sayisidir.

#define BIRLIK_CETE      (1)
#define BIRLIK_MAFYA     (2)
#define BIRLIK_HABER     (3)
#define BIRLIK_LEGAL     (4)
#define BIRLIK_LSPD      (5)
#define BIRLIK_LSMD      (6)
#define BIRLIK_FBI       (7)
#define BIRLIK_GOV       (8)
#define BIRLIK_TAMIRHANE (9)

#define INVALID_FACTION_ID -2

#define Hata(%0,%1)    \
	SendClientMessageEx(%0, -1, "{FF0000}[HATA]: {fafafa}"%1)

#define Bilgi(%0,%1)    \
	SendClientMessageEx(%0, -1, "{33CC33}[BILGI]: {fafafa}"%1)

#define Kullanim(%0,%1)    \
	SendClientMessageEx(%0, -1, "{5762FF}[W:RP]: {fafafa}"%1)

#define Uyari(%0,%1)    \
	SendClientMessageEx(%0, -1, "{FF9900}[UYARI]: {fafafa}"%1)

new MySQL:mysqlC;

enum a_CopEnum
{
    olusumamodel,
    olusumaname[24]
}

new AttachCops[][a_CopEnum] = 
{
	{19141, "SWAT Kaski1"},
	{19142, "SWAT Zirhi1"},
	{18636, "Polis Kepi1"},
	{19099, "Polis Kepi2"},
	{19100, "Polis Kepi3"},
	{18637, "Polis Kalkani1"},
	{19161, "Polis Sapkasi1"},
	{19162, "Polis Sapkasi2"},
	{19200, "Polis Kaski1"},
	{19138, "Polis Gozlugu1"},
	{19139, "Polis Gozlugu2"},
	{19140, "Polis Gozlugu3"},
	{19347, "Rozet"},
	{19472, "Gaz Maskesi"},
	{19773, "Kilif"},
	{19785, "Senior Arma"}
};

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
	pOnDuty,
	pOnDutySkin,
	pFactionRutbe,
	pFactionDivizyon,
	pSkin,
	pTazer,
	pBeanbag,
	pASlot[10],
	pTSlot[10],
	pABone[10],
	pARenk[10],
	pSilahlar[13],
	pMermiler[13],
	pDinle,
	pLSPDDuty,
	pBoy,
	pKilo
};

new PlayerData[MAX_PLAYERS][pData];

enum AracBilgi
{
	aracID,
	aracExists,
	aracModel,
	aracSahip,
	aracDisplay,
	Float:aracPos[4],
	aracInterior,
	aracWorld,
	aracRenkler[2],
	aracPaintjob,
	aracZirh,
	aracKilit,
	aracVergi,
	aracVergiSure,
	aracMods[14],
	aracGaraj,
	TaksiPlaka,
	aracBaglandi,
	aracBaglandiCeza,
	aracTicket,
	aracTicketTime,
	aracElKonuldu,
	aracFaction,
	aracFactionType,
	aracKira,
	aracKiralayan,
	aracTip,
	aracSatilik,
	aracPlaka[24],
	aracKiraZaman,
	aracSilahlar[5],
	aracMermiler[5],
	aracFiyat,
	aracUyusturucu,
	Float:aracKM,
	Float:aracBenzin,
	aracVehicle,
	Text3D:aracLabel,
	bool:aracCamlar,
	bool:aracSirenAcik,
	SirenObject,
	bool:aracRadar,
	TaksiObje,
	Taksimetre,
	OturumKazanci,
	bool:aracPlakaSok,
	aracYuk,
	aracDorse
};

new AracInfo[MAX_ARAC][AracBilgi];

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
new Float:AksesuarData[MAX_PLAYERS][10][10];
new pbOda[MAX_PLAYERS];

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
	AntiDeAMX();
	WasteDeAMXersTime();
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);
    ShowNameTags(1);
    SetNameTagDrawDistance(45.0);
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
    ManualVehicleEngineAndLights();
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
	if(IsPlayerNPC(playerid)) return 1;
	if(!IsValidRoleplayName(ReturnName(playerid)))
	{
		Hata(playerid, "Isminiz roleplaye uygun degil! ( Ornek: Gordon_Kennedy )");
		Kick(playerid);
		return 1;
	}
	return 1;
}

function OyuncuYukle(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(!rows)
	{
		Dialog_Show(playerid, Kayit, DIALOG_STYLE_INPUT, "{5762FF}WionS Roleplay - Kayit", "{fafafa}Sunucumuza hos geldiniz!\n\n{FF9900}Karakter Adi: {fafafa}%s\n\n{FF9900}IP Adresiniz: {fafafa}%s\n\n{fafafa}Kaydolmak icin sifrenizi giriniz: ", "Kaydol", "Cikis", ReturnName(playerid, 0), GetIP(playerid));
	}
	else
	{
		Dialog_Show(playerid, Giris, DIALOG_STYLE_PASSWORD, "{5762FF}WionS Roleplay - Giris", "{fafafa}Sunucumuza tekrardan hos geldiniz!\n\n{FF9900}Karakter Adi: {fafafa}%s\n\n{FF9900}IP Adresiniz: {fafafa}%s\n\n{fafafa}Giris yapmak icin sifrenizi giriniz: ", "Giris", "Cikis", ReturnName(playerid, 0), GetIP(playerid));
	}
	return 1;
}

Dialog:Kayit(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		EkranTemizle(playerid);
		if(strlen(inputtext) < 3 || strlen(inputtext) > 24)
		{
			Hata(playerid, "Sifreniz 3 haneden kisa veya 24 haneden uzun olamaz!");
			Dialog_Show(playerid, Kayit, DIALOG_STYLE_INPUT, "{5762FF}WionS Roleplay - Kayit", "{fafafa}Sunucumuza hos geldiniz!\n\n{FF9900}Karakter Adi: {fafafa}%s\n\n{FF9900}IP Adresiniz: {fafafa}%s\n\n{fafafa}Kaydolmak icin sifrenizi giriniz: ", "Kaydol", "Cikis", ReturnName(playerid, 0), GetIP(playerid));
			return 1;
		}
		if(TurkceKarakter(inputtext))
		{
			Hata(playerid, "Sifreniz Turkce karakter iceremez!");
			Dialog_Show(playerid, Kayit, DIALOG_STYLE_INPUT, "{5762FF}WionS Roleplay - Kayit", "{fafafa}Sunucumuza hos geldiniz!\n\n{FF9900}Karakter Adi: {fafafa}%s\n\n{FF9900}IP Adresiniz: {fafafa}%s\n\n{fafafa}Kaydolmak icin sifrenizi giriniz: ", "Kaydol", "Cikis", ReturnName(playerid, 0), GetIP(playerid));
			return 1;
		}
		if(!OzelKarakter(inputtext))
		{
			Hata(playerid, "Sifreniz ozel karakter icermelidir!");
			Dialog_Show(playerid, Kayit, DIALOG_STYLE_INPUT, "{5762FF}WionS Roleplay - Kayit", "{fafafa}Sunucumuza hos geldiniz!\n\n{FF9900}Karakter Adi: {fafafa}%s\n\n{FF9900}IP Adresiniz: {fafafa}%s\n\n{fafafa}Kaydolmak icin sifrenizi giriniz: ", "Kaydol", "Cikis", ReturnName(playerid, 0), GetIP(playerid));
			return 1;
		}
		SetPVarString(playerid, "Sifre", inputtext);
		Dialog_Show(playerid, Yas, DIALOG_STYLE_INPUT, "{5762FF}Yasiniz: ", "{fafafa}%s adli karakterinizin yasini giriniz: ", "Devam", "Cikis", ReturnName(playerid, 0));
	}
	return 1;
}

Dialog:Yas(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		EkranTemizle(playerid);
		if(!IsNumeric(inputtext) || strval(inputtext) < 18 || strval(inputtext) > 100)
		{
			Hata(playerid, "%s adli karakterinizin yasi 18-100 arasinda olmalidir!", ReturnName(playerid, 0));
			Dialog_Show(playerid, Yas, DIALOG_STYLE_INPUT, "{5762FF}Yasiniz: ", "{fafafa}%s adli karakterinizin yasini giriniz: ", "Devam", "Cikis", ReturnName(playerid, 0));
			return 1;
		}
		PlayerData[playerid][pYas] = strval(inputtext);
		Dialog_Show(playerid, Cinsiyet, DIALOG_STYLE_MSGBOX, "{5762FF}Cinsiyetiniz: ", "{fafafa}Cinsiyetinizi belirleyiniz: ", "Erkek", "Kadin");
	}
	return 1;
}

Dialog:Cinsiyet(playerid, response, listitem, inputtext[])
{
	EkranTemizle(playerid);
	if(response)
	{
		PlayerData[playerid][pCinsiyet] = 1;
		Dialog_Show(playerid, TenRengi, DIALOG_STYLE_LIST, "{5762FF}Ten Renginiz: ", "{fafafa}Beyaz\n{fafafa}Esmer", "Devam", "Cikis");
	}
	else
	{
		PlayerData[playerid][pCinsiyet] = 2;
		Dialog_Show(playerid, TenRengi, DIALOG_STYLE_LIST, "{5762FF}Ten Renginiz: ", "{fafafa}Beyaz\n{fafafa}Esmer", "Devam", "Cikis");
	}
	return 1;
}

Dialog:TenRengi(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		EkranTemizle(playerid);
		switch(listitem)
		{
			case 0:
			{
				PlayerData[playerid][pTen] = 1;
				Dialog_Show(playerid, Boy, DIALOG_STYLE_INPUT, "{5762FF}Boyunuz: ", "{fafafa}%s adli karakterinizin boyunu giriniz: ", "Devam", "Cikis", ReturnName(playerid, 0));
			}
			case 1:
			{
				PlayerData[playerid][pTen] = 2;
				Dialog_Show(playerid, Boy, DIALOG_STYLE_INPUT, "{5762FF}Boyunuz: ", "{fafafa}%s adli karakterinizin boyunu giriniz: ", "Devam", "Cikis", ReturnName(playerid, 0));
			}
		}
	}
	return 1;
}

Dialog:Boy(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		EkranTemizle(playerid);
		if(!IsNumeric(inputtext) | strval(inputtext) < 100 || strval(inputtext) > 230)
		{
			Hata(playerid, "%s adli karakterinizin boyu 100-230 arasinda olmalidir!", ReturnName(playerid, 0));
			Dialog_Show(playerid, Boy, DIALOG_STYLE_INPUT, "{5762FF}Boyunuz: ", "{fafafa}%s adli karakterinizin boyunu giriniz: ", "Devam", "Cikis", ReturnName(playerid, 0));
			return 1;
		}
		PlayerData[playerid][pBoy] = strval(inputtext);
		Dialog_Show(playerid, Kilo, DIALOG_STYLE_INPUT, "{5762FF}Kilonuz: ", "{fafafa}%s adli karakterinizin kilosunu giriniz: ", "Devam", "Cikis", ReturnName(playerid, 0));
	}
	return 1;
}

Dialog:Kilo(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		EkranTemizle(playerid);
		if(!IsNumeric(inputtext) || strval(inputtext) < 30 || strval(inputtext) > 350)
		{
			Hata(playerid, "%s adli karakterinizin kilosu 30-350 arasinda olmalidir!", ReturnName(playerid, 0));
			Dialog_Show(playerid, Kilo, DIALOG_STYLE_INPUT, "{5762FF}Kilonuz: ", "{fafafa}%s adli karakterinizin kilosunu giriniz: ", "Devam", "Cikis", ReturnName(playerid, 0));
			return 1;
		}
		PlayerData[playerid][pKilo] = strval(inputtext);
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	Oyuncu_Kaydet(playerid);
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
   	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(GetPVarInt(playerid, "Kayit") == 1)
	{
		// Kayit olundugunda eklenecek olan kodlar buraya aktarılacak!! ( Dont forget )
	}
	if(GetPVarInt(playerid, "Logged") == 1)
	{
		// Kayitli hesapla giris yapildiginda olacak kodlar buraya aktarılacak!! ( Dont forget )
	}
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
    if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK && PlayerData[playerid][pAdmin] < 1)
	{
 		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	}
	if((GetPlayerWeapon(playerid) == 18 || GetPlayerWeapon(playerid) == 35 || GetPlayerWeapon(playerid) == 36 || GetPlayerWeapon(playerid) == 37 || GetPlayerWeapon(playerid) == 38 || GetPlayerWeapon(playerid) == 39) && PlayerData[playerid][pAdmin] < 1 && pbOda[playerid] == -1)
	{
	    AdminMessage(COLOR_LIGHTRED, "AdmLog: %s adli oyuncu yasakli silah kullanimi sebebiyle sistem tarafindan yasaklandi. (Silah: %s)", ReturnDate(), Player_GetName(playerid), ReturnWeaponName(GetPlayerWeapon(playerid)));
	    ResetWeapons(playerid);
	    AddBan(GetIP(playerid), Player_GetName(playerid), "", "Sistem", 0, "Silah Hilesi");
	    Kick(playerid);
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

//  --  [STOCKLAR]  --  //

stock GetWeapon(playerid)
{
	new weaponid = GetPlayerWeapon(playerid);
	if(1 <= weaponid <= 46 && PlayerData[playerid][pSilahlar][g_aWeaponSlots[weaponid]] == weaponid) return weaponid;
	return 0;
}

stock GetWeaponModel(weaponid) 
{
    new const g_aWeaponModels[] = 
	{
		0, 331, 333, 334, 335, 336, 337, 338, 339, 341, 321, 322, 323, 324,
		325, 326, 342, 343, 344, 0, 0, 0, 346, 347, 348, 349, 350, 351, 352,
		353, 355, 356, 372, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366,
		367, 368, 368, 371
    };
    if(1 <= weaponid <= 46) return g_aWeaponModels[weaponid];
	return 0;
}

stock ParaVer(playerid,miktar,bildirim = 1)
{
	PlayerData[playerid][pCash] += miktar;
	GivePlayerMoney(playerid,miktar);
	new str[50];
	if(bildirim == 1 && miktar > -1)
	{
	    format(str,sizeof(str),"~g~+%s",FormatNumber(miktar));
	    GameTextForPlayer(playerid,str,1000,1);
	}
 	if(bildirim == 1 && miktar < 0)
 	{
 	    format(str,sizeof(str),"~r~%s",FormatNumber(miktar));
	    GameTextForPlayer(playerid,str,1000,1);
 	}
	return 1;
}
stock FormatNumber(number, prefix[] = "$")
{
	static value[32], length;
	format(value, sizeof(value), "%d", (number < 0) ? (-number) : (number));
	if((length = strlen(value)) > 3)
	{
		for(new i = length, l = 0; --i >= 0; l ++)
		{
		    if ((l > 0) && (l % 3 == 0)) strins(value, ",", i + 1);
		}
	}
	if(prefix[0] != 0) strins(value, prefix, 0);
	if(number < 0) strins(value, "-", 0);
	return value;
}

stock spamProtect(playerid, const szSpam[], iTime) 
{
	static s_szPVar[32], s_iPVar;
	format(s_szPVar, sizeof(s_szPVar), "pv_iSpam_%s", szSpam);
	s_iPVar = GetPVarInt(playerid, s_szPVar);
	if((GetTickCount() - s_iPVar) < iTime * 1000) 
	{
		return 0;
	} 
	else 
	{
		SetPVarInt(playerid, s_szPVar, GetTickCount());
	}
	return 1;
}

stock AddBan(bannedip[], bannedname[], hddserial[], bannedby[], gun, sebep[])
{
	new query[600];
	format(query, sizeof(query), "INSERT INTO `bans` (`IP`, `Ad`, `hddserial`, `Banlayan`, `Sure`, `Sebep`, `BanlanmaTarihi`) VALUES ('%s', '%s', '%s', '%s', '%d', '%s', '%s')", bannedip, bannedname, hddserial, bannedby, gun, sebep, ReturnDate());
	mysql_query(mysqlC, query, false);
	if(strlen(bannedname) > 3)
	{
	    format(query, sizeof(query), "UPDATE `oyuncular` SET `Ban` = '1' WHERE `Isim` = '%s'", bannedname);
	    mysql_query(mysqlC, query, false);
	}
	return 1;
}

stock AdminMessage(color, const str[], {Float,_}:...)
{
	static args, start, end, string[144];
	#emit LOAD.S.pri 8
	#emit STOR.pri args
	if(args > 8)
	{
		#emit ADDR.pri str
		#emit STOR.pri start
	    for(end = start + (args - 8); end > start; end -= 4)
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
        foreach(new i : Player)
		{
			if(PlayerData[i][pAdmin] >= 1) 
			{
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
 	foreach (new i : Player)
	{
		if(PlayerData[i][pAdmin] >= 1) 
		{
			SendClientMessage(i, color, str);
		}
	}
	return 1;
}

ReturnDate()
{
	static date[36];
	getdate(date[2], date[1], date[0]);
	gettime(date[3], date[4], date[5]);
	format(date, sizeof(date), "%02d/%02d/%d, %02d:%02d", date[0], date[1], date[2], date[3], date[4]);
	return date;
}

stock Player_GetName(playerid)
{
	new name[MAX_PLAYER_NAME+1];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}

stock EkranTemizle(playerid)
{
	for(new i = 0; i < 100; i++)
	{
		SendClientMessageEx(playerid, -1, "");
	}
}

IsNumeric(const str[])
{
	for (new i = 0, l = strlen(str); i != l; i ++)
	{
	    if (i == 0 && str[0] == '-')
			continue;

	    else if (str[i] < '0' || str[i] > '9')
			return 0;
	}
	return 1;
}

stock OzelKarakter(yazi[])
{
    for(new i = 0; i < strlen(yazi); i++)
	{
		switch(yazi[i])
		{
			case '!', '@', '#', '$','%','^','&','*','(',')','_','+','=','|','[',']','{','}','-','.','`','~','<','>','?',',','/': return 1;
			default: continue;
		}
	}
	return 0;
}

stock TurkceKarakter(yazi[])
{
	if(strfind(yazi, "ş", true) != -1) return 1;
	if(strfind(yazi, "Ş", true) != -1) return 1;
	if(strfind(yazi, "ç", true) != -1) return 1;
	if(strfind(yazi, "Ç", true) != -1) return 1;
	if(strfind(yazi, "ö", true) != -1) return 1;
	if(strfind(yazi, "Ö", true) != -1) return 1;
	if(strfind(yazi, "ğ", true) != -1) return 1;
	if(strfind(yazi, "Ğ", true) != -1) return 1;
	if(strfind(yazi, "ü", true) != -1) return 1;
	if(strfind(yazi, "Ü", true) != -1) return 1;
	if(strfind(yazi, "İ", true) != -1) return 1;
	if(strfind(yazi, "ı", true) != -1) return 1;
	return 0;
}

RGBAToARGB(rgba) return rgba >>> 8 | rgba << 24;

stock BirlikUyeSayisi(birlikid)
{
	new query[100],Cache: _query;
	format(query,sizeof(query),"SELECT null FROM `oyuncular` WHERE `Birlik` = '%d'",birlikid);
	_query = mysql_query(mysqlC, query);
	new rows;
	cache_get_row_count(rows);
	cache_delete(_query);
	return rows;
}

stock Dinleyici_Sayisi(birlikid)
{
	new sayi = 0;
	foreach(new i:Player)
	{
	    if(PlayerData[i][pDinle] == birlikid)
	    {
	        sayi++;
		}
	}
	return sayi;
}

stock SQL_ReturnEscaped(const string[])
{
	new entry[256];
	mysql_escape_string(string, entry, sizeof(entry) , mysqlC);
	return entry;
}

stock Birlik_Kaydet(bid)
{
	static query[2700];
	format(query,sizeof(query),"UPDATE `birlikler` SET `bisim` = '%s',`brenk` = '%d',`btip` = '%d',`bRutbeler` = '%d',`bduyuru` = '%s',`bkasacash` = '%d',`oocdurum` = '%d', `sistemselonay` = '%d', `silahonay` = '%d', `uyusturucuonay` = '%d', `graffitionay` = '%d', `hoodonay` = '%d'",
	SQL_ReturnEscaped(Birlikler[bid][birlikAd]),
	Birlikler[bid][birlikColor],
	Birlikler[bid][birlikTip],
	Birlikler[bid][birlikRutbeler],
	SQL_ReturnEscaped(Birlikler[bid][birlikDuyuru]),
	Birlikler[bid][birlikKasaPara],
	Birlikler[bid][OOCDurum],
	Birlikler[bid][birlikOnaylar][0],
	Birlikler[bid][birlikOnaylar][1],
	Birlikler[bid][birlikOnaylar][2],
	Birlikler[bid][birlikOnaylar][3],
	Birlikler[bid][birlikOnaylar][4]);

	format(query,sizeof(query),"%s, `byetki1` = '%d',`byetki2` = '%d',`byetki3` = '%d',`byetki4` = '%d',`byetki5` = '%d',`byetki6` = '%d',`byetki7` = '%d',`byetki8` = '%d',`bdivizyon1` = '%s',`bdivizyon2` = '%s',`bdivizyon3` = '%s',`bdivizyon4` = '%s',`bdivizyon5` = '%s'",
	query,
	Birlikler[bid][birlikYetkilendirme][0],
	Birlikler[bid][birlikYetkilendirme][1],
	Birlikler[bid][birlikYetkilendirme][2],
	Birlikler[bid][birlikYetkilendirme][3],
	Birlikler[bid][birlikYetkilendirme][4],
	Birlikler[bid][birlikYetkilendirme][5],
	Birlikler[bid][birlikYetkilendirme][6],
	Birlikler[bid][birlikYetkilendirme][7],
	SQL_ReturnEscaped(BirlikDivizyon[bid][0]),
	SQL_ReturnEscaped(BirlikDivizyon[bid][1]),
	SQL_ReturnEscaped(BirlikDivizyon[bid][2]),
	SQL_ReturnEscaped(BirlikDivizyon[bid][3]),
	SQL_ReturnEscaped(BirlikDivizyon[bid][4]));

	format(query, sizeof(query), "%s, `yayindurum` = '%d', `yayintipi` = '%d', `reklamalimi` = '%d', `reklamucreti` = '%d', `reklamsayisi` = '%d', `aktifdinleyici` = '%d', `BirlikUyeSayisi` = '%d', `reklamx` = '%f', `reklamy` = '%f', `reklamz` = '%f'",query,Birlikler[bid][yayinDurum], Birlikler[bid][yayinTipi],Birlikler[bid][ReklamAlimi],Birlikler[bid][ReklamUcreti], Birlikler[bid][ReklamSayisi], Dinleyici_Sayisi(bid), BirlikUyeSayisi(bid),
	Birlikler[bid][reklamPos][0], Birlikler[bid][reklamPos][1], Birlikler[bid][reklamPos][2]);
	format(query, sizeof(query), "%s, `brutbe1` = '%s', `brutbe2` = '%s', `brutbe3` = '%s', `brutbe4` = '%s', `brutbe5` = '%s', `brutbe6` = '%s', `brutbe7` = '%s', `brutbe8` = '%s', `brutbe9` = '%s', `brutbe10` = '%s', `brutbe11` = '%s', `brutbe12` = '%s', `brutbe13` = '%s', `brutbe14` = '%s', `brutbe15` = '%s' WHERE `bid` = '%d'",
	query,
	BirlikRutbe[bid][0],
 	BirlikRutbe[bid][1],
  	BirlikRutbe[bid][2],
   	BirlikRutbe[bid][3],
    BirlikRutbe[bid][4],
    BirlikRutbe[bid][5],
    BirlikRutbe[bid][6],
    BirlikRutbe[bid][7],
    BirlikRutbe[bid][8],
    BirlikRutbe[bid][9],
    BirlikRutbe[bid][10],
    BirlikRutbe[bid][11],
    BirlikRutbe[bid][12],
    BirlikRutbe[bid][13],
    BirlikRutbe[bid][14],
    Birlikler[bid][birlikID]);
    mysql_query(mysqlC, query, false);
    return 1;
}

stock AksesuarTak(playerid, index)
{
	if(PlayerData[playerid][pARenk][index] == 0) return SetPlayerAttachedObject(playerid,index,PlayerData[playerid][pASlot][index],PlayerData[playerid][pABone][index],AksesuarData[playerid][index][0],AksesuarData[playerid][index][1],AksesuarData[playerid][index][2],AksesuarData[playerid][index][3],AksesuarData[playerid][index][4],AksesuarData[playerid][index][5],AksesuarData[playerid][index][6],AksesuarData[playerid][index][7],AksesuarData[playerid][index][8]);
	switch(PlayerData[playerid][pARenk][index])
	{
	    case 1: SetPlayerAttachedObject(playerid,index,PlayerData[playerid][pASlot][index],PlayerData[playerid][pABone][index],AksesuarData[playerid][index][0],AksesuarData[playerid][index][1],AksesuarData[playerid][index][2],AksesuarData[playerid][index][3],AksesuarData[playerid][index][4],AksesuarData[playerid][index][5],AksesuarData[playerid][index][6],AksesuarData[playerid][index][7],AksesuarData[playerid][index][8], RGBAToARGB(0x000000FF), RGBAToARGB(0x000000FF));
	    case 2: SetPlayerAttachedObject(playerid,index,PlayerData[playerid][pASlot][index],PlayerData[playerid][pABone][index],AksesuarData[playerid][index][0],AksesuarData[playerid][index][1],AksesuarData[playerid][index][2],AksesuarData[playerid][index][3],AksesuarData[playerid][index][4],AksesuarData[playerid][index][5],AksesuarData[playerid][index][6],AksesuarData[playerid][index][7],AksesuarData[playerid][index][8], RGBAToARGB(0xFF0000FF), RGBAToARGB(0xFF0000FF));
	    case 3: SetPlayerAttachedObject(playerid,index,PlayerData[playerid][pASlot][index],PlayerData[playerid][pABone][index],AksesuarData[playerid][index][0],AksesuarData[playerid][index][1],AksesuarData[playerid][index][2],AksesuarData[playerid][index][3],AksesuarData[playerid][index][4],AksesuarData[playerid][index][5],AksesuarData[playerid][index][6],AksesuarData[playerid][index][7],AksesuarData[playerid][index][8], RGBAToARGB(0x0000BBFF), RGBAToARGB(0x0000BBFF));
	    case 4: SetPlayerAttachedObject(playerid,index,PlayerData[playerid][pASlot][index],PlayerData[playerid][pABone][index],AksesuarData[playerid][index][0],AksesuarData[playerid][index][1],AksesuarData[playerid][index][2],AksesuarData[playerid][index][3],AksesuarData[playerid][index][4],AksesuarData[playerid][index][5],AksesuarData[playerid][index][6],AksesuarData[playerid][index][7],AksesuarData[playerid][index][8], RGBAToARGB(0xFF9900FF), RGBAToARGB(0xFF9900FF));
	    case 5: SetPlayerAttachedObject(playerid,index,PlayerData[playerid][pASlot][index],PlayerData[playerid][pABone][index],AksesuarData[playerid][index][0],AksesuarData[playerid][index][1],AksesuarData[playerid][index][2],AksesuarData[playerid][index][3],AksesuarData[playerid][index][4],AksesuarData[playerid][index][5],AksesuarData[playerid][index][6],AksesuarData[playerid][index][7],AksesuarData[playerid][index][8], RGBAToARGB(0xa126edFF), RGBAToARGB(0xa126edFF));
	    case 6: SetPlayerAttachedObject(playerid,index,PlayerData[playerid][pASlot][index],PlayerData[playerid][pABone][index],AksesuarData[playerid][index][0],AksesuarData[playerid][index][1],AksesuarData[playerid][index][2],AksesuarData[playerid][index][3],AksesuarData[playerid][index][4],AksesuarData[playerid][index][5],AksesuarData[playerid][index][6],AksesuarData[playerid][index][7],AksesuarData[playerid][index][8], RGBAToARGB(0xffff00FF), RGBAToARGB(0xffff00FF));
	    case 7: SetPlayerAttachedObject(playerid,index,PlayerData[playerid][pASlot][index],PlayerData[playerid][pABone][index],AksesuarData[playerid][index][0],AksesuarData[playerid][index][1],AksesuarData[playerid][index][2],AksesuarData[playerid][index][3],AksesuarData[playerid][index][4],AksesuarData[playerid][index][5],AksesuarData[playerid][index][6],AksesuarData[playerid][index][7],AksesuarData[playerid][index][8], RGBAToARGB(0x33AA33FF), RGBAToARGB(0x33AA33FF));
	}
	return 1;
}

stock AksesuarAyarla(playerid)
{
    for (new i = 0; i < 5; i ++) {
		if(!PlayerData[playerid][pTSlot][i])
		{
			RemovePlayerAttachedObject(playerid, i);
		}
		else
		{
		    AksesuarTak(playerid, i);
		}
	}
	return 1;
}

stock OlusumAksesuariSil(iTargetID)
{
	for(new iToyIter; iToyIter < 5; ++iToyIter) 
	{
		for(new LoopRapist; LoopRapist < sizeof(AttachCops); ++LoopRapist) 
		{
			if(AttachCops[LoopRapist][olusumamodel] == PlayerData[iTargetID][pASlot][iToyIter]) 
			{
                RemovePlayerAttachedObject(iTargetID, iToyIter);
                PlayerData[iTargetID][pASlot][iToyIter] = 0;
				AksesuarAyarla(iTargetID);
			}
		}
	}
	Bilgi(iTargetID, "Olusuma ait olan tum aksesuarlar kaldirildi.");
	return 1;
}

ResetWeapons(playerid)
{
	ResetPlayerWeapons(playerid);

	for (new i = 0; i < 13; i ++) {
		PlayerData[playerid][pSilahlar][i] = 0;
		PlayerData[playerid][pMermiler][i] = 0;
	}
	return 1;
}

stock Oyuncu_Kaydet(playerid, disconnect=1)
{
	new query[189000];
	format(query, sizeof(query), "UPDATE `oyuncular` SET `Birlik` = '%d',`BirlikRutbe` = '%d',`BirlikDivizyon` = '%d'",
	PlayerData[playerid][pFaction],
	PlayerData[playerid][pFactionRutbe],
	PlayerData[playerid][pFactionDivizyon]);
	mysql_tquery(mysqlC, query, "OyuncuKaydedildi", "d", playerid);
}

function OyuncuKaydedildi(playerid)
{
	new rows = cache_affected_rows();
	if(!rows) printf("%s kullanicinin verilerinde degisiklik olmadi.", ReturnName(playerid));
	else printf("%s adli kullanicinin verileri kayit edildi.", ReturnName(playerid));
	return 1;
}

BirliktenAt(playerid)
{
	if(PlayerData[playerid][pFaction] == -1) return 1;
	if(Birlikler[PlayerData[playerid][pFaction]][birlikTip] != BIRLIK_CETE && Birlikler[PlayerData[playerid][pFaction]][birlikTip] != BIRLIK_MAFYA && Birlikler[PlayerData[playerid][pFaction]][birlikTip] != BIRLIK_LEGAL)
	{
	    SetPlayerSkin(playerid, PlayerData[playerid][pSkin]);
		SetPlayerColor(playerid, 0xFFFFFFFF);
		PlayerData[playerid][pOnDuty] = 0;
		PlayerData[playerid][pOnDutySkin] = 0;
		PlayerData[playerid][pTazer] = 0;
		PlayerData[playerid][pBeanbag] = 0;
		OlusumAksesuariSil(playerid);
		ResetWeapons(playerid);
	}
	Birlik_Kaydet(PlayerData[playerid][pFaction]);
    PlayerData[playerid][pFaction] = -1;
    PlayerData[playerid][pFactionRutbe] = 0;
    PlayerData[playerid][pFactionDivizyon] = 0;
   	for (new i = 0; i < MAX_ARAC; i ++) if (AracInfo[i][aracExists] && AracInfo[i][aracSahip] == PlayerData[playerid][pID])
	{
	    AracInfo[i][aracFactionType] = 0;
		AracInfo[i][aracFaction] = -1;
	}
	return 1;
}

stock OyundaDegil(playerid)
{
	if(!IsPlayerConnected(playerid) || GetPVarInt(playerid,"Logged") == 0)
	{
	    return 0;
	}
	return 1;
}

GetFactionIDBySQL(sqlid)
{
    new i;
    for(i = 0; i < MAX_BIRLIK; i++)
    {
        if(Birlikler[i][birlikID] == sqlid && Birlikler[i][birlikExists]) return i;
    }
    return INVALID_FACTION_ID;
}

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
	if(!IsPlayerAdmin(playerid)) return YetkinizYok(playerid);
	if(sscanf(params, "ds[32]", type, name))
	{
	    Kullanim(playerid,"/birlikolustur [Tip] [Isim]");
     	SendClientMessage(playerid, COLOR_YELLOW, "[TIP]:{FFFFFF}1: Cete 2: Mafya 3: Yayin Ajansi 4: Legal 5: LSPD 6: LSFMD 7: FBI 8: GOV 9: Mekanik");
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
    if(!IsPlayerAdmin(playerid)) return YetkinizYok(playerid);
	if(sscanf(params, "d", id)) return Kullanim(playerid, "/birliksil [Birlik ID]");
	if((id < 0 || id >= MAX_BIRLIK) || !Birlikler[id][birlikExists]) return Hata(playerid, "Gecersiz ID!");
	Birlik_Sil(id);
	Uyari(playerid, "Birlik ID %d silindi.", id);
	return 1;
}

CMD:setleader(playerid, params[])
{
    new targetid, factionid, sqlid;
    if(!IsPlayerAdmin(playerid)) return YetkinizYok(playerid);
    if(sscanf(params, "ui", targetid, sqlid)) return Kullanim(playerid, "/setleader [ID/Isim] [SQL ID] (-1 yazarsan liderlikten atilir)");
	if(factionid == INVALID_FACTION_ID) return Hata(playerid, "Hatali birlik SQL ID!");
    factionid = GetFactionIDBySQL(sqlid);
    if(factionid == -1)
    {
        BirliktenAt(targetid);
        Bilgi(playerid, "%s adlı oyuncuyu birlik liderliğinden attınız.", ReturnName(targetid, 0));
        Bilgi(targetid, "%s adlı yetkili sizi birlik liderliğinden attı.", ReturnName(playerid, 0));
        Oyuncu_Kaydet(targetid);
    }
    else
    {
        BirliktenAt(targetid);
        PlayerData[targetid][pFaction] = factionid;
        PlayerData[targetid][pFactionRutbe] = Birlikler[factionid][birlikRutbeler];
        PlayerData[targetid][pFactionDivizyon] = 0;
        Bilgi(playerid, "%s adlı oyuncuyu \"%s\" adlı birliğin lideri yaptınız.", ReturnName(targetid, 0), Birlikler[factionid][birlikAd]);
        Bilgi(targetid, "%s adlı yetkili seni \"%s\" adlı birliğin lideri yaptı.", ReturnName(playerid, 0), Birlikler[factionid][birlikAd]);
        Oyuncu_Kaydet(targetid);
    }
    return 1;
}

CMD:setskin(playerid, params[])
{
    static userid,skinid;
    if(!IsPlayerAdmin(playerid)) return YetkinizYok(playerid);
    if(sscanf(params, "ud", userid, skinid)) return Kullanim(playerid, "/setskin [ID/Isim] [Skin ID]");
    if(!OyundaDegil(userid)) return Hata(playerid, "Belirttiginiz oyuncu oyunda degil!");
    SetPlayerSkin(userid, skinid);
    PlayerData[userid][pSkin] = skinid;
    Bilgi(playerid, "%s adli oyuncunun kiyafetini ID %d olarak degistirdiniz.", ReturnName(userid, 0), skinid);
    Uyari(userid, "%s adli yetkili skininizi ID %d olarak degistirdi.", PlayerData[playerid][pAdminName], skinid);
    return 1;
}
