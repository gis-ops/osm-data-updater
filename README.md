# KADAS Routing Server Project

## OSM Updater

This repository updates the OSM data for a user-specified region in user-specified intervals.

The project relies on the presence of a PostgreSQL database which has the `hstore`, `postgis` and `pgrouting` extensions installed.

### Installation

It's easiest to use the Docker image:

`docker pull registry.gitlab.com/swiss-topo/kadas-routing-server/kadas-routing-osm-updater`

### Customization

Ideally you don't customize the `volumes` section in `docker-compose.yml`, as most of the functionality relies on those directories being present.

#### OSM Files

Download a OSM file and place it in the `./osm` folder.

Each container can only process one single OSM file. However, you can `append` data to existing tables. And if you need to update multiple areas separately, you can run multiple `docker-compose.yml` files.

#### Volumes

There are 5 important volumes in this image, which can be found in this repository to mount:

- `/osm_updater/osmosis_config`: Contains most `osmosis` configuration to update OSM.
- `/osm_updater/polys`: Contains the polygons with which to clip the OSM changesets. Can be found on [Geofabrik](https://download.geofabrik.de).
- `/osm_updater/styles`: Contains the `style` files to limit the tags being imported.
- `/osm_updater/osm`: Contains the OSM files. Needs to be supplied by user.
- `/osm_updater/tmp`: Temporary directory for internal processing. That can grow big and is best mounted on an external drive.

See the `docker-compose.yml` for examples using the repository's defaults.

#### Environment variables

The following environment variables can be set in `docker-compose.yml` or `docker run`:

- `OSM_DB`: The DB name to import the OSM data into.
- `OSM_POLY`: The `poly` file to use to clip. Relative to `./polys`.
- `OSM_FILE`: The OSM PBF file to import initially. Relative to `./osm`.
- `TAG_SET`: The `style` file to include. Relative to `./styles`.
- `POSTGRES_HOST`: Postgres host.
- `POSTGRES_USER`: Postgres user.
- `POSTGRES_PASS`: Postgres password.
- `POSTGRES_PORT`: Postgres port.

See the `docker-compose.yml` for examples using the repository's defaults.

### Usage

The usage of the script is built around `docker-compose`, mostly due to the variety of environment variables and mandatory mounted volumes.

#### Import of OSM data

##### First time

**Careful**, this will delete existing OSM tables and create new tables from the provided PBF file:

```
docker-compose run --rm --name osm-tools osm-tools create
```

##### Append data

If you already have OSM tables set up in that database, you can also append data:

```
docker-compose run --rm --name osm-tools osm-tools append
```

#### Automatic Data Updater

To prepare the update, execute the following command first:

```bash
wget "https://replicate-sequences.osm.mazdermind.de/?"`date -u +"%Y-%m-%dT%H:%M:00Z"` -O state.txt
```

With a simple command one can update the OSM data. This is meant to be run within a daily `cron` job:

```
docker-compose run --rm --name osm-tools osm-tools update
```

E.g. a cron job can look like this:

```
# m h dom mon dow user	command
15  15 *   *   *  root  docker-compose -f /root/test/kadas-routing-osm-updater/docker-compose.yml run --rm --name osm-tools osm-tools update >> /var/log/osm_updater.log 2>&1
```
