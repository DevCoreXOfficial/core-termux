> 🇪🇸 **Documentación en español.** El contenido técnico profundo procede de la
> documentación oficial del proyecto; la traducción íntegra está en progreso.
> Consulta la versión completa con `core show ncu` (inglés).

## Información del Paquete

- **Nombre:** npm-check-updates
- **Tags:** updates, npm, dependencies
- **Proyecto:** https://github.com/raineorshine/npm-check-updates
- **Dependencias:** nodejs

## ¿Qué es?

Find and update outdated npm dependencies

> ℹ️ La descripción técnica detallada de este proyecto está disponible en inglés:
> ```bash
> core show ncu
> ```

## ¿Cómo usarlo?

```bash
core install ncu        # instalar
core update ncu         # actualizar
core uninstall ncu      # eliminar
core search ncu         # encontrarlo entre las herramientas
```

## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- Los métodos de instalación son específicos por plataforma; Core elige el correcto automáticamente.
- En Termux algunas herramientas ofrecen varios métodos de instalación (glibc nativo, glibc+proot, contenedor proot-distro); en Ubuntu/WSL se usan siempre métodos oficiales sin workarounds.
