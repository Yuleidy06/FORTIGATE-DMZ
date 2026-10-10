#!/bin/bash
# =============================================================
# Script de instalación y configuración del DB Server
# SRV-DB (10.9.50.4)
# Imagen: Ubuntu 22.04 (Docker, GNS3)
#
# Uso: bash srv-db.sh
# =============================================================

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
apt install -y --fix-missing mysql-server openssh-server iproute2 curl

# 5. Iniciar MySQL y crear las bases de datos
service mysql start
mysql -e "CREATE DATABASE IF NOT EXISTS caja; CREATE DATABASE IF NOT EXISTS inventario;"

# 6. Permitir conexiones desde los Web Servers de la DMZ
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart
mysql -e "CREATE USER IF NOT EXISTS 'app'@'10.9.50.%' IDENTIFIED BY 'App123';
          GRANT ALL ON caja.* TO 'app'@'10.9.50.%';
          GRANT ALL ON inventario.* TO 'app'@'10.9.50.%';
          FLUSH PRIVILEGES;"

# 7. Usuario para acceso SSH (la contraseña se asigna a mano con: passwd admin)
id admin >/dev/null 2>&1 || useradd -m -s /bin/bash admin

# 8. Iniciar SSH
mkdir -p /run/sshd
service ssh start

# 9. Verificación
mysql -e "SHOW DATABASES;"
echo "Listo. Asigne la contraseña del usuario admin con: passwd admin"
