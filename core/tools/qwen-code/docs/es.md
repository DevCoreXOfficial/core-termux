> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Qwen Code
- **Tags:** ai, agent, coding
- **Proyecto:** https://qwenlm.github.io/qwen-code-docs/
- **Código fuente:** https://github.com/QwenLM/qwen-code
- **Dependencias:** git, ripgrep

## ¿Qué es?

Asistente de programación de Alibaba basado en los modelos Qwen.

## Binario y referencia CLI

**Binario:** `qwen`

Salida real de `--help` y comandos comunes:


### Common commands

```bash
qwen          # Launch interactive terminal UI
/auth         # Configure your provider and API key
</details>
| Feature                                                            | Qwen Code | Claude Code |
| ------------------------------------------------------------------ | :-------: | :---------: |
| SubAgents, Agent Teams, Dynamic Workflows                          |     ✓     |      ✓      |
| Auto-Memory, Auto-Skills, Hooks                                    |     ✓     |      ✓      |
| Built-in Skills (/review, /batch, /loop, /bugfix…)                 |     ✓     |      ✓      |
```

## ¿Cómo usarlo?

```bash
core install qwen-code        # instalar
core update qwen-code         # actualizar
core uninstall qwen-code      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
### Quick Start

```bash
qwen          # Launch interactive terminal UI
# Inside the session:
/auth         # Configure your provider and API key
```

See the [Authentication Guide](https://qwenlm.github.io/qwen-code-docs/en/users/configuration/auth/) and [Settings Reference](https://qwenlm.github.io/qwen-code-docs/en/users/configuration/settings/) for detailed setup.

![Qwen Code](https://img.alicdn.com/imgextra/i2/O1CN01K0nwj41RM1Il8kB0t_!!6000000002096-2-tps-1544-1060.png)


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show qwen-code`.
