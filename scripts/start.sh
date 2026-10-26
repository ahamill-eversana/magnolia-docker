#!/bin/sh
# Validates the WAR, Magnolia home folder and light-modules repo exist, then starts Compose.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
ENV_FILE="$ROOT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: .env not found at $ENV_FILE"
  echo "Run: cp .env.example .env   then set the three paths inside it."
  exit 1
fi

read_var() {
  value=$(awk -F= -v key="$1" '$1==key {sub(/^[^=]*=/,""); print; exit}' "$ENV_FILE")
  case "$value" in
    \"*\") value=${value#\"}; value=${value%\"} ;;
    \'*\') value=${value#\'}; value=${value%\'} ;;
  esac
  printf '%s' "$value"
}

# Relative paths are resolved against the project folder, as Compose does.
resolve() {
  case "$1" in
    /*) printf '%s' "$1" ;;
    *) printf '%s' "$ROOT_DIR/${1#./}" ;;
  esac
}

WAR=$(resolve "$(read_var MAGNOLIA_WAR_PATH | sed 's/^$/.\/bundle\/ROOT.war/')")
DATA=$(resolve "$(read_var MAGNOLIA_DATA_DIR | sed 's/^$/.\/data/')")
LM=$(resolve "$(read_var LM_REPO_DIR | sed 's/^$/.\/light-modules/')")

errors=0
fail() {
  echo "ERROR: $1"
  echo "       $2"
  errors=1
}

if [ ! -f "$WAR" ]; then
  fail "Magnolia WAR not found: $WAR" "Set MAGNOLIA_WAR_PATH in .env to the absolute path of your Magnolia author WAR file."
fi
if [ ! -d "$DATA" ]; then
  fail "Magnolia home folder not found: $DATA" "Set MAGNOLIA_DATA_DIR in .env to your existing Magnolia home folder (the one containing repositories/)."
fi
if [ ! -d "$LM" ]; then
  fail "Light-modules repo folder not found: $LM" "Set LM_REPO_DIR in .env to the folder containing your light modules."
elif [ ! -d "$LM/sanofi-lm-dupixent" ]; then
  fail "Light module not found: $LM/sanofi-lm-dupixent" "Clone sanofi-lm-dupixent into LM_REPO_DIR, or point LM_REPO_DIR at the right folder."
fi

if [ "$errors" -ne 0 ]; then
  echo
  echo "Nothing was started. Fix the items above (see README, 'Where to put your files') and re-run."
  exit 1
fi

cd "$ROOT_DIR"
exec docker compose up -d "$@"
