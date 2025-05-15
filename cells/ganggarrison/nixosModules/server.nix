{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.gg2;
  usageLimitAttrs = {
    CPUAccounting = true;
    MemoryAccounting = true;
    MemoryHigh = 128 * 1024 * 1024;
    MemoryMax = 172 * 1024 * 1024;
    TasksAccounting = true;
    IOAccounting = true;
  };

  hardeningAttrs = port: let
    isOnLowerPort = port < 1024;
  in {
    NoNewPrivileges = true;
    DevicePolicy = "closed";
    ProtectSystem = true;
    ProtectHome = true;
    ProtectControlGroups = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
    ProtectKernelLogs = true;
    PrivateMounts = true;
    ProtectHostname = true;
    PrivateTmp = true;
    # breaks CAP_NET_BIND_SERVICE if enabled
    PrivateUsers = !isOnLowerPort;
    # Net
    SecureBits = lib.optionalString isOnLowerPort "keep-caps";
    AmbientCapabilities = lib.optionals isOnLowerPort ["CAP_NET_BIND_SERVICE" "CAP_NET_ADMIN"];
    CapabilityBoundingSet = lib.optionals isOnLowerPort ["CAP_NET_BIND_SERVICE" "CAP_NET_ADMIN"];
    # This causes gg2 to crash for some reason
    /*
    SocketBindDeny = "any";
    SocketBindAllow = ["tcp:${builtins.toString port}"];
    */
  };
  userDir = "/var/lib/${user}";
  xorgDisplayNumber = "27";
  user = "gg2";
  group = "gg2";
  abbr = "gg2";
  name = "deathmatch";
  rotationFileName = "rotation.txt";

  serverServiceName = "${abbr}-${name}";
  xdummyServiceName = "${abbr}-xdummy";
  dataPackage = cfg.dataPackage;
  gameExecutable = cfg.gameExecutable;

  launchCmd = exe: "wine ${exe} -D2D_quiet";
in {
  options.services.gg2 = {
    enable = (lib.mkEnableOption "Gang Garrison 2 servers") // {default = true;};
    wine = lib.mkPackageOption pkgs "wineWow64Packages.stable" {};
    gameExecutable = lib.mkPackageOption pkgs "gg2Patched" {};
    dataPackage = lib.mkPackageOption pkgs "gg2Data" {};
    swiftshaderD3d8Dll = lib.mkOption {
      type = lib.types.path;
      description = ''
        Swiftshader software render d3d8 dll.
      '';
    };
    rotationFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Map rotation text file.
      '';
    };
    openFirewall = (lib.mkEnableOption "opening ports on firewall for Gang Garrison 2 servers") // {default = true;};
    settings = lib.mkOption {
      description = ''
        Generates the `gg2.ini` file.
      '';
      default = {};
      type = lib.types.attrs;
    };
  };

  config = let
    port = cfg.settings.Settings.HostingPort;
    mkServerService = name: {
      description = "Gang Garrison 2 server instance '${name}'";
      wantedBy = ["multi-user.target"];
      after = ["network.target" "${xdummyServiceName}.service"];
      requires = ["network.target" "${xdummyServiceName}.service"];
      path = [cfg.wine pkgs.xdotool pkgs.xorg.xwininfo pkgs.gawk];
      environment = {
        WINEPREFIX = "${userDir}/wine";
        XDG_RUNTIME_DIR = "${userDir}/tmp";
        HOME = "${userDir}/tmp";
        DISPLAY = ":${xorgDisplayNumber}";
        WINEDLLOVERRIDES = "d3d8=n;winemenubuilder.exe=d;mscoree,mshtml=";
        #WINEDEBUG="-all";
      };
      serviceConfig =
        {
          #              StandardOutput = "null";
          #              StandardError = "null";
          User = user;
          Group = user;
          LogFilterPatterns = [
          ];
          # Restart every 8 hours, because the game server may die over time.
          Restart = "always";
          RuntimeMaxSec = "8h";

          ExecStart = script userDir;
        }
        // (hardeningAttrs port)
        // usageLimitAttrs;
    };

    mkXdummyService = let
      inherit (pkgs) writeText xorg writeShellScriptBin;
      megabytes = bytes: builtins.toString (builtins.ceil (bytes * 1000));
      xorgConfig = writeText "dummy-xorg.conf" ''
        Section "ServerLayout"
          Identifier     "dummy_layout"
          Screen         0 "dummy_screen"
          InputDevice    "dummy_keyboard" "CoreKeyboard"
          InputDevice    "dummy_mouse" "CorePointer"
        EndSection

        Section "ServerFlags"
          Option "DontVTSwitch" "true"
          Option "AllowMouseOpenFail" "true"
          Option "PciForceNone" "true"
          Option "AutoEnableDevices" "false"
          Option "AutoAddDevices" "false"
        EndSection

        Section "Files"
          ModulePath "${xorg.xorgserver.out}/lib/xorg/modules"
          ModulePath "${xorg.xf86videodummy}/lib/xorg/modules"
        EndSection

        Section "Module"
          Load           "glx"
        EndSection

        Section "InputDevice"
          Identifier     "dummy_mouse"
          Driver         "void"
        EndSection

        Section "InputDevice"
          Identifier     "dummy_keyboard"
          Driver         "void"
        EndSection

        Section "Monitor"
          Identifier     "dummy_monitor"
          HorizSync       30.0 - 130.0
          VertRefresh     50.0 - 250.0
          Option         "DPMS"
        EndSection

        Section "Device"
          Identifier     "dummy_device"
          Driver         "dummy"
          VideoRam       ${megabytes 1}
        EndSection

        Section "Screen"
          Identifier     "dummy_screen"
          Device         "dummy_device"
          Monitor        "dummy_monitor"
          DefaultDepth    24
          SubSection     "Display"
            Depth       24
            Modes      "1x1"
          EndSubSection
        EndSection
      '';
      xdummy = writeShellScriptBin "xdummy" ''
        exec ${xorg.xorgserver.out}/bin/Xorg \
          -noreset \
          -logfile /dev/null \
          "$@" \
          -config "${xorgConfig}"
      '';
    in {
      description = "Xdummy server for Gang Garrison game servers";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig =
        {
          ExecStart = ''
            ${xdummy}/bin/xdummy :${xorgDisplayNumber} +extension GLX
          '';
        }
        // {
          CPUAccounting = true;
          MemoryAccounting = true;
          MemoryHigh = 8 * 1024 * 1024;
          MemoryMax = 16 * 1024 * 1024;
          TasksAccounting = true;
          IOAccounting = true;
        };
    };

    printSettings = (pkgs.formats.ini {}).generate "gg2.ini";
    script = userDir: let
      exe = "gg2_doom2dorg.exe";
      configFile = let
        src = printSettings (cfg.settings
          # If there is a rotation file, override user settings
          // lib.optionalAttrs (!builtins.isNull cfg.rotationFile) {
            "Server"."MapRotation" =
              "Standard.txt";
          });
        converted = convertToWin1251 src;
      in
        converted;
      convertToWin1251 = x: let
        drv =
          pkgs.runCommandLocal "win1251-convert" {
            nativeBuildInputs = [pkgs.iconv pkgs.coreutils];
          } ''
            mkdir -p $out
            iconv -f UTF-8 -t WINDOWS-1251 -o "$out/str" ${x}
          '';
      in
        drv;
      closeErrorWindowScript =
        pkgs.writeShellScript "close-gg2-error-window"
        ''
          while true; do
              sleep 10s;
              xdotool key enter;
              sleep 10s;
          done
        '';
    in
      # nix-store -q --referrers-closure /nix/store/dp2c6lh3mj8kx1l1520ackwjw8y9r400-gtk4-4.16.3/
      pkgs.writeShellScript "gg2-run"
      (
        ''
          mkdir -p "${userDir}/wine" "${userDir}/tmp"
          cd "${userDir}"
          cp ${dataPackage}/* "${userDir}" -r
          cp "${gameExecutable}" ${exe}
          cp "${cfg.swiftshaderD3d8Dll}" "${userDir}/d3d8.dll"
          ${lib.optionalString (!builtins.isNull cfg.rotationFile) ''
            cp ${cfg.rotationFile} ${userDir}/${rotationFileName}
            ${pkgs.dos2unix}/bin/unix2dos ${userDir}/${rotationFileName}
          ''}

          chmod 700 -R ${userDir}
        ''
        + ''
          cat "${configFile}/str" > "${userDir}/gg2.ini"
        ''
        # First, initialize the prefix. Unset DISPLAY so that WINE doesn't offer to install Mono and other things with a graphical dialog.
        # Then, disable showing crash dialog and kill wineserver.
        # Finally, try to launch the server.
        + ''
          (
          unset DISPLAY;
          wineboot -i
          wine regedit ${pkgs.writeText "no-crashdialog.reg" ''
            [HKEY_CURRENT_USER\Software\Wine\WineDbg]
            "ShowCrashDialog"=dword:00000000
          ''};
          wineboot -r -f
          wineserver -k
          )
          ${closeErrorWindowScript} &
          ${launchCmd exe}
        ''
      );
  in
    lib.mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = lib.mkIf (cfg.openFirewall) [
        port
      ];
      users.users."${user}" = {
        description = "Gang Garrison service user";
        isSystemUser = true;
        inherit group;
      };
      users.groups."${group}" = {};
      systemd.services."${xdummyServiceName}" = mkXdummyService;
      systemd.services."${serverServiceName}" = mkServerService name;
      systemd.tmpfiles.rules = [
        # Recursively change owner to Gang Garrison service user
        "d '${userDir}' 0700 ${user} ${group} - -"
        "Z '${userDir}' 0700 ${user} ${group} - -"
      ];
    };
}
