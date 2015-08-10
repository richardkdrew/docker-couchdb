# DOCKER-VERSION 1.6.2
#
# CouchDB Dockerfile
#
# https://github.com/richardkdrew/docker-couchdb
#

FROM debian:jessie

MAINTAINER Richard Drew <richardkdrew@gmail.com>

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r couchdb && useradd -r -g couchdb couchdb

# install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
 build-essential \
 erlang-base-hipe \
 erlang-dev \
 erlang-manpages \
 erlang-eunit \
 erlang-nox \
 libicu-dev \
 libmozjs185-dev \
 libcurl4-openssl-dev \
 pkg-config \
 rebar \
 curl \
 ca-certificates \
# download CouchDB
 && mkdir src \
 && cd src \
 && curl -sSLO http://apache.mirrors.ionfish.org/couchdb/source/1.6.1/apache-couchdb-1.6.1.tar.gz \
 && curl -sSLO https://www.apache.org/dist/couchdb/source/1.6.1/apache-couchdb-1.6.1.tar.gz.asc \
 && curl -sSL -o KEYS https://www.apache.org/dist/couchdb/KEYS \
 && gpg --import KEYS && gpg --verify apache-couchdb-1.6.1.tar.gz.asc \
 && tar xzvf apache-couchdb-1.6.1.tar.gz \
# install CouchDB & clean-up
 && cd apache-couchdb-1.6.1 \
 && ./configure \
 && make \
 && make install \
 && apt-get -y autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /src/* /var/tmp/* \
# grab gosu for easy step-down from root
 && gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
 && curl -sSL -o /usr/local/bin/gosu  "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
 && curl -sSL -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
 && gpg --verify /usr/local/bin/gosu.asc \
 && rm /usr/local/bin/gosu.asc \
 && chmod +x /usr/local/bin/gosu \
# set up permissions
 && chown -R couchdb:couchdb \
    /usr/local/lib/couchdb /usr/local/etc/couchdb \
    /usr/local/var/lib/couchdb /usr/local/var/log/couchdb /usr/local/var/run/couchdb \
 && chmod -R g+rw \
    /usr/local/lib/couchdb /usr/local/etc/couchdb \
    /usr/local/var/lib/couchdb /usr/local/var/log/couchdb /usr/local/var/run/couchdb \
# set up port to expose
 && sed -e 's/^bind_address = .*$/bind_address = 0.0.0.0/' -i /usr/local/etc/couchdb/default.ini

# default configuration
EXPOSE 5984
WORKDIR /usr/local/var/lib/couchdb

# Expose data, logs and configuration volumes
VOLUME ["/usr/local/var/lib/couchdb", "/usr/local/var/log/couchdb", "/usr/local/etc/couchdb"]

# run CouchDB
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["couchdb"]