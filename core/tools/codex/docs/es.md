> 🇪🇸 **Documentación en español.** El contenido técnico profundo procede de la
> documentación oficial del proyecto; la traducción íntegra está en progreso.
> Consulta la versión completa con `core show codex` (inglés).

## Información del Paquete

- **Nombre:** Codex CLI
- **Tags:** ai, agent, coding
- **Proyecto:** https://developers.openai.com/codex/
- **Dependencias:** nodejs

## ¿Qué es?

Codex CLI is a coding agent from OpenAI that runs locally on your computer

> ℹ️ La descripción técnica detallada de este proyecto está disponible en inglés:
> ```bash
> core show codex
> ```

## ¿Cómo usarlo?

```bash
core install codex        # instalar
core update codex         # actualizar
core uninstall codex      # eliminar
core search codex         # encontrarlo entre las herramientas
```

## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- Los métodos de instalación son específicos por plataforma; Core elige el correcto automáticamente.
- En Termux algunas herramientas ofrecen varios métodos de instalación (glibc nativo, glibc+proot, contenedor proot-distro); en Ubuntu/WSL se usan siempre métodos oficiales sin workarounds.
