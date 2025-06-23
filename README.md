# Getting started with NixOS

## Table of Contents:

- [Introduction](##Introduction)
- [Installation](#Installation)
- [Configuration](#Configuration)
- [The Nix language](#The-Nix-language)
- [Home Manager](#Home-Manager)
- [Flakes](#Flakes)

## Introduction


## Installation

Steps for installation can be categorized into:

- Preparation
- Ensuring an Internet connection
- Disk Partitioning and mounting
- Config generation
- Finishing 

As usual with installation for any other operating system, obtain the iso image for the installer from the [**official website**](https://nixos.org/download/). The graphical installer includes a calamares installer for a faster, non-manual install.

For manual installation, detailed (and actually pretty well written) instructtions are available in the [official](https://nixos.org/manual/nixos/stable/index.html#ch-installation) as well as [unofficial](https://nixos.wiki/wiki/NixOS_Installation_Guide) wikis.

Side Note: Manual installation is fairly easier compared to 

A quick guide to how i manually install is as follows:

- Boot into the live iso via a bootable usb drive, or a ventoy drive (my preferred method)

- Upon successful booting, you will be logged in as the user nixos, which usually has no password. Since the installation requires elevated privileges, you could proceed with the nixos user and use `sudo` whenever needed, or switch to root via the `sudo -i` command.

## Configuration

## The Nix language

## Home Manager

## Flakes


