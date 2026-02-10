{
  inputs,
  lib,
  config,
  pkgs,
  pkgsUnstable,
  ...
}:
{
  # Import hardware configuration
  imports = [
    ./hardware-configuration.nix
    inputs.spicetify-nix.nixosModules.spicetify
    inputs.home-manager.nixosModules.home-manager
  ];

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
      channel.enable = false; # Disable channels for pure flake usage
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
  home-manager.useGlobalPkgs = true;

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
    # -- Build tools --
    cmake
    gcc
    gnumake
    meson
    ninja

    # -- System libraries --
    aubio
    cpio
    gtk3
    gtk4
    libGL
    libpcap
    libqalculate
    mesa
    openssl

    # -- CLI utilities --
    fd
    htop
    jq
    killall
    lynx
    ripgrep
    tree
    unzip
    wget
    zoxide

    # -- Dev runtimes & tools --
    bun
    go
    gopls
    lua
    lua-language-server
    nil
    nixd
    nixfmt-rfc-style
    nodejs_23
    pnpm_9
    python3
    python313Packages.pip
    python312Packages.python-lsp-server
    stylua
    terser
    typescript-language-server
    vscode-langservers-extracted
    yarn

    # -- Git & version control --
    git
    gh
    gitmoji-cli

    # -- Hyprland & Wayland --
    cliphist
    hyprcursor
    hyprpaper
    hyprpicker
    hyprshot
    matugen
    pavucontrol
    swww
    tofi
    waybar
    wl-clipboard

    # -- System services --
    bluez
    bluez-tools
    cava
    ddcutil
    docker
    kubectl
    postgresql
    starship
    upower

    # -- Theming --
    gnome-themes-extra
    lxappearance
    materia-theme
    papirus-icon-theme

    # -- Nix tooling --
    home-manager

    # -- Desktop environment --
    kdePackages.full
    inputs.quickshell.packages.${pkgs.system}.default
    xterm

    # -- Shell --
    tmux
    vim
    neovim
    fastfetch
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
    extraSpecialArgs = { inherit inputs pkgsUnstable; };
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
    ];
  };

  ## System Version
  system.stateVersion = "24.11"; # Installed NixOS version
}
