package com.axonivy.connector.mattermost.demo.service;

import org.apache.commons.lang.StringUtils;

import com.axonivy.connector.mattermost.bo.IncomingWebhookParameter;
import com.axonivy.connector.mattermost.service.ChannelService;
import com.axonivy.connector.mattermost.service.IncomingWebhookService;
import com.axonivy.connector.mattermost.service.TeamService;
import com.your.mattermost.url.client.Channel;
import com.your.mattermost.url.client.IncomingWebhook;

import ch.ivyteam.ivy.environment.Ivy;

public class MattermostWebhookService {
	public MattermostWebhookService() {
	}

	public void sendMessageToMattermostChannel(String channelId, String message) {
		try {
			String teamId = TeamService.getTeamId();
			if (StringUtils.isBlank(teamId)) {
				return;
			}

			IncomingWebhook webhook = IncomingWebhookService.getIncommingWebhookId(channelId, teamId);
			if (webhook == null || StringUtils.isBlank(webhook.getId())) {
				return;
			}

			Channel channel = ChannelService.getChannelById(channelId);
			if (channel == null || StringUtils.isBlank(channel.getId())) {
				return;
			}

			IncomingWebhookParameter parameter = new IncomingWebhookParameter(channel.getName(), message);
			IncomingWebhookService.sendIncomingWebhook(parameter, webhook.getId());
		} catch (Exception ex) {
			Ivy.log().error("Failed to notify channel Id {0}: {1}", channelId, ex);
		}
	}
}