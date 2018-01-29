#include <sourcemod>
#include <sdktools>

int g_iBeamSprite = -1;

int g_iColorPurple[4] = {165, 19, 194, 255};
int g_iColorGrey[4] = {67, 67, 67, 255};

int g_iNumZones = 0;
float g_fDeadzones[64][2][3];

void SetupZones() {
    g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");

    CreateTimer(0.10, Timer_DrawZones, INVALID_HANDLE, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

void DrawZone(float[3] bottomLeft, float[3] topRight, int color[4]) {
    float zonePoints[8][3];
    zonePoints[0] = bottomLeft;
    zonePoints[7] = topRight;

    CreateZonePoints(zonePoints);
    DrawBox(zonePoints, g_iBeamSprite, 0, color, 0.10);
}

void DrawBox(float array[8][3], int beamsprite, int halosprite, int color[4], float life) {
    for(int i = 0, i2 = 3; i2 >= 0; i += i2--) {
        for(int j = 1; j <= 7; j += (j / 2) + 1) {
            if(j != 7 - i) {
                TE_SetupBeamPoints(array[i], array[j], beamsprite, halosprite, 0, 0, life, 5.0, 5.0, 0, 0.0, color, 0);
                
                TE_SendToAll();
            }
        }
    }
}

void CreateZonePoints(float points[8][3]) {
    // TODO: Unroll
    for(int i = 1; i < 7; i++) {
        for(int j = 0; j < 3; j++) {
            points[i][j] = points[((i >> (2-j)) & 1) * 7][j];
        }
    }
}

bool InsideZone(int client, float bottomLeft[3], float topRight[3]) {
    float origin[3];
    GetClientAbsOrigin(client, origin);
    origin[2] += 5;

    for (int i = 0; i < 3; i++) {
        if (bottomLeft[i] >= origin[i] == topRight[i] >= origin[i]) {
            return false;
        }
    }

    return true;
}

bool InsideDeadzone(int client) {
    for (int i = 0; i < g_iNumZones; i++) {
        if (InsideZone(client, g_fDeadzones[i][0], g_fDeadzones[i][1])) {
            return true;
        }
    }

    return false;
}

public Action Timer_DrawZones(Handle timer, any data) {
    for (int i = 0; i < g_iNumZones; i++) {
        DrawZone(g_fDeadzones[i][0], g_fDeadzones[i][1], g_iColorGrey);
    }
}