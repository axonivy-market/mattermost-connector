package com.axonivy.connector.mattermost.service;

import java.util.HashMap;
import java.util.Map;

import javax.ws.rs.client.Entity;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import com.axonivy.connector.mattermost.bo.IncomingWebhookParameter;
import com.axonivy.connector.mattermost.client.MattermostClient;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.your.mattermost.url.client.IncomingWebhook;

import ch.ivyteam.ivy.bpm.error.BpmError;

public class IncomingWebhookService {

	private final static String INCOMING_WEBHOOK_PATH = "/hooks/%s";

	public static IncomingWebhook getIncommingWebhookId(String channelId, String teamId) {
		Map<String, Object> params = new HashMap<>();
		params.put("teamId", teamId);
		params.put("channelId", channelId);
		Map<String, Object> response = IvyAdapterService.startSubProcessInApplication(
				"getIncomingWebhookByTeamIdAndChannelId(java.lang.String,java.lang.String)", "IncomingWebhookService",
				params);
		return (IncomingWebhook) response.get("incomingWebhook");
	}

	public static void sendIncomingWebhook(IncomingWebhookParameter parameter, String webhookId)
			throws JsonProcessingException {
		Response response = new MattermostClient().getClient().path(String.format(INCOMING_WEBHOOK_PATH, webhookId))
				.request(MediaType.APPLICATION_JSON)
				.post(Entity.entity(new ObjectMapper().writeValueAsString(parameter), MediaType.APPLICATION_JSON));
		try {
			if (response.getStatus() != 200) {
				BpmError.create("ivy:error:rest").withMessage("Fail").throwError();
			}
		} finally {
			response.close();
		}
	}
}
