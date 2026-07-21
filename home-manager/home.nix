{
  config,
  pkgs,
  user,
  home,
  uniquePkgs,
  ...
}:

{
  imports = [
    ./../modules/fasder.nix
  ];
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true); # Optional: allows all unfree packages
    };
  };

  fonts.fontconfig.enable = false;
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  #  home.username = "zell";
  #  home.homeDirectory = "/Users/zell";
  home.username = user;
  home.homeDirectory = home;
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages =
    let
      gdk = pkgs.google-cloud-sdk.withExtraComponents (
        with pkgs.google-cloud-sdk.components;
        [
          gke-gcloud-auth-plugin
        ]
      );
    in
    with pkgs;
    [
      _1password-cli
      bun
      btop
      # claude-code
      fd
      fira-code
      fzf
      gdk
      gh
      just
      k3d
      k9s
      kubernetes-helm
      # nerd-fonts.fira-code
      # nerd-fonts.jetbrains-mono
      nufmt
      nixfmt-rfc-style
      typescript-language-server
      nodejs
      obsidian
      pandoc
      ripgrep
      shellcheck
      shfmt
      topiary
      uv
      zellij
    ]
    ++ uniquePkgs;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".config/ghostty/config" = {
      source = ./../config_files/ghostty;
    };
    ".config/ghostty/themes/biscotty" = {
      source = config.lib.file.mkOutOfStoreSymlink "/Users/zell/config/config_files/ghostty-themes/biscotty";
    };
    ".config/ghostty/themes/pastel-neon-night" = {
      source = config.lib.file.mkOutOfStoreSymlink "/Users/zell/config/config_files/ghostty-themes/pastel-neon-night";
    };
    ".config/zellij/layouts/coder.kdl" = {
      text = ''
        layout {
            default_tab_template {
                pane size=1 borderless=true {
                    plugin location="zellij:tab-bar"
                }
                children
                pane size=2 borderless=true {
                    plugin location="zellij:status-bar"
                }
            }
            tab name="Remote" {
                pane split_direction="vertical" {
                    pane {
                        command "ssh"
                        args "ZellVM.coder" "-t" "nu"
                    }
                    pane {
                        command "ssh"
                        args "ZellVM.coder" "-t" "nu"
                        focus true
                    }
                }
            }
            tab name="Local" {
                pane {
                    command "nu"
                }
            }
        }
      '';
    };
