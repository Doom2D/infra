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
    instanceIp = cfg.ip;
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

      boot.kernelModules = ["tcp_bbr" "sch_netem"];
      boot.kernel.sysctl = let
        severalValues = arr: lib.concatStringsSep " " (lib.map builtins.toString arr);
        forwardIp = 0;
      in
        lib.recursiveUpdate {
          "net.core.default_qdisc" = "fq";
          "net.ipv4.tcp_congestion_control" = "bbr";
        } {
          # TODO
          # Decide whether ip forward is needed
          "net.ipv4.ip_forward" = forwardIp;
          "net.ipv4.conf.all.forwarding" = forwardIp;
          "net.ipv6.conf.all.forwarding" = forwardIp;
          "net.ipv6.conf.all.accept_ra" = 0;
          "net.ipv6.conf.all.accept_redirects" = 0;
          "net.ipv6.conf.all.accept_source_route" = 0;
          # Haaax
          "net.core.netdev_max_backlog" = 16 * 1024; # 16 KB
          "net.core.rmem_default" = 1 * 1024 * 1024; # 1 MB
          "net.core.rmem_max" = 16 * 1024 * 1024; # 16 MB
          "net.core.wmem_default" = 1 * 1024 * 1024; # 1 MB
          "net.core.wmem_max" = 16 * 1024 * 1024; # 16 MB
          "net.core.optmem_max" = 64 * 1024; # 1 KB
          "net.ipv4.tcp_rmem" = severalValues [(4 * 1024) (1 * 1024 * 1024) (2 * 1024 * 1024)]; #  4KB 1MB 2 MB
          "net.ipv4.tcp_wmem" = severalValues [(4 * 1024) (64 * 1024) (16 * 1024 * 1024)]; #  4KB 64KB 16MB;
          "net.ipv4.udp_rmem_min" = 8 * 1024; # 8 KB
          "net.ipv4.udp_wmem_min" = 8 * 1024; # 8 KB
          # enable all listeners to support Fast Open by default without explicit TCP_FASTOPEN socket option: 0x1 + 0x2 + 0x400
          "net.ipv4.tcp_fastopen" = 1027;
          "net.ipv4.tcp_max_syn_backlog" = 8192;
          "net.ipv4.tcp_max_tw_buckets" = 2000000;
          "net.ipv4.tcp_tw_reuse" = 1;
          "net.ipv4.tcp_fin_timeout" = 10;
          "net.ipv4.tcp_slow_start_after_idle" = 0;
          "net.ipv4.tcp_keepalive_time" = 60;
          "net.ipv4.tcp_keepalive_intvl" = 10;
          "net.ipv4.tcp_keepalive_probes" = 6;
          "net.ipv4.tcp_mtu_probing" = 1;
          # For high latency networks
          # net.ipv4.tcp_sack = 1;
          "net.ipv4.tcp_rfc1337" = 1;
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
          "${cfg.interface}/24"
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
