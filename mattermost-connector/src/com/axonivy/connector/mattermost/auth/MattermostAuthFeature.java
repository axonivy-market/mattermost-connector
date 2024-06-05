package com.axonivy.connector.mattermost.auth;

import javax.ws.rs.Priorities;
import javax.ws.rs.core.Feature;
import javax.ws.rs.core.FeatureContext;

public class MattermostAuthFeature implements Feature {
	@Override
	public boolean configure(FeatureContext context) {
		context.register(new MattermostAuthorizationFilter(), Priorities.AUTHORIZATION);
		return true;
	}
}
