{ pkgs, hostname, custom, ... }:

{
  # Import hardware configuration
  imports = [
    ./hardware-configuration.nix
    ../home-manager/home.nix
    ../shared
  ];

  users = {
    users = {
      ${custom.username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh = {
          authorizedKeys = {
            keys = [
              custom.publicKey
            ];
          };
        };
        hashedPassword = custom.hashedPassword;
      };
      runner = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
    };
  };

  # Cross-compilation settings
  nixpkgs = {
    config = {
      allowUnsupportedSystem = true;
      crossSystem = {
        system = "aarch64-linux";
        config = "aarch64-unknown-linux-gnu";
      };
    };
  };

  # Nix package manager configuration
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
    settings = {
      trusted-users = [ "aloshy" "runner" ];
    };
  };

  # Boot configuration for ARM64
  boot = {
    loader = {
      grub.enable = false;  # Disable GRUB for ARM
      generic-extlinux-compatible.enable = true;  # Use extlinux for ARM
    };
  };

  # Network configuration
  networking = {
    hostName = hostname;
    # Static IP configuration
    interfaces = {
      end0 = {
        ipv4 = {
          addresses = [{
            address = "192.168.8.69";
            prefixLength = 24;
          }];
        };
      };
    };
    defaultGateway = {
      address = "192.168.8.1";
      interface = "end0";
    };
    nameservers = [ "192.168.8.1" ];
  };

  # System services configuration
  services = {
    # SSH server configuration
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = true;
      };
    };
    # Tailscale VPN configuration
    tailscale = {
      enable = true;
      authKeyFile = "/etc/tailscale/authkey";
      extraUpFlags = [
        "--ssh"
        "--advertise-exit-node"
      ];
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  system = {
    stateVersion = pkgs.lib.trivial.release;
  };
}
