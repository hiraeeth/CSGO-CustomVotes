/**
 *
 * Alyx Network - CS:GO Custom Votes
 * A plugin for server admins in Counter-Strike: Global Offensive which allows creating custom votes.
 *
 * Features:
 * - Defining a DEFAULT_MAP.
 * - Cooldowns
 * - Code friendly (you can edit it with any AI)
 *
 * My discord: dragos112
 * Website: https://alyx.ro/
 * Repository: https://github.com/Alyx-Network/CSGO-Essentials
 *
 */

#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#include <cstrike>

#include <customvotes>

#pragma newdecls required
#pragma semicolon 1

#define VERSION	"1.0.0"
#define MAX_SIZE 512

// in minutes
#define AWP_COOLDOWN 3
#define CHANGEMAP_COOLDOWN 6

#define DEFAULT_MAP "de_mirage" // replace with your default map
#define PREFIX "\x0BALYXHVH \x08▪"

public Plugin myinfo =
{
	name		= "[Alyx Core] Server Votes",
	author		= "dragos112",
	description = "General server voting utilities",
	version		= VERSION,
	url			= "https://www.alyx.ro/"
};

enum struct Cooldown
{
	char name[MAX_SIZE];
	int id;
	int last_call;
	int delay;
	any optional;
	char last_map[PLATFORM_MAX_PATH];
}

Cooldown cooldowns[] = {
	{"AWP", 1, 0, AWP_COOLDOWN*60, false, "none"},
	{"CHANGEMAP", 2, 0, CHANGEMAP_COOLDOWN*60, 0, DEFAULT_MAP}
};

ArrayList MapList = null;
ArrayList Maps = null;

public void OnPluginStart()
{
	RegConsoleCmd("sm_awp", Command_Awp);
	RegConsoleCmd("sm_changemap", Command_Changemap);
	RegConsoleCmd("sm_resetcooldowns", Command_ResetCooldowns);

	MapList = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	Maps = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
}

public void OnMapStart()
{
	for (int i = 0; i < sizeof(cooldowns); i++)
		cooldowns[i].last_call = 0;
	cooldowns[0].optional = false; // reset awp restriction
}

Action Command_ResetCooldowns(int client, int args) {
	char PRINT_MESSAGE[MAX_SIZE];
	if (CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC, false))
	{
		for (int i = 0; i < sizeof(cooldowns); i++)
			cooldowns[i].last_call = 0;	
		Format(PRINT_MESSAGE, sizeof(PRINT_MESSAGE), " %s All cooldowns have been reset.", PREFIX);
	} else 
		Format(PRINT_MESSAGE, sizeof(PRINT_MESSAGE), " %s Only admins can reset the cooldown.", PREFIX);

	PrintToChat(client, PRINT_MESSAGE);
	return Plugin_Handled;
}

Action Command_Awp(int client, int args)
{
	int id = 0;
	if (CustomVotes_IsVoteInProgress())
	{
		PrintToChat(client, " %s A vote is already in progress.", PREFIX);
		return Plugin_Handled;
	}

	if (GameRules_GetProp("m_bWarmupPeriod") == 1)
	{
		PrintToChat(client, " %s You can not start a vote during warm up period.", PREFIX);
		return Plugin_Handled;
	}

	int time = GetTime();
	char message[MAX_SIZE];

	if (cooldowns[id].last_call + cooldowns[id].delay > time) {
		int difference = cooldowns[id].last_call + cooldowns[id].delay - time;
		Format(message, sizeof(message), "\x0B%i \x08minutes, \x0B%i \x08seconds", difference / 60, difference % 60);
		PrintToChat(client, " %s You need to wait %s before calling a vote again.", PREFIX, message);
		return Plugin_Handled;
	}

	Format(message, sizeof(message), "<font color='#FFF'>Do you want to</font> <font color='#ff3b61'>%s</font><font color='#FFF'>?</font>", cooldowns[id].optional ? "unrestrict awp (1 per team)" : "restrict awp (0 per team)");

	CustomVoteSetup setup;
	setup.team		= CS_TEAM_NONE;
	setup.initiator = client;
	setup.issue_id	= VOTE_ISSUE_CONTINUE;
	setup.dispstr	= message;
	setup.disppass	= "<font color='#3df218'>Vote Passed!</font>";
	setup.pass_percentage = 51.0;

	CustomVotes_Execute(setup, 10, Vote_AWP, Failed, id);

	cooldowns[id].last_call = time;
	return Plugin_Handled;
}

