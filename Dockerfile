FROM ubuntu:18.04 as builder
LABEL maintainer=nils@gis-ops.com

ARG OSMOSIS_VERSION=0.47.4
ENV TERM xterm

WORKDIR /osm_updater

COPY osmosis.config /osm_updater/

# Install everything
RUN apt-get update && apt-get install -y software-properties-common gpg wget && \
    export DEBIAN_FRONTEND=noninteractive && \

    # Install osm2pgsql
    add-apt-repository -y ppa:osmadmins/ppa && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv A438A16C88C6BE41CB1616B8D57F48750AC4F2CB && \
    apt-get update && \
    apt-get install -y git-core osm2pgsql \
        python3-lxml python3-psycopg2 python3-shapely default-jre && \

    # Install Osmosis
    mkdir /osm_updater/osmosis && \
    wget --quiet -P /osm_updater/osmosis https://github.com/openstreetmap/osmosis/releases/download/0.47.4/osmosis-${OSMOSIS_VERSION}.tgz && \
    cd osmosis && tar xvfz osmosis-${OSMOSIS_VERSION}.tgz && rm osmosis-${OSMOSIS_VERSION}.tgz && \
    chmod a+x bin/osmosis && ln -s /osm_updater/osmosis/bin/osmosis /usr/bin/osmosis && \
    mv /osm_updater/osmosis.config /root/.osmosis && \

    # Install regional clipping script
    cd /osm_updater && \
    git clone https://github.com/gis-ops/regional.git && \
    chmod u+x /osm_updater/regional/trim_osc.py && \
    # Make tmp dir for osmosis
    mkdir /osm_updater/tmp

COPY docker-entrypoint.sh ./

ENTRYPOINT ["/bin/bash", "/osm_updater/docker-entrypoint.sh"]
