import hudson.model.JDK
import hudson.tasks.Maven.MavenInstallation
import hudson.tools.InstallSourceProperty
import hudson.tools.ToolProperty
import hudson.tools.ToolPropertyDescriptor
import hudson.util.DescribableList

def mavenDesc = jenkins.model.Jenkins.instance.getExtensionList(hudson.tasks.Maven.DescriptorImpl.class)[0]

def isp = new InstallSourceProperty()
isp.installers.add(new hudson.tasks.Maven.MavenInstaller("3.5.0"))

def proplist = new DescribableList<ToolProperty<?>, ToolPropertyDescriptor>()
proplist.add(isp)

def mvn = new MavenInstallation("maven3", "", proplist)
mavenDesc.setInstallations(mvn)
mavenDesc.save()

def jdkDesc = jenkins.model.Jenkins.instance.getDescriptorByName("hudson.model.JDK");

def jdk = new JDK("jdk8", "/usr/lib/jvm/java-8-openjdk-amd64");
jdkDesc.setInstallations(jdk)
jdkDesc.save()