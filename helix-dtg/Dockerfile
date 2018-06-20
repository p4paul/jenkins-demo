# --------------------------------------------------------------------------------
# Docker configuration for DTG
# --------------------------------------------------------------------------------

FROM ubuntu:16.04

MAINTAINER Paul Allen (pallen@perforce.com)

# Update Ubuntu
RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential software-properties-common default-jre netcat && \
  apt-get install -y libfontconfig1 libxrender1 libxrandr2 libxcursor1 libice6 libsm6 curl wget unzip vim

# Add Perforce Package Source
RUN \
  wget -qO - https://package.perforce.com/perforce.pubkey | apt-key add - && \
  echo "deb http://package.perforce.com/apt/ubuntu trusty release" > /etc/apt/sources.list.d/perforce.list && \
  apt-get update

RUN apt-get install -y helix-cli

# Add DTG
RUN mkdir -p /opt/perforce/bin
ADD files/p4dtg.tgz /opt/perforce/bin/
ADD files/jobspec.p4s /opt/perforce/bin/
ADD files/src-p4.xml /opt/perforce/bin/p4dtg-2014.1.982880/config/
ADD files/startup.sh /opt/perforce/bin/
RUN chmod +x /opt/perforce/bin/startup.sh

WORKDIR /opt/perforce/bin/p4dtg-2014.1.982880
ENV PATH /opt/perforce/bin/p4dtg-2014.1.982880:$PATH

ENV P4PORT ${P4PORT}
ENV P4USER ${P4USER}
ENV P4PASSWD ${P4PASSWD}

CMD ["/opt/perforce/bin/startup.sh"]
