{
 inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ci-detector = {
      url = "github:loophp/ci-detector";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
   };
 };

  nixConfig = {
    allow-impure-eval = true;
  };

 outputs = inputs@{ flake-parts, nixpkgs, home-manager, nix-darwin, mac-app-util, ci-detector, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, ... }:
   flake-parts.lib.mkFlake { inherit inputs; } {
     systems = [
       "x86_64-linux"
       "aarch64-darwin"
     ];

     flake = let
       custom = {
         username = "aloshy";
         email = "noreply@aloshy.ai";
         fullName = "aloshy.🅰🅸";
         publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzsLYdG0gkky7NCydRoqc0EMYEb61V+xsFKYJpH+ivV aloshy@ETHERFORGE.local";
         hashedPassword = "$6$OF89tQYOvaEHKCfx$KYSdQu/GHroUMovkUKUqbvUpEM51MurUpLob6E9YiEMWxvABDsrfACQxej02f9xuV5.HnNtMmpEoLDeAqCZfB1";
         hostnames = {
           darwin = "ethermac";
           nixos = "ethernix";
         };
       };
     in rec {
       inherit custom;

      #  homeManagerConfig = { config, pkgs, lib, system, ... }: {
      #    home-manager = {
      #      useGlobalPkgs = true;
      #      useUserPackages = true;
      #      backupFileExtension = "backup";
      #      extraSpecialArgs = { inherit custom; };
      #      users.${custom.username} = import ./shared/home.nix;
      #      sharedModules = lib.optionals (pkgs.stdenv.isDarwin) [
      #        mac-app-util.homeManagerModules.default
      #      ];
      #    };
      #  };

       darwinConfigurations = let
         mkDarwinSystem = hostname: nix-darwin.lib.darwinSystem {
           system = "aarch64-darwin";
           specialArgs = { 
             inherit custom hostname ci-detector nix-homebrew homebrew-core homebrew-cask homebrew-bundle;
           };
           modules = [
             ./darwin/configuration.nix
             mac-app-util.darwinModules.default
             home-manager.darwinModules.home-manager
             nix-homebrew.darwinModules.nix-homebrew
           ];
         };
       in {
         ${custom.hostnames.darwin} = mkDarwinSystem custom.hostnames.darwin;
       };

       nixosConfigurations = let
         mkNixosSystem = hostname: nixpkgs.lib.nixosSystem {
           system = "aarch64-linux";
           specialArgs = { 
             inherit custom hostname;
           };
           modules = [
             ./nixos/configuration.nix
             home-manager.nixosModules.home-manager
           ];
         };
       in {
         ${custom.hostnames.nixos} = mkNixosSystem custom.hostnames.nixos;
       };
     };

     perSystem = { config, self', inputs', pkgs, system, ... }: {
       devShells.default = pkgs.mkShell {
         packages = with pkgs; [
           nixfmt
         ];
         shellHook = pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
           ${pkgs.mac-app-util}/bin/mac-app-util sync-binary-store-apps
         '';
       };
     };
   };
}
