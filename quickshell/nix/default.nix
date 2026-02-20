{ pkgs, quickshell, ... }:

pkgs.stdenv.mkDerivation {
  pname = "mhdshell";
  version = "0.1.1";

  # On prend le projet sans nettoyage
  src = ../.;

  nativeBuildInputs = [ pkgs.qt6.wrapQtAppsHook pkgs.tree ];
  buildInputs = [ quickshell pkgs.qt6.qtbase pkgs.qt6.qtdeclarative ];

  installPhase = ''
    rm -rf $out
    mkdir -p $out/share/quickshell
    # Copier tout y compris fichiers .gitignore, .qml, etc.
    cp -r $src/. $out/share/quickshell/
    tree $src

    mkdir -p $out/bin
    cat > $out/bin/mhdshell <<EOF
    #!${pkgs.bash}/bin/bash
    export QML_IMPORT_PATH="${pkgs.kdePackages.full}/lib/qt-6/qml:/home/mhd/dev/caelestia/build/qml"
    export QT_PLUGIN_PATH="${pkgs.kdePackages.full}/lib/qt-6/plugins"
    export PATH="$PATH:${pkgs.qt6.wrapQtAppsHook}/bin"

    exec ${quickshell}/bin/quickshell -p \$out/share/quickshell/
    EOF
    chmod +x $out/bin/mhdshell
  '';

  meta = {
    description = "mhd's shell using Quickshell";
    license = pkgs.lib.licenses.mit;
  };
}
