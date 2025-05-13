{
  lib,
  stdenvNoCC,
  fetchurl,
  rar,
  findutils,
}: let
  tag = "Tag6";
  name = "GG2.Host.rar";
in
  stdenvNoCC.mkDerivation rec {
    pname = "gg2-data";
    version = "1.0";
    dontUnpack = true;

    src = fetchurl {
      url = "https://github.com/Doom2D/blobs_vault/releases/download/${tag}/${name}";
      sha256 = "sha256-2hadQKirg9aSFulwoTZDYVvPUj1GHgT66M8jmOoedzs=";
    };

    nativeBuildInputs = [rar findutils];

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      rar x ${src} .
      mv 'GG2 Host'/* $out
      runHook postInstall
    '';

    meta = with lib; {
      homepage = "https://ganggarrison.com";
      description = "Gang Garrison game data";
      license = licenses.unfree;
      maintainers = [];
      platforms = platforms.all;
    };
  }
