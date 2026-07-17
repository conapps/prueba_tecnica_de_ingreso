# Prueba técnica de ingreso — DevOps (IA / Infraestructura)

**Objetivo:** Desarrollar una solución que consulte la **API de Zabbix**, muestre el estado operativo de un entorno de red monitoreado y, ante una falla simulada, permita **diagnosticar** y **remediar** el problema usando **Ansible**.

> **💡 Sobre el uso de IA**  
> Podés usar **tus propias** herramientas de IA (ChatGPT, Claude, Cursor, Copilot, Gemini, Antigravity u otras), de lo contrario te proporcionaremos una. Nos interesa ver **cómo las usás**, **cómo validás** lo que te proponen y **cómo comunicás** avances y bloqueos. No se evalúa memorizar endpoints ni comandos Cisco de memoria.

---

## Contexto

Tenemos un entorno pequeño monitoreado con **Zabbix**, compuesto por **3 hosts**:


| Host    | Rol         | Tipo      |
| ------- | ----------- | --------- |
| `Host1` | Router      | Cisco IOS |
| `Host2` | Switch core | Cisco IOS |
| `Host3` | Switch edge | Cisco IOS |


> **💡 Nota:** Los nombres te los entregamos en la plantilla de entrega.

**Diagrama del ambiente (referencia):**

```
      [ Zabbix ] ←→ [ VM Linux ] → [ Solución web ]
          |              |
      +---------------------+---------------------+
      |                                           |
  [Switch edge] ←→ [Router] ←→ [Switch core]
```

Tu tarea es construir una **página web simple** que consuma la API de Zabbix y muestre información operativa de **esos 3 hosts únicamente** (mismos nombres que en Zabbix). Las credenciales de la API están en el servidor (ver abajo).

---

## Qué te entregamos al iniciar

Al comenzar la prueba recibirás credenciales y datos de acceso (hosts, IPs, usuarios). 

Guardalos de forma segura y **no los compartas** ni los subas a repositorios públicos.

## Reglas generales

- **⚠️ Leé esto antes de empezar (Partes 1–3)**  
- Todo el trabajo de la prueba vive en `~/prueba-tecnica/`, por lo que tu app, playbooks y configs deben estar ahí.  
- El usuario Linux proporcionado **no tiene** `sudo`, ya que no hace falta, la consigna está pensada para que no necesites instalar software de sistema; usá lo ya disponible.
- La app se levanta con **Docker**, por lo que no podés usar otros contenedores o orquestadores.
- La remediación Cisco se hace con `lab-ansible`, por lo que no podés usar `ansible-playbook` a mano.
- Conectividad hacia Zabbix y los equipos Cisco.

### Servidor Linux

Datos del servidor:

- **Directorio de trabajo:** `~/prueba-tecnica/`
  ```bash
  ~/prueba-tecnica/
  ├── README.md               # mapa del directorio de trabajo
  ├── app/                    # tu solución web (Docker)
  ├── ansible/                # inventario + playbooks (Parte 3)
  │   ├── ansible.cfg
  │   ├── inventory/
  │   │   ├── group_vars/
  │   │   ├── host_vars/
  │   │   └── hosts.yml
  │   └── playbooks/
  │       └── participante/   # tus playbooks (.yml) (Parte 3)
  ├── scripts/                # lab-ansible, aliases — no modifiques estos archivos
  └── .env.prueba-tecnica     # variables ZABBIX_*
  ```
  - Creá y deja todo lo que necesites para la prueba **dentro de este directorio**.
- **Usuario sin sudo:** entras con el usuario proporcionado. No tenés privilegios de administrador. Lo que necesitás ya está instalado (Docker, Ansible, etc.).
- En el servidor tenés disponibles, entre otras cosas: 
  - **Ansible** y **Docker** preinstalados por comodidad (no hace falta instalarlos).
  - **Docker** — forma requerida de correr tu solución web (Docker / Docker Compose).
  - **Ansible** — automatización con permisos de cambio en equipos **solo** vía el wrapper `lab-ansible` (ver abajo).
  - **Inventario** — ya configurado en `~/prueba-tecnica/ansible/` (hosts, grupos). No lo armes desde cero: concentrate en los **playbooks**. Esos permisos de cambio se usan **solo desde Ansible**, no desde una sesión SSH manual en Cisco.
  - Conectividad hacia Zabbix y los equipos Cisco.

