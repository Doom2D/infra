{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:
stdenvNoCC.mkDerivation rec {
  pname = "gg2-re-DSM";
  version = "2.0";
  dontUnpack = true;
  src = fetchurl {
    url = "https://github.com/Derpduck/Gang-Garrison-2/releases/download/Re-DSM-v3/Re-DSM.7z";
    sha256 = "sha256-YMEU5YoXW15U60iHcQ2zYnZdhi1UlOuIrtoWDwZphEk=";
  };
  nativeBuildInputs = [_7zz];
  installPhase = ''
    runHook preInstall
    mkdir -p tmp
    7zz x ${src} -otmp
    mv tmp/Re-DSM.exe $out
    runHook postInstall
  '';
  meta = with lib; {
    homepage = "https://ganggarrison.com";
    description = "Gang Garrison re-DSM executable";
    license = licenses.unfree;
    maintainers = [];
    platforms = platforms.all;
  };
}
