{
  inputs,
  cell,
}: {
  lib,
  modulesPath,
  pkgs,
  ...
}: let
  tags = cell.nixosTags;
  inherit (inputs.lib) natPort;
in {
  imports = [
    tags.disableDocumentation
    tags.kvmMachine
    tags.ssh
    tags.d2dfMaster
    tags.d2dmpMaster
    inputs.disko.nixosModules.disko
    inputs.d2df-flake.nixosModules.d2dfServer
    inputs.d2df-flake.nixosModules.d2dmpServer

    # ~Very important if you want the VM to boot!~
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  config = let
    ip = "193.233.84.243";
    gateway = "193.233.84.1";
    interface = "ens3";
    timeZone = "Asia/Novosibirsk";
    hostName = "cheapnsk";
    serverName = mode: "The Hometown of rs.falcon - Novosibirsk (GMT+7, ${mode})";
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
    deployment.kvm = {
      inherit ip gateway interface;
      networkSetupType = "manual";
    };

    environment.systemPackages = [pkgs.compsize];
    users.users.root.initialPassword = lib.mkForce "test";
    boot.loader.grub.enable = true;
    boot.loader.efi.canTouchEfiVariables = false;
    boot.loader.grub.efiInstallAsRemovable = false;
    boot.loader.grub.efiSupport = false;
    # These are really for a "gamer" PC, but maybe it will help a CPU starved machine with latency
    boot.kernelParams = [
      "mitigations=off"
      "workqueue.power_efficient=false"
      "skew_tick=1"
      "threadirqs"
      "preempt=full"
    ];
    # A "gamer" kernel with better defaults and latest version
    boot.kernelPackages = inputs.chaotic.legacyPackages.linuxPackages_cachyos-server;
    boot.supportedFilesystems = {
      zfs = lib.mkForce false;
      btrfs = true;
      vfat = true;
    };
    boot.initrd = {
      systemd = {
        enable = true;
        dbus.enable = true;
      };
      services = {
        lvm.enable = true;
      };
      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];
    };
    disko = {
      enableConfig = true;
      devices = let
        main = {device = "/dev/vda";};
      in {
        disk = {
          main = {
            type = "disk";
            device = main.device;
            content = {
              type = "gpt";
              partitions = {
                boot = {
                  priority = 1;
                  size = "1M";
                  type = "EF02"; # for grub
                };
                root = {
                  size = "100%";
                  priority = 2;
                  content = {
                    type = "btrfs";
                    extraArgs = ["-f"];
                    subvolumes = {
                      "/rootfs" = {
                        mountOptions = [
                          "compress-force=zstd:2"
                          "noatime"
                        ];
                        mountpoint = "/";
                      };
                      "/nix" = {
                        mountOptions = [
                          "compress-force=zstd:2"
                          "noatime"
                        ];
                        mountpoint = "/nix";
                      };
                      "/var" = {
                        mountOptions = [
                          "compress-force=zstd:2"
                          "noatime"
                        ];
                        mountpoint = "/var";
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };

    services.d2dfMasterServer.port = ports.master.d2df;
    services.d2dmpMasterServer.port = ports.master.d2dmp;

    services.d2dmp = lib.mkMerge [
      (cell.nixosTemplates.d2dmp.deathmatch {})
      {
        settings = {
          sv_name = lib.mkForce ("Novosibirsk (GMT+7, DM)");
          sv_welcome = lib.mkForce "------> t.me/doom2d | doom2d.org <-------";
          sv_port = lib.mkForce ports.game.d2dmp;
        };
      }
    ];

    services.d2df = {
      enable = true;

      servers = let
        template = cell.nixosTemplates.d2df;
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
