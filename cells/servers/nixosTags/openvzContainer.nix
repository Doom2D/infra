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
  ];
  options = {
    deployment.openvz = {
      enable = lib.mkEnableOption "changes to make this configuration bootable as an openvz instance" // {default = true;};
      ip = lib.mkOption {
        type = lib.types.string;
        description = ''
          IP address assigned to this instance.
        '';
      };
    };
  };
  config = let
    cfg = config.deployment.openvz;
    instanceIp = cfg.ip;
  in
    lib.mkIf cfg.enable {
      # Force 22 port for SSH, because it is a special forwarded port
      services.openssh.ports = lib.mkForce [22];
      networking.useNetworkd = true;
      systemd.network.networks.venet0 = {
        name = "venet0";
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
    };
}
