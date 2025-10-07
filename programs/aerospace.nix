{
  ...
}:
{
  programs.aerospace = {
    enable = true;
    userSettings = {
      after-login-command = [ ];
      after-startup-command = [
        "exec-and-forget borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=5.0"
      ];
      start-at-login = true;
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      accordion-padding = 30;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";
      on-focused-monitor-changed = [
        "move-mouse monitor-lazy-center"
      ];
      automatically-unhide-macos-hidden-apps = false;
      key-mapping = {
        preset = "qwerty";
      };

      gaps = {
        inner.horizontal = 0;
        inner.vertical = 0;
        outer.left = 0;
        outer.bottom = 0;
        outer.top = 0;
        outer.right = 0;
      };

      mode.main.binding = {
        cmd-ctrl-alt-period = "layout tiles horizontal vertical";
        cmd-ctrl-alt-comma = "layout accordion horizontal vertical";
        cmd-ctrl-alt-left = "focus left";
        cmd-ctrl-alt-down = "focus down";
        cmd-ctrl-alt-up = "focus up";
        cmd-ctrl-alt-right = "focus right";

        cmd-ctrl-alt-shift-left = "move left";
        cmd-ctrl-alt-shift-down = "move down";
        cmd-ctrl-alt-shift-up = "move up";
        cmd-ctrl-alt-shift-right = "move right";

        cmd-ctrl-alt-shift-r = "resize smart +100";
        cmd-ctrl-alt-r = "resize smart -100";

        cmd-ctrl-alt-i = "mode service";

        cmd-ctrl-alt-shift-1 = "focus-monitor next --wrap-around";
        cmd-ctrl-alt-shift-3 = "workspace next --wrap-around";
        cmd-ctrl-alt-shift-7 = "move-node-to-monitor next --focus-follows-window --wrap-around";
        cmd-ctrl-alt-shift-9 = "move-node-to-workspace next --focus-follows-window --wrap-around";
      };

      mode.service.binding = {
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

        left = [
          "join-with left"
          "mode main"
        ];
        down = [
          "join-with down"
          "mode main"
        ];
        up = [
          "join-with up"
          "mode main"
        ];
        right = [
          "join-with right"
          "mode main"
        ];
      };

      on-window-detected = [
        {
          "if" = {
            app-id = "tandem.app";
          };
          run = "layout floating";
        }
        {
          "if" = {
            app-id = "com.apple.Terminal";
          };
          run = "layout floating";
        }
      ];
    };
  };
}
