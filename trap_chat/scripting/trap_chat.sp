#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>

// Nunppong == 눈뽕

#define SOUND_FREEZE	"physics/glass/glass_impact_bullet4.wav"

new Handle:kv[200] = {INVALID_HANDLE, ...};
new MaxItem;
new UserMsg:g_uFade;

new aaa[MAXPLAYERS+1];

new String:N_Color[9][30] =
{
	"255, 255, 255",	// 흰색
	"255, 0, 0",		// 빨
	"255, 127, 0",		// 주
	"255, 255, 0",		// 노
	"0, 255, 0",		// 초
	"0, 0, 255",		// 파
	"111, 0, 255",		// 남
	"143, 0, 255",		// 보
	"0, 0, 0",			// 검
};

public OnPluginStart()
{
	g_uFade = GetUserMessageId("Fade");
	RegAdminCmd("sm_treload", reload, ADMFLAG_KICK);
}

public OnPluginEnd() OnMapEnd();

public OnMapStart()
{
    PrecacheSound(SOUND_FREEZE, true); 
}

public OnMapEnd()
{
	// i는 200까지 i는 컨픽 개수 까지 증가
	for(new i = 0 ; i < 200 && i < MaxItem; i++) if(kv[i] != INVALID_HANDLE) CloseHandle(kv[i]);
}

public OnConfigsExecuted()
{
	decl String:strPath[192], String:szBuffer[64];
	new count = 0;
	
	BuildPath(Path_SM, strPath, sizeof(strPath), "configs/trap_chat.cfg");
	
	new Handle:DB = CreateKeyValues("trap");
	FileToKeyValues(DB, strPath);

	if(KvGotoFirstSubKey(DB))
	{
		do
		{
			kv[count] = CreateArray(100);
			
			KvGetSectionName(DB, szBuffer, sizeof(szBuffer));
			PushArrayString(kv[count], szBuffer);				
			KvGetString(DB, "chat", szBuffer, sizeof(szBuffer));
			PushArrayString(kv[count], szBuffer);
			
			PushArrayCell(kv[count], KvGetNum(DB, "precision"));
			
			KvGetString(DB, "blind", szBuffer, sizeof(szBuffer));
			PushArrayString(kv[count], szBuffer);
			
			PushArrayCell(kv[count], KvGetNum(DB, "ice"));
			PushArrayCell(kv[count], KvGetNum(DB, "kill"));
			
			KvGetString(DB, "teleport", szBuffer, sizeof(szBuffer));
			PushArrayString(kv[count], szBuffer);
			
			PushArrayCell(kv[count], KvGetNum(DB, "slot", -1));
			
			KvGetString(DB, "center", szBuffer, sizeof(szBuffer));
			PushArrayString(kv[count], szBuffer);
			
			KvGetString(DB, "hint", szBuffer, sizeof(szBuffer));
			PushArrayString(kv[count], szBuffer);
			
			KvGetString(DB, "tt", szBuffer, sizeof(szBuffer));
			PushArrayString(kv[count], szBuffer);
			
			KvGetString(DB, "mm", szBuffer, sizeof(szBuffer));
			PushArrayString(kv[count], szBuffer);
			
			PushArrayCell(kv[count], KvGetNum(DB, "nunppong"));
			
			count++;
		}
		while(KvGotoNextKey(DB));
	}
	CloseHandle(DB);
	MaxItem = count;
}

public OnClientPutInServer(client) aaa[client] = -1;

public Action:reload(client, args)
{
	ServerCommand("sm plugins reload trap_chat");
	PrintToChat(client, "\x03리로드 되었습니다.");
	return Plugin_Handled;
}

