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
  pkgs = import inputs.nixpkgs {
    inherit system;
    config = inputs.nixpkgs.lib.recursiveUpdate {} {
      permittedInsecurePackages = [
        "python-2.7.18.8"
      ];
    };
    overlays = [
      (final: prev: {
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
