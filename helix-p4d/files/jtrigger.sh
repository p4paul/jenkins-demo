#!/bin/bash

CHANGE=0
P4PORT=p4.helix:1666
JUSER=admin
JPASS=admin

curl --header 'Content-Type: application/json' \
     --request POST \
     --silent \
     --user $JUSER:$JPASS \
     --data payload="{change:$CHANGE,p4port:\"$P4PORT\"}" \
     http://jenkins.helix:8080/p4/change
