# Claves SSH — usuario `demo` en la VM

## ¿Qué archivo le das al participante?

**Solo uno:**

| Archivo | ¿Entregar? |
|---------|------------|
| **`demo-access`** | **SÍ** — clave privada (adjunto) |
| `demo-access.pub` | **NO** — es la pública; ya está en el servidor |
| Cualquier otro archivo en esta carpeta | **NO** — son restos viejos; borrarlos |

## ¿Dónde la guarda el participante?

Donde quiera en **su** PC. Lo habitual:

```bash
mkdir -p ~/.ssh
mv demo-access ~/.ssh/demo-access
chmod 600 ~/.ssh/demo-access
ssh -i ~/.ssh/demo-access demo@demo1.conatel-lab.conatel.cloud
```

También puede dejarla en `~/Descargas/demo-access` y usar `ssh -i ~/Descargas/demo-access demo@...`.  
Lo importante: **`chmod 600`** y usar **`-i`** con la ruta donde la guardó.

## Evaluador

- Crear clave (solo la primera vez): `bash host-setup/scripts/deploy/ensure-demo-access-key.sh`
- Instalar en la VM (sube `demo-access.pub` a `demo`): `bash host-setup/install-on-demo-vm.sh demo1...`
- Qué adjuntar al participante: `bash host-setup/scripts/deploy/print-install-summary.sh demo1...`

Pasos SSH para el participante: [`docs/plantilla-entrega.md`](../../docs/plantilla-entrega.md) (no duplicar acá).
