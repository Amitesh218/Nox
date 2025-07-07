{ config, pkgs, ... }:

{
  # Required: your username and home path
  home.username = "S01";
  home.homeDirectory = "/home/S01";

  # Optional programs and configs (NO packages here)

  programs.git = {
    enable = true;
    userName = "Amitesh218";
    userEmail = "amiteshrawal1@gmail.com";
    extraConfig = {
      credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
      core.editor = "vim";
    };
  };

  # Example of copying a config file (like waybar styling)
  xdg.configFile."waybar/config.jsonc".source = ../dotfiles/S01/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ../dotfiles/S01/waybar/style.css;
  xdg.configFile."hypr/hyprland.conf".source = ../dotfiles/S01/hypr/hyprland.conf;

  # Optionally enable GTK theming
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # Fonts (for GTK apps, terminal, etc.)
  fonts.fontconfig.enable = true;

  # Don't forget this
  home.stateVersion = "25.05"; # Match your NixOS version
}
