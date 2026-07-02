{
  pkgs,
  lib,
  ...
}:
let
  masApps = {
    "SponsorBlock for Safari" = 1573461917;
    "1Blocker" = 1365531024;
  };

  masPath = "${pkgs.mas}/bin/mas";
  timeout = 120; # 2 minutes per app
in
{
  home.packages = [ pkgs.mas ];

  home.activation.installMasApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    install_mas_app() {
      local name="$1"
      local id="$2"

      if ${masPath} list 2>/dev/null | grep -q "^$id "; then
        echo "[OK] $name already installed"
        return 0
      fi

      # No signed-in check: `mas account` is broken on macOS 12+ (mas-cli/mas#417),
      # so just attempt the install and let it fail per-app with a warning.
      echo "[..] Installing $name..."
      if timeout ${toString timeout} ${masPath} install "$id" 2>/dev/null; then
        echo "[OK] $name installed successfully"
      else
        echo "[FAIL] Failed to install $name (timeout or error)"
        echo "       Try manually: mas install $id"
      fi
    }

    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: id: ''install_mas_app "${name}" "${toString id}"'') masApps
    )}
  '';
}
