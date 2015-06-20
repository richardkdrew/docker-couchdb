# DOCKER-VERSION 1.6.2

FROM debian:jessie

MAINTAINER Richard Drew <richardkdrew@gmail.com>

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
 curl

# install CouchDB 1.6.1 & clean-up
RUN mkdir src \
 && cd src \
 && curl -O http://apache.mirrors.ionfish.org/couchdb/source/1.6.1/apache-couchdb-1.6.1.tar.gz \
 && tar xzvf apache-couchdb-1.6.1.tar.gz \
 && cd apache-couchdb-1.6.1 \
 && ./configure \
 && make \
 && make install \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /src/* /var/tmp/*

# set up data and port to expose
RUN sed -e 's/^bind_address = .*$/bind_address = 0.0.0.0/' -i /usr/local/etc/couchdb/default.ini \
 && sed -e 's/^database_dir = .*$/database_dir = \/data/' -i /usr/local/etc/couchdb/default.ini \
 && sed -e 's/^view_index_dir = .*$/view_index_dir = \/data/' -i /usr/local/etc/couchdb/default.ini

# Expose main listening port
EXPOSE 5984

# Expose data, logs and configuration volumes
VOLUME ["/data", "/usr/local/var/log/couchdb", "/usr/local/etc/couchdb"]

# run CouchDB
ENTRYPOINT ["/usr/local/bin/couchdb"]