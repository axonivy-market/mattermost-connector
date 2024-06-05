package com.axonivy.connector.mattermost.client;

import java.util.UUID;

import javax.ws.rs.client.WebTarget;

import ch.ivyteam.ivy.environment.Ivy;

public class MattermostClient {

	private WebTarget client;

	public MattermostClient() {
		client = Ivy.rest().client(UUID.fromString("402ef8e2-8431-4198-b4c7-be6000e557c9"));
	}

	public WebTarget getClient() {
		return client;
	}
}