### Zabbix

Datos de Zabbix:

- Los 3 hosts ya están configurados en Zabbix con el rol correspondiente.
- La UI web de Zabbix no la vas a necesitar; algunos clientes o métodos de la API pueden pedir usuario y contraseña además del token.
- URL, usuario, contraseña y token de la API están en variables en el archivo `~/prueba-tecnica/.env.prueba-tecnica` en el servidor Linux.
  - `ZABBIX_URL`: URL de la API de Zabbix.
  - `ZABBIX_USER`: Usuario de la API de Zabbix.
  - `ZABBIX_PASSWORD`: Contraseña de la API de Zabbix.
  - `ZABBIX_TOKEN`: Token de la API de Zabbix.
  - Se cargan al abrir sesión SSH; también podés leer ese archivo desde tu aplicación (por ejemplo `env_file` en Docker).
  - **No** hardcodees esos valores en el código.

### Equipos Cisco

Datos de los equipos Cisco:

- Los 3 hosts ya están configurados con SSH y SNMP.

> **Regla:** El acceso SSH es **únicamente para diagnóstico**. 
> **No** debés aplicar cambios manuales por SSH en los equipos.

Se te proporcionan los siguientes alias de SSH para conectarte a los equipos:
- `ssh-rtr` para el router.
- `ssh-core` para el switch core.
- `ssh-edge` para el switch edge.

> No hacer `ssh ssh-rtr` sino usar el alias directamente.

---

## Parte 1 — Web con estado de los equipos

**Objetivo:** Crear una página web que muestre el **estado general** de los 3 equipos monitoreados, consultando la API de Zabbix.

### Pedido

La página debe mostrar, como mínimo:


| Campo                       | Descripción                                                   |
| --------------------------- | ------------------------------------------------------------- |
| **Nombre del equipo**       | Nombre del host en Zabbix                                     |
| **Estado / disponibilidad** | Disponible, No disponible o Desconocido (o equivalente claro) |
| **Indicador visual**        | Algo simple: color, badge o texto que distinga los estados    |


### Ejemplo de salida esperada


| Equipo      | Estado        |
| ----------- | ------------- |
| Router      | Disponible    |
| Switch core | Disponible    |
| Switch edge | No disponible |


### Condiciones

- La solución debe **correr en el servidor Linux** provisto, dentro del directorio `~/prueba-tecnica/app/`, con **Docker** (o Docker Compose) y **debe ser accesible por navegador** desde el servidor de la prueba (publicá un puerto del contenedor).
- **No** hace falta autenticación en la página web ni diseño visual avanzado.
- **No** hardcodees credenciales en el código: usá variables de entorno o archivos de config fuera del repositorio (por ejemplo `env_file` apuntando a `~/prueba-tecnica/.env.prueba-tecnica`).
- Consultá Zabbix **solo vía API** con las variables `ZABBIX_`* de `~/prueba-tecnica/.env.prueba-tecnica` (no hace falta entrar ni modificar Zabbix por la interfaz web).
- La solución debe mostrar los **3 hosts** de la prueba (nombres en la entrega al iniciar).
- Podés refrescar manualmente o automáticamente; no es obligatorio un frontend complejo.

---

## Parte 2 — Alertas y problemas activos

**Objetivo:** Extender la página para mostrar **problemas activos** de los equipos de la prueba.

> **💡 Nota:** Al llegar a esta parte puede haber **alertas ya presentes** en Zabbix (por ejemplo, un host que sigue operativo pero con un problema de monitoreo). Tu página debe **mostrarlas**.

### Pedido

**1. Tabla resumen** — Agregar a la salida de la Parte 1 la **cantidad de problemas activos** por equipo:


