package com.axonivy.connector.mattermost.test;

import org.junit.jupiter.api.BeforeEach;

import ch.ivyteam.ivy.bpm.exec.client.IvyProcessTest;
import ch.ivyteam.ivy.environment.AppFixture;

@IvyProcessTest(enableWebServer = true)
public class BaseProcessTest {

	@BeforeEach
	void beforeEach(AppFixture fixture) {
		fixture.config("RestClients.Mattermost API (Mattermost API Reference).Features",
				"ch.ivyteam.ivy.rest.client.mapper.JsonFeature");
		fixture.var("mattermost.baseUrl", "{ivy.app.baseurl}/api/mattermostDataMock");
	}
}