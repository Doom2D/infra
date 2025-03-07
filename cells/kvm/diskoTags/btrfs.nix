{
  inputs,
  cell,
}: {
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.deployment.disko;
in {
  imports = [inputs.disko.nixosModules.disko];
  options.deployment.disko = {
    enable = lib.mkEnableOption "this disko and nixos boot config" // {default = true;};
    mainDevice = lib.mkOption {
      type = lib.types.str;
      description = ''
        Name of the disk for disko formatting.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.compsize];
    boot.loader.grub.enable = true;
    boot.loader.efi.canTouchEfiVariables = false;
    boot.loader.grub.efiInstallAsRemovable = false;
    boot.loader.grub.efiSupport = false;
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
        main = {device = cfg.mainDevice;};
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
  };
}
