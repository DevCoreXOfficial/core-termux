> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Vercel CLI
- **Tags:** cloud, deploy, hosting, serverless
- **Proyecto:** https://vercel.com/docs/cli
- **Código fuente:** https://github.com/vercel/vercel
- **Dependencias:** nodejs

## ¿Qué es?

CLI de despliegue para Vercel: preview y producción.

## Binario y referencia CLI

**Binario:** `vercel`

Salida real de `--help` y comandos comunes:

- **Binary:** `vercel`

## ¿Cómo usarlo?

```bash
core install vercel        # instalar
core update vercel         # actualizar
core uninstall vercel      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
Example from the official README:

```bash
npm i -g vercel
```

Native CLI binaries are distributed separately and do not affect the `vercel` npm package. To opt into the native binary and replace existing global `vercel` and `vc` commands, install the native package explicitly:
```

Full documentation: https://vercel.com/docs/cli

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show vercel`.
