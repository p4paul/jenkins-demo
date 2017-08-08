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

ENTRYPOINT /opt/perforce/git-connector/bin/configure-git-connector.sh -n -m --ssh --https --forcehttps --p4port p4.helix:1666 --super admin --gcuserp4password Passw0rd && bash
