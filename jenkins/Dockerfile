FROM jenkins/jenkins:2.107.3

MAINTAINER Paul Allen (pallen@perforce.com)

# Update Ubuntu
USER root
RUN \
  apt-get update && \
  apt-get install -y dnsutils ant junit
  
USER jenkins

RUN /usr/local/bin/install-plugins.sh \
	mailer:1.21 \
	matrix-auth:2.2 \
	pipeline-model-definition:1.2.9 \
	git:3.9.1 \
	p4:1.8.10 

# Set Jenkins User/Password
ENV JENKINS_USER admin
ENV JENKINS_PASS admin
COPY groovy/default-user.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY groovy/default-credentials.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY groovy/default-tools.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY groovy/graphHybrid-job.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY groovy/dockerTrigger-job.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY groovy/gitDemo-job.groovy /usr/share/jenkins/ref/init.groovy.d/

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV GIT_SSL_NO_VERIFY=true

VOLUME /m2/repository

WORKDIR $JENKINS_HOME
