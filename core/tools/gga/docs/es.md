> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Gentleman Guardian Angel
- **Tags:** ai, code-review
- **Código fuente:** https://github.com/Gentleman-Programming/gentleman-guardian-angel
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Revisión de código por IA, independiente del proveedor, en cada commit.

## Binario y referencia CLI

**Binario:** `gga`

Salida real de `--help` y comandos comunes:


### Common commands

```bash
┌─────────────────┐     ┌──────────────┐     ┌─────────────────┐
│   git commit    │ ──▶ │  AI Review   │ ──▶ │  ✅ Pass/Fail   │
│  (staged files) │     │  (any LLM)   │     │  (with details) │
└─────────────────┘     └──────────────┘     └─────────────────┘
git clone https://github.com/Gentleman-Programming/gentleman-guardian-angel.git
cd gentleman-guardian-angel
./install.sh
git clone https://github.com/Gentleman-Programming/gentleman-guardian-angel.git
```

## ¿Cómo usarlo?

```bash
core install gga        # instalar
core update gga         # actualizar
core uninstall gga      # eliminar
```

### Example

<img width="962" height="941" alt="image" src="https://github.com/user-attachments/assets/c8963dff-6aa5-420c-b58b-1416e81af384" />


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show gga`.
