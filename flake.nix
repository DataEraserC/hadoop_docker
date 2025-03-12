{
  description = "基于 nix 的 hadoop docker ";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/0e74ca98a74bc7270d28838369593635a5db3260";
  inputs.flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b";

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
      packages = rec {
        docker_builder = pkgs.dockerTools.buildLayeredImage {
          name = "hadoop_docker";
          tag = "3.3";
          created = "now";
          contents = with pkgs; [
            hadoop_3_3
            # CA for secure connect
            cacert
            # bash
            bashInteractive
            which
            # vim editor
            vim
            # coreutils for some common command
            coreutils-full
            openjdk
          ];

          enableFakechroot = true;
          config = {
            Cmd = [
              "${pkgs.bashInteractive}/bin/bash"
            ];
          };
        };

        default = docker_builder;
      };
      formatter = pkgs.alejandra;
    })
  );
}
