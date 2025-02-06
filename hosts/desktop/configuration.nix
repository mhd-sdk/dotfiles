### MHD's NixOS Configuration

{
  inputs,
  outputs,
  nix-colors,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];



  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      flake-registry = "";
      nix-path = config.nix.nixPath; # Workaround for https://github.com/NixOS/nix/issues/9574
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
  };

  nixpkgs.config.allowUnfree = true;

  ### Bootloader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;  

  ### Aliases
  environment = {
    shellAliases = {
      install-dots = "sh /home/mhd/dev/dotfiles/install.sh";
      nixswitch = "sudo rm -rf /etc/nixos/* && sudo cp /home/mhd/dev/dotfiles/* /etc/nixos -R && sudo nixos-rebuild switch --flake '/etc/nixos#nixos' --show-trace";
      homeswitch = "home-manager switch -b backup --flake '/home/mhd/dev/dotfiles#mhd' --show-trace ";
      logs-home-manager = "journalctl -xe --unit home-manager-mhd";
      waybar-reload= "pkill waybar && hyprctl dispatch exec waybar";
    };
  };

  ### Network.
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  ### Time & language.
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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

  ### Sound (pipewire)
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  ### General system configuration.
  security.polkit.enable = true;
  console.keyMap = "fr";
  services.displayManager.ly.enable = true;
  services.printing.enable = true;
  programs.hyprland.enable = true;

  ### Packages.
  environment.systemPackages = with pkgs; [
    waybar
    hyprpicker
    blueman
    bluez
    cava
    home-manager
    discord
    inputs.swww.packages.${pkgs.system}.swww
    rofi-wayland
    vim
    vscode
    go
    wget
    git
    google-chrome
    kitty
    neofetch
  ]; 
  
  ### Graphics.
  hardware.graphics = {
    # Enable OpenGL
    enable = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  ### Users
  users.users = {
    mhd = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "audio" "docker" ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
