{ config, pkgs, ... }:

{
  # Required: your username and home path
  home.username = "S01";
  home.homeDirectory = "/home/S01";

  # Optional programs and configs (NO packages here)
  programs.zsh = {
    enable = true;
    oh-my-zsh.enable = true;
    oh-my-zsh.theme = "agnoster";  # Example theme
  };

  programs.git = {
    enable = true;
    userName = "Amitesh218";
    userEmail = "amiteshrawal1@gmail.com";
    extraConfig = {
      core.editor = "vim";
    };
  };

  # Example of copying a config file (like waybar styling)
  xdg.configFile."waybar/config".source = ../../dotfiles/waybar/config;
  xdg.configFile."waybar/style.css".source = ../../dotfiles/waybar/style.css;

  # Optionally enable GTK theming
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
  };

  # Fonts (for GTK apps, terminal, etc.)
  fonts.fontconfig.enable = true;

  # Don't forget this
  home.stateVersion = "25.05"; # Match your NixOS version
}
