# Plantilla de entrega — Prueba técnica DevOps (formato)

Plantilla **vacía** para reutilizar. Para cada prueba:

1. Copiar este archivo a `plantilla-entrega.md`.
2. Completar todos los campos.
3. Enviar al participante: consigna + plantilla + archivo **`demo-access`**.

---

## Servidor Linux


| Campo              | Valor |
| ------------------ | ----- |
| Host               |       |
| Usuario            |       |
| Clave / acceso SSH |       |
| Puerto SSH         |       |
| Notas              |       |

### Cómo conectarte

Te proporcionamos un archivo adjunto: `demo-access` (clave privada).

1. Guardalo en tu PC, por ejemplo:

```bash
mkdir -p ~/.ssh
mv demo-access ~/.ssh/demo-access
chmod 600 ~/.ssh/demo-access
```

(Podés usar otra carpeta; lo importante es `chmod 600` y la ruta en el comando `ssh -i`.)

2. Conectate con usuario **`...`** (usuario Linux del participante):

```bash
ssh -i ~/.ssh/demo-access ...@<host>
whoami   # → ...
```

3. Usuario proporcionado **sin `sudo`**.

---

## Zabbix


| Campo                             | Valor |
| --------------------------------- | ----- |
| URL                               |       |
| Usuario                           |       |
| Contraseña                        |       |
| API Token (entregar al participante) |       |

> **💡 Nota:** Las credenciales de Zabbix estan en el servidor Linux en el archivo `~/prueba-tecnica/.env.prueba-tecnica` y se cargan al abrir sesión SSH; usalas en tu app sin hardcodear.
> Puedes usar las variables `ZABBIX_URL`, `ZABBIX_USER`, `ZABBIX_PASSWORD`, `ZABBIX_TOKEN` en tu app sin hardcodear.

---

## Equipos Cisco


| Host Zabbix | Rol         | IP  | Usuario SSH | Contraseña SSH | SNMPv2 |
| ----------- | ----------- | --- | ----------- | -------------- | ------ |
|             | Router      |     |             |                |        |
|             | Switch core |     |             |                |        |
|             | Switch edge |     |             |                |        |
