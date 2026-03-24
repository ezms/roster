#!/bin/sh

if lsof -i :3306 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "Port 3306 in use, falling back to 3307"
    export DB_PORT=3307
else
    export DB_PORT=3306
fi

if [ -f .env ]; then
    while IFS='=' read -r key value; do
        case "$key" in
            '#'*|'') continue ;;
        esac
        eval "[ -z \"\${${key}+x}\" ] && export ${key}=\"${value}\""
    done < .env
fi

export DB_HOST=${DB_HOST:-127.0.0.1}
export DB_USER=${DB_USER:-root}
export DB_PASSWORD=${DB_PASSWORD:-root}

docker compose up "$@" -d
