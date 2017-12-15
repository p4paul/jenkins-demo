FROM jenkins:2.60.3

MAINTAINER Paul Allen (pallen@perforce.com)

# Update Ubuntu
USER root
RUN \
  apt-get update && \
  apt-get install -y dnsutils ant junit
  
USER jenkins

RUN /usr/local/bin/install-plugins.sh p4:1.8.2

# Set Jenkins User/Password
ENV JENKINS_USER admin
ENV JENKINS_PASS admin
COPY groovy/default-user.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY groovy/default-credentials.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY groovy/default-tools.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY groovy/graphHybrid-job.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY groovy/dockerTrigger-job.groovy /usr/share/jenkins/ref/init.groovy.d/

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

VOLUME /m2/repository

WORKDIR $JENKINS_HOME
