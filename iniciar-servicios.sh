#!/bin/bash
# =============================================================
# Inicia los servicios después de encender un servidor.
# (Los contenedores Docker de GNS3 no inician servicios solos.)
#
# Uso: bash iniciar-servicios.sh
# =============================================================

mkdir -p /run/sshd

if command -v nginx >/dev/null 2>&1; then
    service nginx start
fi

if command -v mysqld >/dev/null 2>&1; then
    service mysql start
fi

service ssh start
