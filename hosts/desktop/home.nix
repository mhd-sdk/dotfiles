{
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # nix-colors.homeManagerModules.default
  ];

  # colorScheme = nix-colors.colorSchemes.nord;

  programs.git = {
    enable = true;
    userName = "mhd";
    userEmail = "mhdi.seddik@gmail.com";
  };

  home = {
    username = "mhd";
    homeDirectory = "/home/mhd";
  };


  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/hypr/hyprland.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/mhd/dev/dotfiles/configs/hyprland/hyprland.conf";
    ".config/kitty/kitty.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/mhd/dev/dotfiles/configs/kitty/kitty.conf";
    ".config/kitty/nord-theme.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/mhd/dev/dotfiles/configs/kitty/nord-theme.conf";
    ".config/waybar/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink "/home/mhd/dev/dotfiles/configs/waybar/config.jsonc";
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
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
  home.sessionVariables = {
    # EDITOR = "emacs";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # add backupfile extension to home-manager

  # Nicely reload system units when changing configs
  # systemd.user.startServices = "sd-switch";
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
  
}
