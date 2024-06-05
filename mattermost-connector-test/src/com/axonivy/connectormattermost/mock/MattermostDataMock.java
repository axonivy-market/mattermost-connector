package com.axonivy.connectormattermost.mock;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

import javax.annotation.security.PermitAll;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.apache.commons.io.IOUtils;

import io.swagger.v3.oas.annotations.Hidden;

@Path("mattermostDataMock")
@PermitAll
@Hidden
public class MattermostDataMock {

	@GET
	@Path("/api/v4/teams/name/{name}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response getTeamId(@PathParam("name") String name) {
		if ("Unknown".equals(name)) {
			return Response.status(400).build();
		}

		return Response.status(200).entity(load("json/team.json")).build();
	}

	@GET
	@Path("/api/v4/channels/{channel_id}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response getChannelById(@PathParam("channel_id") String id) {
		if ("Unknown".equals(id)) {
			return Response.status(400).build();
		}

		return Response.status(200).entity(load("json/channel.json")).build();
	}

	@GET
	@Path("/api/v4/hooks/incoming")
	@Produces(MediaType.APPLICATION_JSON)
	public Response getIncomingWebhookByTeamIdAndChannelId(@QueryParam("team_id") String teamId) {
		if ("Unknown".equals(teamId)) {
			return Response.status(400).build();
		}
		return Response.status(200).entity(load("json/incomingWebhook.json")).build();
	}

	private static String load(String path) {
		try (InputStream is = MattermostDataMock.class.getResourceAsStream(path)) {
			return IOUtils.toString(is, StandardCharsets.UTF_8);
		} catch (IOException ex) {
			throw new RuntimeException("Failed to read resource: " + path);
		}
	}
}
