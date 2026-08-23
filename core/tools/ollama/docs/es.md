> 🇪🇸 **Documentación en español.** El contenido técnico profundo procede de la
> documentación oficial del proyecto; la traducción íntegra está en progreso.
> Consulta la versión completa con `core show ollama` (inglés).

## Información del Paquete

- **Nombre:** Ollama
- **Tags:** ai, llm, local
- **Proyecto:** https://ollama.com
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Run open-source LLMs locally on Termux

> ℹ️ La descripción técnica detallada de este proyecto está disponible en inglés:
> ```bash
> core show ollama
> ```

## ¿Cómo usarlo?

```bash
core install ollama        # instalar
core update ollama         # actualizar
core uninstall ollama      # eliminar
core search ollama         # encontrarlo entre las herramientas
```

## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- Los métodos de instalación son específicos por plataforma; Core elige el correcto automáticamente.
- En Termux algunas herramientas ofrecen varios métodos de instalación (glibc nativo, glibc+proot, contenedor proot-distro); en Ubuntu/WSL se usan siempre métodos oficiales sin workarounds.
