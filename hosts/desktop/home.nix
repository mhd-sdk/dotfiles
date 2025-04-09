{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
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

  home = {
    username = "mhd";
    homeDirectory = "/home/mhd";
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".ssh/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/ssh/config";    
    ".config/hypr/hyprland.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/hypr/hyprland.conf";
    ".config/hypr/hyprpaper.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/hypr/hyprpaper.conf";
    ".config/waybar".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/waybar";
    ".config/tofi/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/tofi/config";
    ".config/kitty/kitty-symlinked.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/kitty/kitty-symlinked.conf";
    ".config/starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/starship/starship.toml";
    ".config/nvim/".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/nvim/";
    ".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/tmux/tmux.conf";
    ".dircolors".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/.dircolors";
  };

  programs.kitty = {
    enable = true;
    extraConfig = ''
      include kitty-symlinked.conf
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
    };
  };
  home.sessionPath = [
    "$HOME/go/bin"
  ];

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
  home.stateVersion = "23.05";
}
