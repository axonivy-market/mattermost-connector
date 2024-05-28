package com.axonivy.connector.mattermost.test;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

import ch.ivyteam.ivy.bpm.engine.client.BpmClient;
import ch.ivyteam.ivy.bpm.engine.client.ExecutionResult;
import ch.ivyteam.ivy.bpm.engine.client.element.BpmElement;
import ch.ivyteam.ivy.bpm.engine.client.element.BpmProcess;
import ch.ivyteam.ivy.bpm.error.BpmError;

public class TeamProcessTest extends BaseProcessTest {
	private static final BpmProcess TEAM_PROCESS = BpmProcess.path("connector/Team");
	private static final BpmElement GET_TEAM_ID = TEAM_PROCESS.elementName("getTeamId(String)");

	@Test
	public void testGetTeamId(BpmClient bpmClient) throws NoSuchFieldException {
		String teamId = "12345";
		ExecutionResult result = bpmClient.start().subProcess(GET_TEAM_ID).execute("AxonIvy");
		String foundTeamId = (String) result.data().last().get("teamId");
		assertThat(teamId).isEqualTo(foundTeamId);
		assertThat(result.bpmError()).isNull();
	}

	@Test
	public void testGetTeamId_ThrowsBpmException(BpmClient bpmClient) throws NoSuchFieldException {
		try {
			bpmClient.start().subProcess(GET_TEAM_ID).execute("Unknown");
		} catch (BpmError e) {
			assertThat(e.getHttpStatusCode()).isEqualTo(400);
		}
	}
}
