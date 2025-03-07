{
  inputs,
  cells,
}: {
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.d2df-flake.nixosModules.d2dfMaster
  ];
  config = {
    services.d2dfMasterServer = {
      enable = true;
      openFirewall = true;
      package = pkgs.doom2d-forever-master-server;
    };
  };
}
