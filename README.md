# Magnolia Local Docker Compose

This setup runs a Magnolia DX Core 6.3.17 author instance locally in Docker using:
- Apache Tomcat 9.0.106
- H2 (file-based, default Magnolia behavior)

## Get this repository

Clone the repository and enter its directory:

```bash
git clone https://github.com/ahamill-eversana/magnolia-docker.git
cd magnolia-docker
```

Alternatively, download the repository as a ZIP from [GitHub](https://github.com/ahamill-eversana/magnolia-docker), extract it, and open a terminal in the extracted `magnolia-docker` directory.

## Prerequisites

- This repository cloned or downloaded to your computer (see [Get this repository](#get-this-repository)).
- Docker Desktop installed and running.
- Magnolia DX Core 6.3.17 author WAR from your licensed bundle.
- An existing Magnolia data/home folder for the database and repository files.
- The `sanofi-lm-dupixent` light-module repository.

## Where to put your files (macOS)

First, keep the WAR, Magnolia data/home folder, and light-module repository in a location Docker Desktop can access. By default, Docker Desktop on macOS shares `/Users`, `/Volumes`, `/private`, `/tmp`, and `/var/folders`. A simple choice is a `Projects` folder in your home directory.

For example, if you cloned this repository into `~/Projects`, arrange the files like this. The `magnolia-docker` folder is the repository you cloned; the separate `magnolia` folder holds the WAR, data, and light modules:

```
~/Projects/
├── magnolia-docker/          (this repo)
└── magnolia/
    ├── local.war             (Magnolia author WAR)
    ├── home/                 (Magnolia data/home folder, contains repositories/)
    └── light-modules/        (repo containing sanofi-lm-dupixent)
```

The `home` folder must already exist and be your Magnolia data/home directory (the folder containing `repositories/`). The `light-modules` folder must contain `sanofi-lm-dupixent`, and `local.war` must be the WAR file itself, not a folder.

macOS may restrict Docker Desktop's access to protected locations such as `~/Desktop`, `~/Documents`, `~/Downloads`, or iCloud Drive. If a mount from one of these locations is denied, check System Settings > Privacy & Security and grant Docker Desktop access if prompted. Docker Desktop shares `/Users` by default; if you keep these files outside its shared locations, add the folder in Docker Desktop > Settings > Resources > File sharing.

## Configure the paths

In Terminal, make sure you are in the `magnolia-docker` folder you cloned (the folder containing `docker-compose.yml`). Create the local `.env` file there:

```sh
cp .env.example .env
```

If Terminal is not already in that folder, use `cd` to go there first. For example, if you cloned the repository into `~/Projects`, run `cd ~/Projects/magnolia-docker`.

Open `.env` in a text editor and set these paths to match where you put your files. Use full paths (starting with `/Users/...`); do not use `~`:

```dotenv
MAGNOLIA_WAR_PATH=/Users/<you>/Projects/magnolia/local.war
MAGNOLIA_DATA_DIR=/Users/<you>/Projects/magnolia/home
LM_REPO_DIR=/Users/<you>/Projects/magnolia/light-modules
```

Change `<you>` to your macOS account name and adjust the paths if your folders are somewhere else. For example, if you are unsure of a folder's full path, open that folder in Terminal and run `pwd`.

## Start Magnolia

Make sure Docker Desktop is running. In Terminal, from inside the `magnolia-docker` folder, run:

```bash
./scripts/start.sh
```

The script checks that the WAR, home folder, light-modules folder, and `sanofi-lm-dupixent` module exist. If something is missing, it reports the problem and does not start the containers. The first startup can take a few minutes; follow the Magnolia logs with:

```bash
docker compose logs -f author
```

When startup finishes, open Magnolia:

- http://localhost:8080

## What gets started

The start script launches two containers:

| Service | Container | Purpose |
|---------|-----------|---------|
| `author` | `magnolia-author` | Runs Magnolia DX Core 6.3.17 on Tomcat 9 / JDK 21. Your WAR is mounted read-only as `ROOT.war`; your data/home folder is mounted at `/magnolia/data`, and your light modules at `/magnolia/light-modules`. Magnolia is served at http://localhost:8080. |
| `lm-dev` | `magnolia-lm-dev` | Runs `npm run start` in `sanofi-lm-dupixent` using Node 20. It watches and builds front-end assets in the shared light-modules folder so Magnolia can pick up changes. |

Both containers share the light-modules folder. File watching uses polling because file events do not reliably propagate into Docker on macOS.

## Stop

Stop:

```bash
docker compose down
```
