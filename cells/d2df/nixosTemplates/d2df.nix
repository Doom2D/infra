{
  inputs,
  cell,
}: {
  lib,
  pkgs,
}: let
  rawDmJson = ./d2df_dm.json;
  rawPubgJson = pkgs.writeText "maps.json" ''
    [
        {"source": "RUBG_2.zip", "maps": ["MAP01", "MAP02", "MAP03", "MAP04", "MAP05"]}
    ]
  '';
  rawDefragJson = pkgs.writeText "maps.json" ''
    [
        {"source": "Defrag.zip", "maps": ["MAP01", "MAP02"]}
    ]
  '';
  rawCoopJson = pkgs.writeText "coop.json" ''
    [
        {"source": "Bloodworks.wad", "entry": "MAP01"},
        {"source": "dm99.dfz", "entry": "MAP01"},
        {"source": "DM2002_DF_RC.1.wad", "entry": "MAP01"},
        {"source": "doom2d.wad", "entry": "MAP01"},
        {"source": "DOOM2D.dfz", "entry": "MAP01"},
        {"source": "FAIL.wad", "entry": "MAP01"},
        {"source": "franken.dfz", "entry": "MAP01"},
        {"source": "hoe2.wad", "entry": "MAP01"},
        {"source": "makkad.wad", "entry": "MAP01"},
        {"source": "Stupidity_Coop.wad", "entry": "MAP01"},
        {"source": "Timewall.wad", "entry": "MAP01"},
        {"source": "VETERAN.wad", "entry": "MAP01"}
    ]
  '';
  rawDuelJson = ./d2df_duel_ctf1on1.json;
  rawTdmJson = ./d2df_tdm_ctf.json;
  defaultPackage = let
    base = pkgs.doom2df;
    # FIXME there should be a minimal derivation
    headless = base.override {
      disableIo = true;
      withSDL2 = false;
      headless = true;
      withOpenAL = false;
      disableSound = true;
      disableGraphics = true;
      withOpenGL2 = false;
      withHolmes = false;

      withVorbis = false;
      withLibXmp = false;
      withMpg123 = false;
      withOpus = false;
      withMiniupnpc = false;
      withFluidsynth = false;
    };
    withPatch = headless.overrideAttrs (finalAttrs: prevAttrs: {
      patches =
        prevAttrs.patches
        or []
        ++ [
          ./0001-Experimental-network-patch.patch
        ];
    });
  in
    withPatch;
  disableGraphicsSettings = {
    r_maxfps = 1;
    r_vsync = 0;
    r_fullscreen = 0;
    r_bpp = 16;
    r_background = 0;
    r_maximized = 0;
    r_texfilter = 0;
    r_interp = 0;
    r_showfps = 0;
    r_showtime = 0;
    r_showping = 0;
    r_showscore = 0;
    r_showkillmsg = 1;
    r_showlives = 0;
    r_showstat = 0;
    r_showspect = 0;
    r_showpids = 1;
    s_nosound = 1;
    s_sfx = 0;
    s_announcer = 0;
    s_chatsounds = 0;
    g_gibs_count = 0;
    g_blood_count = 0;
    g_adv_blood = 0;
    g_adv_corpses = 0;
    g_adv_gibs = 0;
    g_max_particles = 0;
    g_max_shells = 0;
    g_max_gibs = 0;
    g_max_corpses = 0;
    r_flash = 0;
  };
  commonSettings = {
    p1_name = "Приколист";
    p2_name = "Приколист";
    net_master_list = ["dfms.doom2d.org:25665" "dfms2.doom2d.org:1005"];

    g_max_bots = 24;
    g_spawn_invul = 1;
    g_weaponstay = 1;
    sv_intertime = 7;
    g_timelimit = 15 * 60;
    g_scorelimit = 0;
    g_maxlives = 0;

    g_item_respawn_time = 60;
    g_powerup_respawn_time = 60;
    g_powerup_time_random = 2;
    g_item_time_random = 2;

    g_powerup_randomize_respawn = 1;
    g_items_all_respawn_random = 1;
    g_items_help_respawn_random = 0;
    g_items_ammo_respawn_random = 0;
    g_items_weapon_respawn_random = 0;

    g_friendlyfire = 0;
    g_team_hit_trace = 1;
    g_team_hit_projectile = 1;
    g_team_absorb_attacks = 1;
    g_allow_dropflag = 1;
    g_throw_flag = 1;

    g_allow_exit = 1;
    g_allow_monsters = 1;
    g_bot_vsmonsters = 1;
    g_bot_vsplayers = 1;
    g_dm_keys = 1;
    g_warmup_time = 0;

    g_screenshot_stats = 0;
    g_save_stats = 1;
    sv_autoban_threshold = 0;
    sv_autoban_permanent = 0;
    sv_autoban_warn = 1;
    sv_forwardports = 0;
    sv_public = 1;
    rdl_hashdb_save_enabled = 1;
    rdl_ignore_enabled = 1;
    rdl_ignore_names = "standart;shrshade";
    cl_downloadtimeout = 60;
    cl_predictself = 0;
    cl_forceplayerupdate = 0;
    cl_interp = 0;
    cl_deafen = 0;
  };

  commonExecStart =
    # Generate aliases bot_x which creates x bots
    (
      (flr: ceil:
        lib.concatStringsSep "\n" (lib.genList
          (
            n: let
              i = toString (flr + n);
            in "alias bots_${i} \"${let x = lib.genList (_: "call addbot") (flr + n); in lib.concatStringsSep ";" x}\";"
          )
          (ceil - flr + 1)))
      1
      64
    )
    + "\n";
