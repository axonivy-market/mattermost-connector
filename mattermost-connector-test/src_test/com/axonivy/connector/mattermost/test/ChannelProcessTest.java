package com.axonivy.connector.mattermost.test;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

import com.your.mattermost.url.client.Channel;

import ch.ivyteam.ivy.bpm.engine.client.BpmClient;
import ch.ivyteam.ivy.bpm.engine.client.ExecutionResult;
import ch.ivyteam.ivy.bpm.engine.client.element.BpmElement;
import ch.ivyteam.ivy.bpm.engine.client.element.BpmProcess;
import ch.ivyteam.ivy.bpm.error.BpmError;

public class ChannelProcessTest extends BaseProcessTest {
	private static final BpmProcess CHANNEL_PROCESS = BpmProcess.path("connector/Channel");
	private static final BpmElement GET_CHANNEL_BY_ID = CHANNEL_PROCESS.elementName("getChannelById(String)");

	@Test
	public void testGetChannelById(BpmClient bpmClient) throws NoSuchFieldException {
		String channelId = "123456";
		ExecutionResult result = bpmClient.start().subProcess(GET_CHANNEL_BY_ID).execute(channelId);
		Channel foundChannel = (Channel) result.data().last().get("channel");
		assertThat(channelId).isEqualTo(foundChannel.getId());
		assertThat(result.bpmError()).isNull();
	}

	@Test
	public void testGetChannelById_ThrowsBpmException(BpmClient bpmClient) throws NoSuchFieldException {
		try {
			bpmClient.start().subProcess(GET_CHANNEL_BY_ID).execute("Unknown");
		} catch (BpmError e) {
			assertThat(e.getHttpStatusCode()).isEqualTo(400);
		}
	}
}
