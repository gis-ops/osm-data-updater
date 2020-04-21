cmd=${1}

export PGPASSWORD=$POSTGRES_PASS

OSMOSIS_DIR=/osm_updater/osmosis
FILENAME=/osm_updater/tmp/osmchange.osm.gz

if [ "${cmd}" == 'initialize' ]; then
  if test -f ${OSM_FILE}; then
    echo "OSM_FILE is empty"
  fi
  osm2pgsql -s -C 2000 -c -l --hstore --hstore-match-only --style /osm_updater/styles/$TAG_SET -d $OSM_DB -H $POSTGRES_HOST -U $POSTGRES_USER /osm_updater/osm/${OSM_FILE}
  # update the state.txt for osmosis
  wget "https://replicate-sequences.osm.mazdermind.de/?"`date -u +"%Y-%m-%d"`"T00:00:00Z" -O $OSMOSIS_DIR/state.txt
elif [ "${cmd}" == 'update-db' ]; then
  osmosis --read-replication-interval workingDirectory="${OSMOSIS_DIR}" --simplify-change --write-xml-change $FILENAME
  python3 /osm_updater/regional/trim_osc.py --password -d $OSM_DB --user $POSTGRES_USER --host $POSTGRES_HOST --port $POSTGRES_PORT -p "/osm_updater/polys/liechtenstein.poly" -z $FILENAME $FILENAME
  osm2pgsql -s -C 2000 --append -l --hstore --hstore-match-only --style /osm_updater/styles/$TAG_SET -d $OSM_DB -H $POSTGRES_HOST -P $POSTGRES_PORT -U $POSTGRES_USER $FILENAME
elif [ -n "${cmd}" ]; then
  echo "Command ${cmd} not recognized"
  exit 1
#else
#  echo "No command specified. Choose from 'initialize', 'update'"
fi

# Keep docker running easy
#exec "$@"
