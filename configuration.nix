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
    useDHCP = false;
    bridges = {
      externalbr0 = {
        interfaces = [ "enp1s0" ];
      };
    };
    interfaces = {
      externalbr0 = {
        useDHCP = true;
        macAddress = "db:31:3e:f2:f1:f6";
      };
    };
  }; 

  time.timeZone = "Europe/Helsinki";
  console.keyMap = "uk";
  i18n.defaultLocale = "en_GB.UTF-8";
  system.stateVersion = "25.05";
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
    pkgs.mkcert
  ];

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
    home.stateVersion = "25.05";
      
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
    incus = {
      enable = true;
      ui.enable = true;
      package = pkgs.incus.overrideAttrs (finalAttrs: previousAttrs: {
        pname = previousAttrs.pname + "-patched";
        patches =
          previousAttrs.patches
          ++ [
            ./patches/incus.patch # revert "oci improvements" https://github.com/lxc/incus/pull/1873
          ];
        }
      );
      preseed = {
        networks = [
          {
            name = "internalbr0";
            type = "bridge";
            description = "Internal/NATed bridge";
            config = {
              "ipv4.address" = "auto";
              "ipv4.nat" = "true";
              "ipv6.address" = "auto";
              "ipv6.nat" = "true";
            };
          }
        ];
        profiles = [
          {
            name = "default";
            description = "Default Incus Profile";
            devices = {
              eth0 = {
                name = "eth0";
                network = "internalbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "tank";
                type = "disk";
              };
            };
          }
          {
            name = "bridged";
            description = "Instances bridged to LAN";
            devices = {
              eth0 = {
                name = "eth0";
                nictype = "bridged";
                parent = "externalbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "tank";
                type = "disk";
              };
            };
          }
        ];
        storage_pools = [
          {
            name = "tank";
            driver = "zfs";
            config = {
              source = "tank/incus";
            };
          }
        ];
      };
    };
  };

  users.users.andy = {
    isNormalUser = true;
    description = "its me";
    extraGroups = [  "wheel" "incus-admin" ];
  };
}
