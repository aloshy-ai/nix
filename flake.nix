{
 inputs = {
    nixpkgs.url = "github:nixpkgs/nixpkgs/nixos-unstable";
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

     flake = rec {
       userConfig = {
         username = "aloshy";
         email = "noreply@aloshy.ai";
         fullName = "aloshy.🅰🅸";
         publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzsLYdG0gkky7NCydRoqc0EMYEb61V+xsFKYJpH+ivV aloshy@ETHERFORGE.local";
         hashedPassword = "$6$OF89tQYOvaEHKCfx$KYSdQu/GHroUMovkUKUqbvUpEM51MurUpLob6E9YiEMWxvABDsrfACQxej02f9xuV5.HnNtMmpEoLDeAqCZfB1";
       };

       homeManagerConfig = { config, ... }: {
         home-manager = {
           useGlobalPkgs = true;
           useUserPackages = true;
           users.${config.userConfig.username} = 
             import ./home-manager/home.nix { inherit (config) userConfig; };
         };
       };

       nixosConfigurations.ethernix = inputs.nixpkgs.lib.nixosSystem {
         system = "aarch64-linux";
         specialArgs = { inherit userConfig; };
         modules = [
           ./nixos/configuration.nix
           inputs.home-manager.nixosModules.home-manager
           homeManagerConfig
         ];
       };

       darwinConfigurations.ethermac = inputs.darwin.lib.darwinSystem {
         system = "aarch64-darwin";
         specialArgs = { inherit userConfig; };
         modules = [
           ./darwin/configuration.nix
           inputs.home-manager.darwinModules.home-manager
           homeManagerConfig
         ];
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