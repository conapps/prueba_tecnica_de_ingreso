# Prueba técnica de ingreso — DevOps (IA / Infraestructura)

**Objetivo:** Desarrollar una solución que consulte la **API de Zabbix**, muestre el estado operativo de un entorno de red monitoreado y, ante una falla simulada, permita **diagnosticar** y **remediar** el problema usando **Ansible**.

> **💡 Sobre el uso de IA**  
> Podés usar **tus propias** herramientas de IA (ChatGPT, Claude, Cursor, Copilot, Gemini, Antigravity u otras), de lo contrario te proporcionaremos una. Nos interesa ver **cómo las usás**, **cómo validás** lo que te proponen y **cómo comunicás** avances y bloqueos. No se evalúa memorizar endpoints ni comandos Cisco de memoria.

---

## Contexto

Tenemos un entorno pequeño monitoreado con **Zabbix**, compuesto por **3 hosts** con nombres fijos:

| Host name en Zabbix | Rol | Tipo |
| --- | --- | --- | --- |
| `**RTR-Prod-Gateway1`** | Router | Cisco IOS |
| `**SW-Prod-Core1**` | Switch core | Cisco IOS |
| `**SW-Prod-Edge1**` | Switch edge | Cisco IOS |

**Diagrama del ambiente:**

```
                            [ Zabbix ] ←→ [ VM Linux ] → [ Solución web ]
                                |              |
                            +---------------------+---------------------+
                            |                                           |
                        [SW-Prod-Edge1] ←→ [RTR-Prod-Gateway1] ←→ [SW-Prod-Core1]
```

Tu tarea es construir una **página web simple** que consuma la API de Zabbix con el **token** que te entregamos y muestre información operativa de `**RTR-Prod-Gateway1`**, `**SW-Prod-Core1**` y `**SW-Prod-Edge1**` únicamente.

---

## Qué te entregamos al iniciar

Al comenzar la prueba recibirás credenciales y datos de acceso. Guardalos de forma segura y **no los compartas** ni los subas a repositorios públicos.

### Servidor Linux


| Dato       | Descripción                       |
| ---------- | --------------------------------- |
| IP o DNS   | Dirección para conectarte por SSH |
| Usuario    | Acceso al servidor de la prueba   |
| Clave      | Acceso al servidor de la prueba   |
| Puerto SSH | Puesto por defecto (22)           |


> Datos del servidor Linux:
>
> - En el servidor tenés disponibles, entre otras cosas: **Docker**, **Ansible** y conectividad hacia Zabbix y los equipos Cisco.
> - **Ansible** — automatización con permisos de cambio
> - **Inventario** — ya configurado (hosts, grupos y credenciales de acceso) para que **Ansible** se conecte a los equipos Cisco reales con permisos para **remediar**. No tenés que armar el inventario desde cero en la prueba: usalo tal como viene y concentrate el esfuerzo en los **playbooks**. Esos permisos de cambio se usan **solo desde Ansible**, no desde una sesión SSH manual.

### Zabbix


| URL                                          | Usuario | Contraseña   | API Token                   |
| -------------------------------------------- | ------- | ------------ | --------------------------- |
| `https://zabbixX.conatel-lab.conatel.cloud` | `demo`  | `Zabbix123!` | Te lo entregamos al iniciar |


### Equipos Cisco

| Host Zabbix | IP | Usuario SSH | Contraseña SSH | SNMPv2 |
| --- | --- | --- | --- | --- |
| `RTR-Prod-Gateway1` | `10.0.10.10` | `demo` | `Demo123!` | `snmp-demo` |
| `SW-Prod-Core1` | `10.0.10.11` | `demo` | `Demo123!` | `snmp-demo` |
| `SW-Prod-Edge1` | `10.0.10.12` | `demo` | `Demo123!` | `snmp-demo` |

**Regla:** El acceso SSH es **únicamente para diagnóstico**. **No** debés aplicar cambios manuales por SSH en los equipos.

---

## Reglas generales

