> 🇪🇸 **Documentación en español.** El contenido técnico profundo procede de la
> documentación oficial del proyecto; la traducción íntegra está en progreso.
> Consulta la versión completa con `core show wget` (inglés).

## Información del Paquete

- **Nombre:** Wget
- **Tags:** download, http
- **Proyecto:** https://www.gnu.org/software/wget/
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Network downloader for retrieving files from the web

> ℹ️ La descripción técnica detallada de este proyecto está disponible en inglés:
> ```bash
> core show wget
> ```

## ¿Cómo usarlo?

```bash
core install wget        # instalar
core update wget         # actualizar
core uninstall wget      # eliminar
core search wget         # encontrarlo entre las herramientas
```

## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- Los métodos de instalación son específicos por plataforma; Core elige el correcto automáticamente.
- En Termux algunas herramientas ofrecen varios métodos de instalación (glibc nativo, glibc+proot, contenedor proot-distro); en Ubuntu/WSL se usan siempre métodos oficiales sin workarounds.
