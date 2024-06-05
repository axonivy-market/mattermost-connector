package com.axonivy.connector.mattermost.enums;

public enum CustomField {

	/**
	 * Embed GUI in current frame.
	 *
	 * Set this to <code>false</code> in cases of a GUI to avoid having a second
	 * IFrame.
	 */
	CHANNEL_NAME("channelName"), CHANNEL_ID("channelId");

	private String fieldName;

	private CustomField(String fieldName) {
		this.fieldName = fieldName;
	}

	/**
	 * Get the field name.
	 *
	 * This is the name to use as customField name.
	 *
	 * @return
	 */
	public String getFieldName() {
		return fieldName;
	}
}
