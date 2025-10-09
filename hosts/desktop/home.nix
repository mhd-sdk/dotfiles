{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # You can import other home-manager modules here
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  fonts.fontconfig.enable = true;

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
    ".config/kitty/kitty-symlinked.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/kitty/kitty-symlinked.conf";
    # ".config/starship.toml".source =
    #   config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/starship/starship.toml";
    ".config/nvim/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/nvim/";
    ".config/matugen/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/matugen/";
    # ".tmux.conf".source =
    # config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/tmux/tmux.conf";
    ".dircolors".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/.dircolors";
  };

  programs.kitty = {
    enable = true;
    extraConfig = ''
      include kitty-symlinked.conf
    '';
  };

  stylix.targets.tmux.enable = false;

  home.sessionPath = [
    "$HOME/go/bin"
  ];

  programs.tmux = {
    enable = true;
    extraConfig = ''
            set -g mouse on
            set -g history-limit 10000
            set -g status-interval 5
            set -g status-right-length 50
            set -g status-left-length 50
            setw -g mode-keys vi 
            set-window-option -g mode-keys vi

            # Couleur de la barre de statut
            set -g status-bg "#3b4252"
            set -g status-fg white
            set -g status-right-length 120

            # Format des fenêtres (onglets)
            set -g window-status-format " #I:#W "
            set -g window-status-current-format " #I:#W "

            # Style des fenêtres inactives
            set -g window-status-style fg=colour244,bg=#3b4252

            # Style de la fenêtre active
            set -g window-status-current-style fg=white,bg=#5e81ac

      set -g status-left ""
            # Position du status
      set -g status-right ""
      set -sg escape-time 10
      # Copier avec y et coller avec p
      bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "xclip -selection clipboard -in"

    '';
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      # if command -v tmux &> /dev/null; then
      #   if [ -z "$TMUX" ]; then
      #     tmux new-session
      #   fi
      # fi
      eval "$(dircolors -b ~/.dircolors)"

    '';
    bashrcExtra = ''
      export EDITOR="nvim"
      export VISUAL="nvim"
      if [ -f "$HOME/.bashrc.secrets" ]; then
        source "$HOME/.bashrc.secrets"
      fi
    '';
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
