package com.axonivy.connector.mattermost.bo;

import com.fasterxml.jackson.annotation.JsonProperty;

public class SlashCommandResponse {
	@JsonProperty("text")
	private String text;

	@JsonProperty("attachments")
	private String attachments;

	@JsonProperty("response_type")
	private String responseType;

	@JsonProperty("username")
	private String username;

	@JsonProperty("channel_id")
	private String channelId;

	@JsonProperty("icon_url")
	private String iconUrl;

	@JsonProperty("goto_location")
	private String goToLocation;

	@JsonProperty("type")
	private String type;

	@JsonProperty("extra_responses")
	private String extraResponses;

	@JsonProperty("skip_slack_parsing")
	private String skipSlackParsing;

	@JsonProperty("props")
	private String props;

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}

	public String getAttachments() {
		return attachments;
	}

	public void setAttachments(String attachments) {
		this.attachments = attachments;
	}

	public String getResponseType() {
		return responseType;
	}

	public void setResponseType(String responseType) {
		this.responseType = responseType;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getChannelId() {
		return channelId;
	}

	public void setChannelId(String channelId) {
		this.channelId = channelId;
	}

	public String getIconUrl() {
		return iconUrl;
	}

	public void setIconUrl(String iconUrl) {
		this.iconUrl = iconUrl;
	}

	public String getGoToLocation() {
		return goToLocation;
	}

	public void setGoToLocation(String goToLocation) {
		this.goToLocation = goToLocation;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getExtraResponses() {
		return extraResponses;
	}

	public void setExtraResponses(String extraResponses) {
		this.extraResponses = extraResponses;
	}

	public String getSkipSlackParsing() {
		return skipSlackParsing;
	}

	public void setSkipSlackParsing(String skipSlackParsing) {
		this.skipSlackParsing = skipSlackParsing;
	}

	public String getProps() {
		return props;
	}

	public void setProps(String props) {
		this.props = props;
	}
}