#!/bin/bash
# =============================================================
# Script de instalación y configuración de los Web Servers
# SRV-CAJA (10.9.50.2) y SRV-INVENTARIO (10.9.50.3)
# Imagen: Ubuntu 22.04 (Docker, GNS3)
#
# Uso:
#   bash srv-web.sh caja         -> en SRV-CAJA
#   bash srv-web.sh inventario   -> en SRV-INVENTARIO
# =============================================================

ROL="$1"

if [ "$ROL" = "caja" ]; then
    TITULO="Sistema de Caja"
    IP="10.9.50.2"
elif [ "$ROL" = "inventario" ]; then
    TITULO="Sistema de Inventario"
    IP="10.9.50.3"
else
    echo "Uso: bash srv-web.sh [caja|inventario]"
    exit 1
fi

# 1. DNS: el FortiGate (DNS Service en port3 / DMZ)
echo "nameserver 10.9.50.1" > /etc/resolv.conf

# 2. Repositorios: solo "main" y mirror permitido en GRP-UPDATES
cat > /etc/apt/sources.list <<'EOF'
deb http://mirrors.edge.kernel.org/ubuntu jammy main
deb http://mirrors.edge.kernel.org/ubuntu jammy-updates main
deb http://mirrors.edge.kernel.org/ubuntu jammy-security main
EOF

# 3. Reintentos de descarga (red virtual lenta)
echo 'Acquire::Retries "10";' > /etc/apt/apt.conf.d/80-retries

# 4. Instalación de paquetes
apt update
apt install -y --fix-missing nginx openssh-server iproute2 curl

# 5. Página web del sistema
echo "<h1>${TITULO}</h1><p>Servidor ${IP}</p>" > /var/www/html/index.html

# 6. Usuario para acceso SSH (la contraseña se asigna a mano con: passwd admin)
id admin >/dev/null 2>&1 || useradd -m -s /bin/bash admin

# 7. Iniciar servicios
mkdir -p /run/sshd
service nginx start
service ssh start

# 8. Verificación
curl -s http://localhost
echo
echo "Listo. Asigne la contraseña del usuario admin con: passwd admin"
