# --------------------------------------------------------------------------------
# Docker configuration for GCONN
# --------------------------------------------------------------------------------

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

# Create gconn-auth user with UID to 1000
RUN useradd --home-dir /home/gconn-auth --create-home --uid 1000 gconn-auth
RUN usermod -G sudo -a gconn-auth
RUN echo gconn-auth:gconn-auth | /usr/sbin/chpasswd

# Install p4 and Git Connector
RUN apt-get install -y helix-cli helix-git-connector

# Configure
EXPOSE 80 443 22
ENV P4PORT ${P4PORT}
ENV P4USER ${P4USER}
ENV P4PASSWD ${P4PASSWD}

COPY files/p4-plugin.p4s /home/gconn-auth/
COPY files/triggers.p4s /home/gconn-auth/

COPY files/startup.sh /home/gconn-auth/
RUN chmod +x /home/gconn-auth/startup.sh

CMD ["/home/gconn-auth/startup.sh"]
