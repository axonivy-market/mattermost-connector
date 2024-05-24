package com.axonivy.connector.mattermost.bo;

import javax.ws.rs.QueryParam;

import ch.ivyteam.ivy.environment.Ivy;

public class IncomingWebhookParameter {
	@QueryParam("text")
	private String text;

	@QueryParam("channel")
	private String channel;

	@QueryParam("username")
	private String username;

	@QueryParam("icon_url")
	private String iconUrl;

	@QueryParam("icon_emoji")
	private String iconEmoji;

	@QueryParam("attachments")
	private String attachments;

	@QueryParam("type")
	private String type;

	@QueryParam("props")
	private String props;

	public IncomingWebhookParameter() {
		super();
	}

	public IncomingWebhookParameter(String channel, String text) {
		super();
		this.channel = channel;
		this.text = text;
		this.username = Ivy.var().get("mattermost.botName");
	}

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}

	public String getChannel() {
		return channel;
	}

	public void setChannel(String channel) {
		this.channel = channel;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getIconUrl() {
		return iconUrl;
	}

	public void setIconUrl(String iconUrl) {
		this.iconUrl = iconUrl;
	}

	public String getIconEmoji() {
		return iconEmoji;
	}

	public void setIconEmoji(String iconEmoji) {
		this.iconEmoji = iconEmoji;
	}

	public String getAttachments() {
		return attachments;
	}

	public void setAttachments(String attachments) {
		this.attachments = attachments;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getProps() {
		return props;
	}

	public void setProps(String props) {
		this.props = props;
	}
}