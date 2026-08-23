> 🇪🇸 **Documentación en español.** El contenido técnico profundo procede de la
> documentación oficial del proyecto; la traducción íntegra está en progreso.
> Consulta la versión completa con `core show cactus` (inglés).

## Información del Paquete

- **Nombre:** Cactus Engine CLI
- **Tags:** ai, llm, mobile, inference
- **Proyecto:** https://cactuscompute.com
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

A hybrid edge-cloud AI engine for mobiles, wearables, smart home and robots — quantization, kernels, runtime and inferen

> ℹ️ La descripción técnica detallada de este proyecto está disponible en inglés:
> ```bash
> core show cactus
> ```

## ¿Cómo usarlo?

```bash
core install cactus        # instalar
core update cactus         # actualizar
core uninstall cactus      # eliminar
core search cactus         # encontrarlo entre las herramientas
```

## Notas

- Plataformas soportadas: **termux**.
- Instalación nativa desde el código oficial (v2.0.1): compilación cmake en el dispositivo + `termux-elf-cleaner`. **Sin glibc y sin proot.** Incluye parches de compatibilidad (Python 3.14, tokenizadores SentencePiece).
- Los métodos de instalación son específicos por plataforma; Core elige el correcto automáticamente.
- En Termux algunas herramientas ofrecen varios métodos de instalación (glibc nativo, glibc+proot, contenedor proot-distro); en Ubuntu/WSL se usan siempre métodos oficiales sin workarounds.
