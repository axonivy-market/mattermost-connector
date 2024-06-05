package com.axonivy.connector.mattermost.notification;

import org.apache.commons.lang.StringUtils;

import com.axonivy.connector.mattermost.bo.IncomingWebhookParameter;
import com.axonivy.connector.mattermost.enums.CustomField;
import com.axonivy.connector.mattermost.listener.NewTaskAssignmentListener;
import com.axonivy.connector.mattermost.service.ChannelService;
import com.axonivy.connector.mattermost.service.IncomingWebhookService;
import com.axonivy.connector.mattermost.service.TeamService;
import com.your.mattermost.url.client.Channel;
import com.your.mattermost.url.client.IncomingWebhook;

import ch.ivyteam.ivy.environment.Ivy;
import ch.ivyteam.ivy.workflow.ITask;
import ch.ivyteam.ivy.workflow.IWorkflowManager;

public class MattermostNotifier extends NewTaskAssignmentListener {

	public MattermostNotifier() {
		super(IWorkflowManager.instance());
		taskHandler(this::notifyNewTask);
	}

	private boolean isEnabled() {
		return Boolean.parseBoolean((Ivy.var().get("mattermost.notification.enabled")));
	}

	public void notifyNewTask(ITask newTask) {
		if (!isEnabled()) {
			return;
		}
		Ivy.log().info("notify new task clients on new teask " + newTask);
		notifyToChannel(newTask);
	}

	private void notifyToChannel(ITask newTask) {
		String channelId = newTask.getCase().customFields().stringField(CustomField.CHANNEL_ID.getFieldName())
				.getOrDefault(StringUtils.EMPTY);

		String teamId = TeamService.getTeamIdByTeamName(Ivy.var().get("mattermost.teamName"));
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

		sendIncomingWebhook(newTask, channel, webhook);
	}

	private void sendIncomingWebhook(ITask newTask, Channel channel, IncomingWebhook webhook) {
		try {
			IncomingWebhookParameter parameter = prepareIncomingWebhookParameter(newTask, channel);
			IncomingWebhookService.sendIncomingWebhook(parameter, webhook.getId());
		} catch (Exception ex) {
			Ivy.log().error("Failed to notify channel Id {0} on the new task Id {1}: {2}", channel.getId(),
					newTask.getId(), ex);
		}
	}

	private IncomingWebhookParameter prepareIncomingWebhookParameter(ITask newTask, Channel channel) {
		String newTaskLinkTxt = String.format("[%s](%s)", newTask.getName(), newTask.getStartLink().getAbsolute());
		return new IncomingWebhookParameter(channel.getName(),
				String.format(Ivy.var().get("mattermost.notification.newTaskMessage"), newTaskLinkTxt));
	}
}