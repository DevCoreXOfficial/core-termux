> 🇪🇸 **Documentación en español.** El contenido técnico profundo procede de la
> documentación oficial del proyecto; la traducción íntegra está en progreso.
> Consulta la versión completa con `core show proot` (inglés).

## Información del Paquete

- **Nombre:** proot
- **Tags:** container, chroot, termux
- **Proyecto:** https://proot-me.github.io
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Chroot alternative for user-space sandboxing

> ℹ️ La descripción técnica detallada de este proyecto está disponible en inglés:
> ```bash
> core show proot
> ```

## ¿Cómo usarlo?

```bash
core install proot        # instalar
core update proot         # actualizar
core uninstall proot      # eliminar
core search proot         # encontrarlo entre las herramientas
```

## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- Los métodos de instalación son específicos por plataforma; Core elige el correcto automáticamente.
- En Termux algunas herramientas ofrecen varios métodos de instalación (glibc nativo, glibc+proot, contenedor proot-distro); en Ubuntu/WSL se usan siempre métodos oficiales sin workarounds.
