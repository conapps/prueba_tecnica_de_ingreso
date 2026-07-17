# Tu solución web (Docker)

Acá va **tu aplicación** de las Partes 1 y 2: código, `Dockerfile`, `docker-compose.yml`, etc.

## Cómo levantar la app

Desde esta carpeta, por ejemplo:

```bash
cd ~/prueba-tecnica/app
docker compose up -d --build
```

En `docker-compose.yml` podés usar `env_file: ../.env.prueba-tecnica` para las credenciales de Zabbix (`ZABBIX_*`).

Publicá un puerto y verificá que la página sea accesible desde el servidor de la prueba.
