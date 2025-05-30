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

  dirtcheap-nsk = {
    imports = [nixosConfigurations.dirtcheap-nsk];

    deployment = {
      targetHost = "178.250.186.116";
      targetPort = 7022;
      targetUser = "root";
    };
  };

  msk = {
    imports = [nixosConfigurations.msk];
    deployment = {
      targetHost = "46.17.104.38";
      targetPort = 7022;
      targetUser = "root";
    };
  };

  kemerovo = {
    imports = [nixosConfigurations.kemerovo];
    deployment = {
      targetHost = "2.59.161.80";
      targetPort = 7022;
      targetUser = "root";
    };
  };

  nl = {
    imports = [nixosConfigurations.nl];
    deployment = {
      targetHost = "31.15.17.70";
      targetPort = 7022;
      targetUser = "root";
    };
  };

  germany = {
    imports = [nixosConfigurations.germany];
    deployment = {
      targetHost = "193.23.197.194";
      targetPort = 7022;
      targetUser = "root";
    };
  };
}
