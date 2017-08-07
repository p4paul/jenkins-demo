FROM jenkins:latest

MAINTAINER Paul Allen (pallen@perforce.com)

# Update Ubuntu
USER root
RUN \
  apt-get update && \
  apt-get install -y dnsutils ant junit
  
USER jenkins

RUN /usr/local/bin/install-plugins.sh p4 github-branch-source:latest

VOLUME /usr/share/jenkins

WORKDIR $JENKINS_HOME
