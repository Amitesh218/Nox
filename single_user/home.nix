{ config, pkgs, inputs, ... }:

{
  home.username = "Haze";
  home.homeDirectory = "/home/Haze";
  home.stateVersion = "25.05";

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Amitesh218";
    userEmail = "amiteshrawal1@gmail.com";
    extraConfig = {
      # credential.helper = "libsecret";
      core.editor = "vim";
      init.defaultBranch = "main";
    };
  };

  # Shell configuration
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      eval "$(starship init bash)"
    '';
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

  # Cursor theme
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 18;
    gtk.enable = true;
    x11.enable = true;
  };

  # Enable font configuration
  fonts.fontconfig.enable = true;

  # Home Manager programs management
  programs.home-manager.enable = true;

  # Dotfiles
  xdg.configFile = {
    "waybar/config.jsonc".source = ./dotfiles/waybar/config.jsonc;
    "waybar/style.css".source = ./dotfiles/waybar/style.css;
    "hypr/hyprland.conf".source = ./dotfiles/hypr/hyprland.conf;
    "hypr/hyprlock.conf".source = ./dotfiles/hypr/hyprlock.conf;
    "kitty/kitty.conf".source = ./dotfiles/kitty/kitty.conf;
    "starship.toml".source = ./dotfiles/starship/starship.toml;
    "waypaper/config.ini".source = "./Nox/waypaper/config.ini";
    "rofi/config.rasi".source = "./Nox/rofi/config.rasi";
    "mako/config".source = "./Nox/mako/config";
    ""
  };
}