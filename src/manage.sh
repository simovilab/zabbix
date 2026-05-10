#!/bin/bash

echo "¿Qué quieres hacer?"
echo "1) Levantar servicios"
echo "2) Detener servicios"

read -p "Selecciona una opción [1-2]: " opcion


case $opcion in
  1)
    echo "Levantando servicios..."
    docker compose --profile "*" up -d
    ;;
  2)
    echo "Deteniendo servicios..."
    docker compose --profile "*" down
    ;;
  *)
    echo "Opción inválida"
    exit 1
    ;;
esac