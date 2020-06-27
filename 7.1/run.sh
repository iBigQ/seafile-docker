#!/bin/bash

# Starting Seafile
echo "Executing seafile: './seafile.sh start'"
mkdir -p ../ccnet
./seafile.sh start
/wait_file.sh "/opt/seafile/pids/ccnet.pid" 10
/wait_file.sh "/opt/seafile/pids/seaf-server.pid" 1

# Start Seahub	
echo "Executing seahub: './seahub.sh start'"
if [ ! -z "${SEAFILE_ADMIN_EMAIL}" ] && [ ! -z ${SEAFILE_ADMIN_PASSWORD} ]; then
	echo '{"email": "'${SEAFILE_ADMIN_EMAIL}'", "password": "'${SEAFILE_ADMIN_PASSWORD}'"}' > /opt/seafile/conf/admin.txt
fi
./seahub.sh start
if [ -e /opt/seafile/conf/admin.txt ]; then
	rm /opt/seafile/conf/admin.txt
fi
/wait_file.sh "/opt/seafile/pids/seahub.pid" 10

# Collect PIDs
echo "Collections PIDs"
names=(seafile-control ccnet-server seaf-server gunicorn)
for i in {0..3}; do
	pids[${i}]=$(pgrep -f "${names[${i}]}" | sort -n | head -1)
	if [ -z ${pids[${i}]} ]; then
		echo "${names[${i}]} did not start"
		exit 1
	fi
done

# Watch PIDs
echo "Watching PIDs"
while [ 1 -eq 1 ]; do
	#TODO Implement SIGTERM Handler: ./seafile.sh stop && ./seahub.sh stop
	# Copy seahub folder
	if [ ! -z "${SEAHUB_SHARE}" ]; then
		rsync -r "./seahub/" "${SEAHUB_SHARE}" --delete --inplace -a
	fi
	# Check processes
	for i in {0..3}; do
		if [ ! -e /proc/${pids[${i}]} ]; then
			echo "${names[${i}]} terminated"
			exit 1
		fi
	done
	sleep 5
done
echo "Wait ended"
