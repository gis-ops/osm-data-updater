# KADAS Routing Server Project

## OSM Updater

This repository updates the OSM data for a user-specified region in user-specified intervals.

The project relies on the presence of a PostgreSQL database which has the `hstore`, `postgis` and `pgrouting` extensions installed.

### Installation

It's easiest to use Docker to install the program:

`docker install`


## Usage

It's easiest to use via `docker-compose.yml`.

### Initial import of OSM data

Execute the following command after `init`ing the DB and add `./state.txt` as a volume to `/osm_updater/osmosis`:

```bash
wget "https://replicate-sequences.osm.mazdermind.de/?"`date -u +"%Y-%m-%d"`"T00:00:00Z" -O ./state.txt
```

### Environment Variables
