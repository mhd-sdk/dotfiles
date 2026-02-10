{
  config,
  pkgs,
  pkgsUnstable,
  inputs,
  lib,
  ...
}:
{
  fonts.fontconfig.enable = true;

  ## User Packages (apps utilisateur)
  home.packages = with pkgs; [
    discord
    dolphin
    (lib.lowPrio firefox)
    firefox-devedition
    kitty
    nautilus
    pinta
    pkgsUnstable.code-cursor
    pkgsUnstable.codex
    pkgsUnstable.google-chrome
    pkgsUnstable.obs-studio
    postman
    simple-scan
    brlaser
    slack
    vlc
    vscode
  ];


  programs.git = {
    enable = true;
    userName = "mhd";
    userEmail = "mhdi.seddik@gmail.com";
  };


  programs.starship.enable = true;

  home = {
    username = "mhd";
    homeDirectory = "/home/mhd";

  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".ssh/config".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/ssh/config";
    ".config/hypr/hyprland.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/hypr/hyprland.conf";
    ".config/hypr/hyprpaper.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/hypr/hyprpaper.conf";
    ".config/waybar".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/waybar";
    ".config/tofi/config".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/tofi/config";
    ".config/kitty/kitty.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/kitty/kitty.conf";
    ".config/starship.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/starship/starship.toml";
    ".config/nvim/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/nvim/";
    ".config/matugen/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/matugen/";
    ".dircolors".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/.dircolors";
  };

  # home.sessionPath = [
  #   "${config.home.homeDirectory}/go/bin"
  #   "${config.home.homeDirectory}/.local/bin"
  # ];
  home.sessionVariables = {
  PATH = "$HOME/.local/bin:$HOME/go/bin:$PATH";
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      [ -f "$HOME/dev/dotfiles/configs/bash/bashrc" ] && source "$HOME/dev/dotfiles/configs/bash/bashrc"
    '';
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
