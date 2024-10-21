{
  description = "Gleam dev environment for TaskPigeon";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    { systems, nixpkgs, ... }:
    let
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      erlang_version = "erlang_26";
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
                elixir
                beam.interpreters.${erlang_version}
                beam.packages.erlang_25.rebar3
                nil
              ]
              ++ lib.optional stdenv.isLinux inotify-tools
            );
        };
      });
      formatter = eachSystem (pkgs: pkgs.nixfmt-rfc-style);
    };
}
