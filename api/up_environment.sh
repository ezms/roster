#!/bin/sh

if lsof -i :3306 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "Port 3306 in use, falling back to 3307"
    export MYSQL_PORT=3307
else
    export MYSQL_PORT=3306
fi

docker compose up "$@"
