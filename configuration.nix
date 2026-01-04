{ config, pkgs, ... }:

{
  imports = 
    [
      ./hardware-configuration.nix
       <home-manager/nixos>
    ];
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];

  fileSystems."/" = {
    device = "main/root";
    fsType = "zfs";
  };
  fileSystems."/nix" = {
    device = "main/nix";
    fsType = "zfs";
  };
  fileSystems."/var" = {
    device = "main/var";
    fsType = "zfs";
  };
  fileSystems."/home" = {
    device = "main/home";
    fsType = "zfs";
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  networking = {
    hostId = "bc86c916";
    hostName = "anvil";
    tempAddresses = "disabled";
    nftables.enable = true;
    firewall.enable = false;
    useDHCP = true;
  }; 

  time.timeZone = "Europe/Helsinki";
  console.keyMap = "uk";
  i18n.defaultLocale = "en_GB.UTF-8";
  system.stateVersion = "25.11";
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    allowReboot = true;
  };

  environment.systemPackages = [
    (pkgs.kitty.overrideAttrs (old: {
      meta = old.meta // {
        outputsToInstall = [ "terminfo" ];
      };
    }))
    pkgs.opentofu
    pkgs.ripgrep
    pkgs.dig
    pkgs.certbot-full
    pkgs.git
    pkgs.mkcert
    pkgs.podman-tui
  ];

  environment.etc = {
    "containers/registries.conf.d/localhost.conf" = {
      text = ''
        [[registry]]
        location = "localhost:5000"
        insecure = true
      '';
    };
  };

  services = {
    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };

    tailscale.enable = true;
    
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  security.pki.certificateFiles = [
    /home/andy/.local/share/mkcert/rootCA.pem
  ];

  home-manager.users.andy = { pkgs, ... }: {
    home.packages = with pkgs; [ ];
    home.stateVersion = "25.11";
      
    programs.helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        theme = "kanabox_default";
        editor = {
          bufferline = "always";
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          whitespace = {
            render = "all";
          };
          file-picker = {
            hidden = false;
          };
        };
      };
    };
    
  };
  
  virtualisation = {
    containers = {
      enable = true;
      storage.settings.storage = {
        driver = "zfs";
        graphroot = "/var/lib/containers/storage";
        runroot = "/run/containers/storage";
      };
    };
    # lxd.zfsSupport = true;
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
      extraPackages  = [ pkgs.zfs ];
    };

    oci-containers = {
      backend = "podman";

      containers = {
        zot = {
          image = "ghcr.io/project-zot/zot:v2.1.11";
          autoStart = true;
          ports = [ "0.0.0.0:5000:5000" ];
          volumes = [
            "/root/containers/zot/config.json:/etc/zot/config.json"
            "/root/containers/storage/zot:/var/lib/registry"
          ];
        };

        lb = {
          image = "localhost:5000/apps/caddy/caddy:0";
          autoStart = true;
          ports = [
            "0.0.0.0:80:80"
            "0.0.0.0:443:443"
          ];
          environmentFiles = [
            "/root/containers/lb/secrets.env"
          ];
          volumes = [
            "/root/containers/lb/Caddyfile:/etc/caddy/Caddyfile"
          ];
        };
      };
    };
  };

  users.users.andy = {
    isNormalUser = true;
    description = "its me";
    extraGroups = [  "wheel" "incus-admin" ];
  };
}
