{
  inputs,
  cell,
}: {
  lib,
  pkgs,
  ...
}: let
  tags = cell.nixosTags;
  inherit (inputs.lib) natPort;
in {
  imports = [
    tags.disableDocumentation
    tags.ssh
    inputs.cells.kvm.nixosTags.kvmMachine
    inputs.cells.kvm.diskoTags.btrfs
    inputs.cells.kvm.nixosTags.perdoling
    inputs.cells.d2df.nixosTags.d2dfMaster
    inputs.cells.d2dmp.nixosTags.d2dmpMaster
    inputs.d2df-flake.nixosModules.d2dfServer
    inputs.d2df-flake.nixosModules.d2dmpServer
    inputs.cells.ganggarrison.nixosModules.server
  ];
  config = let
    timeZone = "Europe/Berlin";
    hostName = "germany";
    serverName = mode: "Germany (GMT+2, ${mode})";
    ports = {
      game = {
        d2dmp = 37825;
        d2df = {
          dm = 59260;
          coop = 6242;
        };
      };
      master = {
        d2dmp = 23180;
        d2df = 16431;
      };
    };
    machineId = "";
  in {
    inherit (cell) bee;

    system.stateVersion = "25.05";
    time.timeZone = timeZone;
    networking.hostName = hostName;
    deployment.disko.mainDevice = "/dev/vda";
    deployment.kvm = {
      networkSetupType = "manual";
      interface = "ens3";
      ip = "193.23.197.194";
      ipMask = "32";
      gateway = "10.0.0.1";
    };

    deployment.perdoling.enablePotentiallyDangerous = false;
    users.users.root.initialPassword = lib.mkForce "test";
    services.d2dfMasterServer.port = ports.master.d2df;
    services.d2dmpMasterServer.port = ports.master.d2dmp;

    services.gg2 = (inputs.cells.ganggarrison.nixosTemplates.vanilla {inherit pkgs lib;}).deathmatch {
      port = 8190;
      hostPlayerName = "www.Doom2D.org";
      serverName = "German";
      welcomeMessage = "Welcome! Also check out this awesome DOOM-inspired platformer! ---> doom2d.org <---";
    };

    services.d2dmp =
      (inputs.cells.d2dmp.nixosTemplates.d2dmp {
        inherit pkgs;
        inherit (pkgs) lib;
      })
      .deathmatch {
        sv_name = "German";
        sv_welcome = "------> t.me/doom2d | doom2d.org <-------";
        sv_port = ports.game.d2dmp;
      };

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
            ping = true;
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
