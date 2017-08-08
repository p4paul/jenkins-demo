FROM ubuntu:14.04

MAINTAINER Paul Allen (pallen@perforce.com)

# Update Ubuntu
RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y dnsutils curl git man unzip vim wget

# Add Perforce Package Source
RUN \
  wget -qO - https://package.perforce.com/perforce.pubkey | sudo apt-key add - && \
  echo "deb http://package.perforce.com/apt/ubuntu trusty release" > /etc/apt/sources.list.d/perforce.list && \
  apt-get update

# Create perforce user with UID to 1000 before p4d installation
RUN useradd --home-dir /home/perforce --create-home --uid 1000 perforce
RUN echo perforce:perforce | /usr/sbin/chpasswd

# Install Perforce Server
RUN apt-get install -y helix-p4d
RUN apt-get install -y helix-swarm-triggers

# Configure Perforce
EXPOSE 1666
RUN mkdir /p4
RUN chown -R perforce:perforce /p4

# Add external files
USER perforce
ADD files/main.conf /etc/perforce/p4dctl.conf.d/
ADD files/checkpoint.gz /p4/checkpoint.gz
ADD files/depots.tar.gz /p4

# Restore Checkpoint and Depot files
RUN cd /p4; p4d -jr -z checkpoint.gz; p4d -xu

# Start P4D service
USER root
ENTRYPOINT p4dctl start main && bash

