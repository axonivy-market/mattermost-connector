package com.axonivy.connector.mattermost.auth;

import jakarta.ws.rs.Priorities;
import jakarta.ws.rs.core.Feature;
import jakarta.ws.rs.core.FeatureContext;

public class MattermostAuthFeature implements Feature {
	@Override
	public boolean configure(FeatureContext context) {
		context.register(new MattermostAuthorizationFilter(), Priorities.AUTHORIZATION);
		return true;
	}
}
