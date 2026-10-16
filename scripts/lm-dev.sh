#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
ENV_FILE="$ROOT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: .env not found at $ENV_FILE"
  exit 1
fi

LM_REPO_DIR=$(awk -F= '/^LM_REPO_DIR=/{sub(/^LM_REPO_DIR=/,""); print; exit}' "$ENV_FILE")

if [ -z "${LM_REPO_DIR:-}" ]; then
  echo "ERROR: LM_REPO_DIR is not set in $ENV_FILE"
  exit 1
fi

# Allow optional single/double quotes around the env value.
case "$LM_REPO_DIR" in
  \"*\")
    LM_REPO_DIR=${LM_REPO_DIR#\"}
    LM_REPO_DIR=${LM_REPO_DIR%\"}
    ;;
  \''*\')
    LM_REPO_DIR=${LM_REPO_DIR#\'}
    LM_REPO_DIR=${LM_REPO_DIR%\'}
    ;;
esac

LM_DEV_DIR="$LM_REPO_DIR/sanofi-lm-dupixent"

if [ ! -d "$LM_DEV_DIR" ]; then
  echo "ERROR: LM repo does not exist: $LM_DEV_DIR"
  exit 1
fi

cd "$LM_DEV_DIR"
exec npm run start
