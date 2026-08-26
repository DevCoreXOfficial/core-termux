> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Bat
- **Tags:** cat, syntax, paging
- **Proyecto:** https://github.com/sharkdp/bat
- **Código fuente:** https://github.com/sharkdp/bat
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Clon de cat con resaltado de sintaxis e integración con git.

## Binario y referencia CLI

**Binario:** `bat`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
A cat(1) clone with syntax highlighting and Git integration.

Usage: bat [OPTIONS] [FILE]...
       bat <COMMAND>

Arguments:
  [FILE]...
          File(s) to print / concatenate. Use a dash ('-') or no argument at all to read from
          standard input.

Options:
  -A, --show-all
          Show non-printable characters like space, tab or newline. This option can also be used to
          print binary files. Use '--tabs' to control the width of the tab-placeholders.

      --nonprintable-notation <notation>
          Set notation for non-printable characters.

          Possible values:
            * unicode (␇, ␊, ␀, ..)
            * caret   (^G, ^J, ^@, ..)

      --binary <behavior>
          How to treat binary content. (default: no-printing)

          Possible values:
            * no-printing: do not print any binary content
            * as-text: treat binary content as normal text

  -p, --plain...
          Only show plain style, no decorations. This is an alias for '--style=plain'. When '-p' is
          used twice ('-pp'), it also disables automatic paging (alias for '--style=plain
          --paging=never').

  -l, --language <language>
          Explicitly set the language for syntax highlighting. The language can be specified as a
          name (like 'C++' or 'LaTeX') or possible file extension (like 'cpp', 'hpp' or 'md'). Use
          '--list-languages' to show all supported language names and file extensions.

  -H, --highlight-line <N:M>
          Highlight the specified line ranges with a different background color For example:
            '--highlight-line 40' highlights line 40
            '--highlight-line 30:40' highlights lines 30 to 40
            '--highlight-line :40' highlights lines 1 to 40
            '--highlight-line 40:' highlights lines 40 to the end of the file
            '--highlight-line 30:+10' highlights lines 30 to 40

      --file-name <name>
          Specify the name to display for a file. Useful when piping data to bat from STDIN when bat
          does not otherwise know the filename. Note that the provided file name is also used for
          syntax detection.

  -d, --diff
          Only show lines that have been added/removed/modified with respect to the Git index. Use
          --diff-context=N to control how much context you want to see.
```


### Common commands

```bash
bat --config-file
export BAT_CONFIG_PATH="/path/to/bat/bat.conf"
export BAT_CONFIG_DIR="/path/to/bat"
bat --generate-config-file
--theme="TwoDark"
--style="numbers,changes,header"
--italic-text=always
--map-syntax "*.ino:C++"
```

## ¿Cómo usarlo?

```bash
core install bat        # instalar
core update bat         # actualizar
core uninstall bat      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
### Configuration file

`bat` can also be customized with a configuration file. The location of the file is dependent
on your operating system. To get the default path for your system, call
```bash
bat --config-file
```

Alternatively, you can use `BAT_CONFIG_PATH` or `BAT_CONFIG_DIR` environment variables to point `bat`
to a non-default location of the configuration file or the configuration directory respectively:
```bash
export BAT_CONFIG_PATH="/path/to/bat/bat.conf"
export BAT_CONFIG_DIR="/path/to/bat"
```

A default configuration file can be created with the `--generate-config-file` option.
```bash
bat --generate-config-file
```

There is also now a systemwide configuration file, which is located under `/etc/bat/config` on
Linux and Mac OS and `C:\ProgramData\bat\config` on windows. If the system wide configuration
file is present, the content of the user configuration will simply be appended to it.

### Format

The configuration file is a simple list of command line arguments. Use `bat --help` to see a full list of possible options and values. In addition, you can add comments by prepending a line with the `#` character.

Example configuration file:
```bash
# Set the theme to "TwoDark"
--theme="TwoDark"

# Show line numbers, Git modifications and file header (but no grid)
--style="numbers,changes,header"

# Use italic text on the terminal (not supported on all terminals)
--italic-text=always

# Use C++ syntax for Arduino .ino files
--map-syntax "*.ino:C++"
```


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show bat`.
