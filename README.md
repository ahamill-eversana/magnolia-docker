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

## Configure host paths

Set environment variables in .env next to docker-compose.yml.

Example:

```bash
cp .env.example .env
```

Then edit .env:

```dotenv
MAGNOLIA_WAR_PATH=/absolute/path/to/local.war
MAGNOLIA_DATA_DIR=/absolute/path/to/existing/magnolia-data
LM_REPO_DIR=/absolute/path/to/existing/light-modules-repo
```

Notes:
- MAGNOLIA_WAR_PATH points to your Magnolia author WAR on the host.
- MAGNOLIA_DATA_DIR should point to the Magnolia data root (folder containing repositories, etc.).
- LM_REPO_DIR should point to the folder that contains your light module directories.
- The LM dev service and helper script always use `${LM_REPO_DIR}/sanofi-lm-dupixent`.
- Defaults (if unset): ./bundle/ROOT.war, ./data, ./light-modules.

## Start Magnolia

1. Ensure WAR is available via MAGNOLIA_WAR_PATH or at bundle/ROOT.war.
2. Start services:

```bash
docker compose up -d
```

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
