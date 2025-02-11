{
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [

  ];

  gtk = {
    enable = true;
    cursorTheme.package = pkgs.bibata-cursors;
    cursorTheme.name = "Bibata-Modern-Classic";

    # theme = {
    #   package = pkgs.flat-remix-gtk;
    #   name = "Flat-Remix-GTK-Grey-Darkest";
    # };
    theme = {
      package = pkgs.magnetic-catppuccin-gtk;
      name = "Catppuccin-GTK-Dark";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "roboto";
      size = 11;
    };
  };

  qt = {
    enable = true;
  };

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
    ".config/kitty/black-clover.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/mhd/dev/dotfiles/configs/kitty/black-clover.conf";
    ".config/waybar/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink "/home/mhd/dev/dotfiles/configs/waybar/config.jsonc";
    ".config/waybar/style.css".source = config.lib.file.mkOutOfStoreSymlink "/home/mhd/dev/dotfiles/configs/waybar/style.css";
    ".config/tofi/config".source = config.lib.file.mkOutOfStoreSymlink "/home/mhd/dev/dotfiles/configs/tofi/config";
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

  programs.kitty.themeFile = "Catppuccin-Mocha";

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

  home.sessionPath = [
    "$HOME/go/bin"
  ];

  # idk why but if disabled, copy paste between vscode and chrome is broken 
  programs.bash.enable = true;
  programs.fish.enable = false;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
  
}
