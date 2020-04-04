static Handle g_hCookie = null;
static bool g_bHideBeacon[MAXPLAYERS + 1] = { false , ...};

void NewBeacon_OnPluginStart()
{
	g_hCookie = RegClientCookie("newbeacon_hide", "Enable/Disable NoobGlow", CookieAccess_Private);
}

void NewBeacon_OnClientCookiesCached(int client)
{
	char sBuffer[4];
	GetClientCookie(client, g_hCookie, sBuffer, sizeof(sBuffer));
	g_bHideBeacon[client] = view_as<bool>(StringToInt(sBuffer));
}

public Action Command_Noob(int client, int args)
{
	if (!g_cEnableNewBeacon.BoolValue)
	{
		return Plugin_Handled;
	}
	
	if(!IsClientValid(client))
	{
		return Plugin_Handled;
	}

	if (g_bStamm && STAMM_GetClientPoints(client) > g_cNewBeaconPoints.IntValue)
	{
		CPrintToChat(client, "Das macht kein Sinn mehr...");
		return Plugin_Handled;
	}

	if (g_bHideBeacon[client])
	{
		g_bHideBeacon[client] = false;
		CPrintToChat(client, "Dein Glow sollte wieder sichtbar sein.");
	}
	else
	{
		g_bHideBeacon[client] = true;
		CPrintToChat(client, "Dein Glow sollte nicht mehr sichtbar sein.");
	}

	char sBuffer[4];
	IntToString(g_bHideBeacon[client], sBuffer, sizeof(sBuffer));
	SetClientCookie(client, g_hCookie, sBuffer);

	return Plugin_Handled;
}

void NewBeacon_OnClientDisconnect(int client)
{
	if(AreClientCookiesCached(client))
	{
		char sBuffer[4];
		IntToString(g_bHideBeacon[client], sBuffer, sizeof(sBuffer));
		SetClientCookie(client, g_hCookie, sBuffer);
	}
}

public Action OnGlowCheck(int client, int target, bool &seeTarget, bool &overrideColor, int &red, int &green, int &blue, int &alpha, int &style)
{
	if (!g_cEnableNewBeacon.BoolValue)
	{
		return Plugin_Handled;
	}
	
	bool bValid = true;

	if (g_bStamm && STAMM_GetClientPoints(target) > g_cNewBeaconPoints.IntValue)
	{
		bValid = false;
	}
	
	if (GetClientTeam(target) == CS_TEAM_T && IsPlayerAlive(target) && !g_bHideBeacon[target] && bValid)
	{
		overrideColor = true;

		red = 0;
		green = 255;
		blue = 255;
		alpha = 255;
		style = 2;

		seeTarget = true;

		return Plugin_Changed;
	}

	return Plugin_Handled;
}
