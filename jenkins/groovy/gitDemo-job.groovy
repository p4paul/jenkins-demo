import jenkins.model.Jenkins;
import org.jenkinsci.plugins.p4.trigger.P4Trigger;
import org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition;
import org.jenkinsci.plugins.workflow.job.WorkflowJob;

String jobName = 'git-demo';

// Only create job if it does not exist
Jenkins j = Jenkins.getInstance();
if(!j.getJobNames().contains(jobName)) {
	WorkflowJob job = j.createProject(WorkflowJob.class, jobName);
	job.setDefinition(new CpsFlowDefinition("" +
			"pipeline {\n" +
			"\tagent any\n" +
			"\tstages {\n" +
			"\t\tstage('Sync') {\n" +
			"\t\t\tsteps {\n" +
			"\t\t\t\tdir('p4-plugin') {\n" +
			"\t\t\t\t\tgit credentialsId: 'gitadmin', url: 'https://gcon.helix/plugins/p4-plugin'\n" +
			"\t\t\t\t}\n" +
			"\t\t\t\tdir('matrix-auth-plugin') {\n" +
			"\t\t\t\t\tgit credentialsId: 'gitadmin', url: 'https://gcon.helix/plugins/matrix-auth-plugin'\n" +
			"\t\t\t\t}\n" +
			"\t\t\t}\n" +
			"\t\t}\n" +
			"\t}\n" +
			"}", true));
	job.addTrigger(new P4Trigger())
	job.save();
}

