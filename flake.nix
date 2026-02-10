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
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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

    # Theming
    stylix.url = "github:danth/stylix/release-24.11";

  };

  outputs =
    {
      self,
      nixpkgs,
      stylix,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
    in
    {
      devShells.${system} = {
        quickshell = pkgs.mkShellNoCC {
          name = "quickshell-devshell";
          shellHook = ''
            export PKG_CONFIG_PATH="${pkgs.libqalculate.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
            export PKG_CONFIG_PATH="${pkgs.vulkan-loader.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
            export PKG_CONFIG_PATH="${pkgs.vulkan-headers}/lib/pkgconfig:$PKG_CONFIG_PATH"
            export PKG_CONFIG_PATH="${pkgs.pipewire.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
            export PKG_CONFIG_PATH="${pkgs.aubio}/lib/pkgconfig:$PKG_CONFIG_PATH"
            export PKG_CONFIG_PATH="${unstable.libcava}/lib/pkgconfig:$PKG_CONFIG_PATH"
            export PKG_CONFIG_PATH="${pkgs.fftw.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
            export PKG_CONFIG_PATH="${pkgs.gmp.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
            export PKG_CONFIG_PATH="${pkgs.mpfr.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
                  
            export CPATH="${pkgs.gmp.dev}/include:${pkgs.fftw.dev}/include:${pkgs.mpfr.dev}/include:$CPATH"
            export C_INCLUDE_PATH="${pkgs.gmp.dev}/include:${pkgs.fftw.dev}/include:${pkgs.mpfr.dev}/include:$C_INCLUDE_PATH"
            export CPLUS_INCLUDE_PATH="${pkgs.gmp.dev}/include:${pkgs.fftw.dev}/include:${pkgs.mpfr.dev}/include:$CPLUS_INCLUDE_PATH"

            export QML_IMPORT_PATH="${unstable.kdePackages.full}/lib/qt-6/qml:$HOME/dev/caelestia/build/qml"
            export QT_PLUGIN_PATH="${unstable.kdePackages.full}/lib/qt-6/plugins"
            export CMAKE_PREFIX_PATH="${unstable.qt6.qtbase}:${unstable.qt6.qtdeclarative}:${unstable.kdePackages.full}"

            echo "Entering QuickShell dev shell"
          '';
          packages = [
            inputs.quickshell.packages.${system}.default
            unstable.qt6.qtbase
            unstable.qt6.wrapQtAppsHook
            unstable.kdePackages.full
            unstable.qt6.qtpositioning

            # dépendances supplémentaires
            pkgs.ddcutil
            pkgs.pkg-config
            pkgs.libqalculate.dev
            pkgs.brightnessctl
            pkgs.mpfr.dev
            unstable.app2unit
            unstable.libcava
            pkgs.fftw.dev
            pkgs.gmp.dev
            pkgs.networkmanager
            pkgs.lm_sensors
            pkgs.fish
            pkgs.aubio
            pkgs.pipewire.dev
            pkgs.glibc
            pkgs.mesa.dev
            pkgs.vulkan-loader
            pkgs.vulkan-headers
            unstable.qt6.qtdeclarative
            unstable.material-symbols
            pkgs.swappy
            pkgs.bash
          ];

        };
      };

      # Configuration NixOS
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit outputs inputs; };
          modules = [
            stylix.nixosModules.stylix
            ./hosts/desktop/configuration.nix
          ];
        };
      };
    };
}
