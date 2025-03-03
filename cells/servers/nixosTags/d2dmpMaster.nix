{
  inputs,
  cell,
}: {pkgs, ...}: {
  imports = [inputs.d2df-flake.nixosModules.d2dmpMaster];
  config = {
    services.d2dmpMasterServer = {
      enable = true;
      openFirewall = true;
      package = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/Doom2D/Doom2D-Multiplayer/refs/heads/v0.6/Masterserver/d2dmp_ms.py";
        name = "d2dmp_ms.py";
        hash = "sha256-DcMU8IgjcWdgkvJoh1UygmQKnRX+jLhUCmHt8xLjfgo=";
      };
    };
  };
}
