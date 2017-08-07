FROM jenkins:2.60.2

MAINTAINER Paul Allen (pallen@perforce.com)

# Update Ubuntu
USER root
RUN \
  apt-get update && \
  apt-get install -y dnsutils ant junit
  
USER jenkins

RUN /usr/local/bin/install-plugins.sh matrix-auth:1.7 p4:1.7.3

# Set Jenkins User/Password
ENV JENKINS_USER admin
ENV JENKINS_PASS admin
COPY groovy/default-user.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY groovy/default-credentials.groovy /usr/share/jenkins/ref/init.groovy.d/

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

VOLUME /var/jenkins_home

WORKDIR $JENKINS_HOME
