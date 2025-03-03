{
  inputs,
  cell,
}: let
  inherit (cell) nixosConfigurations;
in {
  dirtcheap-usa = {
    imports = [nixosConfigurations.dirtcheap-usa];

    deployment = {
      targetHost = "104.168.51.130";
      targetPort = 1020;
      targetUser = "root";
    };
  };
}
