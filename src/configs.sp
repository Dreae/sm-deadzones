#include <sourcemod>

void CheckConfigDir() {
    char configDir[256];
    BuildPath(Path_SM, configDir, 256, "configs/deadzones");

    if (!DirExists(configDir)) {
        CreateDirectory(configDir, 557);
    }
}

void LoadZones(const char[] map) {
    char mapConfig[256];
    BuildPath(Path_SM, mapConfig, 256, "configs/deadzones/%s.txt", map);

    if (FileExists(mapConfig)) {
        KeyValues mapZones = new KeyValues("zones");
        mapZones.ImportFromFile(mapConfig);
        if (mapZones.GotoFirstSubKey()) {
            do {
                float bottomLeft[3];
                float topRight[3];

                mapZones.GetVector("point1", bottomLeft);
                mapZones.GetVector("point2", topRight);

                g_fDeadzones[g_iNumZones][0] = bottomLeft;
                g_fDeadzones[g_iNumZones][1] = topRight;
                g_iNumZones += 1;
            } while (mapZones.GotoNextKey());
        }

        delete mapZones;
    }
}

void SaveZones(const char[] map) {
    char mapConfig[256];
    BuildPath(Path_SM, mapConfig, 256, "configs/deadzones/%s.txt", map);

    KeyValues mapZones = new KeyValues("zones");
    for (int i = 0; i < g_iNumZones; i++) {
        char sectionName[16];
        Format(sectionName, 16, "zone%i", i);

        mapZones.JumpToKey(sectionName, true);        

        float point1[3];
        point1[0] = g_fDeadzones[i][0][0];
        point1[1] = g_fDeadzones[i][0][1];
        point1[2] = g_fDeadzones[i][0][2];

        float point2[3];
        point2[0] = g_fDeadzones[i][1][0];
        point2[1] = g_fDeadzones[i][1][1];
        point2[2] = g_fDeadzones[i][1][2];

        mapZones.SetVector("point1", point1);
        mapZones.SetVector("point2", point2);

        mapZones.GoBack();
    }

    mapZones.Rewind();
    mapZones.ExportToFile(mapConfig);

    delete mapZones;
}