package com.axonivy.connector.mattermost.demo.service;

import javax.annotation.security.PermitAll;
import javax.ws.rs.BeanParam;
import javax.ws.rs.GET;
import javax.ws.rs.Path;

import org.apache.commons.lang.StringUtils;

import com.axonivy.connector.mattermost.bo.SlashCommandGetRequestParams;
import com.axonivy.connector.mattermost.bo.SlashCommandResponse;
import com.fasterxml.jackson.databind.ObjectMapper;

import ch.ivyteam.ivy.environment.Ivy;
import ch.ivyteam.ivy.process.model.value.SignalCode;

@Path("/mattermost/slashCommand")
@PermitAll
public class MattermostSlashCommandService {
	@GET
	public String startProcess(@BeanParam SlashCommandGetRequestParams params) {
		SlashCommandResponse response = new SlashCommandResponse();
		response.setResponseType("in_channel");
		response.setText(String.format("Process CheckTeamAbsences has been started by %s", params.getUserName()));
		Ivy.wf().signals().send(new SignalCode("CheckTeamAbsences"), params.getChannelId());
		ObjectMapper mapper = new ObjectMapper();
		try {
			return mapper.writeValueAsString(response);
		} catch (Exception e) {
			e.printStackTrace();
			return StringUtils.EMPTY;
		}
	}
}