public Action:OnClientSayCommand(client, const String:command[], const String:sArgs[])
{
	for(new i = 0 ; i < MaxItem ; i++)
	{
		new String:cmd[64], String:chat[100], String:blind[30], String:teleport[30], String:center[100], String:hint[100], String:tt[100], String:mm[100];
		new precision, kill, slot;
		new Float:ice, Float:Nunppong;
		
		if(kv[i] != INVALID_HANDLE)
		{
			GetArrayString(kv[i], 0, cmd, sizeof(cmd));
			GetArrayString(kv[i], 1, chat, sizeof(chat));
			GetArrayString(kv[i], 3, blind, sizeof(blind));
			GetArrayString(kv[i], 6, teleport, sizeof(teleport));
			GetArrayString(kv[i], 8, center, sizeof(center));
			GetArrayString(kv[i], 9, hint, sizeof(hint));
			GetArrayString(kv[i], 10, tt, sizeof(tt));
			GetArrayString(kv[i], 11, mm, sizeof(mm));
			
			precision = GetArrayCell(kv[i], 2);
			kill = GetArrayCell(kv[i], 5);
			slot = GetArrayCell(kv[i], 7);
			
			ice = float(GetArrayCell(kv[i], 4));
			Nunppong = float(GetArrayCell(kv[i], 12));
		}
		
		if(precision == 1)
		{
			if(StrContains(sArgs, cmd, false) != -1)
			{
				if(!StrEqual(chat, "")) PrintToChat(client, "\x04%s", chat);
				if(!StrEqual(center, "")) PrintCenterText(client, "%s", center);
				if(!StrEqual(hint, "")) PrintHintText(client, "%s", hint);
				if(!StrEqual(tt, ""))
				{
					decl String:aa[4][100];
					ExplodeString(tt, ", ", aa, 4, 100);
					
					SendDialogToOne(client, StringToInt(aa[0]), StringToInt(aa[1]), StringToInt(aa[2]), aa[3]);
				}
				if(!StrEqual(mm, ""))
				{
					decl String:aa[3][100];
					ExplodeString(mm, ", ", aa, 3, 100);
					SendPanel(client, aa[0], aa[1], StringToInt(aa[2]));
				}
				
				if(!StrEqual(blind, "")) 
				{
					decl String:aa[4][30];
					ExplodeString(blind, ", ", aa, 4, 30);
					
					PerformBlind(client, StringToInt(aa[1]), StringToInt(aa[2]), StringToInt(aa[3]), 255);
					CreateTimer(StringToFloat(aa[0]), UnBlind, client);
				}
				
				if(ice != 0.0) PerformFreeze(client, ice);
				if(kill == 1) ForcePlayerSuicide(client);
				
				if(!StrEqual(teleport, ""))
				{
					decl String:aa[3][64];
					ExplodeString(teleport, ", ", aa, 3, 64);
					
					new Float:pos[3];
					pos[0] = StringToFloat(aa[0]);
					pos[1] = StringToFloat(aa[1]);
					pos[2] = StringToFloat(aa[2]);
					TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
				}
				
				if(slot != -1) TF2_RemoveWeaponSlot(client, slot);
				if(Nunppong != 0.0)
				{
					CreateTimer(0.1, ready, client);
					aaa[client] = 0;
					CreateTimer(Nunppong, UnNunppong, client);
				}
			}
		}
		else
		{
			if(StrEqual(sArgs, cmd))
			{
				if(!StrEqual(chat, "")) PrintToChat(client, "\x04%s", chat);
				if(!StrEqual(center, "")) PrintCenterText(client, "%s", center);
				if(!StrEqual(hint, "")) PrintHintText(client, "%s", hint);
				if(!StrEqual(tt, ""))
				{
					decl String:aa[4][100];
					ExplodeString(tt, ", ", aa, 4, 100);
					
					SendDialogToOne(client, StringToInt(aa[0]), StringToInt(aa[1]), StringToInt(aa[2]), aa[3]);
				}
				if(!StrEqual(mm, ""))
				{
					decl String:aa[3][100];
					ExplodeString(mm, ", ", aa, 3, 100);
					SendPanel(client, aa[0], aa[1], StringToInt(aa[2]));
				}
				
				if(!StrEqual(blind, "")) 
				{
					decl String:aa[4][30];
					ExplodeString(blind, ", ", aa, 4, 30);
					
					PerformBlind(client, StringToInt(aa[1]), StringToInt(aa[2]), StringToInt(aa[3]), 255);
					CreateTimer(StringToFloat(aa[0]), UnBlind, client);
				}
				
				if(ice != 0.0) PerformFreeze(client, ice);
				if(kill == 1) ForcePlayerSuicide(client);
				
				if(!StrEqual(teleport, ""))
				{
					decl String:aa[3][64];
					ExplodeString(teleport, ", ", aa, 3, 64);
					
					new Float:pos[3];
					pos[0] = StringToFloat(aa[0]);
					pos[1] = StringToFloat(aa[1]);
					pos[2] = StringToFloat(aa[2]);
					TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
				}
				
				if(slot != -1) TF2_RemoveWeaponSlot(client, slot);
				
				if(Nunppong != 0.0)
				{
					CreateTimer(0.1, ready, client);
					aaa[client] = 0;
					CreateTimer(Nunppong, UnNunppong, client);
				}
			}
		}
	}
	return Plugin_Continue;
}

