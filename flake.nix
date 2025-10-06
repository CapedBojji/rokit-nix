{
  description = "Description for the project";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs@{ flake-parts, devenv-root, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        packages.default = pkgs.rustPlatform.buildRustPackage rec {
          owner = "rojo-rbx"; 
          pname = "rokit";
          version = "v1.2.0";
          src = pkgs.fetchFromGitHub {
              owner = owner;
              repo = pname;
              rev = version;
              hash = "sha256-cGsxfz3AT8W/EYk3QxVfZ8vd6zGNx1Gn6R1SWCYbVz0=";
          };

          cargoHash = "sha256-Z/egZ/OC68GbJjwMOrCrUX2JWMqXwppoSzz0q4Nbg+A=";
          # postInstall =''
          #   export ROKIT_ROOT=$out
          #   $out/bin/rokit self-install
          #   # rm -rf $out/bin/bin
          # ''; 

          meta = with pkgs.lib; {
            description = "Next-generation toolchain manager for Roblox projects.";
            license = licenses.mit;
          };
        };
        devenv.shells.default = {
          devenv.root =
            let
              devenvRootFileContent = builtins.readFile devenv-root.outPath;
            in
            pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;
          name = "rokit dev shell";
          # https://devenv.sh/reference/options/
          packages = with pkgs; [ git cargo rustc];
        };
      };
    };
}
