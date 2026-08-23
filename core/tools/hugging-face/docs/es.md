> 🇪🇸 **Documentación en español.** El contenido técnico profundo procede de la
> documentación oficial del proyecto; la traducción íntegra está en progreso.
> Consulta la versión completa con `core show hugging-face` (inglés).

## Información del Paquete

- **Nombre:** Hugging Face CLI
- **Tags:** ai, models, datasets, ml
- **Proyecto:** https://huggingface.co/docs/huggingface_hub
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

The official Hugging Face Hub CLI — download, upload, and manage models, datasets, Spaces, buckets, repos, papers, colle

> ℹ️ La descripción técnica detallada de este proyecto está disponible en inglés:
> ```bash
> core show hugging-face
> ```

## ¿Cómo usarlo?

```bash
core install hugging-face        # instalar
core update hugging-face         # actualizar
core uninstall hugging-face      # eliminar
core search hugging-face         # encontrarlo entre las herramientas
```

## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- Instalación global por pip **sin venv**. Se usa `--no-deps` para evitar `hf-xet` (sin wheel para Termux); las descargas Xet se desactivan vía `HF_HUB_DISABLE_XET=1`.
- Los métodos de instalación son específicos por plataforma; Core elige el correcto automáticamente.
- En Termux algunas herramientas ofrecen varios métodos de instalación (glibc nativo, glibc+proot, contenedor proot-distro); en Ubuntu/WSL se usan siempre métodos oficiales sin workarounds.
