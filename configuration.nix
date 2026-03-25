# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
in
{
imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/nvidia.nix
      ./openclaw.nix
    ];

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      #systemd-boot.configurationLimit = 5;
      timeout = 3;
    };
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internaXFCEtionalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the greetd Desktop Environment.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --cmd Hyprland --user-menu";
	user = "greeter";
      };
    };
  };

systemd.services.greetd = {
  after = [ "systemd-user-sessions.service" ];
  wants = [ "systemd-user-sessions.service" ];
};

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;

  # Enable ALSA sound
  security.rtkit.enable = true;

  # PipeWire configuration
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hangsai = {
    isNormalUser = true;
    description = "hangsai";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowInsecure = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Fonts
  fonts.fontDir.enable = true;
  fonts.fontconfig.enable = true;


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alsa-utils
    pavucontrol
    bibata-cursors
    brightnessctl
    bluez
    bluez-alsa
    bluez-tools
    bluetui
    btop
    cliphist
    coreutils
    curl
    dunst
    grim
    hyprpaper
    imagemagick
    jq
    libnotify
    (unstable.llama-cpp.override { cudaSupport = true; })
    networkmanagerapplet
    nvtop
    pamixer
    playerctl
    rofi-wayland
    slurp
    swaynotificationcenter
    swaylock-effects
    swww
    greetd.tuigreet
    uv
    wofi
    wlogout
    waybar
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
    }))

    #openclaw
    google-cloud-sdk

    # Terminals
    kitty
    unstable.opencode
    nodejs_22
    vim
    zsh
    unstable.codex
    unstable.antigravity

    # SRE
    docker-compose
    kubectl
    kubernetes
    k3s
    kubernetes-helm
    skopeo

    # Media
    spotify

    # fonts
    (pkgs.nerdfonts.override {
      fonts = [
        "IBMPlexMono"
        "Iosevka"
        "IosevkaTerm"
        "JetBrainsMono"
      ];
    })

    # themes
    libsForQt5.qt5.qtquickcontrols
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.full
    sddm-sugar-dark
  ];
  fonts.packages = with pkgs; [
    font-awesome
    powerline-fonts
    powerline-symbols
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];

 # Enable swaylock PAM authentication
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  # Set swaylock as the system screen locker
  #programs.swaylock = {
  #  enable = true;
  #  package = pkgs.swaylock-effects;
  #};

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "breeze";
  };

  programs.nix-ld.enable = true;
  programs.thunar.enable = true;
  programs.hyprland.enable = true;
  environment.variables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable docker
  virtualisation.docker = {
    enable = true;
  };

  # Basic k3s configuration without custom containerd
  services.k3s = {
    enable = true;
    role = "server";
    # Remove the custom containerd flag
  };

  # llama setup

  # If you use NVIDIA on NixOS:
   nixpkgs.config.cudaSupport = true;
   services.xserver.videoDrivers = [ "nvidia" ];
   # hardware.nvidia.open = true; # (if you're on newer kernels/GPU)
   hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  # Enable the OpenSSH daemon.
   services.openssh.enable = true;

  # Open ports in the firewall.
  # port for kubernetes Api-server
  networking.firewall.allowedTCPPorts = [ 6443 11434 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.extraHosts = ''
    192.168.1.201 rust-server.local
    127.0.0.1 n8n.local
  '';

  system.stateVersion = "24.11"; # Did you read the comment?
}
