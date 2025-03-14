{
  config,
  lib,
  pkgs,
  ...
}: let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
  nix-alien-pkgs = import (
    builtins.fetchTarball "https://github.com/thiagokokada/nix-alien/tarball/master"
  ) {};
in {
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  imports = [
    ./hardware-configuration.nix
    ./flatpak.nix
    (import "${home-manager}/nixos")
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = ["amdgpu"];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Kolkata";

  i18n.defaultLocale = "en_US.UTF-8";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.graphics = {
    extraPackages = [pkgs.amdvlk];
    extraPackages32 = [pkgs.driversi686Linux.amdvlk];
    enable32Bit = true;
  };

  environment.pathsToLink = ["/libexec"];

  services.openssh.enable = true;
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    desktopManager = {
      xterm.enable = false;
    };

    videoDrivers = ["amdgpu"];

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
      ];
    };
  };

  services.displayManager = {
    defaultSession = "none+i3";
  };

  programs.zsh.enable = true;
  programs.dconf.enable = true;
  programs.nix-ld.enable = true;
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  xdg.portal.config.common.default = "*";

  users.users.manan = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "audio" "tty" "dialout"];
    shell = pkgs.zsh;
    packages = with pkgs; [
    ];
  };

  home-manager.users.manan = {
    home.stateVersion = "24.05";

    dconf = {
      enable = true;
      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
    };

    home.pointerCursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 16;
    };

    home.sessionVariables = {
      TERM = "xterm-256color";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
      XDG_BIN_HOME = "$HOME/.local/bin";

      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    };

    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home-manager.users.manan.home.homeDirectory}/system/desktop";
      download = "${config.home-manager.users.manan.home.homeDirectory}/downloads";
      templates = "${config.home-manager.users.manan.home.homeDirectory}/system/templates";
      publicShare = "${config.home-manager.users.manan.home.homeDirectory}/system/public";
      documents = "${config.home-manager.users.manan.home.homeDirectory}/documents";
      music = "${config.home-manager.users.manan.home.homeDirectory}/media/music";
      pictures = "${config.home-manager.users.manan.home.homeDirectory}/media/photos";
      videos = "${config.home-manager.users.manan.home.homeDirectory}/media/videos";
    };

    home.sessionPath = [
      "$XDG_BIN_HOME"
      "$HOME/go/bin"
    ];

    systemd.user.sessionVariables = config.home-manager.users.manan.home.sessionVariables;

    programs.kitty = {
      enable = true;
      font = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
        size = 16;
      };
      themeFile = "Kaolin_Aurora";
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
        v = "nvim";
        vi = "nvim";
        vim = "nvim";
        dev = "nix develop --command zsh";
        ytmp3 = "yt-dlp -x --add-metadata --audio-quality 0 --audio-format mp3";
      };

      history = {
        size = 10000;
      };

      oh-my-zsh = {
        enable = true;
        plugins = ["git" "thefuck"];
        theme = "robbyrussell";
      };
    };

    programs.git = {
      enable = true;
      userName = "Manan Chawla";
      userEmail = "mananchawla10@gmail.com";
    };

    programs.neovim.enable = true;

    home.packages = with pkgs; [
      nemo
      thefuck
      nix-alien-pkgs.nix-alien
      dbeaver-bin
      mangohud
      protonup
      apostrophe
      flameshot
      networkmanagerapplet
      pasystray
      mpv
      deluge
      clipit
      gcc
      gnumake
      fd
      ripgrep
      xclip
      fzf
      gimp
      sqlitebrowser
      stow
      (pass.withExtensions (exts: [passExtensions.pass-otp]))
      (lutris.override {
        extraLibraries = pkgs: [
        ];
        extraPkgs = pkgs: [
        ];
      })
      heroic
      htop
      hoppscotch
      nodejs_23
      arduino-ide
      yt-dlp
      blender

      # lsp
      phpactor
      gopls
      lua-language-server
    ];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.tmux.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.gamemode.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    alejandra
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  system.copySystemConfiguration = true;

  system.stateVersion = "24.11";
}
