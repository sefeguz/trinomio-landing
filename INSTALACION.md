# 📚 Guía de Instalación - Trinomio CMS

## 🎯 Resumen

Esta guía te ayudará a instalar y configurar el sistema completo de Trinomio con:
- Landing page dinámica que consume datos de una API
- Strapi CMS para gestión de contenido
- PostgreSQL como base de datos
- Nginx como servidor web
- PM2 para mantener los servicios activos

## 📋 Prerrequisitos

- Servidor Ubuntu 20.04 o superior
- Acceso SSH al servidor
- Al menos 2GB de RAM
- 20GB de espacio en disco

## 🚀 Instalación Rápida

### Paso 1: Conectar al servidor

```bash
# Si tienes PuTTY en Windows:
plink -i "C:\ruta\a\tu\llave.ppk" ubuntu@168.138.135.98

# Si tienes SSH en Linux/Mac:
ssh -i /ruta/a/tu/llave.pem ubuntu@168.138.135.98
```

### Paso 2: Subir y ejecutar el script de instalación

1. Sube el archivo `setup-strapi-server.sh` al servidor
2. Dale permisos de ejecución:
```bash
chmod +x setup-strapi-server.sh
```

3. Ejecuta el script:
```bash
./setup-strapi-server.sh
```

El script instalará automáticamente:
- Node.js 18 LTS
- PostgreSQL
- Strapi CMS
- Nginx
- PM2
- Tu landing page

## 🛠️ Instalación Manual (Paso a Paso)

### 1. Actualizar el sistema

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential git curl
```

### 2. Instalar Node.js 18

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

### 3. Instalar herramientas globales

```bash
sudo npm install -g yarn pm2
```

### 4. Instalar PostgreSQL

```bash
sudo apt install -y postgresql postgresql-contrib

# Crear base de datos
sudo -u postgres psql
CREATE DATABASE trinomio_cms;
CREATE USER trinomio WITH PASSWORD 'TrinomioSecure2024';
GRANT ALL PRIVILEGES ON DATABASE trinomio_cms TO trinomio;
\q
```

### 5. Instalar Strapi

```bash
mkdir -p /home/ubuntu/trinomio/cms
cd /home/ubuntu/trinomio/cms

# Crear package.json
cat > package.json <<'EOF'
{
  "name": "trinomio-cms",
  "version": "1.0.0",
  "scripts": {
    "develop": "strapi develop",
    "start": "strapi start",
    "build": "strapi build"
  },
  "dependencies": {
    "@strapi/strapi": "4.24.2",
    "@strapi/plugin-users-permissions": "4.24.2",
    "@strapi/plugin-i18n": "4.24.2",
    "pg": "^8.11.3"
  }
}
EOF

npm install
```

### 6. Configurar Strapi

Crear archivo `/home/ubuntu/trinomio/cms/config/database.js`:

```javascript
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
```

### 7. Clonar el frontend

```bash
cd /home/ubuntu/trinomio
git clone https://github.com/sefeguz/trinomio-landing.git frontend
```

### 8. Configurar Nginx

```bash
sudo apt install -y nginx

# Crear configuración
sudo nano /etc/nginx/sites-available/trinomio
```

Pegar la configuración de Nginx del archivo `setup-strapi-server.sh`

```bash
# Activar el sitio
sudo ln -s /etc/nginx/sites-available/trinomio /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx
```

### 9. Iniciar servicios con PM2

```bash
cd /home/ubuntu/trinomio/cms
npm run build
pm2 start npm --name strapi-trinomio -- start
pm2 save
pm2 startup
```

## 📝 Configuración Post-Instalación

### 1. Crear usuario admin en Strapi

1. Abre: `http://TU-IP-SERVIDOR/admin`
2. Crea tu primer usuario administrador
3. Este será tu acceso principal al CMS

### 2. Configurar Content Types

En el panel de Strapi, crea los siguientes Content Types:

#### Configuración General (Single Type)
- `siteName` (Text)
- `heroTitle` (Text)
- `heroSubtitle` (Text)
- `slogan` (Text)
- `heroImage` (Media)
- `whatsapp` (Text)
- `instagram` (Text)
- `email` (Email)
- `address` (Text)

#### Dimensiones (Collection Type)
- `name` (Text)
- `description` (Long text)
- `icon` (Text)
- `color` (Enumeration: coral, blue, mint, yellow)
- `status` (Enumeration: active, coming_soon)

#### Talleres (Collection Type)
- `name` (Text)
- `description` (Long text)
- `schedule` (Text)
- `duration` (Text)
- `price` (Number)
- `image` (Media)
- `active` (Boolean)

### 3. Configurar permisos de API

1. Ve a Settings → Roles → Public
2. Para cada Content Type, marca:
   - `find` (para listas)
   - `findOne` (para elementos individuales)

### 4. Agregar contenido inicial

Desde el panel de Strapi, agrega:
1. La configuración general del sitio
2. Las 4 dimensiones (Creativa, Madera, Herrería, Textil)
3. Los talleres actuales con sus precios

## 🔧 Mantenimiento

### Comandos útiles

```bash
# Ver logs de Strapi
pm2 logs strapi-trinomio

# Reiniciar Strapi
pm2 restart strapi-trinomio

# Ver estado de servicios
pm2 status

# Reiniciar Nginx
sudo systemctl restart nginx

# Ver logs de Nginx
sudo tail -f /var/log/nginx/error.log
```

### Actualizar contenido

1. Accede a: `http://TU-IP-SERVIDOR/admin`
2. Modifica el contenido desde el panel
3. Los cambios se reflejan automáticamente en la web

### Backup de base de datos

```bash
# Crear backup
pg_dump -U trinomio trinomio_cms > backup_$(date +%Y%m%d).sql

# Restaurar backup
psql -U trinomio trinomio_cms < backup_20240101.sql
```

## 🚨 Solución de Problemas

### La página no carga

1. Verifica que Nginx esté funcionando:
```bash
sudo systemctl status nginx
```

2. Verifica que Strapi esté funcionando:
```bash
pm2 status
```

### Error de conexión a la base de datos

1. Verifica que PostgreSQL esté activo:
```bash
sudo systemctl status postgresql
```

2. Prueba la conexión:
```bash
psql -U trinomio -d trinomio_cms -h localhost
```

### El contenido no se actualiza

1. Limpia el caché del navegador
2. Verifica los permisos de API en Strapi
3. Revisa la consola del navegador por errores

## 📞 Soporte

Si tienes problemas:
1. Revisa los logs: `pm2 logs`
2. Verifica la configuración de Nginx
3. Asegúrate de que los puertos 80 y 1337 estén abiertos

## 🎉 ¡Listo!

Tu sitio debería estar funcionando en:
- **Frontend**: `http://TU-IP-SERVIDOR`
- **Admin Panel**: `http://TU-IP-SERVIDOR/admin`
- **API**: `http://TU-IP-SERVIDOR/api`

Ahora puedes gestionar todo el contenido desde el panel de administración sin tocar código.