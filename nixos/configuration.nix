{ pkgs, hostname, ... }:

{
  # Import hardware configuration
  imports = [
    ./hardware-configuration.nix
    ../modules/users.nix
  ];

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
      experimental-features = nix-command flakes
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

  environment = {
    systemPackages = with pkgs; [ ];
    variables = {
      SHELL = "zsh";
      EDITOR = "nano";
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
    stateVersion = "25.05";
  };
}