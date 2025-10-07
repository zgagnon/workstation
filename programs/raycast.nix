{
  pkgs,
  ...
}:
let
  # Create shell applications with proper Emacs in PATH
  emacsTerminalScript = pkgs.writeShellApplication {
    name = "emacs-terminal";
    runtimeInputs = [ pkgs.emacs30 ];
    text = ''
      # Required parameters:
      # @raycast.schemaVersion 1
      # @raycast.title Terminal Emacs
      # @raycast.mode compact
      # @raycast.packageName Emacs Servers
      # @raycast.icon 📝

      # Optional parameters:
      # @raycast.description Launch emacsclient connected to terminal server

      # Try to connect to terminal server, start if not running
      if ! emacsclient -s terminal --eval "()" 2>/dev/null; then
          echo "Starting terminal emacs daemon..."
          emacs --daemon=terminal
      fi

      # Launch emacsclient in a new terminal window
      osascript -e 'tell application "Terminal" to do script "emacsclient -s terminal -nw"'
    '';
  };

  emacsGuiScript = pkgs.writeShellApplication {
    name = "emacs-gui";
    runtimeInputs = [ pkgs.emacs30 ];
    text = ''
      # Required parameters:
      # @raycast.schemaVersion 1
      # @raycast.title GUI Emacs
      # @raycast.mode compact
      # @raycast.packageName Emacs Servers
      # @raycast.icon 🖥️

      # Optional parameters:
      # @raycast.description Launch emacsclient GUI connected to gui server

      # Try to connect to gui server, start if not running
      if ! emacsclient -s gui --eval "()" 2>/dev/null; then
          echo "Starting GUI emacs daemon..."
          emacs --daemon=gui
      fi

      # Launch GUI emacsclient (--no-wait so script exits immediately)
      emacsclient -s gui -c --no-wait
    '';
  };

  emacsWorkScript = pkgs.writeShellApplication {
    name = "emacs-work";
    runtimeInputs = [ pkgs.emacs30 ];
    text = ''
      # Required parameters:
      # @raycast.schemaVersion 1
      # @raycast.title Work Emacs
      # @raycast.mode compact
      # @raycast.packageName Emacs Servers
      # @raycast.icon 💼

      # Optional parameters:
      # @raycast.description Launch emacsclient connected to work server

      if ! emacsclient -s work --eval "()" 2>/dev/null; then
          echo "Starting work emacs daemon..."
          emacs --daemon=work
      fi

      emacsclient -s work -c --no-wait
    '';
  };

  emacsStatusScript = pkgs.writeShellApplication {
    name = "emacs-status";
    runtimeInputs = [ pkgs.emacs30 ];
    text = ''
      # Required parameters:
      # @raycast.schemaVersion 1
      # @raycast.title Emacs Server Status
      # @raycast.mode fullOutput
      # @raycast.packageName Emacs Servers
      # @raycast.icon 📊

      # Optional parameters:
      # @raycast.description Show status of all emacs servers

      echo "Emacs Server Status:"
      echo "==================="

      for server in terminal gui work; do
          if emacsclient -s "$server" --eval "()" 2>/dev/null; then
              echo "✅ $server: Running"
          else
              echo "❌ $server: Not running"
          fi
      done
    '';
  };

  emacsKillScript = pkgs.writeShellApplication {
    name = "emacs-kill-servers";
    runtimeInputs = [ pkgs.emacs30 ];
    text = ''
      # Required parameters:
      # @raycast.schemaVersion 1
      # @raycast.title Kill All Emacs Servers
      # @raycast.mode compact
      # @raycast.packageName Emacs Servers
      # @raycast.icon 🛑

      # Optional parameters:
      # @raycast.description Kill all running emacs servers

      echo "Killing all emacs servers..."

      for server in terminal gui work; do
          if emacsclient -s "$server" --eval "()" 2>/dev/null; then
              echo "Killing $server server..."
              emacsclient -s "$server" --eval "(kill-emacs)"
          fi
      done

      echo "Done!"
    '';
  };
in
{
  home.file = {
    ".config/raycast/scripts/emacs-terminal.sh" = {
      source = "${emacsTerminalScript}/bin/emacs-terminal";
      executable = true;
    };

    ".config/raycast/scripts/emacs-gui.sh" = {
      source = "${emacsGuiScript}/bin/emacs-gui";
      executable = true;
    };

    ".config/raycast/scripts/emacs-work.sh" = {
      source = "${emacsWorkScript}/bin/emacs-work";
      executable = true;
    };

    ".config/raycast/scripts/emacs-status.sh" = {
      source = "${emacsStatusScript}/bin/emacs-status";
      executable = true;
    };

    ".config/raycast/scripts/emacs-kill-servers.sh" = {
      source = "${emacsKillScript}/bin/emacs-kill-servers";
      executable = true;
    };
  };
}
