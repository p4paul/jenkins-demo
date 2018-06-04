#!/bin/bash                                                                

# wait for Perforce server to start
until nc -zw 1 p4.helix 1666; do sleep 1; done && sleep 1
echo "GCONN discovered p4.helix"
  
export P4PASSWD=${P4PASSWD}
export GCONN_CONFIG=/opt/perforce/git-connector/gconn.conf

# Configure gconn  
/opt/perforce/git-connector/bin/configure-git-connector.sh \
	-n -m \
	--ssh --https --forcehttps \
	--gconnhost gcon.helix \
	--p4port ${P4PORT} \
	--super ${P4USER} --superpassword ${P4PASSWD} \
	--gcuserp4password Passw0rd 

# Import sample GitHub repos...
sudo -E -u gconn-auth gconn --mirrorhooks add plugins/p4-plugin https://github.com/jenkinsci/p4-plugin.git
sudo -E -u gconn-auth gconn --mirrorhooks add plugins/credentials-plugin https://github.com/jenkinsci/credentials-plugin.git
sudo -E -u gconn-auth gconn --mirrorhooks add plugins/scm-api-plugin https://github.com/jenkinsci/scm-api-plugin.git
sudo -E -u gconn-auth gconn --mirrorhooks add plugins/workflow-aggregator-plugin https://github.com/jenkinsci/workflow-aggregator-plugin.git
#sudo -E -u gconn-auth gconn --mirrorhooks add plugins/matrix-project-plugin https://github.com/jenkinsci/matrix-project-plugin.git
#sudo -E -u gconn-auth gconn --mirrorhooks add plugins/matrix-auth-plugin https://github.com/jenkinsci/matrix-auth-plugin.git


p4 stream -i < /home/gconn-auth/p4-plugin.p4s

p4 triggers -i < /home/gconn-auth/triggers.p4s

# Keep docker alive
tail -f /dev/null