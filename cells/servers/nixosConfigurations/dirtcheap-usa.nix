{
  inputs,
  cell,
}: {
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-openvz.nixosModules.ovz-container
    #inputs.nixos-openvz.nixosModules.ovz-installer
    inputs.d2df-flake.nixosModules.d2dfServer
    inputs.d2df-flake.nixosModules.d2dfMaster
    inputs.d2df-flake.nixosModules.d2dmpMaster
  ];
  config = let
    instanceIp = "10.10.66.10";
    timeZone = "America/New_York";
    hostName = "cheaupsa";
    sshKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHik2xQpWzL47QkJJq9oqgyAiG2HjlSsSUSLYLkbFqU8 enhance"];
  in {
    inherit (cell) bee;

    system.stateVersion = "25.05";
    time.timeZone = timeZone;
    networking.hostName = hostName;
    networking.useNetworkd = true;
    systemd.network.networks.venet0 = {
      name = "venet0";
      # Change to your assigned IP
      address = ["${instanceIp}/32"];
      networkConfig = {
        DHCP = "no";
        DefaultRouteOnDevice = "yes";
        ConfigureWithoutCarrier = "yes";
      };
    };
    services.resolved.enable = false;
    networking.resolvconf = {
      enable = true;
      extraConfig = "name_servers='1.1.1.1'";
    };

    users.users.root.openssh.authorizedKeys.keys = sshKeys;
    services.openssh = {
      enable = true;
      ports = [22];
    };
    documentation.enable = false;
    programs.bash.completion.enable = false;
    xdg.icons.enable = false;
    xdg.mime.enable = false;
    xdg.sounds.enable = false;
    environment.defaultPackages = [];

    services.d2dfMasterServer = {
      enable = true;
      openFirewall = true;
      port = 1010;
      package = pkgs.doom2d-forever-master-server;
    };
    services.d2dmpMasterServer = {
      enable = true;
      openFirewall = true;
      package = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/Doom2D/Doom2D-Multiplayer/refs/heads/v0.6/Masterserver/d2dmp_ms.py";
        name = "d2dmp_ms.py";
        hash = "sha256-DcMU8IgjcWdgkvJoh1UygmQKnRX+jLhUCmHt8xLjfgo=";
      };
      port = 1009;
    };
    services.d2df = let
      name = mode: "New York ${mode}";
    in {
      enable = true;

      servers = let
        template = cell.nixosTemplate.d2df;
      in {
        coop = (
          template.coop
          {
            name = name "Cooperative";
            port = 1001;
            rcon = {
              enable = false;
            };
            order = lib.mkForce 2;
          }
        );
        classic = (
          template.classic
          {
            name = name "DM";
            port = 1000;
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
      };
    };
  };
}
