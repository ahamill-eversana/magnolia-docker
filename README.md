# Magnolia Local Docker Compose

This setup runs a Magnolia DX Core 6.3.17 author instance locally in Docker using:
- Apache Tomcat 9.0.106
- H2 (file-based, default Magnolia behavior)

## Prerequisites

- Docker Desktop running
- Magnolia DX Core 6.3.17 author WAR from your licensed bundle

## Folder layout

Default local structure:
- bundle/ROOT.war (optional if MAGNOLIA_WAR_PATH is set)
- light-modules/ (optional default local folder for file system modules)
- data/ (optional default local Magnolia data folder)

## Containers

`./scripts/start.sh` (`docker compose up -d`) starts two containers:

| Service | Container | Purpose |
|---------|-----------|---------|
| `author` | `magnolia-author` | Runs Magnolia DX Core 6.3.17 (author) on Tomcat 9 / JDK 21. Mounts your WAR as `ROOT.war` (read-only), your home folder at `/magnolia/data` (repositories persist on your Mac) and your light-modules repo at `/magnolia/light-modules`. Served on http://localhost:8080. |
| `lm-dev` | `magnolia-lm-dev` | Node 20 container that runs `npm run start` in `sanofi-lm-dupixent` inside your light-modules repo. It watches and builds front-end assets, writing changes into the shared folder so Magnolia picks them up without a restart. Uses polling for file watching because file events don't propagate reliably into Docker on macOS. |

Both containers share the same `LM_REPO_DIR` folder, which is how front-end changes reach Magnolia.

## Where to put your files (macOS)

Docker can only mount folders it has been granted access to. By default Docker Desktop on macOS shares `/Users`, `/Volumes`, `/private`, `/tmp` and `/var/folders`. Keep the WAR, Magnolia home folder and light-modules repo under your home directory (for example `~/Projects`) to avoid mount errors.

Recommended layout:

```
~/Projects/
├── magnolia-docker/          (this repo)
└── magnolia/
    ├── local.war             (Magnolia author WAR)
    ├── home/                 (Magnolia data/home folder, contains repositories/)
    └── light-modules/        (repo containing sanofi-lm-dupixent)
```

Guidance:
- Do NOT use protected locations such as `~/Desktop`, `~/Documents`, `~/Downloads` or iCloud Drive unless Docker Desktop has been granted access in System Settings > Privacy & Security > Files and Folders (or Full Disk Access). Otherwise mounts may appear empty or fail with permission errors.
- Avoid paths outside the shared locations (e.g. external drives not under `/Volumes`). If you must use one, add it in Docker Desktop > Settings > Resources > File sharing, then Apply & restart.
- Use absolute paths in `.env`. Run `pwd` in Terminal inside each folder to get its full path (e.g. `/Users/<you>/Projects/magnolia/home`). `~` is not expanded in `.env`.
- The WAR must be a file, not a folder, and the home and light-modules paths must be existing folders.
- Quick check that Docker can see a folder:

```bash
docker run --rm -v /Users/<you>/Projects/magnolia:/check alpine ls /check
```

## Configure host paths

Set environment variables in .env next to docker-compose.yml.

Example:

```bash
cp .env.example .env
```

Then edit .env:

```dotenv
MAGNOLIA_WAR_PATH=/Users/<you>/Projects/magnolia/local.war
MAGNOLIA_DATA_DIR=/Users/<you>/Projects/magnolia/home
LM_REPO_DIR=/Users/<you>/Projects/magnolia/light-modules
```

Notes:
- MAGNOLIA_WAR_PATH points to your Magnolia author WAR on the host.
- MAGNOLIA_DATA_DIR should point to the Magnolia data root (folder containing repositories, etc.).
- LM_REPO_DIR should point to the folder that contains your light module directories.
- The LM dev service and helper script always use `${LM_REPO_DIR}/sanofi-lm-dupixent`.
- Defaults (if unset): ./bundle/ROOT.war, ./data, ./light-modules.

## Start Magnolia

1. Ensure WAR is available via MAGNOLIA_WAR_PATH or at bundle/ROOT.war.
2. Start services with the preflight script:

```bash
./scripts/start.sh
```

It checks that the WAR file, Magnolia home folder and `sanofi-lm-dupixent` light module exist. If any is missing, it prints what is wrong and how to fix it, and nothing is started. If all pass, it runs `docker compose up -d`.

Running `docker compose up -d` directly also refuses to start when a mounted path is missing (Docker will not create it), but with a terser error.

This starts:
- `author` (Magnolia)
- `lm-dev` (runs `npm run start` in `${LM_REPO_DIR}/sanofi-lm-dupixent`)

3. Follow logs during first startup (can take a few minutes):

```bash
docker compose logs -f author
```

4. Open Magnolia:

- Login UI: http://localhost:8080/magnoliaAuthor

## Run LM dev script

To run the LM start command in `${LM_REPO_DIR}/sanofi-lm-dupixent`:

```bash
./scripts/lm-dev.sh
```

Or use Compose logs for the managed dev service:

```bash
docker compose logs -f lm-dev
```

## Stop / reset

Stop:

```bash
docker compose down
```

Fresh start (default local bind mounts):

```bash
docker compose down
rm -rf ./data/* ./light-modules/*
touch ./data/.gitkeep ./light-modules/.gitkeep
```

If you use external folders via `.env` (`MAGNOLIA_DATA_DIR` / `LM_REPO_DIR`), clean those paths directly instead.

## Notes

- Persisted data is mounted to /magnolia/data from ${MAGNOLIA_DATA_DIR:-./data}.
- Light modules are mounted to /magnolia/light-modules from ${LM_REPO_DIR:-./light-modules}.
- WAR is mounted from ${MAGNOLIA_WAR_PATH:-./bundle/ROOT.war}.
- LM dev service runs in ${LM_REPO_DIR:-./light-modules}/sanofi-lm-dupixent.
- JVM options are set via CATALINA_OPTS in docker-compose.yml.
- Container startup validates the mounted WAR exists and exits with a clear error if it is missing.
