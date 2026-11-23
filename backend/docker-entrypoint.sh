#!/bin/sh
set -e

DATABASE_VALUE="${DB_URL:-${DATABASE_URL:-}}"

if [ -n "$DATABASE_VALUE" ]; then
    case "$DATABASE_VALUE" in
        jdbc:postgresql://*)
            export SPRING_DATASOURCE_URL="$DATABASE_VALUE"
            ;;
        postgresql://*|postgres://*)
            DATABASE_REST="${DATABASE_VALUE#*://}"
            if [ "${DATABASE_REST#*@}" != "$DATABASE_REST" ]; then
                DATABASE_AUTH="${DATABASE_REST%%@*}"
                DATABASE_REST="${DATABASE_REST#*@}"
                DATABASE_USER="${DATABASE_AUTH%%:*}"
                DATABASE_PASS="${DATABASE_AUTH#*:}"
                [ -z "${SPRING_DATASOURCE_USERNAME:-}" ] && [ -z "${DB_USERNAME:-}" ] &&
                    export SPRING_DATASOURCE_USERNAME="$DATABASE_USER"
                [ -z "${SPRING_DATASOURCE_PASSWORD:-}" ] && [ -z "${DB_PASSWORD:-}" ] &&
                    export SPRING_DATASOURCE_PASSWORD="$DATABASE_PASS"
            fi
            export SPRING_DATASOURCE_URL="jdbc:postgresql://$DATABASE_REST"
            ;;
        *:5432/*)
            export SPRING_DATASOURCE_URL="jdbc:postgresql://${DATABASE_VALUE}"
            ;;
        *)
            export SPRING_DATASOURCE_URL="jdbc:postgresql://$DATABASE_VALUE"
            ;;
    esac
fi

if [ -z "${SPRING_DATASOURCE_USERNAME:-}" ] && [ -n "${DB_USERNAME:-}" ]; then
    export SPRING_DATASOURCE_USERNAME="$DB_USERNAME"
fi

if [ -z "${SPRING_DATASOURCE_PASSWORD:-}" ] && [ -n "${DB_PASSWORD:-}" ]; then
    export SPRING_DATASOURCE_PASSWORD="$DB_PASSWORD"
fi

exec java -jar /app/app.jar "$@"
