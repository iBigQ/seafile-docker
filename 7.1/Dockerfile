FROM python:3.6-buster AS builder

ARG SEAFILE_VERSION

RUN mkdir -p /opt/seafile/ && cd /opt/seafile/ && \
	wget https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
	tar -zxvf seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
	rm -f seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    python3-setuptools \
    libmemcached-dev && \
  rm -rf /var/lib/apt/lists/*

RUN pip3 install --timeout=3600 \
  Pillow \
  pylibmc \
  captcha \
  jinja2 \
  sqlalchemy \
  django-pylibmc \
  django-simple-captcha \
  python3-ldap

# Initiate to set symliks
COPY ./utils/wait_file.sh /

# Allow some volumes to already be mapped when initializing
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

COPY ./utils/wait_file.sh /
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./run.sh /run.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

WORKDIR /opt/seafile/seafile-server-${SEAFILE_VERSION}
CMD ["seafile"]
