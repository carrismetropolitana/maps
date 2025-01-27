#!/bin/sh

while true; do
    docker compose -p maps up -d --build --force-recreate --remove-orphans --pull=always planetiler
    sleep 21600  # 6 horas em segundos
done
