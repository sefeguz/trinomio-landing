#!/bin/bash

# ================================================
# Script de instalación de Strapi para Trinomio
# ================================================

echo "🚀 INSTALACIÓN DE STRAPI CMS PARA TRINOMIO"
echo "=========================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuración
DB_NAME="trinomio_cms"
DB_USER="trinomio"
DB_PASS="TrinomioSecure2024"
PROJECT_DIR="/home/ubuntu/trinomio"

# Función para imprimir mensajes
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}📌 $1${NC}"
}

# 1. Actualizar sistema
echo ""
echo "1️⃣ Actualizando sistema..."
echo "----------------------------"
sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential git curl

# 2. Instalar Node.js 18 LTS
echo ""
echo "2️⃣ Instalando Node.js 18 LTS..."
echo "--------------------------------"
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verificar instalación
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
print_success "Node.js instalado: $NODE_VERSION"
print_success "NPM instalado: $NPM_VERSION"

# 3. Instalar herramientas globales
echo ""
echo "3️⃣ Instalando herramientas globales..."
echo "--------------------------------------"
sudo npm install -g yarn pm2

# 4. Instalar y configurar PostgreSQL
echo ""
echo "4️⃣ Instalando PostgreSQL..."
echo "---------------------------"
sudo apt install -y postgresql postgresql-contrib

# Iniciar PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Configurar base de datos
echo "Configurando base de datos..."
sudo -u postgres psql <<EOF
CREATE DATABASE $DB_NAME;
CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
ALTER DATABASE $DB_NAME OWNER TO $DB_USER;
\q
EOF

print_success "Base de datos configurada"

# 5. Crear directorio del proyecto
echo ""
echo "5️⃣ Preparando directorio del proyecto..."
echo "----------------------------------------"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# 6. Instalar Strapi
echo ""
echo "6️⃣ Instalando Strapi CMS..."
echo "---------------------------"

# Crear package.json para Strapi
cat > $PROJECT_DIR/cms/package.json <<'EOF'
{
  "name": "trinomio-cms",
  "version": "1.0.0",
  "description": "CMS para Trinomio",
  "scripts": {
    "develop": "strapi develop",
    "start": "strapi start",
    "build": "strapi build",
    "strapi": "strapi"
  },
  "dependencies": {
    "@strapi/strapi": "4.24.2",
    "@strapi/plugin-users-permissions": "4.24.2",
    "@strapi/plugin-i18n": "4.24.2",
    "pg": "^8.11.3"
  },
  "engines": {
    "node": ">=16.0.0 <=20.x.x",
    "npm": ">=6.0.0"
  }
}
EOF

# Instalar dependencias
cd $PROJECT_DIR/cms
npm install

# Crear configuración de base de datos
mkdir -p config
cat > config/database.js <<EOF
module.exports = ({ env }) => ({
  connection: {
    client: 'postgres',
    connection: {
      host: env('DATABASE_HOST', '127.0.0.1'),
      port: env.int('DATABASE_PORT', 5432),
      database: env('DATABASE_NAME', '$DB_NAME'),
      user: env('DATABASE_USERNAME', '$DB_USER'),
      password: env('DATABASE_PASSWORD', '$DB_PASS'),
      ssl: env.bool('DATABASE_SSL', false),
    },
  },
});
EOF

# Crear archivo .env
cat > .env <<EOF
HOST=0.0.0.0
PORT=1337
APP_KEYS=toBeModified1,toBeModified2,toBeModified3,toBeModified4
API_TOKEN_SALT=tobemodified
ADMIN_JWT_SECRET=tobemodified
TRANSFER_TOKEN_SALT=tobemodified
JWT_SECRET=tobemodified
DATABASE_HOST=127.0.0.1
DATABASE_PORT=5432
DATABASE_NAME=$DB_NAME
DATABASE_USERNAME=$DB_USER
DATABASE_PASSWORD=$DB_PASS
DATABASE_SSL=false
EOF

