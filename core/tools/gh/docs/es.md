> 🇪🇸 **Documentación en español.** El contenido técnico profundo procede de la
> documentación oficial del proyecto; la traducción íntegra está en progreso.
> Consulta la versión completa con `core show gh` (inglés).

## Información del Paquete

- **Nombre:** GitHub CLI
- **Tags:** git, github, cli
- **Proyecto:** https://cli.github.com
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Official GitHub command-line tool for managing repositories, PRs, and issues

> ℹ️ La descripción técnica detallada de este proyecto está disponible en inglés:
> ```bash
> core show gh
> ```

## ¿Cómo usarlo?

```bash
core install gh        # instalar
core update gh         # actualizar
core uninstall gh      # eliminar
core search gh         # encontrarlo entre las herramientas
```

## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- Los métodos de instalación son específicos por plataforma; Core elige el correcto automáticamente.
- En Termux algunas herramientas ofrecen varios métodos de instalación (glibc nativo, glibc+proot, contenedor proot-distro); en Ubuntu/WSL se usan siempre métodos oficiales sin workarounds.
