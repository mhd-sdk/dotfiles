{
  description = "MHD's NixOS configuration";

  inputs = {
    matugen.url = "github:/InioX/Matugen";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    quickshell = {
      # add ?ref=<tag> to track a tag
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";

      # THIS IS IMPORTANT
      # Mismatched system dependencies will lead to crashes and other issues.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    swww.url = "github:LGFae/swww";
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
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland"; # Prevents version mismatch.
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming
    stylix.url = "github:danth/stylix/release-24.11";

  };

  outputs =
    {
      self,
      nixpkgs,
      ags,
      astal,
      stylix,
      nixvim,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system} = {
        default = pkgs.mkShell {
          shellHook = ''
            echo "Entering ags/astal dev shell";
          '';
          buildInputs = [
            pkgs.bashInteractive
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
        quickshell = pkgs.mkShell {
          shellHook = ''
            echo "Entering QuickShell dev shell";
          '';
          buildInputs = [
            inputs.quickshell.packages.${system}.default
            pkgs.kdePackages.full
          ];
          # expose QML modules correctement
          QML_IMPORT_PATH = "${pkgs.kdePackages.full}/lib/qt-6/qml";
          QT_PLUGIN_PATH = "${pkgs.kdePackages.full}/lib/qt-6/plugins";
        };
      };

      # Configuration NixOS
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {

          specialArgs = { inherit outputs inputs; };
          modules = [
            stylix.nixosModules.stylix
            nixvim.nixosModules.nixvim
            ./hosts/desktop/configuration.nix
          ];
        };
      };
    };
}
