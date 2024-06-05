package com.axonivy.connector.mattermost.test;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

import com.your.mattermost.url.client.IncomingWebhook;

import ch.ivyteam.ivy.bpm.engine.client.BpmClient;
import ch.ivyteam.ivy.bpm.engine.client.ExecutionResult;
import ch.ivyteam.ivy.bpm.engine.client.element.BpmElement;
import ch.ivyteam.ivy.bpm.engine.client.element.BpmProcess;
import ch.ivyteam.ivy.bpm.error.BpmError;

public class IncomingWebhookProcessTest extends BaseProcessTest {
	private static final BpmProcess INCOMING_WEBHOOK_PROCESS = BpmProcess.path("connector/IncomingWebhook");
	private static final BpmElement GET_INCOMING_WEBHOOK = INCOMING_WEBHOOK_PROCESS
			.elementName("getIncomingWebhookByTeamIdAndChannelId(String,String)");

	@Test
	public void testGetIncomingWebhook(BpmClient bpmClient) throws NoSuchFieldException {
		String expectationWebhookId = "12345";
		ExecutionResult result = bpmClient.start().subProcess(GET_INCOMING_WEBHOOK).execute("teamId", "channelId");
		IncomingWebhook webhook = (IncomingWebhook) result.data().last().get("webhook");
		assertThat(result.bpmError()).isNull();
		assertThat(expectationWebhookId).isEqualTo(webhook.getId());
	}

	@Test
	public void testGetIncomingWebhook_ThrowsBpmException(BpmClient bpmClient) throws NoSuchFieldException {
		try {
			bpmClient.start().subProcess(GET_INCOMING_WEBHOOK).execute("Unknown", "channelId");
		} catch (BpmError e) {
			assertThat(e.getHttpStatusCode()).isEqualTo(400);
		}
	}
}
