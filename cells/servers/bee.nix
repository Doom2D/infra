#        ████  ████
#      ██    ██    ██
#        ██    ██  ██
#          ██████████
#        ████░░██░░░░██
#      ██░░██░░██░░░░░░▓▓
#  ▓▓▓▓██░░██░░██░░▓▓░░██
#      ██░░██░░██░░░░░░██
#        ████░░██░░░░██
#          ██████████
{
  inputs,
  cell,
}: let
  system = "x86_64-linux";
in {
  inherit system;
  pkgs = import inputs.nixpkgs-stable {
    inherit system;
    config = inputs.nixpkgs.lib.recursiveUpdate {} {
      permittedInsecurePackages = [
        "python-2.7.18.8"
      ];
      allowUnfree = true;
    };
    overlays = [
      (final: prev: {
        doom2df-assets = final.stdenv.mkDerivation (finalAttrs: {
          pname = "doom2df-assets";
          version = "unstable";
          src = null;
          base = inputs.d2df-flake.assets.defaultAssetsPath.override {
            extraRoots = [];
            withDates = false;
            toLower = true;
            unixLineEndings = true;
          };
          distrib = inputs.d2df-flake.dfInputs.d2df-distro-content;
          nativeBuildInputs = [final._7zz final.rar];
          dontUnpack = true;
          installPhase = ''
            runHook preInstall
            mkdir -p $out
            7zz x ${finalAttrs.base} -o$out
            rar x ${finalAttrs.distrib} $out
            runHook postInstall
          '';
        });
        doom2df =
          (inputs.d2df-flake.legacyPackages.doom2df-base.override {
            Doom2D-Forever = inputs.d2df-flake.dfInputs.Doom2D-Forever;
            headless = true;
            disableSound = true;
            disableGraphics = true;
            disableIo = true;
          })
          .overrideAttrs (finalAttrs: prevAttrs: {
            dontFixup = false;
            dontPatchELF = false;
            dontStrip = false;
            postFixup = ''
              patchelf \
                --add-needed ${final.enet.out}/lib/libenet.so.7 \
                $out/bin/Doom2DF
            '';
          });
        doom2d-forever-master-server = (inputs.d2df-flake.legacyPackages.doom2d-forever-master-server.override {}).overrideAttrs (finalAttrs: prevAttrs: {
          src = final.doom2df.src;
        });
        doom2d-multiplayer-game-data = inputs.d2df-flake.legacyPackages.doom2d-multiplayer-game-data.override {};
      })
    ];
  };
}
