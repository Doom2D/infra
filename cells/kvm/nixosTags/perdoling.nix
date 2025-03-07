{
  inputs,
  cell,
}: {
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.deployment.perdoling;
in {
  options.deployment.perdoling = {
    enable = lib.mkEnableOption "perdoling tweaks for this machine" // {default = true;};
    enablePotentiallyDangerous = lib.mkEnableOption "potentially dangerous tweaks for this machine";
  };
  config = lib.mkIf cfg.enable {
    # These are really for a "gamer" PC, but maybe it will help a CPU starved machine with latency
    boot.kernelParams =
      [
        "mitigations=off"
        "workqueue.power_efficient=false"
        "skew_tick=1"
        "threadirqs"
        "preempt=full"
        "smt=on"
      ]
      ++ lib.optionals cfg.enablePotentiallyDangerous [
        # Disable various mitigations
        "mitigations=off"
        "l1tf=off"
        "kvm-intel.vmentry_l1d_flush=off"
      ];

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

    # A "gamer" kernel with better defaults and latest version
    boot.kernelPackages = inputs.chaotic.legacyPackages.linuxPackages_cachyos-server;
  };
}
