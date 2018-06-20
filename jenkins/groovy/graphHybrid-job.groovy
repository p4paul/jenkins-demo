import jenkins.model.Jenkins;
import org.jenkinsci.plugins.p4.PerforceScm;
import org.jenkinsci.plugins.p4.populate.AutoCleanImpl;
import org.jenkinsci.plugins.p4.populate.Populate;
import org.jenkinsci.plugins.p4.workspace.ManualWorkspaceImpl;
import org.jenkinsci.plugins.p4.workspace.WorkspaceSpec;
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition;
import org.jenkinsci.plugins.workflow.job.WorkflowJob;

String jobName = 'graph-hybrid-demo';

// Credential ID created in default-credentials.groovy
String credential = 'p41666'

String client = 'jenkins-${NODE_NAME}-${JOB_NAME}-script';
String view = '//projects/p4-plugin.main/Jenkinsfile //' + client + '/Jenkinsfile';
WorkspaceSpec spec = new WorkspaceSpec(false, false, false, false, false, false, null, "LOCAL", view);
ManualWorkspaceImpl workspace = new ManualWorkspaceImpl('utf8', true, client, spec);

Populate populate = new AutoCleanImpl();
PerforceScm scm = new PerforceScm(credential, workspace, populate);

// Only create job if it does not exist
Jenkins j = Jenkins.getInstance();
if(!j.getJobNames().contains(jobName)) {
	WorkflowJob job = j.createProject(WorkflowJob.class, jobName);
	job.setDefinition(new CpsScmFlowDefinition(scm, 'Jenkinsfile'));
	job.save();
}