> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** OpenSSH
- **Tags:** ssh, remote, scp
- **Proyecto:** https://www.openssh.com
- **Código fuente:** https://github.com/openssh/openssh-portable
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Suite de conectividad segura SSH (cliente y servidor).

## Binario y referencia CLI

**Binario:** `ssh`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
ssh: invalid option -- -
usage: ssh [-46AaCfGgKkMNnqsTtVvXxYyZ] [-B bind_interface] [-b bind_address]
           [-c cipher_spec] [-D [bind_address:]port] [-E log_file]
           [-e escape_char] [-F configfile] [-I pkcs11] [-i identity_file]
           [-J destination] [-L address] [-l login_name] [-m mac_spec]
           [-O ctl_cmd] [-o option] [-P tag] [-p port] [-R address]
           [-S ctl_path] [-W host:port] [-w local_tun[:remote_tun]]
           destination [command [argument ...]]
       ssh [-Q query_option]
```


### Common commands

```bash
tar zxvf openssh-X.YpZ.tar.gz
cd openssh
./configure # [options]
make && make tests
```

## ¿Cómo usarlo?

```bash
core install openssh        # instalar
core update openssh         # actualizar
core uninstall openssh      # eliminar
```

Example from the official README:

```bash
tar zxvf openssh-X.YpZ.tar.gz
cd openssh
./configure # [options]
make && make tests
```

Full documentation: https://www.openssh.com

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show openssh`.
