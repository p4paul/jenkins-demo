#!/bin/bash                                                                

# wait for Perforce server to start
until nc -zw 1 p4.helix 1666; do sleep 1; done && sleep 1
echo "DTG discovered p4.helix"
  
p4 jobspec -i < /opt/perforce/bin/jobspec.p4s

# Keep docker alive
tail -f /dev/null