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
    ".config/hypr/hyprland.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/hyprland/hyprland.conf";
    ".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/tmux/tmux.conf";
    ".config/tofi/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/tofi/config";
    ".config/kitty/kitty-symlinked.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/kitty/kitty-symlinked.conf";
    ".config/starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/starship/starship.toml";
    ".config/nvim/".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/dotfiles/configs/nvim/";
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


  services.hyprpaper =  {
    enable = true;
    settings = {
      preload = [
       "../../assets/math.png"
      ];
    };
  };


  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/mhd/etc/profile.d/hm-session-vars.sh
  #
  # home.sessionVariables = {
  #   ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  # };  

  home.sessionPath = [
    "$HOME/go/bin"
  ];

  programs.bash = {
    enable = true;
  };
  
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
