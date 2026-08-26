> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** n8n
- **Tags:** automation, workflows, integration, self-hosted
- **Proyecto:** https://n8n.io
- **Código fuente:** https://github.com/n8n-io/n8n
- **Dependencias:** nodejs

## ¿Qué es?

Automatización de flujos self-hosted conectando apps y APIs.

## Binario y referencia CLI

**Binario:** `n8n`

Salida real de `--help` y comandos comunes:


### Common commands

```bash
docker volume create n8n_data
docker run -it --rm --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n
docker volume create n8n_data
docker run -it --rm --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n
docker volume create n8n_data
docker run -it --rm --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n
docker volume create n8n_data
docker run -it --rm --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n
```

## ¿Cómo usarlo?

```bash
core install n8n        # instalar
core update n8n         # actualizar
core uninstall n8n      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
### Quick Start

Try n8n instantly with our install script (requires [Docker](https://www.docker.com/)):

```sh
curl -fsSL https://get.n8n.io | sh
```

Or deploy manually with [Docker](https://docs.n8n.io/hosting/installation/docker/):

```
docker volume create n8n_data
docker run -it --rm --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n
```

Access the editor at http://localhost:5678


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show n8n`.
