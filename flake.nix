{
  description = "Cloudflare account configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.discord-oidc-worker = pkgs.callPackage ./nix/discord-oidc-worker.nix { };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            opentofu
            secretspec
            sops
            cf
            jq
            nodejs
            rumdl
          ];
        };
      }
    );
}
