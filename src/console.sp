#include <sourcemod>

bool g_bIsPlacing[MAXPLAYERS];
float g_fStartPoint[MAXPLAYERS][3];

void RegConsoleCmds() {
    RegAdminCmd("sm_deadzone_place", Cmd_PlaceDeadzone, ADMFLAG_CHANGEMAP, "Start placing a deadzone");
    RegAdminCmd("sm_deadzone_cancel", Cmd_CancelDeadzone, ADMFLAG_CHANGEMAP, "Stop placing a deadzone");
    RegAdminCmd("sm_deadzone_finish", Cmd_SaveDeadzone, ADMFLAG_CHANGEMAP, "Save a deadzone for this map");
}

public Action Cmd_PlaceDeadzone(int client, int args) {
    g_bIsPlacing[client] = true;
    float origin[3];
    GetClientAbsOrigin(client, origin);

    g_fStartPoint[client] = origin;

    ReplyToCommand(client, "[Deadzone] Placing deadzone, use sm_deadzone_finish when done");
    ReplyToCommand(client, "[Deadzone] Use sm_deadzone_cancel to cancel zone placement");

    return Plugin_Handled;
}

public Action Cmd_CancelDeadzone(int client, int args) {
    g_bIsPlacing[client] = false;

    return Plugin_Handled;
}

public Action Cmd_SaveDeadzone(int client, int args) {
    g_bIsPlacing[client] = false;

    float origin[3];
    GetClientAbsOrigin(client, origin);
    origin[2] += 90;

    g_fDeadzones[g_iNumZones][0] = g_fStartPoint[client];
    g_fDeadzones[g_iNumZones][1] = origin;

    g_iNumZones += 1;

    
    char mapName[256];
    GetCurrentMap(mapName, 256);
    SaveZones(mapName);

    return Plugin_Handled;
}

public void TestStartZone(int client) {
    if (g_bIsPlacing[client]) {
        float origin[3];
        GetClientAbsOrigin(client, origin);
        origin[2] += 90.0;
        
        DrawZone(g_fStartPoint[client], origin, g_iColorPurple);
    }
}