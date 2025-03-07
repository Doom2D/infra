{
  inputs,
  cell,
}: {
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    # ~Very important if you want the VM to boot!~
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  options = {
    deployment.kvm = {
      enable = lib.mkEnableOption "changes to make this configuration bootable as KVM virtual machine (a typical VPS instance)" // {default = true;};
      ip = lib.mkOption {
        type = lib.types.str;
        description = ''
          IP address assigned to this instance.
        '';
      };
      interface = lib.mkOption {
        type = lib.types.str;
        description = ''
          Interface name of this instance.
        '';
      };
      gateway = lib.mkOption {
        type = lib.types.str;
        description = ''
          Gateway assigned to this instance.
        '';
      };
      # Some VPS providers work fine with DHCP.
      # But some require manual setup.
      networkSetupType = lib.mkOption {
        type = lib.types.enum ["dhcp" "manual"];
      };
    };
  };
  config = let
    cfg = config.deployment.kvm;
    isDhcp = cfg.networkSetupType == "dhcp";
    isManualSetup = cfg.networkSetupType == "manual";
  in
    lib.mkIf cfg.enable {
      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 100 / config.zramSwap.swapDevices;
        swapDevices = 1;
      };

      networking.firewall = {
        enable = true;
        allowPing = false;
        logRefusedConnections = false;
        logRefusedPackets = false;
        logReversePathDrops = false;
        logRefusedUnicastsOnly = false;
        checkReversePath = "loose";
      };
      networking.nftables = {
        enable = true;
      };
      environment.systemPackages = [pkgs.nftables];
      networking.iproute2 = {
        enable = true;
      };

      networking.nameservers = ["1.1.1.1" "8.8.8.8"];
      services.resolved = {
        enable = true;
        dnssec = "true";
        domains = ["~."];
        fallbackDns = ["1.1.1.1" "8.8.8.8"];
        dnsovertls = "false";
      };

      networking.firewall.trustedInterfaces = [cfg.interface];
      networking.networkmanager.enable = false;
      networking.useDHCP = isDhcp;
      networking.dhcpcd.enable = isDhcp;
      systemd.network.enable = isManualSetup;
      systemd.network.networks."30-manual-setup" = {
        matchConfig.Name = cfg.interface;
        networkConfig.DHCP = "no";
        address = [
          # replace this address with the one assigned to your instance
          "${cfg.ip}/24"
        ];
        routes = [
          {
            routeConfig = {
              Gateway = "${cfg.gateway}";
              GatewayOnLink = true;
            };
          }
        ];
      };
    };
}
