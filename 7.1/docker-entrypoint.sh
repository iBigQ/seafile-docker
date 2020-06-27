#!/bin/bash

set -e

# Run regularly
if [ "$1" = 'seafile' ]; then

	# Waiting for mysql to serve connections
	if [ -z "${DB_HOST}" ]; then
		DB_HOST=seafile-db
	fi
	echo "Waiting for database server on host '${DB_HOST}' to become available"
	while ! nc -q 1 ${DB_HOST} 3306 </dev/null >/dev/null 2>&1; do sleep 1; done

	# Has seafile been initialized yet?
	SEAFILE_DIR=/opt/seafile/seafile-data
	if [ ! -d ${SEAFILE_DIR} ] || [ ! "$(ls -A ${SEAFILE_DIR})" ]; then

		# Prepare for initial configuration
		SEAFILE_ARGS=""
		if [ ! -z "${SEAFILE_NAME}" ]; then
			SEAFILE_ARGS="${SEAFILE_ARGS} --server-name ${SEAFILE_NAME}"
		fi
		if [ ! -z "${SEAFILE_URL}" ]; then
			SEAFILE_ARGS="${SEAFILE_ARGS} --server-ip ${SEAFILE_URL}"
		fi
		if [ ! -z "${DB_HOST}" ]; then
			SEAFILE_ARGS="${SEAFILE_ARGS} --mysql-host ${DB_HOST}"
		fi
		if [ ! -z "${DB_USER}" ]; then
			SEAFILE_ARGS="${SEAFILE_ARGS} --mysql-user ${DB_USER} --mysql-user-host %"
			if [ -z "${DB_USER_PASSWORD}" ]; then
				# TODO generate random password
				DB_USER_PASSWORD=seafile-pw
			fi
		fi
		if [ ! -z "${DB_USER_PASSWORD}" ]; then
			SEAFILE_ARGS="${SEAFILE_ARGS} --mysql-user-passwd ${DB_USER_PASSWORD}"
		fi
		if [ ! -z "${DB_ROOT_PASSWORD}" ]; then
			SEAFILE_ARGS="${SEAFILE_ARGS} --mysql-root-passwd ${DB_ROOT_PASSWORD}"
		fi
	
		# Install Seafile
		echo "Running seafile setup: ./setup-seafile-mysql.sh auto ${SEAFILE_ARGS}"
		./setup-seafile-mysql.sh auto ${SEAFILE_ARGS}
	fi

	# Custom user
	if [ -n "${GID}" ]; then
	    groupmod -o -g "${GID}" seafile
	fi
	
	if [ -n "${UID}" ]; then
	    usermod -o -u "${UID}" seafile
	fi

	if [ -n "${GID}" ] || [ -n "${UID}" ]; then
		echo "Chown to new user"
		chown -R seafile:seafile /opt/seafile
	fi

	# Prepare sharing seahub folder
	if [ ! -z "${SEAHUB_SHARE}" ]; then
		mkdir -p "${SEAHUB_SHARE}"
		if [ -n "${GID}" ] || [ -n "${UID}" ]; then
			chown -R seafile:seafile "${SEAHUB_SHARE}"
		fi
	fi

	# Fix symlinks
	runuser seafile -c './upgrade/minor-upgrade.sh'

	# Run Seafile
	# TODO Make exec of run.sh with seafile user
	runuser seafile -c '/run.sh'
else
	exec "$@"
fi