- La solución debe **correr en el servidor Linux** provisto (directo en el host o en contenedor).
- Debe ser **accesible por navegador** (indicá URL y puerto al finalizar cada parte).
- **No** hace falta autenticación en la página web ni diseño visual avanzado.
- **No** hardcodees credenciales en el código: usá variables de entorno o archivos de config fuera del repositorio.
- Consultá Zabbix **solo vía API** con el **token** entregado (no hace falta entrar ni modificar Zabbix por la interfaz web).
- La solución debe mostrar: `RTR-Prod-Gateway1`, `SW-Prod-Core1` y `SW-Prod-Edge1`.
- Ante la Parte 3: **diagnóstico** por SSH lectura; **corrección** solo con **Ansible**.

**Stack libre:** elegí la tecnología que te resulte más cómoda.

---

## Parte 1 — Estado de los equipos

**Objetivo:** Crear una página web que muestre el **estado general** de los 3 equipos monitoreados, consultando la API de Zabbix.

### Pedido

La página debe mostrar, como mínimo:


| Campo                       | Descripción                                                   |
| --------------------------- | ------------------------------------------------------------- |
| **Nombre del equipo**       | Nombre del host en Zabbix                                     |
| **Estado / disponibilidad** | Disponible, No disponible o Desconocido (o equivalente claro) |
| **Indicador visual**        | Algo simple: color, badge o texto que distinga los estados    |


### Ejemplo de salida esperada


| Equipo            | Estado        |
| ----------------- | ------------- |
| RTR-Prod-Gateway1 | Disponible    |
| SW-Prod-Core1     | Disponible    |
| SW-Prod-Edge1     | No disponible |


### Condiciones

- Consumir la API con el **token** provisto.
- La app debe estar **corriendo y accesible** desde el servidor de la prueba.
- Podés refrescar manualmente o automáticamente; no es obligatorio un frontend complejo.

### Al finalizar la Parte 1

> **Avisanos cuando termines** y mostranos **cómo acceder a la página** (URL, puerto y, si aplica, comando para levantarla).

---

## Parte 2 — Alertas y problemas activos

**Objetivo:** Extender la página para mostrar **problemas activos** de los equipos de la prueba.

### Pedido

**1. Tabla resumen** — Agregar a la salida de la Parte 1 la **cantidad de problemas activos** por equipo:


| Equipo            | Estado        | Problemas activos |
| ----------------- | ------------- | ----------------- |
| RTR-Prod-Gateway1 | Disponible    | 0                 |
| SW-Prod-Core1     | Disponible    | 0                 |
| SW-Prod-Edge1     | No disponible | 1                 |


**2. Detalle de alertas** — Nueva sección o tabla con los problemas activos. Como mínimo:


| Campo               | Descripción                               |
| ------------------- | ----------------------------------------- |
| Equipo afectado     | Host relacionado                          |
| Nombre de la alerta | Descripción del problema en Zabbix        |
| Severidad           | High, Average, Warning, etc.              |
| Desde               | Fecha/hora de inicio, si la API lo provee |
| Estado              | Estado actual del problema (si aplica)    |


### Ejemplo de detalle


| Equipo            | Alerta           | Severidad | Desde |
| ----------------- | ---------------- | --------- | ----- |
| SW-Prod-Edge1     | SNMP unavailable | High      | 10:32 |
| RTR-Prod-Gateway1 | Interface down   | Average   | 10:45 |


### Condiciones

- Seguir usando la **API de Zabbix**.
- Mostrar **solo** problemas de los 3 hosts de la prueba.
- Actualización manual o automática: a tu criterio.

### Al finalizar la Parte 2

> **Avisanos cuando termines.** Vamos a **simular una falla** en el entorno para validar que tu página la detecta.

---

## Parte 3 — Falla simulada, diagnóstico y remediación

**Objetivo:** Ante un problema real introducido en el entorno, **identificar la causa**, explicarla y **corregirla con Ansible**.

> **⚠️ No sabés de antemano qué falla vamos a generar.** Solo sabés que habrá un incidente operativo que deberás investigar.

El evaluador generará una **falla controlada** la cual podrás ver en tu solución (si la Parte 2 fue exitosa).

### Qué esperamos que hagas vos

