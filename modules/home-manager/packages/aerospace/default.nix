let
  # Quick-jot notes doc, kept as a Chrome app-mode window on workspace N.
  # alt-n toggles there and back; the on-window-detected rule routes the
  # window (matched by doc title) to N whenever it opens. AeroSpace has no
  # sticky windows — this is the community-standard scratchpad emulation.
  notesUrl = "https://docs.google.com/document/d/1Ekt01p9ZauyQp52dnRgrYBC3u9aM7e-lDQorn9cJTqM/edit?tab=t.0";
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

      "on-window-detected" = [
        {
          "if" = {
            app-id = "com.google.Chrome";
            window-title-regex-substring = "Matt's Notes";
          };
          run = "move-node-to-workspace N";
        }
      ];

      "mode" = {
        main = {
          binding = {
            cmd-h = [ ];
            cmd-alt-h = [ ];

            "alt-slash" = "layout tiles horizontal vertical";
            "alt-comma" = "layout accordion horizontal vertical";

            # Quick-jot notes: toggle to workspace N and back; shift launches
            "alt-n" = "workspace --auto-back-and-forth N";
            "alt-shift-n" = "exec-and-forget /usr/bin/open -na 'Google Chrome' --args --app='${notesUrl}'";

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
