package com.axonivy.connector.mattermost.listener;

import java.util.function.Consumer;

import ch.ivyteam.ivy.application.ActivityState;
import ch.ivyteam.ivy.workflow.ITask;
import ch.ivyteam.ivy.workflow.IWorkflowEvent;
import ch.ivyteam.ivy.workflow.IWorkflowListener;
import ch.ivyteam.ivy.workflow.IWorkflowManager;
import ch.ivyteam.ivy.workflow.TaskState;
import ch.ivyteam.ivy.workflow.WorkflowChangeEvent;
import ch.ivyteam.ivy.workflow.WorkflowChangeEventKind;

public class NewTaskAssignmentListener implements IWorkflowListener {

	private final IWorkflowManager workflowManager;
	private Consumer<ITask> newTask = task -> {
	};

	public NewTaskAssignmentListener(IWorkflowManager workflowManager) {
		this.workflowManager = workflowManager;
	}

	public void taskHandler(Consumer<ITask> newTask) {
		this.newTask = newTask;
	}

	@Override
	public void workflowChanged(WorkflowChangeEvent changeEvent) {
		if (changeEvent.kind() == WorkflowChangeEventKind.CREATED
				&& changeEvent.workflowObjectClass() == IWorkflowEvent.class) {
			var event = workflowManager.findWorkflowEvent(changeEvent.workflowObjectId());
			var task = event.getTask();
			if (task == null) {
				return;
			}

			if (task.getApplication().getActivityState() != ActivityState.ACTIVE) {
				return;
			}

			boolean send = false;
			if (event.getTaskState() == TaskState.SUSPENDED && !task.activator().isSystemUser()) {
				switch (event.getEventKind()) {
				case EVENT_CHANGE_TASK_ACTIVATOR:
				case EVENT_CREATE_TASK_BY_JOINED_TASKS:
				case EVENT_CREATE_FIRST_TASK_OF_CASE: // task was created by trigger
														// task has state suspended
				case EVENT_REDO_TASK:
				case EVENT_TASK_DELAY_EXPIRED:
				case EVENT_CHANGE_TASK_ACTIVATOR_BY_TIMEOUT:
					send = true;
					break;
				default:
					// do nothing
					break;
				}
				if (send) {
					newTask.accept(task);
				}
			}
		}
	}

}