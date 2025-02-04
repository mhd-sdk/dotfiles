{
  description = "MHD's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    swww.url = "github:LGFae/swww";
    stylix.url = "github:danth/stylix";
    nix-colors.url = "github:misterio77/nix-colors";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-colors, ...  } @ inputs:
  let 
    inherit (self) outputs;
    system = "x86_64-linux";

  in {

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#nixos'
    
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs; inherit nix-colors;};
        modules = [ 
          ./hosts/desktop/configuration.nix
        ];
      };
    };

    # Home Manager configuration entrypoint
    # Available through 'home-manager --flake .#mhd switch'
    homeConfigurations = {
      mhd = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ 
          ./hosts/desktop/home.nix
          inputs.stylix.nixosModules.stylix
        ];
      };
    };
    
  };

  
}
