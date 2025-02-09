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
    mithril-shell.url = "github:andreashgk/mithril-shell";
  };

  outputs = { self, nixpkgs, home-manager, nix-colors, ags, astal, mithril-shell, ... } @ inputs:
  let 
    inherit (self) outputs;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {

    packages.${system}.default = ags.lib.bundle { 
      inherit pkgs;
      src = ./configs/statusbar;
      name = "statusbar"; # name of executable
      entry = "app.tsx";
      gtk4 = false;

      # additional libraries and executables to add to gjs' runtime
      extraPackages = [
        ags.packages.${system}.battery
        ags.packages.${system}.astal3
        ags.packages.${system}.bluetooth
        ags.packages.${system}.hyprland
        ags.packages.${system}.mpris
        ags.packages.${system}.network
        ags.packages.${system}.tray
        ags.packages.${system}.io
        ags.packages.${system}.wireplumber
        ags.packages.${system}.cava
        # pkgs.fzf
      ];
    };
    devShells.${system} = {
      default = pkgs.mkShell {
        shellHook = ''
        echo "Entering ags/astal dev shell";
        '';
        buildInputs = [
          # includes astal3 astal4 astal-io by default
          (ags.packages.${system}.default.override {
            extraPackages = [
              ags.packages.${system}.battery
              ags.packages.${system}.astal3
              ags.packages.${system}.bluetooth
              ags.packages.${system}.hyprland
              ags.packages.${system}.mpris
              ags.packages.${system}.network
              ags.packages.${system}.tray
              ags.packages.${system}.io
              ags.packages.${system}.wireplumber
              ags.packages.${system}.cava
              astal.packages.${system}.default
            ];
          })
        ];
      };
    };

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
        modules = [ 
          mithril-shell.homeManagerModules.default
          ./hosts/desktop/home.nix
        ];
      };
    };
  };
}
