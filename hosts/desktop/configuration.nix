{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
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
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"# Rules for Oryx web flashing and live training
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

  ## Shell Aliases
  environment.shellAliases = {
    install-dots = "sh /home/mhd/dev/dotfiles/install.sh";
    nixswitch = "sudo rm -rf /etc/nixos/* && sudo cp /home/mhd/dev/dotfiles/* /etc/nixos -R && sudo nixos-rebuild switch --flake '/etc/nixos#nixos' --show-trace";
    clearTofi = "rm -rf /home/mhd/.cache/tofi-drun";
    logs-home-manager = "journalctl -xe --unit home-manager-mhd";
    waybar-reload = "pkill waybar && hyprctl dispatch exec waybar";
  };

  # environment.sessionVariables.NIXOS_OZONE_WL = "1";

  ## Network & Shell
  networking = {
    hostName = "nixos";
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
  services.displayManager.ly.settings = {
    animation = "matrix";
  };

  services.printing.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = false; # recommended for most users
    xwayland.enable = true; # Xwayland can be disabled.
  };

  ## System Packages
  environment.systemPackages = with pkgs; [
    gtk3
    gtk4
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
    inputs.swww.packages.${pkgs.system}.swww
    outputs.packages.${system}.default
    inputs.astal.packages.${system}.default
    hyprcursor
    hyprshot
    vim
    tofi
    pavucontrol
    vscode
    go
    gopls
    wget
    git
    gh
    chromium
    google-chrome
    vscode-langservers-extracted
    neofetch
    nerdfonts
    departure-mono
    spotify
    lua
    neovim
    lua-language-server
    spotify
    cliphist
    wl-clipboard
    obs-studio
    hyprpaper
    gcc
    fd
    nodejs_23
    yarn
    pnpm_9
    unzip
    tree
    vlc
    docker
    code-cursor
    pinta
    nixfmt-rfc-style
    typescript-language-server
    ripgrep
    simple-scan
    brlaser
    lynx
    firefox
    terser
    nodePackages.rollup
    gnumake
    firefox-devedition
    http-server
  ];

  ## Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  ## File Manager
  programs.thunar.enable = true;

  ## Graphics & NVIDIA
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
  hardware.opengl.enable = true;

  users.groups.plugdev = {};
  users.groups.docker = {};

  ## Users
  users.users.mhd = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "docker"
      "plugdev"
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
  ];

  stylix = {
    enable = true;
    image = ../../assets/wallpaper.png;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Classic";
    fonts = {
      monospace = {
        package = pkgs.nerdfonts;
        name = "JetBrains Mono Nerd Font";
      };
      # monospace = {
      #   package = pkgs.departure-mono;
      #   name = "DepartureMono";
      # };
      serif = config.stylix.fonts.monospace;
      sansSerif = config.stylix.fonts.monospace;
      emoji = config.stylix.fonts.monospace;
    };
  };
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
    ];
  };

  ## System Version
  system.stateVersion = "24.11"; # Installed NixOS version
}
