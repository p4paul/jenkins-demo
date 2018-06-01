# --------------------------------------------------------------------------------
# Docker configuration for HTH
# --------------------------------------------------------------------------------

FROM ubuntu:16.04

MAINTAINER Paul Allen (pallen@perforce.com)

ENV container docker

# Update Ubuntu (libgomp1 python
RUN \
  apt-get update -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y postfix mailutils cron && \
  apt-get install -y sudo vim wget unzip bzip2 python-dev python-docutils gettext && \
  apt-get install -y libpam0g-dev libidn11 libidn11-dev locales tzdata && \
  apt-get install -y openssh-server	openssh-client
	
# Add Perforce Package Source
RUN \
  wget -qO - https://package.perforce.com/perforce.pubkey | sudo apt-key add - && \
  echo "deb http://package.perforce.com/apt/ubuntu xenial release" > /etc/apt/sources.list.d/perforce.list && \
  apt-get update -y
  
# Install HTH combo
RUN apt-get install hth
RUN apt-get clean

# Set the stop signal for graceful systemd stop
STOPSIGNAL SIGRTMIN+3

# No need for graphical.target here
#RUN systemctl set-default multi-user.target

VOLUME [ "/sys/fs/cgroup" ]

EXPOSE 443 80 22

ADD files/startup.sh /usr/bin/hth-startup
RUN chmod +x /usr/bin/hth-startup

#CMD ["/sbin/init"]

ENTRYPOINT ["/sbin/init"]
