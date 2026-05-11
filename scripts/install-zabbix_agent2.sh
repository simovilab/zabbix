#!/bin/bash
# Ruta relativa al compose desde la ubicación del script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"   # directorio real del script
COMPOSE_FILE="$SCRIPT_DIR/../agent2/docker-compose-agent2.yml"

export DOCKER_GID=$(getent group docker | cut -d: -f3)
echo "🐳 Docker GID: $DOCKER_GID"

docker compose -f "$COMPOSE_FILE" up -d "$@"