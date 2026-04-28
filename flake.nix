{
  description = "SHC Minecraft Server development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";

          settings.global.excludes = [
            "modpack/*.toml"
            "modpack/**/*.pw.toml"
          ];

          programs.nixfmt.enable = true;
          programs.yamlfmt.enable = true;
          programs.prettier.enable = true;
          programs.prettier.includes = [ "*.json" ];
        };

        # Helper scripts
        mc-up = pkgs.writeShellScriptBin "mc-up" ''
          echo "Starting test server..."
          docker compose -f docker-compose.yml -f docker-compose.test.yml up "$@"
        '';

        mc-down = pkgs.writeShellScriptBin "mc-down" ''
          echo "Stopping server..."
          docker compose -f docker-compose.yml -f docker-compose.test.yml down "$@"
        '';

        mc-logs = pkgs.writeShellScriptBin "mc-logs" ''
          docker compose -f docker-compose.yml -f docker-compose.test.yml logs -f "$@"
        '';

        mc-rcon = pkgs.writeShellScriptBin "mc-rcon" ''
          set -a
          source "$(git rev-parse --show-toplevel)/.env"
          set +a
          docker exec -it mc-server rcon-cli --host 127.0.0.1 --password "$RCON_PASSWORD" "$@"
        '';

        mc-refresh = pkgs.writeShellScriptBin "mc-refresh" ''
          echo "Refreshing packwiz index..."
          cd "$(git rev-parse --show-toplevel)/modpack" && packwiz refresh "$@"
        '';

        mc-add-mod = pkgs.writeShellScriptBin "mc-add-mod" ''
          cd "$(git rev-parse --show-toplevel)/modpack" && packwiz modrinth add "$@"
        '';
      in
      {
        formatter = treefmtEval.config.build.wrapper;

        checks.formatting = treefmtEval.config.build.check self;

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.packwiz
            pkgs.docker-compose
            pkgs.tmux

            mc-up
            mc-down
            mc-logs
            mc-rcon
            mc-refresh
            mc-add-mod
          ];

          shellHook = ''
            echo "SHC Minecraft Server dev shell"
            echo ""
            echo "Commands:"
            echo "  mc-up       Start test server (pass -d for detached)"
            echo "  mc-down     Stop server"
            echo "  mc-logs     Tail server logs"
            echo "  mc-rcon     Open RCON console"
            echo "  mc-refresh  Run packwiz refresh in modpack/"
            echo "  mc-add-mod  Add a mod (e.g. mc-add-mod lithium)"
            echo ""
            echo "Extra Packages:"
            echo "  packwiz     Directly control the modpack"
            echo "  tmux        Do multiple things in one terminal window"
          '';
        };
      }
    );
}
