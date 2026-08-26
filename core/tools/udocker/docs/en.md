## Package Information

- **Name:** udocker
- **Tags:** containers, docker, rootless
- **Project:** https://indigo-dc.github.io/udocker/
- **Source:** https://github.com/indigo-dc/udocker
- **Dependencies:** None required by Core

## What is it?

A basic user tool to execute simple docker containers in batch or interactive systems without root privileges.

## How to use it?

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

## Notes

- Supported platforms: **termux**.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show udocker:es`.
