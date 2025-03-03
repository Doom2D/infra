{
  inputs,
  cell,
}: {
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    sshKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHik2xQpWzL47QkJJq9oqgyAiG2HjlSsSUSLYLkbFqU8 enhance"];
  in {
    users.users.root.openssh.authorizedKeys.keys = sshKeys;
    services.openssh = {
      enable = true;
      ports = [7022];
    };
  };
}
