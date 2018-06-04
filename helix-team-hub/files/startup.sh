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
	
	sudo chown hth:hth /var/opt/hth/shared/.license.pem
	sudo chmod 600 /var/opt/hth/shared/.license.pem
fi

exec "$@"