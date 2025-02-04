{
 inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
   };
 };

 outputs = inputs@{ flake-parts, ... }:
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
       userConfig = {
         username = "aloshy";
         email = "noreply@aloshy.ai";
         fullName = "aloshy.🅰🅸";
         publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzsLYdG0gkky7NCydRoqc0EMYEb61V+xsFKYJpH+ivV aloshy@ETHERFORGE.local";
         hashedPassword = "$6$OF89tQYOvaEHKCfx$KYSdQu/GHroUMovkUKUqbvUpEM51MurUpLob6E9YiEMWxvABDsrfACQxej02f9xuV5.HnNtMmpEoLDeAqCZfB1";
       };

       homeManagerConfig = { config, pkgs, ... }: {
         home-manager = {
           users.${userConfig.username} = import ./home-manager/home.nix {
             inherit (pkgs) pkgs;
             inherit userConfig;
           };
         };
       };

       darwinConfigurations = let
         mkDarwinSystem = hostname: inputs.nix-darwin.lib.darwinSystem {
           system = "aarch64-darwin";
           specialArgs = { 
             inherit userConfig hostname;
           };
           modules = [
             ./darwin/configuration.nix
             inputs.home-manager.darwinModules.home-manager
             inputs.home-manager.darwinModules.home-manager
             {
               home-manager = {
                 useGlobalPkgs = true;
                 useUserPackages = true;
                 extraSpecialArgs = { 
                   inherit userConfig hostname;
                 };
                 users.${userConfig.username} = import ./home-manager/home.nix;
                 backupFileExtension = "backup";
               };
             }
           ];
         };
       in {
         ${hostnames.darwin} = mkDarwinSystem hostnames.darwin;
       };

       nixosConfigurations = let
         mkNixosSystem = hostname: inputs.nixpkgs.lib.nixosSystem {
           system = "aarch64-linux";
           specialArgs = { 
             inherit userConfig hostname;
           };
           modules = [
             ./nixos/configuration.nix
             inputs.home-manager.nixosModules.home-manager
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
       };
     };
   };
}
