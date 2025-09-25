# 📋 INSTALACIÓN MANUAL PASO A PASO

## ⚠️ IMPORTANTE
El servidor parece estar ocupado procesando la instalación. Sigue estos pasos manualmente:

## 1️⃣ Conecta al servidor

```bash
plink -i "C:\Users\SEFEGUZ\Downloads\VPN.ppk" ubuntu@168.138.135.98
```

## 2️⃣ Verifica si la instalación se completó

```bash
# Ver si npm terminó de instalar
ps aux | grep npm

# Si no hay procesos npm, verifica los archivos
ls -la /home/ubuntu/trinomio/cms/

# Si existe node_modules, la instalación se completó
```

## 3️⃣ Si la instalación NO se completó, ejecuta:

```bash
# Limpia e instala de nuevo
cd /home/ubuntu
rm -rf trinomio/cms
mkdir -p trinomio/cms
cd trinomio/cms

# Crea el package.json
cat > package.json << 'EOF'
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
    "@strapi/strapi": "4.15.5",
    "@strapi/plugin-users-permissions": "4.15.5",
    "@strapi/plugin-i18n": "4.15.5",
    "pg": "8.11.3"
  },
  "engines": {
    "node": ">=16.0.0 <=20.x.x",
    "npm": ">=6.0.0"
  }
}
EOF

# Instala dependencias
npm install
```

## 4️⃣ Configura la base de datos

```bash
# Crea la carpeta config
mkdir -p config

# Crea el archivo de configuración de la base de datos
cat > config/database.js << 'EOF'
module.exports = ({ env }) => ({
  connection: {
    client: 'postgres',
    connection: {
      host: '127.0.0.1',
      port: 5432,
      database: 'trinomio_cms',
      user: 'trinomio',
      password: 'TrinomioSecure2024',
      ssl: false,
    },
  },
});
EOF

# Crea el archivo .env
cat > .env << 'EOF'
HOST=0.0.0.0
PORT=1337
APP_KEYS=key1,key2,key3,key4
API_TOKEN_SALT=token1
ADMIN_JWT_SECRET=secret1
TRANSFER_TOKEN_SALT=transfer1
JWT_SECRET=jwt1
EOF
```

## 5️⃣ Genera las claves de seguridad

```bash
# Genera claves aleatorias para .env
node -e "
const crypto = require('crypto');
const fs = require('fs');
const gen = () => crypto.randomBytes(16).toString('base64');
const env = fs.readFileSync('.env', 'utf8')
  .replace('key1', gen())
  .replace('key2', gen())
  .replace('key3', gen())
  .replace('key4', gen())
  .replace('token1', gen())
  .replace('secret1', gen())
  .replace('transfer1', gen())
  .replace('jwt1', gen());
fs.writeFileSync('.env', env);
console.log('✅ Claves generadas');
"
```

## 6️⃣ Construye Strapi

```bash
npm run build
```

## 7️⃣ Inicia Strapi con PM2

```bash
# Instala PM2 si no lo tienes
sudo npm install -g pm2

# Inicia Strapi
pm2 start npm --name strapi-trinomio -- start
pm2 save
pm2 startup
```

## 8️⃣ Clona y configura el frontend

```bash
cd /home/ubuntu/trinomio
git clone https://github.com/sefeguz/trinomio-landing.git frontend

# Copia la versión dinámica como principal
cd frontend
cp index-dynamic.html index.html
```

## 9️⃣ Configura Nginx

```bash
# Instala Nginx
sudo apt install -y nginx

# Crea la configuración
sudo nano /etc/nginx/sites-available/trinomio
```

Pega esto en el archivo:

```nginx
server {
    listen 80;
    server_name _;

    # Frontend
    location / {
        root /home/ubuntu/trinomio/frontend;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # Strapi Admin
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
```

Guarda con `Ctrl+X`, luego `Y`, luego `Enter`

## 🔟 Activa el sitio

```bash
# Activa la configuración
sudo ln -sf /etc/nginx/sites-available/trinomio /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Reinicia Nginx
sudo nginx -t
sudo systemctl restart nginx
```

## ✅ VERIFICACIÓN FINAL

1. **Frontend**: Abre http://168.138.135.98
2. **Admin Panel**: Abre http://168.138.135.98/admin
3. **API**: http://168.138.135.98/api

## 🎯 CONFIGURAR STRAPI

1. Accede a http://168.138.135.98/admin
2. Crea tu usuario administrador
3. Ve a Content-Type Builder y crea:

### Configuración (Single Type)
- siteName (Text)
- heroTitle (Text)
- heroSubtitle (Text)
- slogan (Text)
- whatsapp (Text)
- instagram (Text)
- address (Text)

### Talleres (Collection Type)
- name (Text)
- description (Rich Text)
- schedule (Text)
- duration (Text)
- price (Number)
- active (Boolean)

### Dimensiones (Collection Type)
- name (Text)
- description (Text)
- icon (Text)
- color (Enumeration: coral, blue, mint, yellow)
- status (Enumeration: active, coming_soon)

4. En Settings > Roles > Public, permite:
   - find para todos los content types
   - findOne para todos los content types

## 📱 COMANDOS ÚTILES

```bash
# Ver logs
pm2 logs strapi-trinomio

# Reiniciar Strapi
pm2 restart strapi-trinomio

# Ver estado
pm2 status

# Detener todo
pm2 stop all

# Iniciar todo
pm2 start all
```

## ⚠️ SI ALGO FALLA

1. Verifica los logs: `pm2 logs`
2. Verifica PostgreSQL: `sudo systemctl status postgresql`
3. Verifica Nginx: `sudo systemctl status nginx`
4. Verifica puertos: `sudo netstat -tlnp`

## 🎉 ¡LISTO!

Una vez configurado, podrás actualizar todo el contenido desde el panel admin sin tocar código.