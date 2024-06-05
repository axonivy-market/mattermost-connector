package com.axonivy.connector.mattermost.bo;

import javax.ws.rs.QueryParam;

public class SlashCommandGetRequestParameter {
	@QueryParam("channel_id")
	private String channelId;
	
	@QueryParam("channel_name")
	private String channelName;
	
	@QueryParam("command")
	private String command;

	@QueryParam("response_url")
	private String responseUrl;
	
	@QueryParam("team_domain")
	private String teamDomain;
	
	@QueryParam("team_id")
	private String teamId;
	
	@QueryParam("text")
	private String text;
	
	@QueryParam("token")
	private String token;
	
	@QueryParam("trigger_id")
	private String triggerId;

	@QueryParam("user_id")
	private String userId;
	
	@QueryParam("user_name")
	private String userName;

	public String getChannelId() {
		return channelId;
	}

	public void setChannelId(String channelId) {
		this.channelId = channelId;
	}

	public String getChannelName() {
		return channelName;
	}

	public void setChannelName(String channelName) {
		this.channelName = channelName;
	}

	public String getCommand() {
		return command;
	}

	public void setCommand(String command) {
		this.command = command;
	}

	public String getResponseUrl() {
		return responseUrl;
	}

	public void setResponseUrl(String responseUrl) {
		this.responseUrl = responseUrl;
	}

	public String getTeamDomain() {
		return teamDomain;
	}

	public void setTeamDomain(String teamDomain) {
		this.teamDomain = teamDomain;
	}

	public String getTeamId() {
		return teamId;
	}

	public void setTeamId(String teamId) {
		this.teamId = teamId;
	}

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}

	public String getToken() {
		return token;
	}

	public void setToken(String token) {
		this.token = token;
	}

	public String getTriggerId() {
		return triggerId;
	}

	public void setTriggerId(String triggerId) {
		this.triggerId = triggerId;
	}

	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}
}