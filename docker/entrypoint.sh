#!/bin/sh
set -eu

WAR_PATH="/bundle/ROOT.war"
TARGET_WAR="/usr/local/tomcat/webapps/ROOT.war"

if [ ! -f "$WAR_PATH" ]; then
  echo "ERROR: Magnolia WAR not found at $WAR_PATH"
  echo "Set MAGNOLIA_WAR_PATH in .env to your WAR file path or place bundle/ROOT.war"
  exit 1
fi

cp "$WAR_PATH" "$TARGET_WAR"
exec catalina.sh run
