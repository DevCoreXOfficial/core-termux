> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Localtunnel
- **Tags:** tunnel, localhost, expose
- **Proyecto:** https://theboroer.github.io/localtunnel-www/
- **Código fuente:** https://github.com/localtunnel/server
- **Dependencias:** nodejs

## ¿Qué es?

Expone tu localhost a internet de forma gratuita.

## Binario y referencia CLI

**Binario:** `lt`

Salida real de `--help` y comandos comunes:


### Common commands

```bash
git clone git://github.com/defunctzombie/localtunnel-server.git
cd localtunnel-server
bin/server --port 1234
git clone git://github.com/defunctzombie/localtunnel-server.git
cd localtunnel-server
bin/server --port 1234
git clone git://github.com/defunctzombie/localtunnel-server.git
cd localtunnel-server
```

## ¿Cómo usarlo?

```bash
core install localtunnel        # instalar
core update localtunnel         # actualizar
core uninstall localtunnel      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
Example from the official README:

```bash
# pick a place where the files will live
git clone git://github.com/defunctzombie/localtunnel-server.git
cd localtunnel-server
npm install

# server set to run on port 1234
bin/server --port 1234
```

Full documentation: https://github.com/localtunnel/server

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show localtunnel`.
