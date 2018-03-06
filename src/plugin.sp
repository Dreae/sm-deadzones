#include <sourcemod>
#include <sdkhooks>

public Plugin myinfo = {
    name = "Deadzones",
    author = "Dreae",
    description = "Place player deadzones",
    version = "1.0.1",
    url = "https://dreae.onl"
};

bool g_bGodMode[MAXPLAYERS];
int g_iBlockedKeys = (IN_ATTACK | IN_ATTACK2 | IN_ATTACK3 | IN_RELOAD);

#include "zones.sp"
#include "console.sp"
#include "configs.sp"

public void OnPluginStart() {
    RegConsoleCmds();

    HookEvent("player_spawned", On_PlayerSpawned, EventHookMode_Post);

    CheckConfigDir();
}

public void OnMapStart() {
    char mapName[256];
    GetCurrentMap(mapName, 256);
    LoadZones(mapName);

    SetupZones();
}

public bool IsValidClient(int client) {
    return IsClientConnected(client) && IsClientInGame(client);
}

public Action On_PlayerSpawned(Event event, const char[] name, bool dontBroadcast) {
    int client = event.GetInt("userid");
    if (IsValidClient(client)) {
        g_bGodMode[client] = false;
        if (InsideDeadzone(client)) {
            SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
            g_bGodMode[client] = true;
        }
    }
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float[3] vel, float[3] angles, int &weapon) {
    if (IsValidClient(client)) {
        if (InsideDeadzone(client)) {
            if (buttons & g_iBlockedKeys) {
                buttons &= ~g_iBlockedKeys;
            }

            if (!g_bGodMode[client]) {
                SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
                g_bGodMode[client] = true;
            }
        } else {
            if (g_bGodMode[client]) {
                SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
                g_bGodMode[client] = false;
            }
        }

        TestStartZone(client);
    }

    return Plugin_Continue;
}