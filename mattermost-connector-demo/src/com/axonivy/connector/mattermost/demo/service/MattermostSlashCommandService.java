package com.axonivy.connector.mattermost.demo.service;

import javax.annotation.security.PermitAll;
import javax.ws.rs.BeanParam;
import javax.ws.rs.GET;
import javax.ws.rs.Path;

import org.apache.commons.lang.StringUtils;

import com.axonivy.connector.mattermost.bo.SlashCommandGetRequestParameter;
import com.axonivy.connector.mattermost.bo.SlashCommandResponse;
import com.fasterxml.jackson.databind.ObjectMapper;

import ch.ivyteam.ivy.environment.Ivy;

@Path("/mattermost/slashCommand")
@PermitAll
public class MattermostSlashCommandService {
	@GET
	public String startProcess(@BeanParam SlashCommandGetRequestParameter parameter) {
		SlashCommandResponse response = new SlashCommandResponse();
		response.setResponseType("in_channel");
		response.setText(String.format("Process CheckTeamAbsences has been started by %s", parameter.getUserName()));
		Ivy.wf().signals().create().data(parameter.getChannelId()).makeCurrentTaskPersistent()
				.send("CheckTeamAbsences");
		ObjectMapper mapper = new ObjectMapper();
		try {
			return mapper.writeValueAsString(response);
		} catch (Exception e) {
			e.printStackTrace();
			return StringUtils.EMPTY;
		}
	}
}
