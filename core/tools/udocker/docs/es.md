> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** udocker
- **Tags:** containers, docker, rootless
- **Proyecto:** https://indigo-dc.github.io/udocker/
- **Código fuente:** https://github.com/indigo-dc/udocker
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Ejecuta contenedores tipo docker sin privilegios root.

## Binario y referencia CLI

**Binario:** `udocker`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
Syntax:
  udocker  [general_options] <command>  [command_options]  <command_args>

  udocker [-h|--help|help]        :Display this help and exits
  udocker [-V|--version|version]  :Display udocker and tarball version and exits

General options common to all commands must appear before the command:
  -D, --debug                   :Debug
  -q, --quiet                   :Less verbosity
  --insecure                    :Allow insecure non authenticated https
  --repo=<directory>            :Use repository at directory
  --allow-root                  :Allow execution by root NOT recommended
  --config=<conf_file>          :Use configuration <conf_file>

Commands:
  --help [command]              :Command specific help
  showconf                      :Print all configuration options

  search <repo/expression>      :Search dockerhub for container images
  pull <repo/image:tag>         :Pull container image from dockerhub
  create <repo/image:tag>       :Create container from a pulled image
  run <container_id|name>       :Execute created container
  run <repo/image:tag>          :Pull, create and execute container

  images -l                     :List container images
  ps -m -s                      :List created containers
  name <container_id> <name>    :Give name to container
  rmname <name>                 :Delete name from container
  rename <name> <new_name>      :Change container name
  clone <container_id>          :Duplicate container
  rm  <container-id|name>       :Delete container
  rmi <repo/image:tag>          :Delete image
  tag <repo/image:tag> <repo2/image2:tag2> :Tag image

  import <tar> <repo/image:tag> :Import tar file (exported by docker)
  import - <repo/image:tag>     :Import from stdin (exported by docker)
  export -o <tar> <container>   :Export container directory tree to file
  export - <container>          :Export container directory tree to stdin
  load -i <exported-image>      :Load image from file (saved by docker)
  load                          :Load image from stdin (saved by docker)
  save -o <imagefile> <repo/image:tag>  :Save image with layers to file

  inspect -p <repo/image:tag>   :Print image or container metadata
  verify <repo/image:tag>       :Verify a pulled image
  manifest inspect <repo/image:tag> :Print manifest metadata

  udocker manifest inspect centos/centos8
  udocker pull --platform=linux/arm64 centos/centos8
  udocker tag centos/centos8  mycentos/centos8:arm64

  protect <repo/image:tag>      :Protect repository
  unprotect <repo/image:tag>    :Unprotect repository
  protect <container>           :Protect container
  unprotect <container>         :Unprotect container

```


### Common commands

```bash
udocker search  fedora
udocker search  ubuntu
udocker search  debian
udocker search --list-tags ubuntu
udocker pull   fedora:39
udocker pull   busybox
udocker pull   iscampos/openqcd
udocker images
```

## ¿Cómo usarlo?

```bash
core install udocker        # instalar
core update udocker         # actualizar
core uninstall udocker      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
### Examples

Some examples of usage:

Search container images in dockerhub and listing tags.

```bash
udocker search  fedora
udocker search  ubuntu
udocker search  debian

udocker search --list-tags ubuntu
```

Pull from dockerhub and list the pulled images.

```bash
udocker pull   fedora:39
udocker pull   busybox
udocker pull   iscampos/openqcd
udocker images
```

Pull from a registry other than dockerhub.

```bash
udocker search  quay.io/bio
udocker search  --list-tags  quay.io/biocontainers/scikit-bio
udocker pull    quay.io/biocontainers/scikit-bio:0.2.3--np112py35_0
udocker images
```

Pull a different architecture such as arm64 instead of amd64.

```bash
udocker manifest inspect centos/centos8
udocker pull --platform=linux/arm64 centos/centos8
udocker tag centos/centos8  mycentos/centos8:arm64
```

Create a container from a pulled image, assign a name to the created
container and run it. A created container can be run multiple times
until it is explicitly removed. Files modified or added to the container
remain available across executions until the container is removed.

```bash
udocker create --name=myfed  fedora:29
udocker run  myfed  cat /etc/redhat-release
```

The three steps of pulling, creating and running can be also achieved
in a single command, however this will be much slower for multiple
invocations of the same container, as a new container will be created
for each invocation. This approach will also consume more storage space.
The following example creates a new container for each invocation.

```bash
udocker run  fedora:29  cat /etc/redhat-release
```

Execute mounting the host /home/u457 into the container directory /home/cuser.
Notice that you can "mount" any host directory inside the container.
Depending on the execution mode the "mount" is implemented differently and
may have restrictions.

```bash
udocker run -v /home/u457:/home/cuser -w /home/user myfed  /bin/bash

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show udocker`.
