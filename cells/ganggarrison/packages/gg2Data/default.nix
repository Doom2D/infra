{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  fd,
}: let
  baseName = "Gang.Garrison.2.v2.9.2";
in
  stdenvNoCC.mkDerivation rec {
    pname = "gg2-data";
    version = "1.0";
    dontUnpack = true;

    src = fetchurl {
      url = "https://github.com/Doom2D/blobs_vault/releases/download/Tag5/${baseName}.zip";
      sha256 = "sha256-X9oVzl9TkgyjX7NdWkbr+Lwxah2yWmx3aZqoT+rsIm4=";
    };

    nativeBuildInputs = [unzip];

    installPhase = ''
      runHook preInstall
      unzip -q ${src} -d $out
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
