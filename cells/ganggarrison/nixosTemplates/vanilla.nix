{
  inputs,
  cell,
}: {
  pkgs,
  lib,
}: {
  deathmatch = quickSettings @ {
    hostPlayerName,
    port,
    serverName,
    welcomeMessage,
  }: let
    default = {
      Settings = {
        Fullscreen = 0;
        UseLobby = 1;

        Music = 1;
        PlayerLimit = 18;
        MultiClientLimit = 3;
        Particles = 0;
        "Gib Level" = 3;
        "Kill Cam" = 1;
        "Monitor Sync" = 0;
        "Healer Radar" = 1;
        "Show Healer" = 1;
        "Show Healing" = 1;
        "Show Healthbar" = 1;
        "Show Extra Teammate Stats" = 0;
        "Timer Position" = 0;
        "Kill Log Position" = 0;
        "KoTH HUD Position" = 0;
        "Fade Scoreboard" = 1;
        ServerPluginsPrompt = 1;
        RestartPrompt = 1;
        CrosshairFilename = "";
        CrosshairRemoveBG = 1;
        "Queued Jumping" = 0;
        "Hide Spy Ghosts" = 0;
        Resolution = 1;
        Framerate = 0;
      };

      Server = {
        MapRotation = "";
        ShuffleRotation = 1;
        Dedicated = 1;
        CapLimit = 4;
        "Deathmatch Kill Limit" = 30;
        "Team Deathmatch Invulnerability Seconds" = 5;
        AutoBalance = 1;
        RespawnTime = 4;
        "Total bandwidth limit for map downloads in bytes per second" = 50000;
        "Time Limit" = 10;
        Password = "";
        AttemptUPnPForwarding = 0;
        ServerPluginList = "";
        ServerPluginsRequired = 0;
      };

      General = {
        UpdaterBetaChannel = 0;
      };

      Background = {
        BackgroundHash = "default";
        BackgroundTitle = "";
        BackgroundURL = "";
        BackgroundShowVersion = 1;
      };

      Classlimits = {
        Scout = 255;
        Pyro = 255;
        Soldier = 255;
        Heavy = 255;
        Demoman = 255;
        Medic = 255;
        Engineer = 255;
        Spy = 255;
        Sniper = 255;
        Quote = 255;
      };

      Maps = {
        ctf_truefort = 1;
        ctf_2dfort = 2;
        ctf_conflict = 3;
        ctf_classicwell = 4;
        ctf_waterway = 5;
        ctf_orange = 6;
        cp_dirtbowl = 7;
        cp_egypt = 8;
        arena_montane = 9;
        arena_lumberyard = 10;
        gen_destroy = 11;
        koth_valley = 12;
        koth_corinth = 13;
        koth_harvest = 14;
        dkoth_atalia = 15;
        dkoth_sixties = 16;
        tdm_mantic = 17;
        ctf_avanti = 18;
        koth_gallery = 19;
        ctf_eiger = 20;
      };
    };
  in {
    swiftshaderD3d8Dll = ../../d2dmp/nixosTemplates/d3d8.dll;
    wine = pkgs.wineWow64Packages.minimal.override {
      wineRelease = "staging";
      x11Support = true;
    };
    gameExecutable = inputs.cells.ganggarrison.packages.gg2Patched;
    dataPackage = inputs.cells.ganggarrison.packages.gg2Data;
    settings = lib.recursiveUpdate default {
      Server = {
        ServerName = serverName;
        WelcomeMessage = welcomeMessage;
      };
      Settings = {
        PlayerName = hostPlayerName;
        HostingPort = port;
      };
    };
  };
}
