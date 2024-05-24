package com.axonivy.connector.mattermost.service;

import java.util.Map;

public class TeamService {
	public static String getTeamId() {
		Map<String, Object> response = IvyAdapterService.startSubProcessInApplication("getTeamId()", "TeamService",
				null);
		return (String) response.get("teamId");
	}
}
