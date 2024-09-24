{
  description = "Nix Flake for the Papyrus static site generator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    ocaml-flake.url = "github:9glenda/ocaml-flake";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.ocaml-flake.flakeModule
        inputs.treefmt-nix.flakeModule
      ];
      systems = ["x86_64-linux"];
      perSystem = {config, ...}: {
        ocaml = {
          duneProjects = {
            default = {
              name = "papyrus";
              src = ./.;
              devShell.extraPackages = [
                config.treefmt.build.wrapper
              ];
            };
          };
        };
        treefmt.config = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            statix.enable = true;
            deadnix.enable = true;
            ocamlformat = {
              enable = true;
              configFile = ./.ocamlformat;
            };
          };
        };
      };
    };
}
