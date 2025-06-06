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
    inputs.cells.d2df.nixosTags.d2dfMaster
    inputs.cells.d2dmp.nixosTags.d2dmpMaster
    inputs.d2df-flake.nixosModules.d2dfServer
  ];
  config = let
    port = natPort natStart natPortsCount;
    natStart = 1000;
    natPortsCount = 20;
    instanceIp = "10.10.66.10";
    timeZone = "America/New_York";
    hostName = "cheaupsa";
    serverName = mode: "Doom2D State Of Mind - New York (GMT-5, ${mode})";
    ports = {
      game = {
        d2dmp = port 10;
        d2df = {
          dm = port 4;
          coop = port 15;
        };
      };
      master = {
        d2dmp = port 13;
        d2df = port 5;
      };
    };
  in {
    inherit (cell) bee;

    system.stateVersion = "25.05";
    time.timeZone = timeZone;
    networking.hostName = hostName;
    deployment.openvz.ip = instanceIp;

    services.d2dfMasterServer.port = ports.master.d2df;
    services.d2dmpMasterServer.port = ports.master.d2dmp;

    services.d2df = {
      enable = true;

      servers = let
        template = inputs.cells.d2df.nixosTemplates.d2df {
          inherit pkgs;
          inherit (pkgs) lib;
        };
      in {
        classic = (
          template.classic
          {
            name = serverName "DM";
            port = ports.game.d2df.dm;
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
            name = serverName "COOP";
            port = ports.game.d2df.coop;
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