| Equipo      | Estado        | Problemas activos |
| ----------- | ------------- | ----------------- |
| Router      | Disponible    | 0                 |
| Switch core | Disponible    | 0                 |
| Switch edge | No disponible | 1                 |


**2. Detalle de alertas** — Nueva sección o tabla con los problemas activos. Como mínimo:


| Campo               | Descripción                               |
| ------------------- | ----------------------------------------- |
| Equipo afectado     | Host relacionado                          |
| Nombre de la alerta | Descripción del problema en Zabbix        |
| Severidad           | High, Average, Warning, etc.              |
| Desde               | Fecha/hora de inicio, si la API lo provee |
| Estado              | Estado actual del problema (si aplica)    |


### Ejemplo de detalle


| Equipo      | Alerta           | Severidad | Desde | Estado |
| ----------- | ---------------- | --------- | ----- | ------ |
| Switch edge | SNMP unavailable | High      | 10:32 | Activo |


### Condiciones

- Seguir usando la **API de Zabbix**.
- Mostrar **solo** problemas de los 3 hosts de la prueba.
- Actualización manual o automática: a tu criterio.

---

## Parte 3 — Ansible con diagnóstico y remediación

**Objetivo:** Ante un problema introducido en el entorno, **identificar la causa**, explicarla y **corregirla con Ansible**.

> **⚠️ No sabés de antemano qué falla se va a generar.** Solo sabés que habrá un incidente operativo que deberás investigar.

> 💡 Vamos a **simular una falla** en el entorno para que puedas validar que tu página la detecta (y así verificar si la Parte 2 fue exitosa); después debés seguir con el diagnóstico y la remediación.

### Activar el incidente (Parte 3)

Ejecutá en el servidor Linux:

```bash
disparar-incidente
```

- Solo podés ejecutarlo **una vez** durante tu prueba.
- La salida del comando es solo un mensaje de confirmación; **no** muestra detalles del cambio aplicado.
- Esperá unos minutos mientras que Zabbix detecte el problema y revisá tu solución.
- Tu solución debe mostrar el problema activo en la parte 2.
- Después investigá y remediá **por tu cuenta** con Ansible hasta considerar resuelto el incidente (ver **Qué esperamos que hagas vos**).

### Qué esperamos que hagas vos

1. **Detectar** el problema en tu solución.
2. **Identificar** el equipo afectado y la alerta relevante.
3. **Diagnosticar** el problema en el equipo(s) afectado(s) (ten en cuenta que el usuario proporcionado es de **solo lectura** ya que la idea es que no hagas cambios manuales por SSH en los equipos sino que uses Ansible para remediar el problema).
  - Como se te comentó anteriormente, en el servidor tenés aliases `ssh-rtr`, `ssh-core`, `ssh-edge` para conectarte a los equipos via SSH (solo lectura) para revisar y diagnosticar el problema.
4. **Explicar** la causa probable y la solución propuesta.
5. **Corregir** el problema con Ansible. Para ello, debes **escribir uno o varios playbooks Ansible** en `~/prueba-tecnica/ansible/playbooks/participante/` que corrijan el problema.
  - Se recomienda que el nombre del archivo sea descriptivo del problema y la solución.
  - Recuerda que el playbook debe apoyarse en el inventario provisto en `~/prueba-tecnica/ansible/inventory/hosts.yml` para remediar el problema.
6. **Ejecutar** la solución con `lab-ansible <nombre-del-archivo.yml>` (solo el nombre; el wrapper busca en esa carpeta y usa el inventario provisto).
7. **Validar** que el incidente quedó resuelto: alerta en recuperación o cerrada en tu solución, estado coherente en tu solución y, si aplica, contraste con diagnóstico por SSH.

#### Ejemplo de cómo correr Ansible (`lab-ansible`)

1. Escribí el playbook en:
  ```bash
   ~/prueba-tecnica/ansible/playbooks/participante/

   # Ejemplo: 
   ~/prueba-tecnica/ansible/playbooks/participante/solucionar-problema.yml
  ```
