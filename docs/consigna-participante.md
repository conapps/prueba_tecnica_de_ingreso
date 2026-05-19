# Prueba técnica — DevOps Jr. (IA / Infraestructura)

**Objetivo:** Desarrollar una solución que consulte la **API de Zabbix**, muestre el estado operativo de un entorno de red monitoreado y, ante una falla simulada, permita **diagnosticar** y **remediar** el problema usando **Ansible**.

> **💡 Sobre el uso de IA**  
> Podés usar herramientas de IA (ChatGPT, Claude, Cursor, Copilot, Gemini, Antigravity u otras). Nos interesa ver **cómo las usás**, **cómo validás** lo que te proponen y **cómo comunicás** avances y bloqueos. No se evalúa memorizar endpoints ni comandos Cisco de memoria.

---

## Contexto

Tenemos un entorno pequeño monitoreado con **Zabbix**, compuesto por:

| Equipo | Tipo | Notas |
| --- | --- | --- |
| **Router** | Cisco IOS (real) | Monitoreado por SNMP; interfaces descubiertas |
| **Switch** | Cisco IOS (real) | Monitoreado por SNMP; interfaces descubiertas |
| **Equipo ficticio** | Simulado | Tiene al menos una **alerta SNMP activa** de referencia |

Tu tarea es construir una **página web simple** que consuma la API de Zabbix con el **token** que te entregamos y muestre información operativa de **esos 3 equipos únicamente**.

> **⚠️ Importante**  
> Tu usuario de Zabbix solo puede ver los hosts de la prueba. La página **no debe** mostrar información de otros equipos del ambiente.

---

## Qué te entregamos al iniciar

Al comenzar la prueba recibirás credenciales y datos de acceso. Guardalos de forma segura y **no los compartas** ni los subas a repositorios públicos.

### Servidor Linux (donde corrés la solución)

| Dato | Descripción |
| --- | --- |
| IP o DNS | Dirección para conectarte por SSH |
| Usuario / clave o contraseña | Acceso al servidor de la prueba |
| Puerto SSH | Si no es el estándar (22) |

En el servidor tenés disponibles, entre otras cosas: **Docker**, **Ansible** y conectividad hacia Zabbix y los equipos Cisco.

### Zabbix (solo lectura sobre los hosts de la prueba)

| Dato | Descripción |
| --- | --- |
| URL | Frontend / endpoint API (`…/api_jsonrpc.php`) |
| Usuario | Usuario exclusivo de la prueba |
| API token | Autenticación para consultas (`host.get`, `problem.get`, etc.) |

> **💡 Tip**  
> Antes de armar la web, podés validar el token con una consulta simple (`curl`, script en Python, etc.). El método `apiinfo.version` no requiere autenticación; para hosts y problemas sí necesitás el token en el campo `auth`.

### Equipos Cisco — SSH de **solo lectura** (diagnóstico)

| Dato | Router | Switch |
| --- | --- | --- |
| IP | *(te la indicamos)* | *(te la indicamos)* |
| Usuario / contraseña | Solo lectura | Solo lectura |

**Regla:** este acceso es **únicamente para diagnóstico** (`show …`, revisar interfaces, rutas, etc.). **No** debés aplicar cambios manuales por SSH en los equipos.

### Ansible — automatización con permisos de cambio

Te entregamos inventario y/o variables para que **Ansible** se conecte a los equipos Cisco con permisos para **remediar** (por ejemplo, levantar una interfaz). Esos permisos se usan **solo desde Ansible**, no desde una sesión SSH manual.

---

## Reglas generales

- La solución debe **correr en el servidor Linux** provisto (directo en el host o en contenedor).
- Debe ser **accesible por navegador** (indicá URL y puerto al finalizar cada parte).
- **No** hace falta autenticación en la página web ni diseño visual avanzado.
- **No** hardcodees credenciales en el código: usá variables de entorno o archivos de config fuera del repositorio.
- Consultá Zabbix **solo vía API** con el token entregado (no hace falta modificar Zabbix).
- Filtrá o mostrá **únicamente** los 3 hosts de la prueba.
- Ante la Parte 3: **diagnóstico** por SSH lectura; **corrección** solo con **Ansible**.

**Stack libre:** Python, Node.js, PHP, contenedor con Nginx/Caddy, etc. Elegí lo que te resulte más cómodo.

---

## Parte 1 — Estado de los equipos

**Objetivo:** Crear una página web que muestre el **estado general** de los 3 equipos monitoreados, consultando la API de Zabbix.

### Pedido

La página debe mostrar, como mínimo:

| Campo | Descripción |
| --- | --- |
| **Nombre del equipo** | Nombre visible en Zabbix |
| **Estado / disponibilidad** | Disponible, No disponible o Desconocido (o equivalente claro) |
| **Indicador visual** | Algo simple: color, badge o texto que distinga los estados |

### Ejemplo de salida esperada

| Equipo | Estado |
| --- | --- |
| Router CML | Disponible |
| Switch CML | Disponible |
| Equipo ficticio | No disponible |

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

