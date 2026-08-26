## Package Information

- **Name:** npm-check-updates
- **Tags:** updates, npm, dependencies
- **Source:** https://github.com/raineorshine/npm-check-updates
- **Dependencies:** nodejs

## What is it?

Find newer versions of package dependencies than what your package.json allows

## How to use it?

### Usage

Check the latest versions of all project dependencies:

```console
$ ncu
Checking package.json
[====================] 5/5 100%

 eslint             7.32.0  →    8.0.0
 prettier           ^2.7.1  →   ^3.0.0
 svelte            ^3.48.0  →  ^3.51.0
 typescript         >3.0.0  →   >4.0.0
 untildify          <4.0.0  →   ^4.0.0
 webpack               4.x  →      5.x

Run ncu -u to upgrade package.json
```

Upgrade a project's package file:

> **Make sure your package file is in version control and all changes have been committed. This _will_ overwrite your package file.**

```console
$ ncu -u
Upgrading package.json
[====================] 1/1 100%

 express           4.12.x  →   4.13.x

Run npm install to install new versions.

$ npm install      # update installed packages and package-lock.json
```

Check global packages:

```sh
ncu -g
```

## Interactive Mode

Choose which packages to update in interactive mode:

```sh
ncu --interactive
ncu -i
```

![ncu --interactive](https://user-images.githubusercontent.com/750276/175337598-cdbb2c46-64f8-44f5-b54e-4ad74d7b52b4.png)

Combine with `--format group` for a truly _luxe_ experience:

![ncu --interactive --format group](https://user-images.githubusercontent.com/750276/175336533-539261e4-5cf1-458f-9fbb-a7be2b477ebb.png)

### Keys

- <kbd>↑</kbd><kbd>↓</kbd> Select a package
- <kbd>Space</kbd> Toggle selection
- <kbd>a</kbd> Toggle all
- <kbd>Enter</kbd> Upgrade

### Pre-selected upgrades

`ncu -i` pre-selects patch and minor upgrades, since `--format group` is enabled by default. Only when group formatting is disabled with `--format no-group` are all upgrades pre-selected, including major. Use `--interactiveSelect` to control this explicitly:

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `ncu`

### Common commands

```bash
Upgrade a project's package file:
Check global packages:
Choose which packages to update in interactive mode:
Combine with `--format group` for a truly _luxe_ experience:
- <kbd>↑</kbd><kbd>↓</kbd> Select a package
- <kbd>Space</kbd> Toggle selection
- <kbd>a</kbd> Toggle all
- <kbd>Enter</kbd> Upgrade
```

