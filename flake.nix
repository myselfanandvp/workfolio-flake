{
  description = "Nix Flake for Workfolio";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "workfolio";
        version = "1.0.0";

        src = pkgs.fetchurl {
          url = "https://workfolio-public.s3.ap-south-1.amazonaws.com/Workfolio+Setup.deb"; # Keep your real URL/local path here
          sha256 = "sha256-dtXP4dyccwP7R1/WcKI4J5+zXA8+wPiE7z5Q6sjrDn8=";
        };

        nativeBuildInputs = with pkgs; [
          dpkg
          autoPatchelfHook
        ];

        # All standard runtime dependencies required by Electron / Chromium apps:
        buildInputs = with pkgs; [
          stdenv.cc.cc.lib
          zlib
          glib
          gtk3
          cairo
          pango
          atk
          gdk-pixbuf
          cups
          dbus
          expat
          fontconfig
          freetype
          libdrm
          libxkbcommon
          mesa
          alsa-lib
          systemd
          at-spi2-core
          libX11
          libXcomposite
          libXcursor
          libXdamage
          libXext
          libXfixes
          libXrandr
          libXrender
          libXScrnSaver
          libXtst
          libxcb
          nspr
          nss
          libnss_nis
        ];

        unpackPhase = ''
          dpkg-deb -x $src .
        '';

        installPhase = ''
          mkdir -p $out

          if [ -d usr ]; then
            cp -r usr/* $out/
          fi
          if [ -d opt ]; then
            cp -r opt/* $out/
          fi
        '';
      };
    };
}