stock PerformFreeze(client, Float:timer)
{
	TF2_AddCondition(client, TFCond:87, timer);
	SetEntityRenderColor(client, 0, 128, 255, 192);
	
	decl Float:pos[3];
	GetClientEyePosition(client, pos);
	EmitAmbientSound(SOUND_FREEZE, pos, client, SNDLEVEL_RAIDSIREN);
	
	CreateTimer(timer, UnFreeze, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:UnFreeze(Handle:timer, any:client)
{
	if(!IsClientInGame(client)) return Plugin_Stop;
	
	TF2_RemoveCondition(client, TFCond:87);
	SetEntityRenderColor(client, 255, 255, 255, 255);
	
	if(IsPlayerAlive(client))
	{
		decl Float:pos[3];
		GetClientEyePosition(client, pos);
		EmitAmbientSound(SOUND_FREEZE, pos, client, SNDLEVEL_RAIDSIREN);
	}
	return Plugin_Continue;
}

stock PerformBlind(client, r, g, b, amount, check = false)
{
	new targets[2], duration = 1536, holdtime = 1536, flags;
	targets[0] = client;

	if(!check)
	{
		if (amount == 0) flags = (0x0001 | 0x0010);
		else flags = (0x0002 | 0x0008);
	}
	else flags = 0x0010;

	new color[4]; color[0] = r; color[1] = g; color[2] = b; color[3] = amount;

	new Handle:message = StartMessageEx(g_uFade, targets, 1);
	if (GetUserMessageType() == UM_Protobuf)
	{
		PbSetInt(message, "duration", duration);
		PbSetInt(message, "hold_time", holdtime);
		PbSetInt(message, "flags", flags);
		PbSetColor(message, "clr", color);
	}
	else
	{
		BfWriteShort(message, duration);
		BfWriteShort(message, holdtime);
		BfWriteShort(message, flags);
		BfWriteByte(message, color[0]);
		BfWriteByte(message, color[1]);
		BfWriteByte(message, color[2]);
		BfWriteByte(message, color[3]);
	}

	EndMessage();
}

public Action:UnBlind(Handle:timer, any:client)
{
	if(!IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
	PerformBlind(client, 0, 0, 0, 0);
	return Plugin_Continue;
}

stock SendDialogToOne(client, r, g, b, String:text[])
{
	new String:message[100];
	VFormat(message, sizeof(message), text, 4);	
	
	new Handle:g_kv = CreateKeyValues("Stuff", "title", message);
	KvSetColor(g_kv, "color", r, g, b, 255);
	KvSetNum(g_kv, "level", 1);
	KvSetNum(g_kv, "time", 10);
	
	CreateDialog(client, g_kv, DialogType_Msg);
	
	CloseHandle(g_kv);	
}
stock SendPanel(client, String:title[], String:msg[], time)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, title);
	DrawPanelText(panel, msg);
	DrawPanelItem(panel, "Exit", ITEMDRAW_CONTROL);
	SendPanelToClient(panel, client, Handler_DoNothing, time);
	CloseHandle(panel);
}

public Handler_DoNothing(Handle:menu, MenuAction:action, param1, param2)
{
}

public Action:ready(Handle:timer, any:entity)
{
	if(!IsClientInGame(entity) || !IsPlayerAlive(entity) || aaa[entity] == -1)
	{
		PerformBlind(entity, 255, 255, 255, 0, true);
		aaa[entity] = -1;
		return Plugin_Stop;
	}
	CreateTimer(0.2, b_color, entity, TIMER_REPEAT);
	return Plugin_Continue;
}

public Action:b_color(Handle:timer, any:entity)
{
	if(!IsClientInGame(entity) || !IsPlayerAlive(entity) || aaa[entity] == -1)
	{ 
		PerformBlind(entity, 255, 255, 255, 0, true);
		aaa[entity] = -1;
		return Plugin_Stop;
	}
	
	new String:aa[3][64];
	ExplodeString(N_Color[aaa[entity]], ", ", aa, 3, 64);
	
	if(aaa[entity] == 8) aaa[entity] = 0;
	else aaa[entity]++;
	
	PerformBlind(entity, StringToInt(aa[0]), StringToInt(aa[1]), StringToInt(aa[2]), 255, true);
	return Plugin_Continue;
}


public Action:UnNunppong(Handle:timer, any:entity)
{
	aaa[entity] = -1;
	return Plugin_Continue;
}