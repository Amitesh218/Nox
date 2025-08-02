{ config, lib, pkgs, ... }:

{
  imports =
  [
    ./hardware-configuration.nix
  ];

  ############################
  ##   Boot configuration   ##
  ############################

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest; # Use latest kernel.

  # Networking
  networking.hostName = "Nyx";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  time.timeZone = "Asia/Kolkata";

  ##########################
  ##   Users , Services   ##
  ##########################

  users.users.Haze = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" "pipewire"];
  };

  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    xserver.xkb.layout = "us";
    libinput.enable = true;  # Enable touchpad support.
    power-profiles-daemon.enable = true;
    dbus.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    blueman.enable = true;
    gnome.gnome-keyring.enable = true;
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  security.polkit.enable = true;


  #############################
  ##   SYSTEMWIDE PACKAGES   ##
  #############################

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  programs.firefox.enable = true;
  programs.hyprland.enable = true;
  programs.chromium.enable = true;
  # programs.steam.enable = true; # steam was being funky so fuck it we ball.

  environment.systemPackages = with pkgs; [
    # Hyprland packages
    hyprsunset lxqt.lxqt-policykit hyprlock swww rofi-wayland
    waypaper playerctl pulseaudio brightnessctl waybar
    mako pavucontrol gnome-keyring clipman rofimoji
    
    # System Tools
    vim wget kitty git
    libnotify grim slurp fastfetch
    btop starship gvfs iw
    
    # Apps
    chromium obs-studio spotify vscode
    xfce.thunar xfce.thunar-volman xfce.tumbler
    localsend

    # Themes
    adwaita-icon-theme gnome-themes-extra
    bibata-cursors 

    # Utilities
    unzip
  ];


  ###########################
  ##   Nix configuration   ##
  ###########################

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 7d";

  nixpkgs.config.allowUnfree = true;

  ## Fonts
  fonts = {
    packages = with pkgs; [
      inter
      inconsolata
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      fira-code
      nerd-fonts.fira-code
      recursive
      nerd-fonts.recursive-mono
      font-awesome
    ];

    fontconfig.defaultFonts = {
      sansSerif = [ "Inter" "Noto Sans" ];
      serif = [ "Noto Serif" ];
      monospace = [ "Fira Code Nerd Font" "JetBrains Mono" ];
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  ######################################################
  ###   Extra comments for future enhancements (?)   ###
  ######################################################

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;



  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

