## Package Information

- **Name:** ngrok
- **Tags:** tunnel, localhost, expose
- **Project:** https://ngrok.com
- **Source:** https://github.com/ngrok/ngrok-go
- **Dependencies:** nodejs

## What is it?

Embed ngrok secure ingress into your Go apps as a net.Listener with a single line of code.

## How to use it?

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

## Traffic Policy

You can use ngrok's [Traffic Policy](https://ngrok.com/docs/traffic-policy/)
engine to apply API Gateway behaviors at ngrok's cloud service to auth, route,
block and rate-limit the traffic. For example:

```go
tp := `
on_http_request:
  - name: "rate limit by ip address"
    actions:
    - type: rate-limit
      config:
        name: client-ip-rate-limit

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `ngrok`

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
## Notes

- Supported platforms: see manifest.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show ngrok:es`.
