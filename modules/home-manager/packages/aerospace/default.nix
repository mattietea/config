{ pkgs, ... }:
let
  # Summon the quick-jot notes doc: a dedicated Chrome app-mode window whose
  # id is cached on first launch. alt-n yanks it to the focused workspace, or
  # launches it if it's gone. AeroSpace has no sticky windows — this is the
  # summon-on-demand equivalent.
  notesUrl = "https://docs.google.com/document/d/1Ekt01p9ZauyQp52dnRgrYBC3u9aM7e-lDQorn9cJTqM/edit?tab=t.0";
  summonNotes = pkgs.writeShellScript "summon-notes" ''
    aero="${pkgs.aerospace}/bin/aerospace"
    state="$HOME/.cache/notes-window-id"

    if [ -f "$state" ]; then
      id=$(cat "$state")
      if [ -n "$id" ] && "$aero" list-windows --all --format '%{window-id}' | grep -qx "$id"; then
        ws=$("$aero" list-workspaces --focused)
        "$aero" move-node-to-workspace --focus-follows-window --window-id "$id" "$ws"
        exit 0
      fi
    fi

    before=$("$aero" list-windows --monitor all --app-bundle-id com.google.Chrome --format '%{window-id}' | sort)
    /usr/bin/open -na "Google Chrome" --args --app="${notesUrl}"

    for _ in $(seq 1 40); do
      sleep 0.25
      after=$("$aero" list-windows --monitor all --app-bundle-id com.google.Chrome --format '%{window-id}' | sort)
      new_id=$(comm -13 <(printf '%s\n' "$before") <(printf '%s\n' "$after") | head -n1)
      if [ -n "$new_id" ]; then
        mkdir -p "$(dirname "$state")"
        printf '%s' "$new_id" > "$state"
        "$aero" layout floating --window-id "$new_id"
        break
      fi
    done
  '';
in
{
  programs.aerospace = {
    enable = true;
    launchd.enable = true;
    settings = {
      "start-at-login" = true;
      "after-startup-command" = [ ];
      "enable-normalization-flatten-containers" = true;
      "enable-normalization-opposite-orientation-for-nested-containers" = true;
      "accordion-padding" = 30;
      "default-root-container-layout" = "tiles";
      "default-root-container-orientation" = "horizontal";
      "on-focused-monitor-changed" = [ "move-mouse monitor-lazy-center" ];
      "automatically-unhide-macos-hidden-apps" = true;
      "key-mapping" = {
        preset = "qwerty";
      };

      "gaps" = {
        inner = {
          horizontal = 5;
          vertical = 5;
        };
        outer = {
          left = 5;
          bottom = 5;
          top = 5;
          right = 5;
        };
      };

      "mode" = {
        main = {
          binding = {
            cmd-h = [ ];
            cmd-alt-h = [ ];

            "alt-slash" = "layout tiles horizontal vertical";
            "alt-comma" = "layout accordion horizontal vertical";

            # Quick-jot notes doc: summon its window here, or launch it
            "alt-n" = "exec-and-forget ${summonNotes}";

            "alt-h" = "focus left";
            "alt-j" = "focus down";
            "alt-k" = "focus up";
            "alt-l" = "focus right";

            "alt-shift-h" = "move left";
            "alt-shift-j" = "move down";
            "alt-shift-k" = "move up";
            "alt-shift-l" = "move right";

            "alt-minus" = "resize smart -100";
            "alt-equal" = "resize smart +100";

            "alt-1" = "workspace 1";
            "alt-2" = "workspace 2";
            "alt-3" = "workspace 3";
            "alt-4" = "workspace 4";
            "alt-5" = "workspace 5";
            "alt-6" = "workspace 6";
            "alt-7" = "workspace 7";
            "alt-8" = "workspace 8";
            "alt-9" = "workspace 9";

            "alt-shift-1" = "move-node-to-workspace 1";
            "alt-shift-2" = "move-node-to-workspace 2";
            "alt-shift-3" = "move-node-to-workspace 3";
            "alt-shift-4" = "move-node-to-workspace 4";
            "alt-shift-5" = "move-node-to-workspace 5";
            "alt-shift-6" = "move-node-to-workspace 6";
            "alt-shift-7" = "move-node-to-workspace 7";
            "alt-shift-8" = "move-node-to-workspace 8";
            "alt-shift-9" = "move-node-to-workspace 9";

            "alt-tab" = "workspace-back-and-forth";
            "alt-shift-tab" = "move-workspace-to-monitor --wrap-around next";

            "alt-shift-semicolon" = "mode service";
          };
        };

        service = {
          binding = {
            esc = [
              "reload-config"
              "mode main"
            ];
            r = [
              "flatten-workspace-tree"
              "mode main"
            ];
            f = [
              "layout floating tiling"
              "mode main"
            ];
            backspace = [
              "close-all-windows-but-current"
              "mode main"
            ];

            "alt-shift-h" = [
              "join-with left"
              "mode main"
            ];
            "alt-shift-j" = [
              "join-with down"
              "mode main"
            ];
            "alt-shift-k" = [
              "join-with up"
              "mode main"
            ];
            "alt-shift-l" = [
              "join-with right"
              "mode main"
            ];

            down = "volume down";
            up = "volume up";
            "shift-down" = [
              "volume set 0"
              "mode main"
            ];
          };
        };
      };
    };
  };
}
