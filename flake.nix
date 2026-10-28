{
  description = "Nix Flake for Workfolio";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation (finalAttrs: {
        pname = "workfolio";
        version = "1.0.0";

        src = pkgs.fetchurl {
          name = "workfolio-${finalAttrs.version}.deb";
          url = "https://workfolio-public.s3.ap-south-1.amazonaws.com/Workfolio+Setup.deb";
          hash = "sha256-dtXP4dyccwP7R1/WcKI4J5+zXA8+wPiE7z5Q6sjrDn8=";
        };

        nativeBuildInputs = with pkgs; [
          dpkg
          autoPatchelfHook
          makeWrapper
        ];

        buildInputs = with pkgs; [
          stdenv.cc.cc.lib
          glib gtk3 cairo pango atk gdk-pixbuf at-spi2-core
          cups dbus expat fontconfig freetype
          libdrm libxkbcommon mesa alsa-lib systemd
          libX11 libXcomposite libXcursor libXdamage libXext
          libXfixes libXrandr libXrender libXScrnSaver libXtst libxcb
          nspr nss libnotify libuuid
        ];

        # dlopen()'d at runtime, invisible to autoPatchelf's DT_NEEDED scan
        runtimeDependencies = with pkgs; [
          (lib.getLib systemd)
          libGL
          vulkan-loader
          libpulseaudio
          libnotify
        ];

        dontConfigure = true;
        dontBuild = true;

        unpackPhase = ''
          runHook preUnpack
          dpkg-deb -x $src .
          runHook postUnpack
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin $out/opt $out/share
          cp -r opt/Workfolio $out/opt/Workfolio
          [ -d usr/share ] && cp -r usr/share/* $out/share/

          makeWrapper $out/opt/Workfolio/workfolio $out/bin/workfolio \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
            --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.runtimeDependencies}"

          # Fix .desktop file to point at the wrapper
          for f in $out/share/applications/*.desktop; do
            substituteInPlace "$f" \
              --replace-quiet "/opt/Workfolio/workfolio" "$out/bin/workfolio"
          done

          runHook postInstall
        '';

        meta = {
          description = "Workfolio desktop app";
          platforms = [ "x86_64-linux" ];
          mainProgram = "workfolio";
          sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        };
      });
    };
}