2. Ejecutalo pasando **solo el nombre del archivo** (no la ruta completa):
  ```bash
   lab-ansible solucionar-problema.yml
  ```
3. `lab-ansible` usa el inventario provisto y las credenciales de cambio. **No** uses `ansible-playbook` directo ni inventarios propios.

### Remediación con Ansible (detalle)


| Paso       | Qué esperamos                                                                                           |
| ---------- | ------------------------------------------------------------------------------------------------------- |
| Ubicación  | Playbook(s) en `~/prueba-tecnica/ansible/playbooks/participante/` (ej. `solucionar-problema.yml`).      |
| Inventario | `~/prueba-tecnica/ansible/inventory/hosts.yml` (ya provisto; credenciales de **cambio** las inyecta `lab-ansible`).        |
| Ejecución  | `lab-ansible solucionar-problema.yml` — **solo el nombre del archivo**, no la ruta completa ni `ansible-playbook`. |
| Validación | Confirmar en tu solución que la alerta bajó; no alcanza con “haberlo corrido” sin verificar.            |


> **💡 Tip:** Si el primer intento no alcanza, podés iterar el playbook y volver a ejecutar. Podes **documentar** qué cambiaste entre intentos.

### Condiciones

- Realizar cambios SSH manuales en Cisco **no** está permitido.
- Escribir, ejecutar y ajustar playbooks Ansible con el inventario provisto.

### Al finalizar la Parte 3

> **Avisá al evaluador cuando termines la Parte 3 (finalización de la prueba)** para que realice la verificación completa de la solución.
> **Mostrarle al evaluador cómo acceder a la página web** (URL, puerto y, si aplica, comando para levantarla).
> **Mostrarle al evaluador el/los playbook(s) Ansible** que escribiste y cómo los ejecutaste con `lab-ansible`.
> El evaluador **restaurará el entorno**, volverá a activar el incidente y revisará que la Parte 1 y 2 detecten el problema para validar que fueron exitosas.
> El evaluador **ejecutará el/los playbook(s) Ansible** que escribiste para validar que la Parte 3 remedió el problema y fue exitosa.

---

## Criterios que tendremos en cuenta (referencia)

No es una rúbrica numérica para vos, pero ayuda a saber qué valoramos:


| Área                        | Qué miramos                                                                                       |
| --------------------------- | ------------------------------------------------------------------------------------------------- |
| Uso de IA                   | Contexto claro, validación, iteración, explicación de lo hecho                                    |
| Desarrollo de la solución   | Integración con la API (token, consultas), 3 hosts, estado y problemas, solución accesible        |
| Linux / Docker / Ansible    | App en Docker bajo `~/prueba-tecnica/`, logs, playbook con `lab-ansible` sin cambios SSH manuales |
| Monitoreo / troubleshooting | Interpretar alertas, cruzar con SSH, remediar y verificar                                         |
| Comunicación                | Consultar el evaluador para cualquier duda o bloqueo                                              |




### No penalizamos por

- Diseño visual básico.
- No conocer los endpoints de la API de memoria.
- No recordar comandos Cisco exactos.
- Una solución Docker simple pero **funcional**.

---

## Checklist rápido

- [ ] Parte 1: página con estado de 3 equipos vía API.
- [ ] Opcional: avisar al evaluador cuando termine la Parte 1.
- [ ] Parte 2: conteo y detalle de problemas activos.
- [ ] Opcional: avisar al evaluador cuando termine la Parte 2.
- [ ] Parte 3: diagnóstico + playbook en `ansible/playbooks/participante/` + `lab-ansible` + verificación.
- [ ] Avisar al evaluador cuando termine la Parte 3 (finalización de la prueba) para que realice la verificación completa de la solución.

---

**Duración orientativa:** la prueba está pensada en **3 partes** que podés encadenar **a tu ritmo**.
**Avisá al evaluador solo al terminar la Parte 3**, salvo que quieras consultarlo antes o te trabés más de unos minutos sin avanzar.

¡Éxitos!