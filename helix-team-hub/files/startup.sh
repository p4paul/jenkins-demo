#!/bin/bash

function teamhubrunning() {
    grep -e "^hth:" /etc/passwd > /dev/null
    if [ $? -eq 0 ]; then
        echo $(ps -o stime= -u hth | head -n 1)
    fi
}
 
if [ -z $(teamhubrunning) ]; then
   echo "TeamHub not configured"
   sudo hth-ctl reconfigure
fi

exec "$@"