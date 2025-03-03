{
  inputs,
  cell,
}: {
  pkgs,
  config,
  lib,
  ...
}: {
  config = {
    documentation.enable = false;
    programs.bash.completion.enable = false;
    xdg.icons.enable = false;
    xdg.mime.enable = false;
    xdg.sounds.enable = false;
    environment.defaultPackages = [];
  };
}
