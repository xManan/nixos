{ config, lib, pkgs, ... }:

let
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
	  gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };

in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "laptop";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Kolkata";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };

  users.users.manan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    XDG_BIN_HOME = "$HOME/.local/bin";
    PATH = [
      "${XDG_BIN_HOME}"
	  "$HOME/go/bin"
    ];
  };

  environment.etc."xdg/user-dirs.defaults".text = ''
    DESKTOP=system/desktop
    DOWNLOAD=downloads
    TEMPLATES=system/templates
    PUBLICSHARE=system/public
    DOCUMENTS=documents
    MUSIC=media/music
    PICTURES=media/photos
    VIDEOS=media/videos
  '';

  environment.systemPackages = with pkgs; [
    dbus
    dbus-sway-environment
    configure-gtk
    wayland
    xdg-utils
    xdg-user-dirs
    glib
    dracula-theme
    gnome3.adwaita-icon-theme
    swaylock
    swayidle
    grim
    wl-clipboard
    mako # notification system developed by swaywm maintainer
    wdisplays # tool to configure displays
    wget
    brave
	cinnamon.nemo
    alacritty
    git
	gnumake
	fzf
	ripgrep
	fd
	gcc
	nodejs
	deluge
	go
	libnotify
	# LSP's
	lua-language-server
	gopls
	nixd
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add missing dlls
  ];

  fonts.packages = with pkgs; [
    font-awesome
    jetbrains-mono
  ];

  services.dbus.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      v = "nvim";
    };
    ohMyZsh = {
    	enable = true;
	plugins = [ "git" ];
	theme = "robbyrussell";
    };
  };
  
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.tmux = {
	enable = true;
  };

  virtualisation.docker.rootless = {
    enable = true;
	setSocketVariable = true;
  };

  system.copySystemConfiguration = true;
  system.stateVersion = "23.11"; # Read-Only
}
