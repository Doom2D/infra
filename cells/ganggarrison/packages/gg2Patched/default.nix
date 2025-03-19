{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:
stdenvNoCC.mkDerivation rec {
  pname = "gg2-data";
  version = "1.0";
  dontUnpack = true;
  src = fetchurl {
    url = "https://github.com/Doom2D/blobs_vault/releases/download/Tag4/gg2_doom2dorg.7z";
    sha256 = "sha256-TRGSCKjjAQ40HPsqJfwQAKRfexLgt5cA6acmnyvxxAM=";
  };
  nativeBuildInputs = [_7zz];
  installPhase = ''
    runHook preInstall
    mkdir -p tmp
    7zz x ${src} -otmp
    mv tmp/gg2_doom2dorg.exe $out
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
