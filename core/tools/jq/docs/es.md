> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** jq
- **Tags:** json, parser
- **Proyecto:** https://jqlang.github.io/jq/
- **Código fuente:** https://github.com/jqlang/jq
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Procesador JSON ligero y potente para la línea de comandos.

## Binario y referencia CLI

**Binario:** `jq`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
jq - commandline JSON processor [version 1.8.2]

Usage:	jq [options] <jq filter> [file...]
	jq [options] --args <jq filter> [strings...]
	jq [options] --jsonargs <jq filter> [JSON_TEXTS...]

jq is a tool for processing JSON inputs, applying the given filter to
its JSON text inputs and producing the filter's results as JSON on
standard output.

The simplest filter is ., which copies jq's input to its output
unmodified except for formatting. For more advanced filters see
the jq(1) manpage ("man jq") and/or https://jqlang.org/.

Example:

	$ echo '{"foo": 0}' | jq .
	{
	  "foo": 0
	}

Command options:
  -n, --null-input          use `null` as the single input value;
  -R, --raw-input           read each line as string instead of JSON;
  -s, --slurp               read all inputs into an array and use it as
                            the single input value;
  -c, --compact-output      compact instead of pretty-printed output;
  -r, --raw-output          output strings without escapes and quotes;
      --raw-output0         implies -r and output NUL after each output;
  -j, --join-output         implies -r and output without newline after
                            each output;
  -a, --ascii-output        output strings by only ASCII characters
                            using escape sequences;
  -S, --sort-keys           sort keys of each object on output;
  -C, --color-output        colorize JSON output;
  -M, --monochrome-output   disable colored output;
      --tab                 use tabs for indentation;
      --indent n            use n spaces for indentation (max 7 spaces);
      --unbuffered          flush output stream after each output;
      --stream              parse the input value in streaming fashion;
      --stream-errors       implies --stream and report parse error as
                            an array;
      --seq                 parse input/output as application/json-seq;
  -f, --from-file           load the filter from a file;
  -L, --library-path dir    search modules from the directory;
      --arg name value      set $name to the string value;
      --argjson name value  set $name to the JSON value;
      --slurpfile name file set $name to an array of JSON values read
                            from the file;
      --rawfile name file   set $name to string contents of file;
      --args                consume remaining arguments as positional
                            string values;
      --jsonargs            consume remaining arguments as positional
                            JSON values;
  -e, --exit-status         set exit status code based on the output;
```


### Common commands

```bash
docker run --rm -i ghcr.io/jqlang/jq:latest < package.json '.version'
```

## ¿Cómo usarlo?

```bash
core install jq        # instalar
core update jq         # actualizar
core uninstall jq      # eliminar
```

Example from the official README:

```bash
docker run --rm -i ghcr.io/jqlang/jq:latest < package.json '.version'
```

Full documentation: https://jqlang.github.io/jq/

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show jq`.
