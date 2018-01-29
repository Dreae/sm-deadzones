#include <sourcemod>

bool g_bIsPlacing[MAXPLAYERS];
float g_fStartPoint[MAXPLAYERS][3];

void RegConsoleCmds() {
    RegAdminCmd("sm_deadzone_place", Cmd_PlaceDeadzone, ADMFLAG_CHANGEMAP, "Start placing a deadzone");
    RegAdminCmd("sm_deadzone_cancel", Cmd_CancelDeadzone, ADMFLAG_CHANGEMAP, "Stop placing a deadzone");
    RegAdminCmd("sm_deadzone_finish", Cmd_SaveDeadzone, ADMFLAG_CHANGEMAP, "Save a deadzone for this map");
    RegAdminCmd("sm_deadzone_delete", Cmd_DeleteDeadzone, ADMFLAG_CHANGEMAP, "Delete the deadzone you're standing in");
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

public Action Cmd_DeleteDeadzone(int client, int args) {
    for (int i = 0; i < g_iNumZones; i++) {
        if (InsideZone(client, g_fDeadzones[i][0], g_fDeadzones[i][1])) {
            float zoneBuffer[63][2][3];
            for (int j = i + 1; j < g_iNumZones; j++) {
                zoneBuffer[j - (i + 1)][0][0] = g_fDeadzones[j][0][0];
                zoneBuffer[j - (i + 1)][0][1] = g_fDeadzones[j][0][1];
                zoneBuffer[j - (i + 1)][0][2] = g_fDeadzones[j][0][2];

                zoneBuffer[j - (i + 1)][1][0] = g_fDeadzones[j][1][0];
                zoneBuffer[j - (i + 1)][1][1] = g_fDeadzones[j][1][1];
                zoneBuffer[j - (i + 1)][1][2] = g_fDeadzones[j][1][2];
            }

            for (int j  = i; j < g_iNumZones - i; j++) {
                g_fDeadzones[j][0][0] = zoneBuffer[j - i][0][0];
                g_fDeadzones[j][0][1] = zoneBuffer[j - i][0][1];
                g_fDeadzones[j][0][2] = zoneBuffer[j - i][0][2];

                g_fDeadzones[j][1][0] = zoneBuffer[j - i][1][0];
                g_fDeadzones[j][1][1] = zoneBuffer[j - i][1][1];
                g_fDeadzones[j][1][2] = zoneBuffer[j - i][1][2];
            }

            g_iNumZones -= 1;

            char mapName[256];
            GetCurrentMap(mapName, 256);
            SaveZones(mapName);

            break;
        }
    }

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