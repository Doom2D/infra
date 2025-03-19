{
  inputs,
  cell,
}: let
  nixpkgs = inputs.cells.servers.bee.pkgs;
  inherit (nixpkgs) lib;

  callPackageWith = attrs: package: lib.callPackageWith (nixpkgs // attrs) package {};

  dirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.);
  packages = lib.mapAttrs (name: _: ./. + "/${name}/default.nix") dirs;
in
  lib.mapAttrs (_: package: callPackageWith {} package) packages
