> 🇪🇸 **Documentación en español.** El contenido técnico profundo procede de la
> documentación oficial del proyecto; la traducción íntegra está en progreso.
> Consulta la versión completa con `core show udocker` (inglés).

## Información del Paquete

- **Nombre:** udocker
- **Tags:** containers, docker, rootless
- **Proyecto:** https://indigo-dc.github.io/udocker/
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Run Docker containers without root privileges

> ℹ️ La descripción técnica detallada de este proyecto está disponible en inglés:
> ```bash
> core show udocker
> ```

## ¿Cómo usarlo?

```bash
core install udocker        # instalar
core update udocker         # actualizar
core uninstall udocker      # eliminar
core search udocker         # encontrarlo entre las herramientas
```

## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- Los métodos de instalación son específicos por plataforma; Core elige el correcto automáticamente.
- En Termux algunas herramientas ofrecen varios métodos de instalación (glibc nativo, glibc+proot, contenedor proot-distro); en Ubuntu/WSL se usan siempre métodos oficiales sin workarounds.
