{
  inputs,
  cell,
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.deployment.charity;
in {
  imports = [
  ];
  options = {
    deployment.charity = {
      enable = lib.mkEnableOption "forwarding ports to other hosts" // {default = true;};
      ip = lib.mkOption {
        type = lib.types.str;
        # Ganggarrison's
        default = "78.46.177.87";
        description = ''
          IP address of host this machine's ports will be forwarded to.
        '';
      };
      ports = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        # Ganggarrison's
        default = [29942 29944 29950 45022];
        description = ''
          Ports of this machine that will be forwarded to host declared in this module.
        '';
      };
    };
  };
  config = let
  in
    lib.mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = cfg.ports;

      networking.nftables.tables = let
        tcpDnat = inputs.lib.tcpDnat cfg.ip;
      in {
        teamfortress = {
          enable = true;
          name = "teamfortress";
          family = "inet";
          content = ''
            chain postrouting {
              type nat hook postrouting priority srcnat;
              ip daddr ${cfg.ip} masquerade
            }

            chain prerouting {
              type nat hook prerouting priority -100
              ${lib.concatStringsSep "\n" (lib.map (port: tcpDnat port) cfg.ports)}
            }
          '';
        };
      };
    };
}
