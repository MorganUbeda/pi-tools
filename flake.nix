{
  description = "Pi tools — skills, prompts, themes, and agent configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in
    {
      packages.${system} = {
        pi-config = pkgs.callPackage ./pkgs/pi-config.nix {};
        default = self.packages.${system}.pi-config;
      };
    };
}
