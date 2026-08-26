> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Live Server
- **Tags:** dev-server, frontend, reload
- **Código fuente:** https://github.com/tapio/live-server
- **Dependencias:** nodejs

## ¿Qué es?

Servidor de desarrollo con recarga automática del navegador.

## Binario y referencia CLI

**Binario:** `live-server`

Salida real de `--help` y comandos comunes:


### Common commands

```bash
var liveServer = require("live-server");
var params = {
port: 8181, // Set the server port. Defaults to 8080.
host: "0.0.0.0", // Set the address to bind to. Defaults to 0.0.0.0 or process.env.IP.
root: "/public", // Set root directory that's being served. Defaults to cwd.
open: false, // When false, it won't load your browser by default.
ignore: 'scss,my/templates', // comma-separated string for paths to ignore
wait: 1000, // Waits for all changes, before reloading. Defaults to 0 sec.
```

## ¿Cómo usarlo?

```bash
core install live-server        # instalar
core update live-server         # actualizar
core uninstall live-server      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
Example from the official README:

```bash
var liveServer = require("live-server");

var params = {
	port: 8181, // Set the server port. Defaults to 8080.
	host: "0.0.0.0", // Set the address to bind to. Defaults to 0.0.0.0 or process.env.IP.
	root: "/public", // Set root directory that's being served. Defaults to cwd.
	open: false, // When false, it won't load your browser by default.
	ignore: 'scss,my/templates', // comma-separated string for paths to ignore
	file: "index.html", // When set, serve this file (server root relative) for every 404 (useful for single-page applications)
	wait: 1000, // Waits for all changes, before reloading. Defaults to 0 sec.
	mount: [['/components', './node_modules']], // Mount a directory to a route.
	logLevel: 2, // 0 = errors only, 1 = some, 2 = lots
	middleware: [function(req, res, next) { next(); }] // Takes an array of Connect-compatible middleware that are injected into the server middleware stack
};
liveServer.start(params);
```

Full documentation: https://github.com/tapio/live-server

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show live-server`.