in {
  coop = overrideAttrs @ {...}: let
    serverAttrs = {
      enable = true;
      order = 2;
      package = defaultPackage;
      maxPlayers = 24;
      gameMode = "coop";

      bots = {
        enable = true;
        count = 2;
      };

      mapsJson = rawCoopJson;

      settings =
        disableGraphicsSettings
        // commonSettings
        // {
          g_item_respawn_time = 125;
          g_timelimit = 60 * 60;
          g_scorelimit = 0;
          g_maxlives = 0;
          sv_master_interval = 54 * 1000;
        };
    };
  in
    lib.mkMerge [serverAttrs overrideAttrs];
  classic = overrideAttrs @ {...}: let
    serverAttrs = {
      enable = true;
      order = 1;
      package = defaultPackage;
      maxPlayers = 24;
      gameMode = "dm";

      bots = {
        enable = true;
        count = 3;
        allowKick = true;
        fillEmptyPlayerSlots = false;
      };

      mapsJson = rawDmJson;

      settings =
        disableGraphicsSettings
        // commonSettings
        // {
          sv_master_interval = 27 * 1000;
          g_timelimit = builtins.ceil (6.5 * 60);
          g_scorelimit = 35;
        };

      execStart = commonExecStart;
    };
  in
    lib.mkMerge [serverAttrs overrideAttrs];

  pubg = overrideAttrs @ {...}: let
    serverAttrs = {
      enable = true;
      order = 2;
      package = defaultPackage;
      maxPlayers = 24;
      gameMode = "pubg";

      bots = {
        enable = true;
        count = 24;
        allowKick = true;
        fillEmptyPlayerSlots = false;
      };

      mapsJson = rawPubgJson;

      settings =
        disableGraphicsSettings
        // commonSettings
        // {
          # Set to a very large number if you want to disable item respawn, because with 0, items don't respawn on new round
          g_item_respawn_time = builtins.ceil (2.5 * 60);
          g_powerup_respawn_time = builtins.ceil (4.5 * 60);
          g_powerup_time_random = 1 * 60;
          g_item_time_random = 1 * 60;

          g_timelimit = builtins.ceil (15 * 60);
          g_scorelimit = 0;
          g_maxlives = 1;
          g_warmup_time = 45;
          sv_master_interval = 27 * 1000;
          g_weaponstay = 0;
          g_max_bots = 255;

          g_friendlyfire = 0;
          g_team_hit_trace = 1;
          g_team_hit_projectile = 0;
          g_team_absorb_attacks = 1;
        };

      execStart = commonExecStart;
    };
  in
    lib.mkMerge [serverAttrs overrideAttrs];

  defrag = overrideAttrs @ {...}: let
    serverAttrs = {
      enable = true;
      order = 3;
      package = defaultPackage;
      maxPlayers = 24;
      gameMode = "defrag";

      bots = {
        enable = false;
        count = 0;
        allowKick = true;
        fillEmptyPlayerSlots = false;
      };

      mapsJson = rawDefragJson;

      settings =
        disableGraphicsSettings
        // commonSettings
        // {
          g_item_respawn_time = 1;
          g_timelimit = builtins.ceil (10 * 60);
          g_scorelimit = 0;
          sv_master_interval = 27 * 1000;
          g_weaponstay = 1;
          g_max_bots = 0;
          g_spawn_invul = 1;
        };

      execStart = commonExecStart;
    };
  in
    lib.mkMerge [serverAttrs overrideAttrs];

  duel = overrideAttrs @ {...}: let
    serverAttrs = {
      enable = true;
      package = defaultPackage;
      maxPlayers = 2;
      gameMode = "duel";

      bots = {
        enable = false;
        count = 0;
        allowKick = true;
        fillEmptyPlayerSlots = false;
      };

      mapsJson = rawDuelJson;

      settings =
        disableGraphicsSettings
        // commonSettings
        // {
          sv_master_interval = 27 * 1000;
        };

      execStart = commonExecStart;
    };
  in
    lib.mkMerge [serverAttrs overrideAttrs];
}
