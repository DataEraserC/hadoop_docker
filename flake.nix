{
  description = "基于 nix 的 hadoop docker ";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: let
    allSystems = flake-utils.lib.allSystems;
  in (
    flake-utils.lib.eachSystem allSystems
    (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # doCheck will fail at write files
      packages = rec {
        docker_builder = pkgs.dockerTools.buildLayeredImage {
          name = "hadoop_docker";
          tag = "latest";
          contents = with pkgs; [
            hadoop_3_3
            cacert
            bashInteractive
          ];
          config = {
            Cmd = ["${pkgs.bashInteractive}/bin/bash"];
          };
        };

        default = docker_builder;
      };
      formatter = pkgs.alejandra;
    })
  );
}
