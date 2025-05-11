# Breek CLI

**Breek** is a lightweight Lua-based CLI tool to **install**, **configure**, and **remove** your dotfiles, applications, and custom packages in a consistent, automated fashion. It reads a plain Lua `config.lua` manifest, executes defined commands, and manages filesystem.

---

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
  - [Manifest Structure](#manifest-structure)
  - [Example Config](#example-config)
- [Commands](#commands)
  - [install](#install)
  - [configure](#configure)
  - [remove](#remove)

---

## Features

- **Modular**: Define packages and operations in plain Lua.
- **Ordered**: Process packages in a custom sequence you specify.
- **Idempotent**: Safe dry-run mode to preview changes.
- **Portable**: Single statically linked binary (via Luastatic) with no Lua dependencies.
- **Extensible**: Customize install, configure, and remove commands per package.

---

## Prerequisites

- A Unix-like environment (Linux, macOS).
- The `breek` executable.
- `config.lua` placed alongside the `breek` binary.

---

## Installation

1. **Download or build** the `breek` binary (see project repo for build instructions).
2. Place `breek` and your `config.lua` in the same directory
3. Ensure `breek` is executable:
   ```bash
   chmod +x ./breek
   ```

---

## Usage

```bash
breek <command> <package|all> [--dry]
```

- `<command>`: One of `install`, `configure`, or `remove`.
- `<package|all>`: The package key from your config, or `all` to operate on every package in order.
- `--dry` (`-d`): Show the actions without executing them.

**Examples:**

```bash
# Install only wezterm
breek install wezterm

# Configure all packages, dry run
breek configure all --dry
```

---

## Configuration

`breek` loads a `config.lua` that must return a table with two keys:

```lua
return {
  order    = order_list,
  packages = packages_table,
}
```

### Manifest Structure

- **`order`** (Array): A list of package keys defining the processing sequence.
- **`packages`** (Map): An object where each key is a package name and the value is a table with up to three sub-tables:
  - `install.commands`  – Array of shell commands to run when installing.
  - `configure`        – Array of `{ source = <path>, destination = <path> }` entries to copy/configure files.
  - `remove.commands`   – Array of shell commands to run when removing.

### Example Config

```lua
-- example config.lua

local order = {
  "wezterm",
  "neovim",
  "tmux",
}

local packages = {
  wezterm = {
    configure = {
      { source = "./wezterm", destination = "~/.config/wezterm/" },
    },
    install = {
      commands = {
        "yay -S wezterm-git --noconfirm --answerclean=None --answerdiff=None --answeredit=None"
      },
    },
    remove = {
      commands = { "yay -R wezterm-git" },
    },
  },
  tmux = {
    configure = {
      { source = "tmux", destination = "~/.config/tmux/" },
    },
    install = { commands = { "sudo pacman -S tmux --noconfirm --needed" } },
    remove  = { commands = { "sudo pacman -R tmux", "rm -r ~/.config/tmux/" } },
  },
  neovim = {
    configure = {
      { source = "neovim/nvim", destination = "~/.config/nvim/" },
    },
    install = { commands = { "./neovim/install.sh" } },
    remove  = { commands = { "rm ~/.local/bin/nvim", "rm -r ~/.config/nvim/" } },
  },
}

return { order = order, packages = packages }
```

---

## Commands

### install

Runs each package’s `install.commands` in order. If `--dry` is provided, displays commands without execution.

```bash
breek install <package|all> [--dry]
```

### configure

Copies files/directories from `source` to `destination`. Respects existing files and handles type mismatches. Supports `--dry`.

```bash
breek configure <package|all> [--dry]
```

### remove

Executes `remove.commands` for cleanup. Supports `--dry` to preview removal steps.

```bash
breek remove <package|all> [--dry]
```
building static binary deps:
- sudo pacman -Syu base-devel lua luarocks git
- sudo luarocks install luastatic

