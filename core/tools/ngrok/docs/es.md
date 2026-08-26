> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** ngrok
- **Tags:** tunnel, localhost, expose
- **Proyecto:** https://ngrok.com
- **Código fuente:** https://github.com/ngrok/ngrok-go
- **Dependencias:** nodejs

## ¿Qué es?

Túneles seguros para exponer localhost a internet.

## Binario y referencia CLI

**Binario:** `ngrok`

Salida real de `--help` y comandos comunes:


### Common commands

```bash
NGROK_AUTHTOKEN=xxxx_xxxx go run examples/http/main.go
You can use ngrok's [Traffic Policy](https://ngrok.com/docs/traffic-policy/)
engine to apply API Gateway behaviors at ngrok's cloud service to auth, route,
block and rate-limit the traffic. For example:
NGROK_AUTHTOKEN=xxxx_xxxx go run examples/http/main.go
You can use ngrok's [Traffic Policy](https://ngrok.com/docs/traffic-policy/)
engine to apply API Gateway behaviors at ngrok's cloud service to auth, route,
block and rate-limit the traffic. For example:
```

## ¿Cómo usarlo?

```bash
core install ngrok        # instalar
core update ngrok         # actualizar
core uninstall ngrok      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
### Quickstart

The following example starts a Go web server that receives traffic from an
endpoint on ngrok's cloud service with a randomly-assigned URL. The ngrok URL
provided when running this example is accessible by anyone with an internet
connection.

You need an ngrok authtoken to run the following example, which you can get from
the [ngrok dashboard](https://dashboard.ngrok.com/get-started/your-authtoken).

Run this example with the following command:

```sh
NGROK_AUTHTOKEN=xxxx_xxxx go run examples/http/main.go
```

```go
package main

import (
	"context"
	"fmt"
	"log"
	"net/http"

	"golang.ngrok.com/ngrok/v2"
)

func main() {
	if err := run(context.Background()); err != nil {
		log.Fatal(err)
	}
}

func run(ctx context.Context) error {
	// ngrok.Listen uses ngrok.DefaultAgent which uses the NGROK_AUTHTOKEN
	// environment variable for auth
	ln, err := ngrok.Listen(ctx)
	if err != nil {
		return err
	}

	log.Println("Endpoint online", ln.URL())

	// Serve HTTP traffic on the ngrok endpoint
	return http.Serve(ln, http.HandlerFunc(handler))
}

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Hello from ngrok-go!")
}
```


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show ngrok`.
