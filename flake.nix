{
  description = "NixOS notebook config with Home Manager and SOPS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      nixos-hardware,
      nix-darwin,
      ...
    }:
    let
      system = "x86_64-linux";
      hostname = "nodebook";
      username = "karafra";

      mkApp = scriptName: system: {
        type = "app";
        program = "${
          nixpkgs.legacyPackages.${system}.writeShellScriptBin scriptName ''
            export PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
            echo "Running ${scriptName} for ${system}"
            exec ${self}/apps/run ${system} ${scriptName} "$@"
          ''
        }/bin/${scriptName}";
      };
    in
    {
      apps = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (system: {
        build = mkApp "build" system;
        build-switch = mkApp "build-switch" system;
      });

      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./hosts/${hostname}/configuration.nix
          ./modules/shared/default.nix
          ./modules/system/default.nix
          nixos-hardware.nixosModules.common-pc-laptop
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username}.imports = [ ./home/karafra/default.nix ];
          }
        ];

        specialArgs = {
          inherit username hostname;
        };
      };

      darwinConfigurations.macbook =
        let
          macUser = "matustoth";
        in
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";

          modules = [
            ./hosts/macbook/configuration.nix
            home-manager.darwinModules.home-manager
            sops-nix.darwinModules.sops
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${macUser}.imports = [
                ./home/matustoth/default.nix
                sops-nix.homeManagerModules.sops
              ];
            }
          ];

          specialArgs = {
            username = macUser;
          };
        };
    };
}
