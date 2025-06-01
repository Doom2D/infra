{
  inputs,
  cell,
}: {
  pkgs,
  lib,
}: {
  deathmatch = overrideAttrs @ {...}: let
    serverAttrs = let
      base = {
        sv_map = "dm_superdm";
        sv_name = "Doom2D Multiplayer";
        sv_port = 18512;
        sv_welcome = "t.me/doom2d";
        sv_maxplayers = 24;
        sv_rcon = 1;
        sv_rcon_pwd = "Gubkabob";

        mp_itemrespawn = 63;
        mp_fraglimit = 50;
        mp_scorelimit = 50;
        mp_caplimit = 8;
        mp_timelimit = 610;
        mp_respawn = 3;
        mp_respawn_inv = 1;
        mp_weaponstay = 1;
        mp_itemdrop = 2;

        sv_sync_type = 2;
        sv_rate = 2;
        sv_dl_rate = 256;

        sv_clalert = 0;
        sv_use_pwd = 0;
        sv_lan = 1;
        sv_portcheck = 0;
        sv_ipbans = 1;
        sv_cycle_maps = 2;
        sv_cheats = 0;
        sv_mastersrv = "104.168.51.130:1013";
        sv_slist = "104.168.51.130:1013";
        sv_slist_upd = 60;
        sv_voting = 1;
        sv_voting_time = 7;
        sv_fps_max = 60;
        sv_fps_correct = 0;
        sv_dl_allow = 1;
        sv_dl_mapcfg = 1;
        sv_md5check = 1;
        sv_autosave = 0;
        sv_log_update = 0;
        sv_autoexec = 2;
        sv_priority = 0;
        sv_plugins = 1;
        cl_rc_time = 7;
        cl_timeout = 15;
        mp_gamemode = 0;
        mp_automode = 1;
        mp_ffire = 0;
        mp_items = 1;
        mp_powerups = 1;
        mp_knockback = 1;
        mp_selfdamage = 1;
        mp_aimtype = 0;
        mp_penalty = 1;
        mp_autobalance = 1;
        mp_announcer = 1;
        mp_drop_clear = 30;
        mp_shootjthr = 0;
        mp_telefrag = 0;
        mp_waterfrag = 2;
        mp_waterbfgdmg = 250;
        bot_names = 1;
        bot_chatter = 0;
        bot_randrate = 32;
        bot_userate = 32;
        bot_cowardly = 0;
      };
      settings = lib.recursiveUpdate base overrideAttrs;
    in {
      enable = true;
      swiftshaderD3d8Dll = ./d3d8.dll;
      wine = pkgs.wineWow64Packages.minimal.override {
        wineRelease = "stable";
        x11Support = true;
      };
      openFirewall = true;
      autoexec = let
        syncCvars = ["mp_itemrespawn" "mp_respawn_inv" "mp_itemdrop" "mp_respawn" "mp_weaponstay" "sv_sync_type" "sv_rate" "sv_dl_rate"];
      in
        # For some reason, sometimes game setting stop applying.
        # Add the CVARs I noticed go out of sync into autoexec.cfg
        lib.concatStringsSep "\n" (lib.map (cvar: let cvarValue = settings."${cvar}"; in "${cvar} ${builtins.toString cvarValue}") syncCvars);
      inherit settings;
    };
  in
    serverAttrs;
}
