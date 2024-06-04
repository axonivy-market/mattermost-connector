package com.axonivy.connector.mattermost.service;

import java.util.HashMap;
import java.util.Map;

public class TeamService {
	public static String getTeamIdByTeamName(String teamName) {
		Map<String, Object> params = new HashMap<>();
		params.put("teamName", teamName);
		Map<String, Object> response = IvyAdapterService.startSubProcessInApplication("getTeamId(java.lang.String)",
				"connector/Team", params);
		return (String) response.get("teamId");
	}
}
