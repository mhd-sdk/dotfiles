{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # Import hardware configuration
  imports = [
    ./hardware-configuration.nix
    inputs.spicetify-nix.nixosModules.spicetify
    inputs.home-manager.nixosModules.home-manager
  ];

  ## Nix
  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      flake-registry = "";
      nix-path = config.nix.nixPath; # Workaround for a known bug
    };
    channel.enable = false; # Disable channels for pure flake usage
    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;

  };


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
    homeswitch = "home-manager switch -b backup --flake '/home/mhd/dev/dotfiles#mhd' --show-trace ";
    logs-home-manager = "journalctl -xe --unit home-manager-mhd";
    waybar-reload = "pkill waybar && hyprctl dispatch exec waybar";
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

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
  console.keyMap = "fr";
  services.displayManager.ly.enable = true;
  services.printing.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = false; # recommended for most users
    xwayland.enable = true; # Xwayland can be disabled.
  };

  ## System Packages
  environment.systemPackages = with pkgs; [
    gtk3 gtk4 lxappearance gnome-themes-extra materia-theme papirus-icon-theme
    hyprpicker bluez bluez-tools cava home-manager discord
    inputs.swww.packages.${pkgs.system}.swww
    outputs.packages.${system}.default
    inputs.astal.packages.${system}.default
    hyprcursor hyprshot vim tofi pavucontrol vscode
    go gopls wget git gh google-chrome neofetch
    nerdfonts departure-mono spotify lua neovim lua-language-server
    spotify cliphist wl-clipboard obs-studio
    hyprpaper gcc fd nodejs_23 yarn pnpm_9 unzip
    tree
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
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  ## Users
  users.users.mhd = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "audio" "docker" ];
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
    image = ../../assets/math.png;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Classic";
    targets.kitty.enable = false;
    fonts = {
      monospace = {
        package = pkgs.nerdfonts;
        name = "JetBrains Mono Nerd Font";
      };
      serif = config.stylix.fonts.monospace;
      sansSerif = config.stylix.fonts.monospace;
      emoji = config.stylix.fonts.monospace;
    };
  };
  
  ## System Version
  system.stateVersion = "24.11"; # Installed NixOS version
}
