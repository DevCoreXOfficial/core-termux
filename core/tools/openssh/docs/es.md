> 🇪🇸 **Documentación en español.** El contenido técnico profundo procede de la
> documentación oficial del proyecto; la traducción íntegra está en progreso.
> Consulta la versión completa con `core show openssh` (inglés).

## Información del Paquete

- **Nombre:** OpenSSH
- **Tags:** ssh, remote, scp
- **Proyecto:** https://www.openssh.com
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

SSH server and client for secure remote access

> ℹ️ La descripción técnica detallada de este proyecto está disponible en inglés:
> ```bash
> core show openssh
> ```

## ¿Cómo usarlo?

```bash
core install openssh        # instalar
core update openssh         # actualizar
core uninstall openssh      # eliminar
core search openssh         # encontrarlo entre las herramientas
```

## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- Los métodos de instalación son específicos por plataforma; Core elige el correcto automáticamente.
- En Termux algunas herramientas ofrecen varios métodos de instalación (glibc nativo, glibc+proot, contenedor proot-distro); en Ubuntu/WSL se usan siempre métodos oficiales sin workarounds.
