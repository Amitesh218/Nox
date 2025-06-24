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

*Coming soon...*

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

*Coming soon...*

## The Nix Language

*Coming soon...*

## Home Manager

*Coming soon...*

## Flakes

*Coming soon...*

---

Let me know if you'd like help filling in the other sections or converting this to a `.nix`-based markdown setup for GitHub.
