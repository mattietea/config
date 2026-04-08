{
  pkgs,
  ...
}:

{
  cachix.enable = false;

  languages.nix.enable = true;
  languages.nix.lsp.package = pkgs.nixd;

  packages = [
    pkgs.deadnix
    pkgs.jq
    pkgs.curl
  ];

  # https://devenv.sh/scripts/
  scripts = {
    switch.exec = ''
      rm -rf ~/Applications/Home\ Manager\ Apps/;
      sudo darwin-rebuild switch --flake .
    '';

    update.exec = ''
      devenv update;
      nix flake update;
      update-clis;
    '';

    update-clis.exec = ''
      update_cli() {
        local name="$1" file="$2" repo="$3" asset_pattern="$4"

        local current_version
        current_version=$(grep 'version = "' "$file" | head -1 | sed 's/.*version = "//;s/".*//')

        local latest_version
        latest_version=$(curl -sL "https://api.github.com/repos/$repo/releases/latest" | jq -r '.tag_name' | sed 's/^v//')

        if [ "$current_version" = "$latest_version" ]; then
          echo "$name: already at $current_version"
          return
        fi

        echo "$name: $current_version -> $latest_version"

        # Build the asset URL by replacing version in pattern
        local url
        url=$(echo "$asset_pattern" | sed "s/VERSION/$latest_version/g")

        local hash
        hash=$(nix-prefetch-url "$url" 2>/dev/null | xargs nix hash convert --hash-algo sha256 --to sri)

        sed -i "" "s|version = \"$current_version\"|version = \"$latest_version\"|" "$file"
        sed -i "" "s|hash = \"sha256-.*\"|hash = \"$hash\"|" "$file"

        echo "$name: updated to $latest_version"
      }

      MODULES="modules/home-manager/packages"

      update_cli "pup" \
        "$MODULES/pup/default.nix" \
        "datadog-labs/pup" \
        "https://github.com/datadog-labs/pup/releases/download/vVERSION/pup_VERSION_Darwin_arm64.tar.gz"

      update_cli "linear" \
        "$MODULES/linear/default.nix" \
        "schpet/linear-cli" \
        "https://github.com/schpet/linear-cli/releases/download/vVERSION/linear-aarch64-apple-darwin.tar.xz"
    '';

    lint.exec = ''
      statix check .
    '';

    format.exec = ''
      treefmt
    '';

    clean.exec = ''
      nix-collect-garbage
    '';

    deadnix.exec = ''
      deadnix --no-lambda-pattern-names .
    '';
  };

  # Configure treefmt for formatting
  # Reference: https://devenv.sh/reference/options/#treefmtenable
  treefmt = {
    enable = true;
    config = {
      programs = {
        nixfmt.enable = true;
        prettier = {
          enable = true;
          package = pkgs.prettier;
        };
        yamlfmt.enable = true;
      };
    };
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    treefmt.enable = true;
    shellcheck.enable = true;
    statix.enable = true;
    deadnix = {
      enable = true;
      settings.noLambdaPatternNames = true;
    };
    flake-check = {
      enable = true;
      entry = "nix flake check --no-build";
      pass_filenames = false;
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
