import jenkins.model.Jenkins;
import org.jenkinsci.plugins.p4.PerforceScm;
import org.jenkinsci.plugins.p4.populate.*;
import org.jenkinsci.plugins.p4.workspace.*;
import org.jenkinsci.plugins.workflow.cps.*;
import org.jenkinsci.plugins.workflow.job.*;


// Credential ID created in default-credentials.groovy
String credential = 'p41666'

String client = 'jenkins-${NODE_NAME}-${JOB_NAME}-script';
String line = 'LOCAL';
String view = '//projects/p4-plugin.main/Jenkinsfile //' + client + '/Jenkinsfile';
WorkspaceSpec spec = new WorkspaceSpec(false, false, false, false, false, false, null, "LOCAL", view);
ManualWorkspaceImpl workspace = new ManualWorkspaceImpl('none', true, client, spec);

Populate populate = new AutoCleanImpl();
PerforceScm scm = new PerforceScm(credential, workspace, populate);

Jenkins j = Jenkins.getInstance();
WorkflowJob job = j.createProject(WorkflowJob.class, 'graphHybrid-demo');
job.setDefinition(new CpsScmFlowDefinition(scm, 'Jenkinsfile'));
job.save();