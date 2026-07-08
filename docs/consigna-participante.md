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

### Servidor Linux

Datos del servidor:

- **Directorio de trabajo:** `~/prueba-tecnica/` — inventario Ansible, variables Zabbix, playbooks y tu aplicación. Creá ahí todo lo que necesites para la prueba.
- En el servidor tenés disponibles, entre otras cosas: **Ansible** y herramientas comunes (incluido **Docker** preinstalado por comodidad).
  - **Ansible** — automatización con permisos de cambio (vía `lab-ansible`).
  - **Inventario** — ya configurado (hosts, grupos y credenciales de acceso) para que **Ansible** se conecte a los equipos Cisco reales con permisos para **remediar**. No tenés que armar el inventario desde cero: usalo tal como viene y concentrate el esfuerzo en los **playbooks**. Esos permisos de cambio se usan **solo desde Ansible**, no desde una sesión SSH manual en Cisco.
  - **Cómo levantar tu app** — **stack libre**: podés usar Docker, Podman, Kubernetes, un proceso en el host, etc.
  - Docker viene instalado para ahorrar tiempo.
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

---

## Reglas generales

- La solución debe **correr en el servidor Linux** provisto (proceso directo, contenedor, orquestador, etc.).
- Desplegá tu solución y archivos propios dentro de **`~/prueba-tecnica/`** (salvo lo ya provisto).
- Debe ser **accesible por navegador** desde el servidor de la prueba.
- **No** hace falta autenticación en la página web ni diseño visual avanzado.
- **No** hardcodees credenciales en el código: usá variables de entorno o archivos de config fuera del repositorio.
- Consultá Zabbix **solo vía API** con las variables `ZABBIX_`* de `~/prueba-tecnica/.env.prueba-tecnica` (no hace falta entrar ni modificar Zabbix por la interfaz web).
- La solución debe mostrar los **3 hosts** de la prueba (nombres en la entrega al iniciar).
- Ante la Parte 3: **diagnóstico** por SSH lectura; **corrección** solo con **Ansible**.

**Stack libre:** elegí la tecnología que te resulte más cómoda.

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

- Consumir la API con las variables `ZABBIX_`* de `~/prueba-tecnica/.env.prueba-tecnica`.
- La app debe estar **corriendo y accesible** desde el servidor de la prueba.
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


| Equipo      | Alerta           | Severidad | Desde |
| ----------- | ---------------- | --------- | ----- |
| Switch edge | SNMP unavailable | High      | 10:32 |


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

- **No** requiere `sudo` (el sistema eleva permisos por detrás).
- Solo podés ejecutarlo **una vez** durante tu prueba.
- La salida del comando es solo un mensaje de confirmación; **no** muestra detalles del cambio aplicado.
- Esperá unos minutos a que Zabbix refleje el problema y revisá tu solución.

Después investigá y remediá **por tu cuenta** con Ansible hasta considerar resuelto el incidente.

### Qué esperamos que hagas vos

1. **Detectar** el problema en tu solución.
2. **Identificar** el equipo afectado y la alerta relevante.
3. **Podés conectarte por SSH** al equipo o equipos afectados (usuario de solo lectura de la plantilla; en el servidor tenés aliases `ssh-rtr`, `ssh-core`, `ssh-edge`) y revisar el estado.
4. **Explicar** la causa probable y la solución propuesta (podés usar IA y documentación; validá antes de ejecutar).
5. **Escribir uno o varios playbooks Ansible** en `~/prueba-tecnica/ansible/playbooks/participante/` que corrijan el problema.
6. **Ejecutarlos** con `lab-ansible <tu-playbook.yml>` (usa el inventario provisto).
7. **Validar** que el incidente quedó resuelto: alerta en recuperación o cerrada en tu solución, estado coherente en tu solución y, si aplica, contraste con diagnóstico por SSH de solo lectura.

### Remediación con Ansible (detalle)


| Paso        | Qué esperamos                                                                                |
| ----------- | -------------------------------------------------------------------------------------------- |
| Inventario  | `~/prueba-tecnica/ansible/` (credenciales de **cambio** ya cargadas).                        |
| Playbook(s) | Código tuyo en `playbooks/participante/`: tareas idempotentes que apliquen la corrección.    |
| Ejecución   | `lab-ansible <playbook.yml>` desde el servidor Linux (inventario provisto).                  |
| Validación  | Confirmar en tu solución que la alerta bajó; no alcanza con “haberlo corrido” sin verificar. |


> **💡 Tip:** Si el primer intento no alcanza, podés iterar el playbook y volver a ejecutar. 
> Documentá qué cambiaste entre intentos.

### Condiciones

- Realizar cambios SSH manuales en Cisco **no** está permitido.
- Escribir, ejecutar y ajustar playbooks Ansible con el inventario provisto.

### Al finalizar la Parte 3

> **Avisá al evaluador cuando termines la Parte 3 (finalización de la prueba)**.
> **Mostrarle al evaluador cómo acceder a la página web** (URL, puerto y, si aplica, comando para levantarla).
> **Mostrarle al evaluador el/los playbook(s) Ansible** que escribiste y cómo los ejecutaste con `lab-ansible`.
> El evaluador **restaurará el entorno**, volverá a activar el incidente y revisará que la Parte 1 y 2 detecten el problema para validar que fueron exitosas.
> El evaluador **ejecutará el/los playbook(s) Ansible** que escribiste para validar que la Parte 3 remedió el problema y fue exitosa.

---

## Criterios que tendremos en cuenta (referencia)

No es una rúbrica numérica para vos, pero ayuda a saber qué valoramos:


| Área                        | Qué miramos                                                                                |
| --------------------------- | ------------------------------------------------------------------------------------------ |
| Uso de IA                   | Contexto claro, validación, iteración, explicación de lo hecho                             |
| Desarrollo de la solución   | Integración con la API (token, consultas), 3 hosts, estado y problemas, solución accesible |
| Linux / Docker / Ansible    | Levantar la app, logs, playbook funcional sin cambios SSH manuales                         |
| Monitoreo / troubleshooting | Interpretar alertas, cruzar con SSH, remediar y verificar                                  |
| Comunicación                | Consultar el evaluador para cualquier duda o bloqueo                                       |


### No penalizamos por

- Diseño visual básico.
- No conocer los endpoints de la API de memoria.
- No recordar comandos Cisco exactos.
- Elegir un stack simple pero **funcional**.

---

## Checklist rápido

- [ ] Parte 1: página con estado de 3 equipos vía API.
- [ ] Opcional: avisar al evaluador cuando termine la Parte 1.
- [ ] Parte 2: conteo y detalle de problemas activos.
- [ ] Opcional: avisar al evaluador cuando termine la Parte 2.
- [ ] Parte 3: diagnóstico + explicación + Ansible + verificación.
- [ ] Avisar al evaluador cuando termine la Parte 3 (finalización de la prueba) para que realice la verificación completa de la solución.

---

**Duración orientativa:** la prueba está pensada en **3 partes** que podés encadenar **a tu ritmo**.
**Avisá al evaluador solo al terminar la Parte 3**, salvo que quieras consultarlo antes o te trabés más de unos minutos sin avanzar.

¡Éxitos!