{
  inputs,
  cell,
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  tags = cell.nixosTags;
  inherit (inputs.lib) natPort;
in {
  imports = [
    tags.disableDocumentation
    tags.openvzContainer
    tags.ssh
    tags.d2dfMaster
    tags.d2dmpMaster
    inputs.d2df-flake.nixosModules.d2dfServer
  ];
  config = let
    port = natPort natStart natPortsCount;
    natStart = 1000;
    natPortsCount = 20;
    instanceIp = "10.10.66.10";
    timeZone = "America/New_York";
    hostName = "cheaupsa";
  in {
    inherit (cell) bee;

    system.stateVersion = "25.05";
    time.timeZone = timeZone;
    networking.hostName = hostName;
    deployment.openvz.ip = instanceIp;

    services.d2dfMasterServer.port = port 0;
    services.d2dmpMasterServer.port = port 1;

    services.d2df = let
      name = mode: "New York ${mode}";
    in {
      enable = true;

      servers = let
        template = cell.nixosTemplates.d2df;
      in {
        classic = (
          template.classic
          {
            name = name "DM";
            port = port 2;
            rcon = {
              enable = false;
            };
            logs = {
              enable = false;
              filterMessages = false;
            };
            order = lib.mkForce 1;
          }
        );
        coop = (
          template.coop
          {
            name = name "Cooperative";
            port = port 3;
            rcon = {
              enable = false;
            };
            logs = {
              enable = false;
              filterMessages = false;
            };
            order = lib.mkForce 2;
          }
        );
      };
    };
  };
}
