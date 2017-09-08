import jenkins.model.Jenkins;
import org.jenkinsci.plugins.p4.trigger.P4Trigger;
import org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition;
import org.jenkinsci.plugins.workflow.job.WorkflowJob;

String jobName = 'docker-trigger-demo';

// Credential ID created in default-credentials.groovy
String credential = 'p41666'
String client = 'jenkins-${NODE_NAME}-${JOB_NAME}';

// Only create job if it does not exist
Jenkins j = Jenkins.getInstance();
if(!j.getJobNames().contains(jobName)) {
	WorkflowJob job = j.createProject(WorkflowJob.class, jobName);
	job.setDefinition(new CpsFlowDefinition(""
			+ "node () {\n" +
			"    p4sync charset: 'none', \n" +
			"      credential: '" + credential + "', \n" +
			"      format: '" + client + "', \n" +
			"      populate: graphClean(quiet: true), \n" +
			"      source: graphSource('//plugins/docker-plugin')\n" +
			"}", true));
	job.addTrigger(new P4Trigger())
	job.save();
}