package com.axonivy.connector.mattermost.auth;

import java.io.IOException;

import javax.ws.rs.client.ClientRequestContext;
import javax.ws.rs.client.ClientRequestFilter;

import ch.ivyteam.ivy.rest.client.FeatureConfig;

public class MattermostAuthorizationFilter implements ClientRequestFilter {
	private static final String AUTHORIZATION = "Authorization";
	private static final String BEARER_TOKEN = "Bearer %s";

	public static interface Property {
		String ACCESS_TOKEN = "AUTH.accessToken";
	}

	@Override
	public void filter(ClientRequestContext ctxt) throws IOException {
		if (ctxt.getHeaders().containsKey(AUTHORIZATION)) {
			return;
		}

		var config = new FeatureConfig(ctxt.getConfiguration(), MattermostAuthFeature.class);
		String accessToken = config.readMandatory(Property.ACCESS_TOKEN);
		ctxt.getHeaders().add(AUTHORIZATION, String.format(BEARER_TOKEN, accessToken));
	}
}
