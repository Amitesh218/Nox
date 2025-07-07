{ config, pkgs, ... }:

{
  home.username = "S01";
  home.homeDirectory = "/home/S01";
  home.stateVersion = "25.05";

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Amitesh218";
    userEmail = "amiteshrawal1@gmail.com";
    extraConfig = {
      credential.helper = "libsecret";
      core.editor = "vim";
      init.defaultBranch = "main";
    };
  };

  # Shell configuration
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      la = "ls -la";
      ".." = "cd ..";
      rebuild = "sudo nixos-rebuild switch --flake .";
    };
  };

  # Dotfiles
  xdg.configFile = {
    "waybar/config.jsonc".source = ./dotfiles/waybar/config.jsonc;
    "waybar/style.css".source = ./dotfiles/waybar/style.css;
    "hypr/hyprland.conf".source = ./dotfiles/hypr/hyprland.conf;
    "hypr/hyprlock.conf".source = ./dotfiles/hypr/hyprlock.conf;
    "kitty/kitty.conf".source = ./dotfiles/kitty/kitty.conf;
  };

  # GTK theming
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # Qt theming (for KDE apps)
  qt = {
    enable = true;
    platformTheme.name = "breeze-dark";
    style = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze;
    };
  };

  # Cursor theme
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Enable font configuration
  fonts.fontconfig.enable = true;

  # Home Manager programs management
  programs.home-manager.enable = true;
}