## Package Information

- **Name:** proot
- **Tags:** container, chroot, termux
- **Project:** https://proot-me.github.io
- **Source:** https://github.com/proot-me/proot
- **Dependencies:** None required by Core

## What is it?

Chroot alternative for user-space sandboxing

## How to use it?

See https://proot-me.github.io for full usage.

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `proot`

### `--help` output

```text
proot 5.1.107.91: chroot, mount --bind, and binfmt_misc without privilege/setup.

Usage:
  proot [option] ... [command]


Regular options:
  -r *path*, --rootfs=*path*
	Use *path* as the new guest root file-system, default is /.

	The specified path typically contains a Linux distribution where
	all new programs will be confined.  The default rootfs is /
	when none is specified, this makes sense when the bind mechanism
	is used to relocate host files and directories, see the -b
	option and the Examples section for details.

	It is recommended to use the -R or -S options instead.

  -b *path*, --bind=*path*, -m *path*, --mount=*path*
	Make the content of *path* accessible in the guest rootfs.

	This option makes any file or directory of the host rootfs
	accessible in the confined environment just as if it were part of
	the guest rootfs.  By default the host path is bound to the same
	path in the guest rootfs but users can specify any other location
	with the syntax: -b *host_path*:*guest_location*.  If the
	guest location is a symbolic link, it is dereferenced to ensure
	the new content is accessible through all the symbolic links that
	point to the overlaid content.  In most cases this default
	behavior shouldn't be a problem, although it is possible to
	explicitly not dereference the guest location by appending it the
	! character: -b *host_path*:*guest_location!*.

  -q *command*, --qemu=*command*
	Execute guest programs through QEMU as specified by *command*.

	Each time a guest program is going to be executed, PRoot inserts
	the QEMU user-mode command in front of the initial request.
	That way, guest programs actually run on a virtual guest CPU
	emulated by QEMU user-mode.  The native execution of host programs
	is still effective and the whole host rootfs is bound to
	/host-rootfs in the guest environment.

  -w *path*, --pwd=*path*, --cwd=*path*
	Set the initial working directory to *path*.

	Some programs expect to be launched from a given directory but do
	not perform any chdir by themselves.  This option avoids the
	need for running a shell and then entering the directory manually.

  --kill-on-exit
	Kill all processes on command exit.

	When the executed command leaves orphean or detached processes
	around, proot waits until all processes possibly terminate. This option forces
```

