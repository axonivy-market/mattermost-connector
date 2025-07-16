package com.axonivy.connector.mattermost.test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import java.io.File;
import java.time.Duration;

import org.apache.http.HttpStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.testcontainers.containers.ComposeContainer;
import org.testcontainers.containers.wait.strategy.Wait;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import com.your.mattermost.url.client.Channel;
import com.your.mattermost.url.client.IncomingWebhook;

import ch.ivyteam.ivy.bpm.engine.client.BpmClient;
import ch.ivyteam.ivy.bpm.engine.client.ExecutionResult;
import ch.ivyteam.ivy.bpm.engine.client.element.BpmElement;
import ch.ivyteam.ivy.bpm.engine.client.element.BpmProcess;
import ch.ivyteam.ivy.bpm.error.BpmError;
import ch.ivyteam.ivy.bpm.exec.client.IvyProcessTest;
import ch.ivyteam.ivy.environment.AppFixture;


@Testcontainers
@IvyProcessTest
public class MattermostTest {
	private final String OCTOPUS_TEAM_NAME = "Octopus";
	private final String OCTOPUS_TEAM_ID = "xjxaqwfdm3rgtjry53iqr6r4pe";
	private final String OCTOPUS_IVY_HOOK_NAME = "Octopus-Ivy";
	private final String OCTOPUS_IVY_HOOK_ID = "r74rdb9eh7dbzqhrornxwgfdqo";
	private final String TOWN_SQUARE_CHANNEL_ID = "38qt17ckcffktjh9czdffytp8r";
	private final String TOWN_SQUARE_CHANNEL_NAME = "town-square";
	private final String TEST_MATTERMOST_INSTANCE_URL = "http://localhost:8065";
	private final String APP_TOKEN_KEY = "appToken";
	private static final BpmProcess CHANNEL_PROCESS = BpmProcess.path("connector/Channel");
	private static final BpmElement GET_CHANNEL_BY_ID = CHANNEL_PROCESS.elementName("getChannelById(String)");
	private static final BpmProcess TEAM_PROCESS = BpmProcess.path("connector/Team");
	private static final BpmElement GET_TEAM_ID = TEAM_PROCESS.elementName("getTeamId(String)");
	private static final BpmProcess INCOMING_WEBHOOK_PROCESS = BpmProcess.path("connector/IncomingWebhook");
	private static final BpmElement GET_INCOMING_WEBHOOK = INCOMING_WEBHOOK_PROCESS
			.elementName("getIncomingWebhookByTeamIdAndChannelId(String,String)");

	@Container
	@SuppressWarnings("resource")
	private static ComposeContainer db2 = new ComposeContainer(
			new File("../mattermost-connector-demo/docker/docker-compose.yaml"))
			.withExposedService("db", 5432, Wait.forLogMessage(".*database system is ready to accept connections.*", 1).withStartupTimeout(Duration.ofMinutes(2)))
			.withExposedService("mattermost", 8065)
			.withLocalCompose(true);

	@BeforeEach
	void beforeEach(AppFixture fixture) {
		String appToken = System.getProperty(APP_TOKEN_KEY);
		fixture.var("mattermost.baseUrl", TEST_MATTERMOST_INSTANCE_URL);
		fixture.var("mattermost.accessToken", appToken);
	}

	@Test
	public void testGetChannelById(BpmClient bpmClient) throws NoSuchFieldException, InterruptedException {
		ExecutionResult result = bpmClient.start().subProcess(GET_CHANNEL_BY_ID).execute(TOWN_SQUARE_CHANNEL_ID);
		Channel foundChannel = (Channel) result.data().last().get("channel");
		assertEquals(TOWN_SQUARE_CHANNEL_NAME, foundChannel.getName());
		assertEquals(TOWN_SQUARE_CHANNEL_ID, foundChannel.getId());
		assertNull(result.bpmError());
	}

	@Test
	public void testGetChannelById_ThrowsBpmException(BpmClient bpmClient) throws NoSuchFieldException {
		try {
			bpmClient.start().subProcess(GET_CHANNEL_BY_ID).execute("Unknown");
		} catch (BpmError e) {
			assertEquals(HttpStatus.SC_BAD_REQUEST, e.getHttpStatusCode());
		}
	}

	@Test
	public void testGetIncomingWebhook(BpmClient bpmClient) throws NoSuchFieldException {
		ExecutionResult result = bpmClient.start().subProcess(GET_INCOMING_WEBHOOK).execute(OCTOPUS_TEAM_ID,
				TOWN_SQUARE_CHANNEL_ID);
		IncomingWebhook webhook = (IncomingWebhook) result.data().last().get("webhook");
		assertNull(result.bpmError());
		assertEquals(OCTOPUS_IVY_HOOK_ID, webhook.getId());
		assertEquals(OCTOPUS_IVY_HOOK_NAME, webhook.getDisplayName());
	}

	@Test
	public void testGetIncomingWebhook_ThrowsBpmException(BpmClient bpmClient) throws NoSuchFieldException {
		try {
			bpmClient.start().subProcess(GET_INCOMING_WEBHOOK).execute("Unknown", "channelId");
		} catch (BpmError e) {
			assertEquals(HttpStatus.SC_BAD_REQUEST, e.getHttpStatusCode());
		}
	}

	@Test
	public void testGetTeamId(BpmClient bpmClient) throws NoSuchFieldException {
		ExecutionResult result = bpmClient.start().subProcess(GET_TEAM_ID).execute(OCTOPUS_TEAM_NAME);
		String foundTeamId = String.class.cast(result.data().last().get("teamId"));
		assertEquals(OCTOPUS_TEAM_ID, foundTeamId);
		assertNull(result.bpmError());
	}

	@Test
	public void testGetTeamId_ThrowsBpmException(BpmClient bpmClient) throws NoSuchFieldException {
		try {
			bpmClient.start().subProcess(GET_TEAM_ID).execute("Unknown");
		} catch (BpmError e) {
			assertEquals(HttpStatus.SC_BAD_REQUEST, e.getHttpStatusCode());
		}
	}
}
