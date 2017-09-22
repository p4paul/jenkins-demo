# --------------------------------------------------------------------------------
# Docker configuration for P4D
# --------------------------------------------------------------------------------

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
RUN useradd --home-dir /p4 --create-home --uid 1000 perforce
RUN echo perforce:perforce | /usr/sbin/chpasswd

# Install Perforce Server
RUN apt-get install -y helix-p4d
RUN apt-get install -y helix-swarm-triggers

# Configure Perforce
EXPOSE 1666
ENV P4PORT ${P4PORT}
ENV P4USER ${P4USER}
ENV P4PASSWD ${P4PASSWD}

# Add external files
USER perforce
ADD files/main.conf /etc/perforce/p4dctl.conf.d/
ADD files/checkpoint.gz /p4/checkpoint.gz
ADD files/depots.tar.gz /p4
ADD files/jtrigger.sh /p4/

# Restore Checkpoint and Depot files
RUN cd /p4; p4d -jr -z checkpoint.gz; p4d -xu

# Start P4D service
USER root
RUN chown -R perforce:perforce /p4
RUN chmod +x /p4/jtrigger.sh

ENTRYPOINT \
	p4dctl start main && \
	until nc -zw 1 p4.helix 1666; do sleep 1; done && \
	
	p4 passwd -P ${P4PASSWD} && \
		
	bash
