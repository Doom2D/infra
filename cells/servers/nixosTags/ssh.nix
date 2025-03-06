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
    sshKeys = let
      gena-nosov = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHik2xQpWzL47QkJJq9oqgyAiG2HjlSsSUSLYLkbFqU8 enhance";
      blackdoomer = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdZgknibVZs2RBLLgUMc/wurYp1YVSFxMiaNvEJdGAk7kBzUcxP/kitKVVShI99mtHR04s6dxoJtWIqFFhIhc62XdDxYaeb9bznkpgKGNaa0OjPhM8I4WQXL8cCC9VTc/kVub8UThJ1cLLLwmzK5NtJp1wd5HemuwBeFFDL/vSuIfIk/eg7OShXCyiac/qMuCo6HX7HydK2LvmYMmDiHCo8Fbxvpp3LEwwvQgKvySoK1K+kdRAApE0Nv7Ap34dxZCwpHqjJpJK8qRY98ZumTHf89O3yw+zunGWshK77JizLslRZ4wz4ZXIdPi3VkQhJA1/JI8K9zqNztFvAme6arCMXO1TlYt6Vc8UGBawfcAjnD5OlUdqQeY3EqljCgAdiYdNkkxiKb7VhWIfeskaKgYefOLRk6gD0uYnT1oRH9ybt8rHPVXQIhgKVJ+xTaqChtmZmX+GFrugaoJw8+FAchUUfh/2fgzmQgE/6VM1s2yTZyCGVxMM3+SZdKdMdCARVsgUgvll9rbcWX4FihBHyxGPhG65N34/hEKq8Uoc062JYtLpg72uFLbF7lftZh4OxrqTmuqcdBd6DYqfPDLLmwxQZyBOvte/pZhqH2wQpYNoKT17G8WfOK5n6sYZXRb3o0vRaRrmCuIJRyhFx/16itmloy721XcCHreyOpOa9x23Uw== 2021-09-28;Admin@DNS-2012";
    in [gena-nosov blackdoomer];
  in {
    users.users.root.openssh.authorizedKeys.keys = sshKeys;
    services.openssh = {
      enable = true;
      ports = [7022];
      settings = {
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
      };
    };
  };
}