Action Command_Changemap(int client, int args)
{
	int id = 1;
	if (CustomVotes_IsVoteInProgress())
	{
		PrintToChat(client, " %s A vote is already in progress.", PREFIX);
		return Plugin_Handled;
	}

	if (GameRules_GetProp("m_bWarmupPeriod") == 1)
	{
		PrintToChat(client, " %s You can not start a vote during warm up period.", PREFIX);
		return Plugin_Handled;
	}

	int time = GetTime();
	char message[MAX_SIZE];

	if (cooldowns[id].last_call + cooldowns[id].delay > time) {
		int difference = cooldowns[id].last_call + cooldowns[id].delay - time;

		Format(message, sizeof(message), "\x0B%i \x08minutes, \x0B%i \x08seconds", difference / 60, difference % 60);
		PrintToChat(client, " %s You need to wait %s before calling a vote again.", PREFIX, message);

		return Plugin_Handled;
	}

	Format(message, sizeof(message), "<font color='#FFF'>Do you want to</font> <font color='#ff3b61'>change the map</font><font color='#FFF'>?</font>");

	CustomVoteSetup setup;
	setup.team		= CS_TEAM_NONE;
	setup.initiator = client;
	setup.issue_id	= VOTE_ISSUE_CHANGELEVEL;
	setup.dispstr	= message;
	setup.disppass	= "<font color='#3df218'>Vote Passed!</font>";
	setup.pass_percentage = 51.0;

	CustomVotes_Execute(setup, 10, Vote_CHANGEMAP, Failed, id);

	cooldowns[id].last_call = time;
	return Plugin_Handled;
}

public void Vote_AWP(int results[MAXPLAYERS + 1], int id)
{
	char PRINT_MESSAGE[MAX_SIZE];
	cooldowns[id].optional = !cooldowns[id].optional;

	int r = cooldowns[id].optional ? 0 : 1;
	Format(PRINT_MESSAGE, sizeof(PRINT_MESSAGE), " %s Weapon \x0Bawp \x08is now restricted to \x0B%i per team\x08.", PREFIX, r);

	char command[MAX_SIZE];
	Format(command, sizeof(command), "sm_restrict awp %i", r); // you can replace this with your restrict logic
	ServerCommand(command);
	
	PrintToChatAll(PRINT_MESSAGE);
}


public void Vote_CHANGEMAP(int results[MAXPLAYERS + 1])
{
	ReadMapList(MapList);

	int count = MapList.Length;
	char message[MAX_SIZE * 4];

	char currentMap[PLATFORM_MAX_PATH];
	GetCurrentMap(currentMap, sizeof(currentMap));

	int c = 0;
	Maps.Clear();
	for (int i = 0; i < count-2; i++)	
	{
		char name[PLATFORM_MAX_PATH];
		MapList.GetString(c, name, sizeof(name));
		if (Maps.FindString(name) == -1 && strcmp(name, currentMap) != 0 && strcmp(name, cooldowns[1].last_map) != 0) 
			Maps.PushString(name);
		else 
			i--;
		c++;
	}
 
	// you can replace with your chngemap logic
	// array Maps has the final maps
 	StrCat(message, sizeof(message), "sm_votemap");
	for (int i = 0; i < Maps.Length; i++) {
		char name[PLATFORM_MAX_PATH];
		Maps.GetString(i, name, sizeof(name));
		StrCat(message, sizeof(message), " ");
		StrCat(message, sizeof(message), name);
	}

	PrintToChatAll(" %s Map \x0B%s \x08was removed from the cycle because it had already been voted for.", PREFIX, cooldowns[1].last_map);
	PrintToChatAll(" %s Started voting for a new map.", PREFIX);
	ServerCommand(message);
	cooldowns[1].last_map = currentMap;
}

public void Failed(int results[MAXPLAYERS + 1])
{
	PrintToChatAll(" %s Not enough players agreed to the vote.", PREFIX);
}
