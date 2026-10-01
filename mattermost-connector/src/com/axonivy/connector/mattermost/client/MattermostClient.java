package com.axonivy.connector.mattermost.client;

import jakarta.ws.rs.client.WebTarget;

import ch.ivyteam.ivy.environment.Ivy;

public class MattermostClient {

	private WebTarget client;

	public MattermostClient() {
		client = Ivy.rest().client("Mattermost");
	}

	public WebTarget getClient() {
		return client;
	}
}