| Equipo | Estado | Problemas activos |
| --- | --- | --- |
| Router CML | Disponible | 0 |
| Switch CML | Disponible | 0 |
| Equipo ficticio | No disponible | 1 |

**2. Detalle de alertas** — Nueva sección o tabla con los problemas activos. Como mínimo:

| Campo | Descripción |
| --- | --- |
| Equipo afectado | Host relacionado |
| Nombre de la alerta | Descripción del problema en Zabbix |
| Severidad | High, Average, Warning, etc. |
| Desde | Fecha/hora de inicio, si la API lo provee |
| Estado | Estado actual del problema (si aplica) |

### Ejemplo de detalle

| Equipo | Alerta | Severidad | Desde |
| --- | --- | --- | --- |
| Equipo ficticio | SNMP unavailable | High | 10:32 |
| Router CML | Interface down | Average | 10:45 |

### Condiciones

- Seguir usando la **API de Zabbix** (p. ej. `problem.get`, `event.get` o métodos equivalentes según versión).
- Mostrar **solo** problemas de los 3 hosts de la prueba.
- Actualización manual o automática: a tu criterio.

### Referencia API (orientativa)

> **📚 Documentación:** [Zabbix API Reference](https://www.zabbix.com/documentation/current/es/manual/api/reference)  
> Métodos útiles: `host.get`, `problem.get`, `trigger.get` (con filtros por host).

### Al finalizar la Parte 2

> **Avisanos cuando termines.** Después vamos a **simular una falla** en el entorno para validar que tu página la detecta.

---

## Parte 3 — Falla simulada, diagnóstico y remediación

**Objetivo:** Ante un problema real introducido en el entorno, **identificar la causa**, explicarla y **corregirla con Ansible**.

> **⚠️ No sabés de antemano qué falla vamos a generar.** Solo sabés que habrá un incidente operativo que deberás investigar.

### Qué haremos nosotros

El evaluador generará una **falla controlada** (por ejemplo: interfaz apagada, ruta eliminada o corte entre router y switch). La falla tiene **procedimiento de rollback** por nuestro lado.

### Qué esperamos que hagas vos

1. **Detectar** el problema en tu página y/o en Zabbix (API o frontend, si te sirve para contrastar).
2. **Identificar** el equipo afectado y la alerta relevante.
3. **Conectarte por SSH** al router o switch con el usuario de **solo lectura** y revisar estado (interfaces, rutas, vecinos, etc.).
4. **Explicar** la causa probable y la solución propuesta (podés usar IA y documentación; validá antes de ejecutar).
5. **Aplicar la corrección mediante Ansible** desde el servidor Linux (playbook o rol que te indiquemos dónde ubicar).
6. **Confirmar** que el problema se resolvió (alerta en recuperación o desaparecida; equipo estable en tu página).

### Reglas de la Parte 3

| Permitido | No permitido |
| --- | --- |
| SSH **solo lectura** para diagnóstico | Cambios manuales en Cisco por SSH (`shutdown`, `no shutdown`, etc.) |
| Consultar Zabbix (API / UI) | Modificar configuración de Zabbix sin necesidad |
| Crear/ejecutar playbook Ansible de remediación | Copiar comandos sin entender su impacto |
| Pedir confirmación antes de cambios con impacto | Exponer tokens o credenciales en logs/commits |

### Entregables de la Parte 3

- **Explicación verbal o escrita breve:** qué pasó, qué revisaste, por qué esa causa, qué hizo tu playbook.
- **Playbook Ansible** (o comando `ansible-playbook` documentado) usado para la remediación.
- **Evidencia de recuperación:** captura o descripción de la alerta/página después del fix.

### Al finalizar la Parte 3

> Contanos el **resumen del incidente** y mostranos que la alerta **bajó o se recuperó** en Zabbix y en tu página.

---

## Criterios que tendremos en cuenta (referencia)

No es una rúbrica numérica para vos, pero ayuda a saber qué valoramos:

| Área | Qué miramos |
| --- | --- |
| Uso de IA | Contexto claro, validación, iteración, explicación de lo hecho |
| Página / API | Token correcto, 3 hosts, estado y problemas, solución accesible |
| Linux / Docker / Ansible | Levantar la app, logs, playbook funcional sin cambios SSH manuales |
| Monitoreo / troubleshooting | Interpretar alertas, cruzar con SSH, remediar y verificar |
| Comunicación | Avisar al terminar cada parte, bloqueos y preguntas a tiempo |

### No penalizamos fuerte por

- Diseño visual básico.
- No conocer todos los endpoints de memoria.
- No recordar comandos Cisco exactos.
- Elegir un stack simple pero **funcional**.

---

## Checklist rápido

- [ ] Parte 1: página con estado de 3 equipos vía API.
- [ ] Avisé cómo acceder a la página.
- [ ] Parte 2: conteo y detalle de problemas activos.
- [ ] Avisé que terminé la Parte 2.
- [ ] Parte 3: diagnóstico (SSH lectura) + explicación + Ansible + verificación.

---

**Duración orientativa:** la prueba está pensada en **3 bloques** con pausas de revisión entre ellos. Si te trabás más de unos minutos sin avanzar, **avisá** — es parte de la evaluación.

¡Éxitos!
