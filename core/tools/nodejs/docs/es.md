> 🇪🇸 **Documentación en español.** El contenido técnico profundo procede de la
> documentación oficial del proyecto; la traducción íntegra está en progreso.
> Consulta la versión completa con `core show nodejs` (inglés).

## Información del Paquete

- **Nombre:** Node.js LTS
- **Tags:** language, runtime, javascript
- **Proyecto:** https://nodejs.org
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

JavaScript runtime environment (Long Term Support version)

> ℹ️ La descripción técnica detallada de este proyecto está disponible en inglés:
> ```bash
> core show nodejs
> ```

## ¿Cómo usarlo?

```bash
core install nodejs        # instalar
core update nodejs         # actualizar
core uninstall nodejs      # eliminar
core search nodejs         # encontrarlo entre las herramientas
```

## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- Los métodos de instalación son específicos por plataforma; Core elige el correcto automáticamente.
- En Termux algunas herramientas ofrecen varios métodos de instalación (glibc nativo, glibc+proot, contenedor proot-distro); en Ubuntu/WSL se usan siempre métodos oficiales sin workarounds.
