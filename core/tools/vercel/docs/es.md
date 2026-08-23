> 🇪🇸 **Documentación en español.** El contenido técnico profundo procede de la
> documentación oficial del proyecto; la traducción íntegra está en progreso.
> Consulta la versión completa con `core show vercel` (inglés).

## Información del Paquete

- **Nombre:** Vercel CLI
- **Tags:** cloud, deploy, hosting, serverless
- **Proyecto:** https://vercel.com/docs/cli
- **Dependencias:** nodejs

## ¿Qué es?

Deploy frontend applications and serverless functions

> ℹ️ La descripción técnica detallada de este proyecto está disponible en inglés:
> ```bash
> core show vercel
> ```

## ¿Cómo usarlo?

```bash
core install vercel        # instalar
core update vercel         # actualizar
core uninstall vercel      # eliminar
core search vercel         # encontrarlo entre las herramientas
```

## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- Los métodos de instalación son específicos por plataforma; Core elige el correcto automáticamente.
- En Termux algunas herramientas ofrecen varios métodos de instalación (glibc nativo, glibc+proot, contenedor proot-distro); en Ubuntu/WSL se usan siempre métodos oficiales sin workarounds.
