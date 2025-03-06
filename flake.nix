{
  outputs = {
    self,
    std,
    hive,
    ...
  } @ inputs: let
    lib = import ./lib {nixpkgs = inputs.nixpkgs;};
  in
    hive.growOn
    {
      inputs = inputs // {inherit lib;};
      cellsFrom = ./cells;
      cellBlocks = with std.blockTypes;
      with hive.blockTypes; [
        (functions "bee")
        (functions "nixosTemplates")
        (functions "nixosTags")
        nixosConfigurations
        colmenaConfigurations
      ];
    }
    {
      nixosConfigurations = hive.collect self "nixosConfigurations";
      colmenaHive = hive.collect self "colmenaConfigurations";
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-24.11";
    d2df-flake = {
      url = "github:Doom2D/flake.nix";
      inputs = {nixpkgs.follows = "nixpkgs";};
    };

    chaotic.url = "github:chaotic-cx/nyx";
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "nixpkgs";
    };
    nixos-openvz = {
      url = "github:zhaofengli/nixos-openvz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    haumea = {
      url = "github:nix-community/haumea";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    std = {
      url = "github:divnix/std";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hive = {
      url = "github:divnix/hive";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.colmena.follows = "colmena";
    };
  };
}
