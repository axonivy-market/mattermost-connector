package com.axonivy.connector.mattermost.service;

import java.util.HashMap;
import java.util.Map;

import ch.ivyteam.ivy.environment.Ivy;

public class TeamService {
	public static String getTeamId() {
		Map<String, Object> params = new HashMap<>();
		params.put("teamName", Ivy.var().get("mattermost.teamName"));
		Map<String, Object> response = IvyAdapterService.startSubProcessInApplication("getTeamId(java.lang.String)",
				"connector/Team", params);
		return (String) response.get("teamId");
	}
}
