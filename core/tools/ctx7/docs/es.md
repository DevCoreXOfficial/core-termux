> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Context7
- **Tags:** ai, docs, mcp
- **Proyecto:** https://context7.com
- **Código fuente:** https://github.com/upstash/context7
- **Dependencias:** nodejs

## ¿Qué es?

Proveedor de documentación en vivo para agentes de IA.

## Binario y referencia CLI

**Binario:** `ctx7`

Salida real de `--help` y comandos comunes:

- **Binary:** `ctx7`

## ¿Cómo usarlo?

```bash
core install ctx7        # instalar
core update ctx7         # actualizar
core uninstall ctx7      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
### CLI Commands

- `ctx7 library <name> <query>`: Searches the Context7 index by library name and returns matching libraries with their IDs.
- `ctx7 docs <libraryId> <query>`: Retrieves documentation for a library using a Context7-compatible library ID (e.g., `/mongodb/docs`, `/vercel/next.js`).

### MCP Tools

- `resolve-library-id`: Resolves a general library name into a Context7-compatible library ID.
  - `query` (required): The user's question or task (used to rank results by relevance)
  - `libraryName` (required): The name of the library to search for
- `query-docs`: Retrieves documentation for a library using a Context7-compatible library ID.
  - `libraryId` (required): Exact Context7-compatible library ID (e.g., `/mongodb/docs`, `/vercel/next.js`)
  - `query` (required): The question or task to get relevant documentation for


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show ctx7`.