# Generar keys aleatorias
node -e "
const crypto = require('crypto');
const fs = require('fs');

const generateKey = () => crypto.randomBytes(16).toString('base64');

const envContent = fs.readFileSync('.env', 'utf8');
const newEnv = envContent
  .replace('toBeModified1', generateKey())
  .replace('toBeModified2', generateKey())
  .replace('toBeModified3', generateKey())
  .replace('toBeModified4', generateKey())
  .replace(/tobemodified/g, generateKey());

fs.writeFileSync('.env', newEnv);
console.log('✅ Keys generadas');
"

# Build Strapi
print_info "Building Strapi (esto puede tardar varios minutos)..."
npm run build

# 7. Clonar frontend
echo ""
echo "7️⃣ Clonando repositorio frontend..."
echo "-----------------------------------"
cd $PROJECT_DIR
git clone https://github.com/sefeguz/trinomio-landing.git frontend

# 8. Instalar y configurar Nginx
echo ""
echo "8️⃣ Instalando Nginx..."
echo "----------------------"
sudo apt install -y nginx

# Crear configuración de Nginx
sudo tee /etc/nginx/sites-available/trinomio > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    # Frontend
    location / {
        root /home/ubuntu/trinomio/frontend;
        index index-dynamic.html index.html;
        try_files $uri $uri/ /index.html;
    }

    # Strapi Admin Panel
    location /admin {
        proxy_pass http://localhost:1337/admin;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Strapi API
    location /api {
        rewrite ^/api/?(.*)$ /$1 break;
        proxy_pass http://localhost:1337;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $http_host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_pass_request_headers on;
    }

    # Strapi uploads
    location /uploads {
        proxy_pass http://localhost:1337/uploads;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Activar sitio
sudo ln -sf /etc/nginx/sites-available/trinomio /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test y reiniciar Nginx
sudo nginx -t
sudo systemctl restart nginx

# 9. Configurar PM2
echo ""
echo "9️⃣ Configurando PM2..."
echo "----------------------"
cd $PROJECT_DIR/cms

# Crear archivo ecosystem para PM2
cat > ecosystem.config.js <<'EOF'
module.exports = {
  apps: [
    {
      name: 'strapi-trinomio',
      script: 'npm',
      args: 'start',
      env: {
        NODE_ENV: 'production',
      },
      cwd: '/home/ubuntu/trinomio/cms',
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
    },
  ],
};
EOF

# Iniciar con PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd -u ubuntu --hp /home/ubuntu

# 10. Configurar firewall
echo ""
echo "🔟 Configurando firewall..."
echo "--------------------------"
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
echo "y" | sudo ufw enable

# Resumen final
echo ""
echo "=========================================="
echo -e "${GREEN}🎉 ¡INSTALACIÓN COMPLETADA!${NC}"
echo "=========================================="
echo ""
echo "📍 ACCESOS:"
echo "  • Sitio Web: http://$(curl -s ifconfig.me)"
echo "  • Panel Admin: http://$(curl -s ifconfig.me)/admin"
echo "  • API: http://$(curl -s ifconfig.me)/api"
echo ""
echo "📝 PRÓXIMOS PASOS:"
echo "  1. Accede al panel admin y crea tu usuario"
echo "  2. Configura los Content Types desde el panel"
echo "  3. Agrega el contenido inicial"
echo ""
echo "⚙️ COMANDOS ÚTILES:"
echo "  • Ver logs: pm2 logs strapi-trinomio"
echo "  • Reiniciar: pm2 restart strapi-trinomio"
echo "  • Estado: pm2 status"
echo ""
echo "🔐 CREDENCIALES BD:"
echo "  • Database: $DB_NAME"
echo "  • Usuario: $DB_USER"
echo "  • Password: $DB_PASS"
echo ""
echo "=========================================="