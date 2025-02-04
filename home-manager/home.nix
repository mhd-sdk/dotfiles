{
  inputs,
  config,
  pkgs,
  nix-colors,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    ./hyprpanel.nix
    ./hyprland.nix
    nix-colors.homeManagerModules.default
  ];

  colorScheme = nix-colors.colorSchemes.nord;

  programs.git = {
    enable = true;
    userName = "mhd";
    userEmail = "mhdi.seddik@gmail.com";
  };

  home = {
    username = "mhd";
    homeDirectory = "/home/mhd";
  };

  # add backupfile extension to home-manager

  # Nicely reload system units when changing configs
  # systemd.user.startServices = "sd-switch";
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";

  
}
