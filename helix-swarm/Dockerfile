# --------------------------------------------------------------------------------
# Docker configuration for SWARM
# --------------------------------------------------------------------------------

FROM ubuntu:14.04

MAINTAINER Paul Allen (pallen@perforce.com)

# Update Ubuntu
RUN \
  apt-get update -y && \
  apt-get install -y wget unzip dnsutils curl

# Add Perforce Package Source
RUN \
  wget -qO - https://package.perforce.com/perforce.pubkey | sudo apt-key add - && \
  echo "deb http://package.perforce.com/apt/ubuntu trusty release" > /etc/apt/sources.list.d/perforce.list && \
  apt-get update -y

# Create swarm user and add to perforce group
RUN useradd --home-dir /home/swarm --create-home --uid 1000 swarm
RUN usermod -G sudo -a swarm
RUN echo swarm:swarm | /usr/sbin/chpasswd
RUN chown -R swarm:swarm /home/swarm

# Install Perforce Client and Swarm
RUN apt-get install -y helix-cli
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libreoffice helix-swarm

# Configure Swarm Environment
ENV P4PORT ${P4PORT}
ENV P4USER ${P4USER}
ENV P4PASSWD ${P4PASSWD}
ENV SWARMHOST ${SWARMHOST}
ENV SWARMUSER ${SWARMUSER}
ENV SWARMPASSWD ${SWARMPASSWD}
ENV SWARMTOKEN ${SWARMTOKEN}
ENV MAILHOST ${MAILHOST}

# Configure Apache
RUN chown -R www-data:www-data /opt/perforce/swarm/data
RUN a2dissite 000-default

ENTRYPOINT \
	
	until nc -zw 1 p4.helix 1666; do sleep 1; done && sleep 1 && \
	
	cron start && \
	
	mkdir -p /opt/perforce/swarm/data/queue/tokens && \
	touch /opt/perforce/swarm/data/queue/tokens/${SWARMTOKEN} && \
	
	/opt/perforce/swarm/sbin/configure-swarm.sh --non-interactive \
		--p4port ${P4PORT} \
		--swarm-user ${SWARMUSER} --swarm-passwd ${SWARMPASSWD} \
		--swarm-host ${SWARMHOST} --email-host ${MAILHOST} \
		--create --create-group \
		--super-user ${P4USER} --super-passwd ${P4PASSWD} && \
		
	bash