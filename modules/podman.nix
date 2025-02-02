{ config, pkgs, lib, ... }:
{
  options.virtualisation.podman = {
    enable = lib.mkEnableOption "Podman container engine";
    dockerCompat = lib.mkEnableOption "Create docker to podman alias";
  };

  config = lib.mkIf config.virtualisation.podman.enable {
    environment.systemPackages = with pkgs; [
      podman
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      vfkit
    ] ++ lib.optionals config.virtualisation.podman.dockerCompat [
      (runCommand "${podman.pname}-docker-compat-${podman.version}"
        {
          outputs = [ "out" "man" ];
          inherit (podman) meta;
        }
        ''
          mkdir -p $out/bin
          ln -s ${lib.getExe podman} $out/bin/docker

          mkdir -p $man/share/man/man1
          for f in ${podman.man}/share/man/man1/*; do
            basename=$(basename $f | sed s/podman/docker/g)
            ln -s $f $man/share/man/man1/$basename
          done
        '')
    ];

    # NixOS-specific configuration
    services = lib.mkIf (!pkgs.stdenv.isDarwin) {
      podman = {
        enable = true;
        dockerSocket.enable = config.virtualisation.podman.dockerCompat;
        defaultNetwork.settings.dns_enabled = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
      };
    };
  };
}