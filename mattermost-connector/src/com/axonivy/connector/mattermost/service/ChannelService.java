package com.axonivy.connector.mattermost.service;

import java.util.HashMap;
import java.util.Map;

import com.your.mattermost.url.client.Channel;

public class ChannelService {

	public static Channel getChannelById(String channelId) {
		Map<String, Object> params = new HashMap<>();
		params.put("channelId", channelId);
		Map<String, Object> response = IvyAdapterService
				.startSubProcessInApplication("getChannelById(java.lang.String)", "connector/Channel", params);
		return (Channel) response.get("channel");
	}
}
