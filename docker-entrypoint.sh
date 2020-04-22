#!/usr/bin/env bash

export PGPASSWORD=$POSTGRES_PASS

OSMOSIS_DIR=/osm_updater/osmosis_config
FILENAME=/osm_updater/tmp/osmchange.osm.gz

result=True
for dir in \
  "polys" \
  "styles" \
  "osm" \
  "osmosis_config"
do
  if ! [ -d "$dir" ]; then
    echo "${dir} is not mounted."
    exit 1
  fi
done

cmd=${1}

if [ "${cmd}" == 'create' ]; then
  if test -f ${OSM_FILE}; then
    echo "OSM_FILE is empty"
    exit 1
  fi
  osm2pgsql -s -C 2000 -c -l --hstore --hstore-match-only --style /osm_updater/styles/$TAG_SET -d $OSM_DB -H $POSTGRES_HOST -U $POSTGRES_USER /osm_updater/osm/${OSM_FILE} > /dev/null
  echo "Created OSM tables for ${OSM_FILE}"
if [ "${cmd}" == 'append' ]; then
  if test -f ${OSM_FILE}; then
    echo "OSM_FILE is empty"
    exit 1
  fi
  osm2pgsql -s -C 2000 --append -l --hstore --hstore-match-only --style /osm_updater/styles/$TAG_SET -d $OSM_DB -H $POSTGRES_HOST -U $POSTGRES_USER /osm_updater/osm/${OSM_FILE} > /dev/null
  echo "Appended to OSM tables for ${OSM_FILE}"
elif [ "${cmd}" == 'update' ]; then
  osmosis --read-replication-interval workingDirectory="${OSMOSIS_DIR}" --simplify-change --write-xml-change $FILENAME > /dev/null
  python3 /osm_updater/regional/trim_osc.py --password -d $OSM_DB --user $POSTGRES_USER --host $POSTGRES_HOST --port $POSTGRES_PORT -p "/osm_updater/polys/${OSM_POLY}" -z $FILENAME $FILENAME
  osm2pgsql -s -C 2000 --append -l --hstore --hstore-match-only --style /osm_updater/styles/$TAG_SET -d $OSM_DB -H $POSTGRES_HOST -P $POSTGRES_PORT -U $POSTGRES_USER $FILENAME > /dev/null
  echo "Updated on `date -u +"%Y-%m-%d at %H:%M."`"
elif [ -n "${cmd}" ]; then
  echo "Command ${cmd} not recognized"
  exit 1
else
  echo "No command specified. Choose from 'create', 'append' or 'update'"
fi