1. **Detectar** el problema en tu solución.
2. **Identificar** el equipo afectado y la alerta relevante.
3. Puedes conectarte por SSH al equipo o equipos afectados (con usuario de solo lectura) y revisar el estado del equipo afectado.
4. **Explicar** la causa probable y la solución propuesta (podés usar IA y documentación; validá antes de ejecutar).
5. **Escribir uno o varios playbooks Ansible** que corrijan el problema.
6. **Ejecutarlos** desde el servidor Linux con el **inventario provisto**.
7. **Validar** que el incidente quedó resuelto: alerta en recuperación o cerrada en tu solución, estado coherente en tu solución y, si aplica, contraste con diagnóstico por SSH de solo lectura.

### Remediación con Ansible (detalle)


| Paso        | Qué esperamos                                                                                |
| ----------- | -------------------------------------------------------------------------------------------- |
| Inventario  | Usar el que te entregamos (credenciales de **cambio** ya cargadas).                          |
| Playbook(s) | Código tuyo: tareas idempotentes que apliquen la corrección al equipo afectado.              |
| Ejecución   | Ejecutar los playbooks con Ansible y revisar salida / errores.                               |
| Validación  | Confirmar en tu solución que la alerta bajó; no alcanza con “haberlo corrido” sin verificar. |


> **💡 Tip**  
> Si el primer intento no alcanza, podés iterar el playbook y volver a ejecutar. Documentá qué cambiaste entre intentos.

### Reglas de la Parte 3


| Permitido                                                                 | No permitido                                        |
| ------------------------------------------------------------------------- | --------------------------------------------------- |
| SSH **solo lectura** para diagnóstico                                     | Cambios manuales en Cisco por SSH                   |
| Consultar Zabbix (API / UI)                                               | Modificar configuración de Zabbix sin necesidad     |
| Escribir, ejecutar y ajustar playbooks Ansible con el inventario provisto | Copiar playbooks o comandos sin entender su impacto |
| Pedir confirmación antes de cambios con impacto                           | Exponer tokens o credenciales en logs/commits       |


### Entregables de la Parte 3

- **Explicación verbal o escrita breve:** qué pasó, qué revisaste, por qué esa causa y qué hace cada playbook relevante.
- **Playbook(s) Ansible** que escribiste y cómo los ejecutaste con el inventario provisto.
- **Evidencia de recuperación:** captura o descripción de la alerta/página **después** de ejecutar el playbook y validar que el problema se resolvió.

### Al finalizar la Parte 3

> Contanos el **resumen del incidente** y mostranos que la alerta **bajó o se recuperó** en tu solución.

---

## Criterios que tendremos en cuenta (referencia)

No es una rúbrica numérica para vos, pero ayuda a saber qué valoramos:


| Área                        | Qué miramos                                                                                |
| --------------------------- | ------------------------------------------------------------------------------------------ |
| Uso de IA                   | Contexto claro, validación, iteración, explicación de lo hecho                             |
| Desarrollo de la solución   | Integración con la API (token, consultas), 3 hosts, estado y problemas, solución accesible |
| Linux / Docker / Ansible    | Levantar la app, logs, playbook funcional sin cambios SSH manuales                         |
| Monitoreo / troubleshooting | Interpretar alertas, cruzar con SSH, remediar y verificar                                  |
| Comunicación                | Avisar al terminar cada parte, bloqueos y preguntas a tiempo                               |


### No penalizamos por

- Diseño visual básico.
- No conocer los endpoints de la API de memoria.
- No recordar comandos Cisco exactos.
- Elegir un stack simple pero **funcional**.

---

## Checklist rápido

- [ ] Parte 1: página con estado de 3 equipos vía API.
- [ ] Avisar cuando termine la Parte 1.
- [ ] Parte 2: conteo y detalle de problemas activos.
- [ ] Avisar cuando termine la Parte 2.
- [ ] Parte 3: diagnóstico + explicación + Ansible + verificación.
- [ ] Avisar cuando termine la Parte 3.

---

**Duración orientativa:** la prueba está pensada en **3 bloques** con pausas de revisión entre ellos. Si te trabás más de unos minutos sin avanzar, **avisá** — es parte de la evaluación.

¡Éxitos!