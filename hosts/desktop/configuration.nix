{
  inputs,
  lib,
  config,
  pkgs,
  pkgsUnstable,
  ...
}:
let
in
# mhdshell = pkgs.callPackage ../../../mhdshell/nix/default.nix { };
{
  # Import hardware configuration
  imports = [
    ./hardware-configuration.nix
    inputs.spicetify-nix.nixosModules.spicetify
    inputs.home-manager.nixosModules.home-manager
  ];

  # systemd.services.mhdshell = {
  #   description = "mhd's shell";
  #   wantedBy = [ "graphical-session.target" ];
  #   partOf = [ "graphical-session.target" ];
  #   after = [ "graphical-session.target" ];
  #
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = "${mhdshell}/bin/mhdshell";
  #     Restart = "on-failure";
  #     RestartSec = "5s";
  #   };
  #
  #   environment = {
  #     QT_QPA_PLATFORM = "wayland";
  #     # Ajoute d'autres variables si nécessaire
  #   };
  # };
  ## Nix
  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;

    in
    {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        flake-registry = "";
        nix-path = config.nix.nixPath; # Workaround for a known bug
      };
      channel.enable = true; # Disable channels for pure flake usage
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    };

  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"

    # Rules for Oryx web flashing and live training
    KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

    # Legacy rules for live training over webusb (Not needed for firmware v21+)
    # Rule for all ZSA keyboards
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
    # Rule for the Moonlander
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
    # Rule for the Ergodox EZ
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
    # Rule for the Planck EZ
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

    # Wally Flashing rules for the Ergodox EZ
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

    # Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
    # Keymapp Flashing rules for the Voyager
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
  '';

  programs.spicetify = {
    enable = true;
    enabledExtensions = with inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system}.extensions; [
      adblockify
      hidePodcasts
      shuffle # shuffle+ (special characters are sanitized out of extension names)
    ];
  };

  # Allow non-free packages
  nixpkgs.config.allowUnfree = true;



  home-manager.backupFileExtension = "backup";

  ## Bootloader & EFI
  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
    };
  };
  qt.enable = true;

  ## Shell Aliases
  environment.shellAliases = {
    install-dots = "sh /home/mhd/dev/dotfiles/install.sh";
    nixswitch = "sudo rm -rf /etc/nixos/* && sudo cp /home/mhd/dev/dotfiles/* /etc/nixos -R && sudo nixos-rebuild switch --flake '/etc/nixos#nixos' --show-trace";
    clearTofi = "rm -rf /home/mhd/.cache/tofi-drun";
    logs-home-manager = "journalctl -xe --unit home-manager-mhd";
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  ## Network & Shell
  networking = {
    hostName = "NixOS_MHD";
    networkmanager.enable = true;
  };

  ## Language & Time
  time.timeZone = "Europe/Paris";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };
  };

  environment.variables.LIBVA_DRIVER_NAME = "nvidia";

  ## Sound (Pipewire)
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ## General Configuration
  security.polkit.enable = true;
  console.keyMap = "us";
  services.displayManager.ly.enable = true;

  services.upower.enable = true;

  services.printing.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = false; # recommended for most users
    xwayland.enable = true; # Xwayland can be disabled.
  };

  # this allows you to access `pkgsUnstable` anywhere in your config
  _module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };

  ## System Packages
  environment.systemPackages = with pkgs; [
    cmake
    meson
    cpio
    gtk3
    gtk4
    aubio
    openssl
    lxappearance
    gnome-themes-extra
    materia-theme
    papirus-icon-theme
    hyprpicker
    bluez
    bluez-tools
    cava
    home-manager
    discord
    matugen
    hyprcursor
    hyprshot
    vim
    tofi
    pavucontrol
    vscode
    go
    libqalculate
    gopls
    mesa
    wget
    git
    gh
    pkgsUnstable.google-chrome
    vscode-langservers-extracted
    neofetch
    pkgsUnstable.nerd-fonts.monaspace
    pkgsUnstable.nerd-fonts.caskaydia-cove
    pkgsUnstable.nerd-fonts.hack
    pkgsUnstable.nerd-fonts.bigblue-terminal
    # terminus_font_ttf
    terminus_font
    slack
    monocraft
    departure-mono
    spotify
    lua
    upower
    neovim
    lua-language-server
    spotify
    cliphist
    wl-clipboard
    pkgsUnstable.obs-studio
    htop
    hyprpaper
    gcc
    cmake
    ninja
    libGL
    mesa
    fd
    nodejs_23
    yarn
    pnpm_9
    unzip
    tree
    vlc
    docker
    stylua
    pkgsUnstable.code-cursor
    libpcap
    pinta
    nixfmt-rfc-style
    typescript-language-server
    ripgrep
    simple-scan
    brlaser
    lynx
    firefox
    terser
    gnumake
    firefox-devedition
    starship
    tmux
    bun
    gitmoji-cli
    kdePackages.full
    postman
    waybar
    ddcutil
    kubectl
    python3
    python313Packages.pip
    python312Packages.python-lsp-server
    nil
    swww
    material-symbols
    nixd
    dolphin
    kitty
    inputs.quickshell.packages.${pkgs.system}.default
    xterm
    nautilus
    zoxide
    killall
    jq
    pkgsUnstable.codex
    proggyfonts
    postgresql
  ];

  hardware.i2c.enable = true;
  boot.kernelModules = [ "i2c-dev" ];

  virtualisation.docker.enable = true;
  ## Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  ## File Manager
  programs.thunar.enable = true;

  ## Graphics & NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # This will no longer be necessary when
    # https://github.com/NixOS/nixpkgs/pull/326369 hits stable
    modesetting.enable = lib.mkDefault true;
    # Power management is nearly always required to get nvidia GPUs to
    # behave on suspend, due to firmware bugs.
    powerManagement.enable = false;
    nvidiaSettings = true;

    # The open driver is recommended by nvidia now, see
    # https://download.nvidia.com/XFree86/Linux-x86_64/565.77/README/kernel_open.html
    open = true;
  };

  hardware.graphics = {
    enable = true;
  };

  users.groups.plugdev = { };
  users.groups.docker = { };

  ## Users
  users.users.mhd = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "docker"
      "plugdev"
      "i2c"
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      mhd = import ./home.nix;
    };
  };

  fonts.packages = with pkgs; [
    departure-mono
    pkgsUnstable.nerd-fonts.monaspace
    pkgsUnstable.nerd-fonts.hack
    pkgsUnstable.nerd-fonts.bigblue-terminal
    pkgsUnstable.nerd-fonts.caskaydia-cove
    material-symbols
    rubik
    monocraft
    proggyfonts
    terminus_font
  ];

  # stylix = {
  #   enable = false;
  #   image = ../../assets/asta_annonce.jpg;
  #   polarity = "dark";
  #   # override = {
  #   #   base00 = "000000";
  #   # };
  #   # base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
  #   cursor.name = "Bibata-Modern-Classic";
  #   cursor.package = pkgs.bibata-cursors;
  #   cursor.size = 24;
  #   fonts = {
  #     monospace = {
  #       package = pkgsUnstable.nerd-fonts.monaspace;
  #       name = "Monaspicear nerd font";
  #     };
  #     # monospace = {
  #     #   package = pkgs.departure-mono;
  #     #   name = "DepartureMono";
  #     # };
  #     serif = config.stylix.fonts.monospace;
  #     sansSerif = config.stylix.fonts.monospace;
  #     emoji = config.stylix.fonts.monospace;
  #   };
  # };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      curl
      dbus
      expat
      fontconfig
      freetype
      fuse3
      gdk-pixbuf
      glib
      gtk3
      icu
      libGL
      libappindicator-gtk3
      libdrm
      libglvnd
      libnotify
      libpulseaudio
      libunwind
      libusb1
      libuuid
      libxkbcommon
      libxml2
      mesa
      nspr
      nss
      openssl
      pango
      pipewire
      stdenv.cc.cc
      systemd
      vulkan-loader
      xorg.libX11
      xorg.libXScrnSaver
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      xorg.libxcb
      xorg.libxkbfile
      xorg.libxshmfence
      zlib
      eslint
      eslint_d
    ];
  };

  ## System Version
  system.stateVersion = "24.11"; # Installed NixOS version
}
