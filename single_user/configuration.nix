# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot configuration
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;  # Keep only last 10 generations
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # System configuration
  networking = {
    hostName = "Nyx";
    networkmanager.enable = true;
  };

  time.timeZone = "Asia/Kolkata";

  # Nix configuration
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  # Hardware services
  services = {
    xserver.xkb.layout = "us";
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    libinput.enable = true;
    power-profiles-daemon.enable = true;
    dbus.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
  };

  security.polkit.enable = true;

  # User configuration
  users.users.S01 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # Programs
  programs = {
    firefox.enable = true;
    hyprland.enable = true;
    chromium.enable = true;
    steam.enable = true;
    nix-ld.enable = true;  # Compatibility shim for running fhs needy installers like precompiled .sh installers
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim
    wget
    git
    
    # Desktop environment
    kitty
    rofi-wayland
    waybar
    polkit_gnome
    swww
    hyprlock
    waypaper
    chromium
    mako
    libnotify
    obs-studio
    spotify
    pavucontrol
    steam-run
    playerctl

    # File management
    xfce.thunar
    xfce.thunar-volman
    xfce.tumbler
    gvfs
    
    # System utilities
    brightnessctl
    hyprsunset
    grim
    slurp
    fastfetch
    btop
    starship

    # Themes and cursors
    adwaita-icon-theme
    gnome-themes-extra
    bibata-cursors
    qt6.qtwayland
    
    ############################################################
    # Core development tools
    vscode
    gcc
    gnumake
    cmake
    binutils
    pkg-config
    automake
    autoconf
    libtool
    gdb

    # Common build tools & scripting
    python3
    perl
    bison
    flex
    gettext
    which
    file
    patch
    xz
    unzip
    zip
    git

    # Optional: C++ tooling
    clang
    lldb
    lld
    ccache
    bear        # For generating compile_commands.json
    valgrind

    # Optional: Misc utils
    man-pages
    man-db
    strace
    lsof
    ############################################################
  ];

  # Environment variables
  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qtct";      # Or "qt5ct" if using qt5ct instead
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      inter
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      fira-code
      nerd-fonts.fira-code
      jetbrains-mono
      nerd-fonts.jetbrains-mono
    ];
    
    fontconfig.defaultFonts = {
      sansSerif = [ "Inter" "Noto Sans" ];
      serif = [ "Noto Serif" ];
      monospace = [ "Fira Code Nerd Font" "JetBrains Mono" ];
    };
  };

  system.stateVersion = "25.05";
}