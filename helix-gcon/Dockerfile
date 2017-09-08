FROM ubuntu:14.04

MAINTAINER Paul Allen (pallen@perforce.com)

# Update Ubuntu
RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y dnsutils curl git man unzip vim wget && \
  apt-get install -y openssh-server openssl apache2

# Add Perforce Package Source
RUN \
  wget -qO - https://package.perforce.com/perforce.pubkey | sudo apt-key add - && \
  echo "deb http://package.perforce.com/apt/ubuntu trusty release" > /etc/apt/sources.list.d/perforce.list && \
  apt-get update

# Create perforce user with UID to 1000 before p4d installation
RUN useradd --home-dir /home/perforce --create-home --uid 1000 perforce
RUN usermod -G sudo -a perforce
RUN echo perforce:perforce | /usr/sbin/chpasswd

# Install p4 and Git Connector
RUN apt-get install -y helix-cli helix-git-connector

# Configure
EXPOSE 80 443 22
ENV P4PORT p4.helix:1666
ENV P4USER admin
COPY p4-plugin.p4s /home/perforce/
COPY triggers.p4s /home/perforce/

ENTRYPOINT \
	/opt/perforce/git-connector/bin/configure-git-connector.sh \
	  -n -m \
	  --ssh --https --forcehttps \
	  --p4port p4.helix:1666 \
    --super admin --gcuserp4password Passw0rd && \
    
  export GCONN_CONFIG=/opt/perforce/git-connector/gconn.conf && \
  
  gconn --mirrorhooks add plugins/p4-plugin https://github.com/jenkinsci/p4-plugin.git && \
  gconn --mirrorhooks add plugins/credentials-plugin https://github.com/jenkinsci/credentials-plugin.git && \
  gconn --mirrorhooks add plugins/scm-api-plugin https://github.com/jenkinsci/scm-api-plugin.git && \
  gconn --mirrorhooks add plugins/workflow-aggregator-plugin https://github.com/jenkinsci/workflow-aggregator-plugin.git && \
  gconn --mirrorhooks add plugins/matrix-project-plugin https://github.com/jenkinsci/matrix-project-plugin.git && \
  gconn --mirrorhooks add plugins/matrix-auth-plugin https://github.com/jenkinsci/matrix-auth-plugin.git && \
   
  p4 stream -i < /home/perforce/p4-plugin.p4s && \
  
  p4 triggers -i < /home/perforce/triggers.p4s && \
  
  bash

