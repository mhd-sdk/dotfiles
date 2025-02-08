{
  description = "MHD's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    swww.url = "github:LGFae/swww";
    stylix.url = "github:danth/stylix";
    nix-colors.url = "github:misterio77/nix-colors";
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-colors, ags, astal, ... } @ inputs:
  let 
    inherit (self) outputs;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {

    # packages.${system}. default = pkgs.stdenvNoCC.mkDerivation rec {
    #   name = "mhdbar";
    #   src = ./configs/mhd-bar;

    #   nativeBuildInputs = [
    #     ags.packages.${system}.default
    #     pkgs.wrapGAppsHook
    #     pkgs.gobject-introspection
    #   ];

    #   buildInputs = with astal.packages.${system}; [
    #     astal3
    #     io
    #     battery
    #     bluetooth
    #     hyprland
    #     mpris
    #     network
    #     tray
    #     wireplumber
    #     # any other package
    #   ];

    #   installPhase = ''
    #     mkdir -p $out/bin
    #     ags bundle app.ts $out/bin/${name}
    #     chmod +x $out/bin/${name}
    #   '';
    # };

    # Configuration NixOS
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit outputs inputs nix-colors; };
        modules = [ ./hosts/desktop/configuration.nix ];
      };
    };

    # Configuration Home Manager
    homeConfigurations = {
      mhd = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./hosts/desktop/home.nix ];
      };
    };
  };
}
