## Package Information

- **Name:** curl
- **Tags:** http, transfer, api
- **Project:** https://curl.se
- **Source:** https://github.com/curl/curl
- **Dependencies:** None required by Core

## What is it?

A command line tool and library for transferring data with URL syntax, supporting DICT, FILE, FTP, FTPS, GOPHER, GOPHERS, HTTP, HTTPS, IMAP, IMAPS, LDAP, LDAPS, MQTT, MQTTS, POP3, POP3S, RTSP, SCP, SFTP, SMB, SMBS, SMTP, SMTPS, TELNET, TFTP, WS and WSS. libcurl offers a myriad of powerful features

Full documentation: https://curl.se

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `curl`

### `--help` output

```text
Usage: curl [options...] <url>
 -d, --data <data>            HTTP POST data
 -f, --fail                   Fail fast with no output on HTTP errors
 -I, --head                   Show document info only
 -H, --header <header/@file>  Pass custom header(s) to server
 -h, --help <subject>         Get help for commands
 -o, --output <file>          Write to file instead of stdout
 -O, --remote-name            Write output to file named as remote file
 -i, --show-headers           Show response headers in output
 -s, --silent                 Silent mode
 -T, --upload-file <file>     Transfer local FILE to destination
 -u, --user <user:password>   Server user and password
 -A, --user-agent <name>      Send User-Agent <name> to server
 -v, --verbose                Make the operation more talkative
 -V, --version                Show version number and quit

This is not the full help; this menu is split into categories.
Use "--help category" to get an overview of all categories, which are:
auth, connection, curl, deprecated, dns, file, ftp, global, http, imap, ldap,
output, pop3, post, proxy, scp, sftp, smtp, ssh, telnet, tftp, timeout, tls,
upload, verbose.
Use "--help all" to list all options
Use "--help [option]" to view documentation for a given option
```

