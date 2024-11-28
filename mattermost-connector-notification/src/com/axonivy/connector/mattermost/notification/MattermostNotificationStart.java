package com.axonivy.connector.mattermost.notification;

import org.eclipse.core.runtime.IProgressMonitor;

import ch.ivyteam.ivy.environment.Ivy;
import ch.ivyteam.ivy.process.eventstart.AbstractProcessStartEventBean;
import ch.ivyteam.ivy.service.ServiceException;
import ch.ivyteam.ivy.workflow.IWorkflowManager;

public class MattermostNotificationStart extends AbstractProcessStartEventBean {

  private MattermostNotifier listener;

  public MattermostNotificationStart() {
    super("MattermostNotificationStart",
      "Installs the hook to inform on new Axon Ivy Tasks via Mattermost");
  }

  @Override
  public void poll() {
    getEventBeanRuntime().poll().disable(); // no poll; we only use start/stop hooks
  }

  @Override
  public void start(IProgressMonitor monitor) throws ServiceException {
    super.start(monitor);
    IWorkflowManager wfManager = IWorkflowManager.instance();
    this.listener = new MattermostNotifier();
    wfManager.addWorkflowListener(listener);
    Ivy.log().info("Mattermost-notification installed");
  }

  @Override
  public void stop(IProgressMonitor monitor) throws ServiceException {
    if (this.listener != null) {
      IWorkflowManager.instance().removeWorkflowListener(listener);
      Ivy.log().info("Mattermost-notification stopped");
    }
    super.stop(monitor);
  }

}
