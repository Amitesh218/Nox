___ 
# Getting Started with NixOS

## Table of Contents

* [Introduction](#introduction)
* [Installation](#installation)
* [Configuration](#configuration)
* [The Nix Language](#the-nix-language)
* [Home Manager](#home-manager)
* [Flakes](#flakes)

## Introduction

**NixOS** is a Linux distribution built on top of the Nix package manager. It was developed to bring the power of *declarative configuration* and *functional system management* to the operating system level.

---

### ❄️ The NixOS Philosophy

The philosophy of NixOS revolves around **reproducibility** and **stability**, aiming to provide a virtually *“unbreakable”* system through a **declarative** and **functional** approach to system management.

In simpler terms, you can declare your **entire system** in just a few Nix configuration files — including:

* System packages
* Environment variables
* Dotfiles and personal settings
* Specific package versions
* Even your hardware configuration

This makes it possible to **replicate** your exact system on any machine with ease — ideal for backup, testing, or sharing your setup.

---

### ❄️ What Makes NixOS Different?

Key points that set NixOS apart from traditional Linux distributions are:

* **Declarative system config**: You describe *what* the system should look like, not *how* to get there.
* **Atomic upgrades and rollbacks**: You can switch between system generations and undo changes safely.
* **Reproducibility**: Your config can be version-controlled and deployed across machines.
* **Isolated environments**: No accidental overwrites or “dependency hell.”
* **Per-user packages**: Unlike traditional distros, Nix allows users to install packages **just for themselves**.
* **Side-by-side versions**: Install multiple versions of the same package — useful for dev environments.

## Installation

Installation steps can be categorized into:

* Preparation
* Ensuring an Internet connection
* Disk partitioning and mounting
* Configuration generation and installation
* Reboot and password setup

### ❄️ Preparation

As with any other OS installation, begin by downloading the ISO image from the [**official website**](https://nixos.org/download/). The graphical installer includes **Calamares**, which provides a faster, non-manual setup process.

For manual installation, well-written guides are available in the [**official manual**](https://nixos.org/manual/nixos/stable/index.html#ch-installation) and the [**unofficial wiki**](https://nixos.wiki/wiki/NixOS_Installation_Guide).

Even if you plan to install manually, I still recommend using the graphical installer initially—it makes it easier to copy and paste commands from the internet.

After booting into the live ISO, you'll have access to two users: **nixos** and **root**, neither of which has a password. You will need elevated privileges during installation, so you can either prefix commands with `sudo` or switch to the root user using `sudo -i`.

**Side note:** Manual installation is significantly easier than, say, Arch Linux.

---

### ❄️ Ensuring an Internet Connection

If using a wired connection, internet access should be available automatically. You can also tether using your phone.

For Wi-Fi:

1. Start the `wpa_supplicant` service:

   ```bash
   sudo systemctl start wpa_supplicant.service
   ```

2. Use `wpa_cli` to connect to your network:

   ```bash
   wpa_cli
   ```

   For most home networks, use the following commands in the `wpa_cli` interface:

   ```
   add_network 0
   set_network 0 ssid "myhomenetwork"
   set_network 0 psk "mypassword"
   enable_network 0
   ```

   For enterprise networks (e.g., eduroam), use:

   ```
   add_network
   0
   set_network 0 ssid "eduroam"
   set_network 0 identity "myname@example.com"
   set_network 0 password "mypassword"
   enable_network 0
   ```

   When successfully connected, you should see a line like:

   ```
   <3>CTRL-EVENT-CONNECTED - Connection to 32:85:ab:ef:24:5c completed [id=0 id_str=]
   ```

   You can now leave `wpa_cli` by typing:

   ```
   quit
   ```
3. Finally, test connectivity using the ping command: `ping nixos.org`

---

### ❄️ Disk Partitioning and Mounting

In this setup, I’ll be using the following partition layout:

| Number | Type             | Size                 | Label |
| ------ | ---------------- | -------------------- | ----- |
| 1      | EFI System       | 1 GiB / 512 MiB      | BOOT  |
| 2      | Linux Filesystem | Remaining disk space | ROOT  |

Start by listing your available block devices to identify the installation target:

```bash
lsblk
```

I recommend using `cfdisk` because it’s more intuitive:

```bash
sudo cfdisk /dev/nvme0n1
```

Partition the disk as described in the table above. Then, format and label the partitions:

```bash
sudo mkfs.fat -F 32 /dev/nvme0n1p1       # Format EFI partition as FAT32
sudo fatlabel /dev/nvme0n1p1 BOOT        # Label the EFI partition
sudo mkfs.ext4 /dev/nvme0n1p2 -L ROOT    # Format root partition as ext4 and label it
```

Mount the partitions:

```bash
sudo mount /dev/disk/by-label/ROOT /mnt    # Mount root partition
sudo mkdir -p /mnt/boot                    # Create boot directory
sudo mount /dev/disk/by-label/BOOT /mnt/boot # Mount boot partition
```

#### Optional: Create a swap file

If you don’t want a dedicated swap partition, you can create a swap file like this:

```bash
sudo dd if=/dev/zero of=/mnt/.swapfile bs=1M count=2048  # Allocate 2 GB swap file
sudo chmod 600 /mnt/.swapfile                            # Set correct permissions
sudo mkswap /mnt/.swapfile                               # Format as swap
sudo swapon /mnt/.swapfile                               # Enable swap temporarily
```

You can also define this swap file in your configuration, which is the preferred long-term method (explained below).

---

### ❄️ Config Generation and Installation

Generate your base NixOS configuration:

```bash
sudo nixos-generate-config --root /mnt
```

Then edit the generated `configuration.nix`:

```bash
sudo nano /mnt/etc/nixos/configuration.nix
```

Here are some useful additions to make:

```nix
# Keyboard layout
services.xserver.xkb.layout = "us";

# Add a user
users.users.alice = {
  isNormalUser = true;
  description = "Alice";
  extraGroups = [ "wheel" ];  # Grants sudo access
  shell = pkgs.bash;
  home = "/home/alice";
};

# Basic networking setup (replace with your actual config)
# networking.wireless.enable = true;
# networking.networkmanager.enable = true;

# Configure GRUB for UEFI systems
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;

# Optional: Install an editor
environment.systemPackages = with pkgs; [ vim ];  # Or nano, neovim, helix, etc.

# Swap file declaration (if created)
swapDevices = [
  { device = "/.swapfile"; }
];
```

If you used labels during partitioning, consider editing `hardware-configuration.nix` to use those:

```nix
fileSystems."/" = {
  device = "/dev/disk/by-label/ROOT";
  fsType = "ext4";
};

fileSystems."/boot" = {
  device = "/dev/disk/by-label/BOOT";
  fsType = "vfat";
};
```

Once your configuration is ready, install the system:

```bash
cd /mnt
sudo nixos-install
```

---

### ❄️ Reboot and Password Setup

After the installation completes successfully, you'll be asked to enter a new root password, enter the new password for the root user and then:

1. **Reboot:**

   ```bash
   sudo reboot
   ```

2. **Set the root password on first boot:**

   When the system boots into NixOS, log in as `root` and run:

   ```bash
   passwd <your username>
   ```

   This will prompt you to set a user password.

3. **Log in as your user:**

   If you added a user (e.g., `alice`), you can now switch to them:

   ```bash
   su - alice
   ```

---


## Configuration

### ❄️ Tiers of NixOS Usage

I like to classify NixOS usage into four increasing tiers of complexity (though you’re not required to follow them in order):

1. **Base** – Standard configuration using `configuration.nix`
2. **With Home Manager** – User-specific config manager for dotfiles and more
3. **With Flakes** – Declarative, version-pinned systems and reproducible builds
4. **With Home Manager + Flakes** – Fully modular, reproducible, and portable setup

This section focuses on the **Base configuration**, while **Home Manager** and **Flakes** are covered later.

---

### ❄️ Base Configuration

After a fresh install, your configuration is defined in:

```
/etc/nixos/configuration.nix
/etc/nixos/hardware-configuration.nix
```

#### Example: `configuration.nix`

```nix
{ config, pkgs, ... }:

{
  # Import hardware settings from auto-generated file
  imports = [ ./hardware-configuration.nix ];

  # Enable systemd-boot bootloader (for EFI systems)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your hostname (used for networking, prompts, etc.)
  networking.hostName = "nixos";

  # Set system timezone
  time.timeZone = "Asia/Kolkata";

  # Define a normal user named "alice"
  users.users.alice = {
    isNormalUser = true;                     # Not a system/root user
    description = "Alice";                   # Optional description
    extraGroups = [ "wheel" ];               # Grants sudo access
    shell = pkgs.bash;                       # Sets default shell (e.g. bash, zsh)
  };

  # Define system-wide packages available to all users
  environment.systemPackages = with pkgs; [
    wget       # For downloading files
    curl       # HTTP requests
    git        # Version control
    neofetch   # Show system info in terminal
    htop       # Interactive process viewer
  ];

  # Enable X11 (graphical display server)
  services.xserver.enable = true;

  # Enable SDDM (Simple Desktop Display Manager) login screen
  services.xserver.displayManager.sddm.enable = true;

  # Enable KDE Plasma 5 as desktop environment
  services.xserver.desktopManager.plasma5.enable = true;

  # Enable audio support
  sound.enable = true;
  hardware.pulseaudio.enable = true;         # PulseAudio sound server (legacy)

  # Define the version of NixOS you're configuring against
  # Important for compatibility with older or newer modules
  system.stateVersion = "24.05";

  # Declare a swap file (must also exist physically at /.swapfile)
  swapDevices = [
    { device = "/.swapfile"; }
  ];
}
```

#### Example: `hardware-configuration.nix`

```nix
{ config, lib, pkgs, ... }:

{
  # Define the root (/) file system
  fileSystems."/" = {
    device = "/dev/disk/by-label/ROOT";   # Use the device labeled "ROOT"
    fsType = "ext4";                      # Use ext4 filesystem
  };

  # Define the EFI boot partition (/boot)
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";   # Use the device labeled "BOOT"
    fsType = "vfat";                      # FAT32 is required for EFI systems
  };

  # Declare the swap file here (referenced during boot)
  swapDevices = [
    { device = "/.swapfile"; }
  ];

  # This file may also include:
  # - GPU or driver config
  # - File system mount options
  # - Detected hardware modules (e.g. for Wi-Fi, SSDs, etc.)
  # Avoid modifying it unless needed — NixOS regenerates it during config generation.
}

```
The generated config file in your system probably has well put comments as well, so i'd suggest referring them too. For a detailed manual, there's always the wiki, both [**official**](https://nixos.org/manual/nixos/stable/) and [**unofficial**](https://nixos.wiki/) which are written by people much smarter than me.

---

### ❄️ Quick Guide to Nix Package Manager

Here are some basic commands for managing packages on NixOS:

| Task                          | Command                                |
| ----------------------------- | -------------------------------------- |
| Search for a package          | `nix search nixpkgs <name>`            |
| Install a package (user-wide) | `nix-env -iA nixpkgs.<package>`        |
| List user-installed packages  | `nix-env -q`                           |
| Remove a package              | `nix-env -e <package>`                 |
| Upgrade all user packages     | `nix-env -u '*'`                       |
| Run a package temporarily     | `nix run nixpkgs#<package>`            |
| Open a dev shell with deps    | `nix-shell -p <pkg1> <pkg2>`           |
| Clean unused generations      | `sudo nix-collect-garbage -d`          |
| Roll back system config       | `sudo nixos-rebuild switch --rollback` |

> *Note:* With **flakes** (covered later), some of these commands change slightly — they become more declarative and consistent. Official documentation for the Nix ecosystem, maintained by the Nix documentation team can be found at [nix.dev](https://nix.dev/)

---

## The Nix Language

As you may have noticed from the previous section, NixOS relies heavily on the usage of the Nix programming language to write the config files. This section covers a quick guide to the Nix programming language to the extent where you can comfortably read and write your flakes.

> Note: the below guide for the nix language is generated by ChatGPT since i did not have enough time to write this section myself. I'll probably update the content once i do get the time myself.

Nix is a **lazy, functional, and purely declarative** language used to describe system configurations, packages, and environments. It looks a bit like JSON or Haskell, but with its own syntax and semantics.

You don't need to be a Nix wizard to use NixOS — but understanding the basics can help you read, debug, and extend your configurations or flakes.

---

### ❄️ Nix Basics

#### Values and Types

Nix has just a few data types:

| Type      | Example                                            |
| --------- | -------------------------------------------------- |
| Strings   | `"hello"`                                          |
| Integers  | `42`, `0`, `-3`                                    |
| Booleans  | `true`, `false`                                    |
| Lists     | `[ "firefox" "git" "vim" ]`                        |
| Sets      | `{ name = "Alice"; age = 30; }`                    |
| Null      | `null`                                             |
| Functions | `x: x + 1` or `{ name, age }: "${name} is ${age}"` |

---

#### Attribute Sets (like dictionaries or objects)

Most things in Nix are expressed as **attribute sets** (aka key-value maps):

```nix
{
  name = "Alice";
  age = 25;
  isCool = true;
}
```

In a NixOS config, many blocks are just sets of attributes:

```nix
users.users.alice = {
  isNormalUser = true;
  description = "Alice";
  extraGroups = [ "wheel" ];
};
```

---

#### Lists

Lists are ordered sequences of values:

```nix
[ "vim" "git" "firefox" ]
```

You can also write them across lines:

```nix
[
  pkgs.neovim
  pkgs.curl
  pkgs.wget
]
```

---

#### Variables and Let Bindings

```nix
let
  name = "Alice";
in
  "Hello, ${name}!"   # → "Hello, Alice!"
```

You’ll see `let ... in` a lot inside functions or derivations.

---

### ❄️ Functions and Arguments

Nix is **functional**, and many things are functions. For example:

```nix
x: x + 1    # function taking x, returning x + 1
```

Functions can also take **attribute sets** (like named arguments):

```nix
{ name, age }: "${name} is ${age} years old"
```

This is how many modules or flake outputs work.

---

### ❄️ Imports and Modularity

You can split Nix code into multiple files and reuse them:

```nix
import ./my-module.nix
```

Or import a module with arguments:

```nix
import ./something.nix { inherit pkgs; }
```

---

### ❄️ With Expressions

The `with` keyword brings attributes into scope (often used with `pkgs`):

```nix
with pkgs; [
  vim
  htop
  firefox
]
```

It’s convenient, but use sparingly — can reduce readability in large configs.

---

### ❄️ Conditionals

```nix
if builtins.currentSystem == "x86_64-linux" then "x64" else "arm64"
```

Or in options:

```nix
services.xserver.enable = if enableGUI then true else false;
```

---

### ❄️ Built-ins

Nix provides a standard library via `builtins`. Some useful ones:

| Function                 | Description             |
| ------------------------ | ----------------------- |
| `builtins.length list`   | Get list length         |
| `builtins.toString x`    | Convert value to string |
| `builtins.attrNames set` | Get attribute names     |
| `builtins.trace msg val` | Debug print `msg`       |
| `builtins.elem x list`   | Check if x is in list   |

---

### ❄️ Example: Simple Nix Expression

```nix
let
  name = "Alice";
  age = 25;
in
{
  user = "${name}";
  greeting = "Hello, ${name}. You are ${toString age} years old.";
}
```

---

### 📘 Further Learning

If you want to dive deeper into the language:

* [**Nix Pills**](https://nixos.org/guides/nix-pills/) – Practical Nix tutorials
* [**nix.dev**](https://nix.dev/) – Official site for learning modern Nix practices
* [**Cookbook of common Nix patterns**](https://nixos.wiki/wiki/Nix_Cookbook)
* [**Nix reference manual**](https://nixos.org/manual/nix/stable/) – Syntax and semantics

---

## Home Manager

*Coming soon...*

## Flakes

*Coming soon...*

---

