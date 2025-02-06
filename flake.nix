{
 inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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

 outputs = inputs@{ flake-parts, nixpkgs, home-manager, nix-darwin, mac-app-util, ci-detector, ... }:
   flake-parts.lib.mkFlake { inherit inputs; } {
     systems = [
       "x86_64-linux"
       "aarch64-darwin"
     ];

     flake = let
       hostnames = {
         darwin = "ethermac";
         nixos = "ethernix";
       };
     in rec {
       custom = {
         username = "aloshy";
         email = "noreply@aloshy.ai";
         fullName = "aloshy.🅰🅸";
         publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzsLYdG0gkky7NCydRoqc0EMYEb61V+xsFKYJpH+ivV aloshy@ETHERFORGE.local";
         hashedPassword = "$6$OF89tQYOvaEHKCfx$KYSdQu/GHroUMovkUKUqbvUpEM51MurUpLob6E9YiEMWxvABDsrfACQxej02f9xuV5.HnNtMmpEoLDeAqCZfB1";
       };

       homeManagerConfig = { config, pkgs, lib, system, ... }: {
         home-manager = {
           useGlobalPkgs = true;
           useUserPackages = true;
           backupFileExtension = "backup";
           extraSpecialArgs = { inherit custom; };
           sharedModules = lib.optionals (pkgs.stdenv.isDarwin) [
             mac-app-util.homeManagerModules.default
           ];
           users.${custom.username} = import ./shared/home.nix;
         };
       };

       darwinConfigurations = let
         mkDarwinSystem = hostname: nix-darwin.lib.darwinSystem {
           system = "aarch64-darwin";
           specialArgs = { 
             inherit custom hostname ci-detector;
           };
           modules = [
             ./darwin/configuration.nix
             mac-app-util.darwinModules.default
             home-manager.darwinModules.home-manager
             homeManagerConfig
           ];
         };
       in {
         ${hostnames.darwin} = mkDarwinSystem hostnames.darwin;
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
             homeManagerConfig
           ];
         };
       in {
         ${hostnames.nixos} = mkNixosSystem hostnames.nixos;
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
