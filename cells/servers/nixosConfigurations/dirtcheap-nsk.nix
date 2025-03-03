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
    tags.kvmMachine
    tags.ssh
    tags.d2dfMaster
    tags.d2dmpMaster
    inputs.disko.nixosModules.disko
    inputs.d2df-flake.nixosModules.d2dfServer
  ];
  config = let
    port = natPort natStart natPortsCount;
    natStart = 1000;
    natPortsCount = 20;
    instanceIp = "193.233.84.243";
    gateway = "193.233.84.1";
    timeZone = "Asia/Novosibirsk";
    hostName = "cheapnsk";
    machineId = "";
  in {
    inherit (cell) bee;

    system.stateVersion = "25.05";
    time.timeZone = timeZone;
    networking.hostName = hostName;
    deployment.kvm = {
      ip = instanceIp;
      inherit gateway;
      interface = "ens3";
      networkSetupType = "manual";
    };

    boot.loader.grub.enable = true;
    boot.loader.efi.canTouchEfiVariables = false;
    boot.loader.grub.efiInstallAsRemovable = false;
    boot.loader.grub.efiSupport = false;
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
                  content = {
                    type = "btrfs";
                    extraArgs = ["-f"]; # Override existing partition
                    subvolumes = {
                      "/rootfs" = {
                        mountpoint = "/";
                        mountOptions = [
                          "compress-force=zstd:2"
                          "noatime"
                        ];
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
                        mountpoint = "/nix";
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

    services.d2dfMasterServer.port = port 0;
    services.d2dmpMasterServer.port = port 1;

    services.d2df = let
      name = mode: "Test Novosibirsk ${mode}";
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
