{
  description = ''
    a wrapped claude-code, with additional tools.
  '';
  inputs.wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
  inputs.wrappers.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  outputs =
    { self
    , nixpkgs
    , wrappers
    , flake-parts
    , ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ wrappers.flakeModules.wrappers flake-parts.flakeModules.easyOverlay ];
      systems = nixpkgs.lib.platforms.all;

      perSystem =
        { pkgs, system, ... }:
        {
          _module.args.pkgs = import self.inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          packages.ccusage = pkgs.callPackage ./packages/ccusage.nix { };
          devShells.default = pkgs.mkShell {
            buildInputs = [ self.packages.${system}.ccusage self.packages.${system}.default ];
          };
        };

      flake.wrappers.default = ./wrapper.nix;
      flake.homeModules = {
        default = wrappers.lib.mkInstallModule {
          name = "claude-code";
          value = ./wrapper.nix;
          loc = [
            "home"
            "packages"
          ];
        };
      };
    };
}
