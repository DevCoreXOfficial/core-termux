## Package Information

- **Name:** OpenSSH
- **Tags:** ssh, remote, scp
- **Project:** https://www.openssh.com
- **Source:** https://github.com/openssh/openssh-portable
- **Dependencies:** None required by Core

## What is it?

Portable OpenSSH

## How to use it?

Example from the official README:

```bash
tar zxvf openssh-X.YpZ.tar.gz
cd openssh
./configure # [options]
make && make tests
```

Full documentation: https://www.openssh.com

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `ssh`

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

