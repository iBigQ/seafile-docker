FROM python:3.6-buster AS builder

ARG SEAFILE_VERSION

RUN mkdir -p /opt/seafile/ && cd /opt/seafile/ && \
	wget https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
	tar -zxvf seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
	rm -f seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz

RUN apt-get update && apt-get -y install python3-setuptools libmemcached-dev

RUN pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy \
	django-pylibmc django-simple-captcha python3-ldap

# Initiate to set symliks
COPY ../utils/wait_file.sh /
#RUN apt-get update && apt-get -y install mariadb-server
#RUN nohup bash -c "mysqld_safe --no-auto-restart --no-watch" && \
#	/wait_file.sh "/var/run/mysqld/mysqld.sock" 10 && \
#	mysqladmin -u root password root-pw && \
#	mysql \
#		-u root -proot-pw\
#		-h localhost \
#		-e "UPDATE mysql.user SET Host='%' WHERE Host='localhost' AND User='root'; FLUSH PRIVILEGES;" && \
#	echo "127.0.0.1 seafile-db" >> /etc/hosts && \
#	/opt/seafile/seafile-server-${SEAFILE_VERSION}/setup-seafile-mysql.sh auto \
#		--server-name "Seafile" \
#		--server-ip "www.example.com" \
#		--mysql-host "seafile-db" \
#		--mysql-user "seafile" \
#		--mysql-user-passwd "seafile-pw" \
#		--mysql-user-host "%" \
#		--mysql-root-passwd "root-pw" && \
#	nohup bash -c "/opt/seafile/seafile-server-${SEAFILE_VERSION}/seafile.sh start" && \
#	/wait_file.sh "/opt/seafile/pids/ccnet.pid" 10 && \
#	/wait_file.sh "/opt/seafile/pids/seaf-server.pid" 10 && \
#	echo '{"email": "me@example.com", "password": "asecret"}' > /opt/seafile/conf/admin.txt && \
#	nohup bash -c "/opt/seafile/seafile-server-${SEAFILE_VERSION}/seahub.sh start" && \
#	/wait_file.sh "/opt/seafile/pids/seahub.pid" 10 && \
#	/opt/seafile/seafile-server-${SEAFILE_VERSION}/seahub.sh stop && \
#	/opt/seafile/seafile-server-${SEAFILE_VERSION}/seafile.sh stop && \
#	rm /opt/seafile/seafile-server-latest && \
#	rm -r /opt/seafile/seafile-data && \
#	rm -r /opt/seafile/seahub-data && \
#	rm -r /opt/seafile/conf && \
#	rm -r /opt/seafile/logs && \
#	rm -r /opt/seafile/ccnet && \
#	echo "Ran seafile and seahub"

# Allow seafile-data volume to be mapped already
RUN sed -e '/seafile_config.validate_seafile_dir(seafile_dir)/ \
		s/^#*/#/' -i /opt/seafile/seafile-server-${SEAFILE_VERSION}/setup-seafile-mysql.py && \
	sed -e '/if os.path.exists(ccnet_config.ccnet_dir)/ \
		s/^#*/#/' -i /opt/seafile/seafile-server-${SEAFILE_VERSION}/setup-seafile-mysql.py && \
	sed -e '/Utils.error('\''Ccnet config dir / \
		s/^#*/#/' -i /opt/seafile/seafile-server-${SEAFILE_VERSION}/setup-seafile-mysql.py



FROM python:3.6-buster AS seafile

ARG SEAFILE_VERSION

RUN apt-get update && apt-get -y install python3-setuptools libmemcached-dev netcat rsync
RUN pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy \
	django-pylibmc django-simple-captcha python3-ldap

RUN addgroup --gid 1000 seafile && \
	adduser --no-create-home --uid 1000 --gid 1000 --disabled-password --disabled-login --gecos '' seafile

COPY --from=builder /opt/seafile /opt/seafile
RUN chown -R seafile:seafile /opt/seafile

COPY ../utils/wait_file.sh /
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./run.sh /run.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

WORKDIR /opt/seafile/seafile-server-${SEAFILE_VERSION}
CMD ["seafile"]
