{
  description = "ziggeth";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" ];
      perSystem = func: nixpkgs.lib.genAttrs systems (system: func nixpkgs.legacyPackages.${system});
    in {
      packages = perSystem (pkgs: {
        default = pkgs.hello;
      });

      devShells = perSystem (pkgs: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            zig_0_12
            solc
          ];
        };
      });
  };
}
