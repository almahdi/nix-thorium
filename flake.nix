{
  description = "Thorium using Nix Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      thoriumVersion = "117.0.5938.157-53";
      thoriumSrc = {
        x86_64-linux = "https://github.com/Alex313031/thorium/releases/download/M${thoriumVersion}/Thorium_Browser_${thoriumVersion}_x64.AppImage";
        aarch64-linux = "https://github.com/Alex313031/Thorium-Raspi/releases/download/M${thoriumVersion}/Thorium_Browser_${thoriumVersion}_arm64.AppImage";
      };

      makeThorium = system: {
        name = "thorium";
        version = thoriumVersion;
        src = nixpkgs.fetchurl {
          url = thoriumSrc.${system};
          sha256 = ""; # Add the correct sha256 hash here
        };
        appimageContents = nixpkgs.appimageTools.extractType2 { inherit name src; };
        appimage = nixpkgs.appimageTools.wrapType2 {
          inherit name version src;
          extraInstallCommands = ''
            install -m 444 -D ${appimageContents}/thorium-browser.desktop $out/share/applications/thorium-browser.desktop
            install -m 444 -D ${appimageContents}/thorium.png $out/share/icons/hicolor/512x512/apps/thorium.png
            substituteInPlace $out/share/applications/thorium-browser.desktop \
              --replace 'Exec=AppRun --no-sandbox %U' "Exec=${name} %U"
          '';
        };
      };
    in
    {
      packages.x86_64-linux.thorium = makeThorium "x86_64-linux";
      packages.aarch64-linux.thorium = makeThorium "aarch64-linux";

      packages.x86_64-linux.default = self.packages.x86_64-linux.thorium;
      packages.aarch64-linux.default = self.packages.aarch64-linux.thorium;

      apps.x86_64-linux.thorium = {
        type = "app";
        program = "${self.packages.x86_64-linux.thorium}/bin/thorium";
      };
      apps.aarch64-linux.thorium = {
        type = "app";
        program = "${self.packages.aarch64-linux.thorium}/bin/thorium";
      };

      apps.x86_64-linux.default = self.apps.x86_64-linux.thorium;
      apps.aarch64-linux.default = self.apps.aarch64-linux.thorium;
    };
}