".bin/coder.sh" = {
      text = ''
        #!/bin/bash
        # Coder script

        # Sync terminfo to coder
        infocmp -x | ssh ZellVM.coder -- tic -x -

        # Launch zellij with coder layout
        zellij --layout coder
      '';
      executable = true;
    };
    ".bin/homeswitch" = {
      source = ./../programs/nushell/homeswitch.nu;
      executable = true;
    };
    ".bin/prompt" = {
      source = ./../programs/nushell/prompt.nu;
      executable = true;
    };
    ".bin/good_morning" = {
      source = ./../programs/nushell/good_morning.nu;
      executable = true;
    };
    ".gitignore_global" = {
      text = ''
        # Global ignore for jj completions
        completions-jj.nu
      '';
    };
    ".config/autostart/ulauncher.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Exec=ulauncher
        Hidden=false
        NoDisplay=false
        X-GNOME-Autostart-enabled=true
        Name=Ulauncher
        Comment=Application launcher
      '';
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/zell/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  services.syncthing = {
    enable = true;
  };

  # Zellij configuration
  programs.zellij = {
    enable = true;
    settings = {
      theme = "biscotty";
      default_mode = "normal";
      default_shell = "zsh";
      themes = {
        biscotty = {
          fg = "#3a3a3a";
          bg = "#f5ede5";
          black = "#3a3a3a";
          red = "#d14830";
          green = "#00875f";
          yellow = "#d7875f";
          blue = "#3d5f9a";
          magenta = "#7a4a94";
          cyan = "#00875f";
          white = "#f5ede5";
          orange = "#d7875f";

          # New-style theme components — yak-map reads text_unselected.background
          # via ModeUpdate to detect light mode and activate the LIGHT palette.
          text_unselected = {
            base = [ 58 58 58 ];
            background = [ 245 237 229 ]; # #f5ede5 — triggers light mode detection
            emphasis_0 = [ 209 72 48 ];
            emphasis_1 = [ 0 135 95 ];
            emphasis_2 = [ 215 135 95 ];
            emphasis_3 = [ 122 74 148 ];
          };

          text_selected = {
            base = [ 58 58 58 ];
            background = [ 229 217 204 ]; # #e5d9cc selection
            emphasis_0 = [ 209 72 48 ];
            emphasis_1 = [ 0 135 95 ];
            emphasis_2 = [ 215 135 95 ];
            emphasis_3 = [ 122 74 148 ];
          };

          ribbon_selected = {
            base = [
              61
              95
              154
            ]; # steel blue (#3d5f9a)
            background = [
              245
              237
              229
            ]; # cream (#f5ede5)
            emphasis_0 = [
              209
              72
              48
            ]; # red/numbers
            emphasis_1 = [
              0
              135
              95
            ]; # green/strings
            emphasis_2 = [
              215
              135
              95
            ]; # orange/definitions
            emphasis_3 = [
              122
              74
              148
            ]; # purple/constants
          };

          ribbon_unselected = {
            base = [
              58
              58
              58
            ]; # dark gray (#3a3a3a)
            background = [
              237
              228
              216
            ]; # slightly darker cream (#ede4d8)
            emphasis_0 = [
              209
              72
              48
            ]; # red/numbers
            emphasis_1 = [
              0
              135
              95
            ]; # green/strings
            emphasis_2 = [
              215
              135
              95
            ]; # orange/definitions
            emphasis_3 = [
              122
              74
              148
            ]; # purple/constants
          };

          frame_selected = {
            base = [
              82
              118
              161
            ]; # #5276a1 cursor blue
            background = [ 0 ];
            emphasis_0 = [
              209
              72
              48
            ]; # red
            emphasis_1 = [
              0
              135
              95
            ]; # green
            emphasis_2 = [
              122
              74
              148
            ]; # purple
            emphasis_3 = [ 0 ];
          };

          frame_unselected = {
            base = [
              138
              138
              138
            ]; # dimmed gray (#8a8a8a)
            background = [ 0 ];
            emphasis_0 = [
              209
              72
              48
            ]; # red/numbers
            emphasis_1 = [
              0
              135
              95
            ]; # green/strings
            emphasis_2 = [
              122
              74
              148
            ]; # purple
            emphasis_3 = [ 0 ];
          };

          frame_highlight = {
            base = [ 209 72 48 ];
            background = [ 0 ];
            emphasis_0 = [ 122 74 148 ];
            emphasis_1 = [ 209 72 48 ];
            emphasis_2 = [ 209 72 48 ];
            emphasis_3 = [ 209 72 48 ];
          };

          table_title = {
            base = [ 82 118 161 ];
            background = [ 0 ];
            emphasis_0 = [ 209 72 48 ];
            emphasis_1 = [ 0 135 95 ];
            emphasis_2 = [ 215 135 95 ];
            emphasis_3 = [ 122 74 148 ];
          };

          table_cell_selected = {
            base = [ 58 58 58 ];
            background = [ 229 217 204 ];
            emphasis_0 = [ 209 72 48 ];
            emphasis_1 = [ 0 135 95 ];
            emphasis_2 = [ 215 135 95 ];
            emphasis_3 = [ 122 74 148 ];
          };

          table_cell_unselected = {
            base = [ 58 58 58 ];
            background = [ 245 237 229 ];
            emphasis_0 = [ 209 72 48 ];
            emphasis_1 = [ 0 135 95 ];
            emphasis_2 = [ 215 135 95 ];
            emphasis_3 = [ 122 74 148 ];
          };

          list_selected = {
            base = [ 58 58 58 ];
            background = [ 229 217 204 ];
            emphasis_0 = [ 209 72 48 ];
            emphasis_1 = [ 0 135 95 ];
            emphasis_2 = [ 215 135 95 ];
            emphasis_3 = [ 122 74 148 ];
          };

          list_unselected = {
            base = [ 58 58 58 ];
            background = [ 245 237 229 ];
            emphasis_0 = [ 209 72 48 ];
            emphasis_1 = [ 0 135 95 ];
            emphasis_2 = [ 215 135 95 ];
            emphasis_3 = [ 122 74 148 ];
          };

          exit_code_success = {
            base = [ 0 135 95 ];
            background = [ 0 ];
            emphasis_0 = [ 0 135 95 ];
            emphasis_1 = [ 58 58 58 ];
            emphasis_2 = [ 122 74 148 ];
            emphasis_3 = [ 0 135 95 ];
          };

          exit_code_error = {
            base = [ 209 72 48 ];
            background = [ 0 ];
            emphasis_0 = [ 215 135 95 ];
            emphasis_1 = [ 0 ];
            emphasis_2 = [ 0 ];
            emphasis_3 = [ 0 ];
          };

          multiplayer_user_colors = {
            player_1 = [ 122 74 148 ];
            player_2 = [ 0 135 95 ];
            player_3 = [ 0 ];
            player_4 = [ 215 135 95 ];
            player_5 = [ 0 135 95 ];
            player_6 = [ 0 ];
            player_7 = [ 209 72 48 ];
            player_8 = [ 0 ];
            player_9 = [ 0 ];
            player_10 = [ 0 ];
          };
        };
      };
    };
  };

  #Fasder configuration
  programs.fasder = {
    enable = true;
    enableAliases = true;
    enableInteractiveSelection = true;
    enableTracking = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
    fzfCommand = "fzf";
  };

  # Activation script to setup topiary-nushell plugin
  # Clones topiary-nushell to $XDG_CONFIG_HOME/topiary (standard location)
  # No environment variables needed since we use the standard location
  home.activation.setupTopiaryNushell =
    let
      setupScript = pkgs.writeShellScript "setup-topiary-nushell" ''
        set -euo pipefail

        TOPIARY_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/topiary"

        # Setup topiary-nushell plugin
        if [[ ! -d "$TOPIARY_DIR" ]]; then
          echo "📥 Cloning topiary-nushell plugin to $TOPIARY_DIR..."
          ${pkgs.git}/bin/git clone https://github.com/blindFS/topiary-nushell "$TOPIARY_DIR"
          echo "✅ Topiary-nushell plugin installed"
          echo "   Config file: $TOPIARY_DIR/languages.ncl"
          echo "   Language dir: $TOPIARY_DIR/languages"
        else
          echo "🔄 Updating topiary-nushell plugin..."
          cd "$TOPIARY_DIR" && ${pkgs.git}/bin/git pull
          echo "✅ Topiary-nushell plugin updated"
        fi

        # Verify the setup
        if [[ -f "$TOPIARY_DIR/languages.ncl" ]] && [[ -d "$TOPIARY_DIR/languages" ]]; then
          echo "✅ Topiary-nushell setup complete"
        else
          echo "⚠️  Warning: Expected files not found in $TOPIARY_DIR"
        fi
      '';
    in
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${
        pkgs.lib.makeBinPath [
          pkgs.git
        ]
      }:$PATH"
      $DRY_RUN_CMD ${setupScript}
    '';

  # macOS + multi-user Nix: programs.ssh generates ~/.ssh/config as a symlink
  # into the Nix store. Store files are owned by root:wheel. SSH requires the
  # config to be owned by the current user, so JetBrains Gateway (and anything
  # else using a strict SSH implementation) gets "Permission denied".
  #
  # Fix: after writeBoundary places the symlink, replace it with a real file
  # owned by the user. home-manager switch re-runs this each time.
  home.activation.fixSshConfigPermissions = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ -L "$HOME/.ssh/config" ]; then
      $DRY_RUN_CMD cp -f "$(readlink -f "$HOME/.ssh/config")" "$HOME/.ssh/config.tmp"
      $DRY_RUN_CMD mv -f "$HOME/.ssh/config.tmp" "$HOME/.ssh/config"
      $DRY_RUN_CMD chmod 600 "$HOME/.ssh/config"
    fi
  '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
