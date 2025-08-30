# 🚀 NixOS Gaming & Development Configuration
# Optimized for ASUS TUF Gaming A15 (AMD Ryzen 9 7940HS + RTX 4050 Max-Q)
# Perfect for gaming, development, and creative work
# 
# ⚠️  IMPORTANT: This configuration is tailored for a specific laptop model.
#     You'll need to adjust hardware settings, GPU bus IDs, and possibly
#     remove/modify drivers for your system. Configuration created with
#     assistance from Claude AI.
# 
# Features:
# - NVIDIA RTX 4050 Max-Q + AMD Radeon 780M hybrid graphics
# - Fish shell with beautiful white/gray theme
# - Comprehensive development tools (Docker, multiple languages)
# - Gaming optimizations (Steam, GameMode, MangoHUD)
# - Creative software (Blender, GIMP, Kdenlive, OBS)
# - Auto-installed Flatpak apps (Vesktop, Sober)
# - Clean GNOME with useful extensions
# 
# Usage:
# 1. Replace /etc/nixos/configuration.nix with this file
# 2. Update GPU bus IDs by running: lspci | grep VGA
# 3. Modify hardware-specific settings for your system
# 4. Run: sudo nixos-rebuild switch
# 5. Reboot for full functionality

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ===========================
  # BOOTLOADER & KERNEL
  # ===========================
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  
  # Performance optimizations for gaming
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "amd_pstate=active"  # Better AMD CPU power management
    "processor.max_cstate=1"  # Better performance for gaming
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"  # NVIDIA suspend fix
  ];

  # Performance tweaks
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 10;
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
  };

  # ===========================
  # HARDWARE & DRIVERS
  # ===========================

  # AMD and NVIDIA graphics with 32-bit support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # AMD GPU drivers (for integrated Radeon 780M)
      rocmPackages.clr.icd
      amdvlk
      # VAAPI drivers for hardware acceleration
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
      # 32-bit support for older games
      pkgsi686Linux.libva
      pkgsi686Linux.mesa
    ];
  };

  # NVIDIA RTX 4050 Max-Q hybrid graphics configuration
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;  # Use proprietary driver for RTX 4050 Max-Q
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      sync.enable = true;  # For better gaming performance
      # IMPORTANT: Update these bus IDs with: lspci | grep VGA
      amdgpuBusId = "PCI:65:0:0";  # AMD Radeon 780M (integrated)
      nvidiaBusId = "PCI:1:0:0";   # RTX 4050 Max-Q (discrete)
    };
  };

  # Hardware support
  hardware.steam-hardware.enable = true;
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;
  powerManagement.enable = true;

  # ===========================
  # NETWORKING & SYSTEM
  # ===========================

  networking.hostName = "nix";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;  # Better WiFi performance
  
  time.timeZone = "Europe/Bucharest";
  
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ro_RO.UTF-8";
    LC_IDENTIFICATION = "ro_RO.UTF-8";
    LC_MEASUREMENT = "ro_RO.UTF-8";
    LC_MONETARY = "ro_RO.UTF-8";
    LC_NAME = "ro_RO.UTF-8";
    LC_NUMERIC = "ro_RO.UTF-8";
    LC_PAPER = "ro_RO.UTF-8";
    LC_TELEPHONE = "ro_RO.UTF-8";
    LC_TIME = "ro_RO.UTF-8";
  };

  # ===========================
  # DESKTOP ENVIRONMENT
  # ===========================

  # GNOME with Wayland support
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # GNOME optimizations and customizations
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.privacy]
    report-technical-problems=false
    
    [org.gnome.desktop.interface]
    show-battery-percentage=true
    clock-show-weekday=true
    
    [org.gnome.desktop.wm.preferences]
    button-layout='appmenu:minimize,maximize,close'
    
    [org.gnome.mutter]
    experimental-features=['scale-monitor-framebuffer']
  '';
  
  # Remove GNOME bloatware
  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour gnome-connections gnome-contacts gnome-maps gnome-weather
    gnome-clocks gnome-calendar gnome-music gnome-photos epiphany cheese
    simple-scan totem geary seahorse yelp gnome-font-viewer gnome-characters
    gnome-logs gnome-disk-utility baobab
    # Games
    gnome-chess gnome-mahjongg gnome-mines gnome-nibbles gnome-robots
    gnome-sudoku gnome-taquin gnome-tetravex four-in-a-row hitori iagno
    lightsoff swell-foop tali quadrapassel atomix
  ]);

  # Keyboard configuration
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ===========================
  # AUDIO & MULTIMEDIA
  # ===========================

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;  # For audio production
    wireplumber.enable = true;
  };

  services.pulseaudio.support32Bit = true;

  # ===========================
  # GAMING & COMPATIBILITY
  # ===========================

  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # Flatpak for additional software
  services.flatpak.enable = true;

  # ===========================
  # DEVELOPMENT TOOLS
  # ===========================

  programs.git.enable = true;
  programs.zsh.enable = true;
  programs.java.enable = true;
  programs.nix-ld.enable = true;

  # Docker for development
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Fish shell with beautiful theme
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "eza -la --icons --group-directories-first";
      ls = "eza --icons --group-directories-first";
      tree = "eza --tree --icons";
      cat = "bat";
      grep = "ripgrep";
      find = "fd";
      ff = "fastfetch";
    };
    shellInit = ''
      # Fastfetch on shell startup
      fastfetch
      
      # Snow/gray theme colors
      set -g fish_color_normal brwhite
      set -g fish_color_command white --bold
      set -g fish_color_quote brblack
      set -g fish_color_redirection bryellow
      set -g fish_color_end white
      set -g fish_color_error brred
      set -g fish_color_param brwhite
      set -g fish_color_selection --background=brblack
      set -g fish_color_search_match --background=brblack
      set -g fish_color_operator bryellow
      set -g fish_color_escape brcyan
      set -g fish_color_autosuggestion brblack
      set -g fish_pager_color_completion brwhite
      set -g fish_pager_color_description brblack
      set -g fish_pager_color_prefix white --bold
      set -g fish_pager_color_progress brblack
    '';
    interactiveShellInit = ''
      set fish_greeting
      starship init fish | source
    '';
  };

  # ===========================
  # USER CONFIGURATION
  # ===========================

  users.users.four = {
    isNormalUser = true;
    description = "four";
    extraGroups = [ "networkmanager" "wheel" "docker" "audio" "video" "gamemode" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      # Browsers
      floorp
      
      # Gaming
      steam
      lutris
      bottles
      prismlauncher
      heroic
      gamemode
      mangohud
      
      # Development Tools
      vscode
      neovim
      git
      gh
      docker
      docker-compose
      nodejs
      python3
      rustc
      cargo
      go
      temurin-bin-17  # OpenJDK 17 (LTS)
      maven
      gradle
      
      # Additional dev tools
      insomnia    # API testing
      meld        # Visual diff tool
      sqlitebrowser # SQLite database browser
      
      # Compatibility layers & runtimes
      wine
      winetricks
      bottles
      steam-run
      appimage-run
      
      # Additional runtimes
      dotnet-runtime_8
      dotnet-sdk_8
      mono
      
      # Build tools & libraries
      gcc
      clang
      cmake
      pkg-config
      meson
      ninja
      
      # Creative Software
      gimp
      inkscape
      blender
      kdePackages.kdenlive
      obs-studio
      audacity
      
      # System Tools
      fastfetch
      htop
      btop
      neofetch
      tree
      wget
      curl
      unzip
      zip
      
      # Advanced system utilities
      lm_sensors
      powertop
      iotop
      nethogs
      ncdu
      ripgrep
      fd
      bat
      eza
      fzf
      tmux
      
      # Password management & security
      bitwarden
      
      # Screen capture/recording
      flameshot
      peek
      
      # PDF and document viewers
      evince
      
      # Torrenting
      qbittorrent
      
      # GNOME Enhancement Tools
      gnome-tweaks
      gnomeExtensions.user-themes
      gnomeExtensions.dash-to-dock
      gnomeExtensions.appindicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.gsconnect
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.caffeine
      gnomeExtensions.vitals
      gnomeExtensions.pop-shell
      gnomeExtensions.removable-drive-menu
      gnomeExtensions.sound-output-device-chooser
      dconf-editor
      
      # Additional utilities
      gparted
      deja-dup
      gnome-calculator
      gnome-text-editor
      file-roller
      
      # Communication
      signal-desktop
      telegram-desktop
      
      # Media
      vlc
      mpv
      
      # Productivity
      libreoffice
      
      # Terminal enhancements
      zsh
      oh-my-zsh
      starship
      
      # File managers
      nautilus
      ranger
    ];
  };

  # ===========================
  # SYSTEM PACKAGES & FONTS
  # ===========================

  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = with pkgs; [
    # Essential tools
    vim wget curl git
    
    # Build tools & compatibility
    gcc cmake pkg-config
    
    # GPU tools
    glxinfo vulkan-tools nvidia-vaapi-driver libva-utils
    
    # Performance monitoring
    hwinfo lshw pciutils usbutils
    
    # Compression & archives
    p7zip unrar zip unzip
    
    # Network tools
    networkmanager
    
    # Compatibility libraries
    libGL libGLU alsa-lib zlib openssl fuse
  ];

  # Comprehensive font support for icons and UI
  fonts.packages = with pkgs; [
    # Base fonts
    noto-fonts noto-fonts-cjk-sans noto-fonts-emoji liberation_ttf
    
    # Programming fonts
    fira-code fira-code-symbols jetbrains-mono source-code-pro
    ubuntu_font_family cascadia-code
    
    # UI fonts
    inter roboto open-sans lato dejavu_fonts freefont_ttf gyre-fonts
    
    # Icon and symbol fonts
    font-awesome material-icons material-design-icons material-symbols
    
    # Nerd fonts for terminal icons
    nerd-fonts.fira-code nerd-fonts.jetbrains-mono nerd-fonts.sauce-code-pro
    nerd-fonts.ubuntu-mono nerd-fonts.dejavu-sans-mono nerd-fonts.hack
    nerd-fonts.meslo-lg nerd-fonts.symbols-only
    
    # Additional symbol fonts
    symbola unifont
    
    # Legacy compatibility
    mplus-outline-fonts.githubRelease dina-font proggyfonts
  ];

  # ===========================
  # SYSTEM SERVICES
  # ===========================

  services.printing.enable = true;
  services.openssh.enable = false;
  services.locate.enable = true;
  services.fstrim.enable = true;  # SSD optimization
  services.fwupd.enable = true;   # Firmware updates
  services.libinput.enable = true;

  # Better scheduling and memory management
  programs.iotop.enable = true;
  zramSwap.enable = true;
  zramSwap.memoryPercent = 25;

  # Firewall
  networking.firewall.enable = true;

  # ===========================
  # FLATPAK AUTO-INSTALLATION
  # ===========================

  # Automatic Flatpak setup
  systemd.services.flatpak-repo-setup = {
    description = "Setup Flatpak repositories";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "setup-flatpak-repos" ''
        ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo
        ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists --system flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
      '';
    };
  };
  
  systemd.services.flatpak-app-install = {
    description = "Install essential Flatpak apps";
    wantedBy = [ "multi-user.target" ];
    after = [ "flatpak-repo-setup.service" ];
    wants = [ "flatpak-repo-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "install-flatpak-apps" ''
        # Install Vesktop (better Discord client with Vencord)
        ${pkgs.flatpak}/bin/flatpak install --noninteractive --system flathub dev.vencord.Vesktop || true
        # Install Sober (Roblox client for Linux)
        ${pkgs.flatpak}/bin/flatpak install --noninteractive --system flathub org.vinegarhq.Sober || true
      '';
    };
  };

  # ===========================
  # CUSTOM CONFIGURATIONS
  # ===========================

  # Fastfetch configuration - minimal and clean
  environment.etc."fastfetch/config.jsonc" = {
    text = ''
      {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {
          "source": "nixos_small",
          "color": { "1": "white", "2": "white" }
        },
        "display": {
          "separator": " ❯ ",
          "color": { "separator": "white", "key": "white", "output": "white" }
        },
        "modules": [
          { "type": "title", "color": { "user": "white", "at": "white", "host": "white" } },
          { "type": "separator", "string": "─────────────────" },
          { "type": "os", "key": "OS", "format": "{3}" },
          { "type": "host", "key": "Host" },
          { "type": "kernel", "key": "Kernel" },
          { "type": "uptime", "key": "Uptime" },
          { "type": "shell", "key": "Shell" },
          { "type": "de", "key": "DE" },
          { "type": "cpu", "key": "CPU" },
          { "type": "gpu", "key": "GPU", "format": "{2}" },
          { "type": "memory", "key": "Memory" },
          { "type": "break" },
          { "type": "colors", "paddingLeft": 2, "symbol": "circle" }
        ]
      }
    '';
    mode = "0444";
  };
  
  # Starship prompt configuration
  environment.etc."starship.toml" = {
    text = ''
      format = """
      $username\
      $hostname\
      $directory\
      $git_branch\
      $git_state\
      $git_status\
      $cmd_duration\
      $line_break\
      $character"""
      
      [username]
      style_user = "white bold"
      style_root = "red bold"
      format = "[$user]($style)"
      disabled = false
      show_always = true
      
      [hostname]
      ssh_only = false
      format = "[@$hostname](bold white)"
      disabled = false
      
      [directory]
      style = "bold cyan"
      format = " [$path]($style)"
      truncation_length = 3
      truncation_symbol = "…/"
      
      [git_branch]
      symbol = " "
      format = " [$symbol$branch]($style)"
      style = "bright-white"
      
      [git_status]
      format = '([\[$all_status$ahead_behind\]]($style))'
      style = "cyan"
      
      [git_state]
      format = '\([$state( $progress_current/$progress_total)]($style)\) '
      style = "bright-black"
      
      [cmd_duration]
      format = " [$duration]($style)"
      style = "yellow"
      
      [character]
      success_symbol = "[❯](bold white)"
      error_symbol = "[❯](bold red)"
    '';
    mode = "0444";
  };

  # This value determines the NixOS release
  system.stateVersion = "25.05";
}

# ===========================
# ADDITIONAL SETUP NOTES
# ===========================
#
# After installing:
# 1. Update GPU bus IDs: lspci | grep VGA
# 2. Install additional Flatpaks: flatpak install flathub <app-id>
# 3. Configure GNOME extensions via Extensions app
# 4. Set up development environments as needed
# 5. Enjoy your optimized NixOS gaming/dev setup! 🚀
