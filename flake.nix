{
  description = "Gleam dev environment for TaskPigeon";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    { systems, nixpkgs, ... }@inputs:
    let
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      erlang_version = "erlang_25";
    in
    {
      packages = eachSystem (pkgs: { });

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          buildInputs =
            with pkgs;
            (
              [
                gleam
                beam.interpreters.${erlang_version}
                beam.packages.${erlang_version}.rebar3 # optional, probably not gonna use it
              ]
              ++ lib.optional stdenv.isLinux inotify-tools
            );
        };
      });
      formatter = eachSystem (pkgs: pkgs.nixfmt-rfc-style);
    };
}
