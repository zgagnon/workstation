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

  fonts.fontconfig.enable = true;
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
      beadsSrc = pkgs.fetchFromGitHub {
        owner = "steveyegge";
        repo = "beads";
        rev = "main";
        sha256 = "gZ7+vnccJWlcoH4BJodzigMCgG/sZluobWrJYG/kM7Y=";
      };
      beads = pkgs.callPackage "${beadsSrc}/default.nix" { self = beadsSrc; };
      claude-code = pkgs.callPackage ./../packages/claude-code.nix { };
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
      action-validator
      bat
      # beads
      beam27Packages.elixir-ls
      bun
      cabal-install
      claude-code
      cmake
      coreutils
      emacs-lsp-booster
      erlfmt
      eza
      fd
      figlet
      fira-code
      fzf
      gcc
      gdk
      gh
      glibtool
      gnugrep
      haskellPackages.hoogle
      haskellPackages.lsp
      just
      k9s
      kubectx
      kubernetes-helm
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nufmt
      nil
      nixfmt-rfc-style
      nodePackages.js-beautify
      nodePackages.typescript-language-server
      nodejs
      obsidian
      pandoc
      ripgrep
      sc-im
      shellcheck
      shfmt
      stgit
      stylelint
      tree
      tree-sitter
      tree-sitter-grammars.tree-sitter-heex
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
  };

  home.sessionPath = [
    "$HOME/.emacs.d/bin"
  ];

  services.syncthing = {
    enable = true;
  };

  #Fasder configuration
  programs.fasder = {
    enable = true;
    enableAliases = true;
    enableInteractiveSelection = true;
    enableTracking = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
    editor = "emacs -nw"; # or your preferred editor
    fzfCommand = "fzf";
  };

  # Activation script to setup MCP servers globally
  home.activation.setupMcpServers =
    let
      setupScript = pkgs.writeShellScript "setup-mcp-servers" ''
        set -euo pipefail

        MCP_SERVERS_DIR="$HOME/mcp-servers"
        MCP_REPO="$MCP_SERVERS_DIR/run-typescript-skills-mcp"

        # Ensure mcp-servers directory exists
        mkdir -p "$MCP_SERVERS_DIR"

        # Setup run-typescript-skills-mcp
        if [[ ! -d "$MCP_REPO" ]]; then
          echo "📥 Cloning run-typescript-skills-mcp with jj..."
          ${pkgs.jujutsu}/bin/jj git clone git@github.com:zgagnon/run-typescript-skills-mcp.git "$MCP_REPO"
          echo "📂 Checking out main branch..."
          cd "$MCP_REPO" && ${pkgs.jujutsu}/bin/jj new main
        elif [[ -d "$MCP_REPO/.jj" ]]; then
          echo "🔄 Updating run-typescript-skills-mcp with jj..."
          cd "$MCP_REPO" && ${pkgs.jujutsu}/bin/jj git fetch
        elif [[ -d "$MCP_REPO/.git" ]]; then
          echo "🔄 Converting existing git repo to jj..."
          cd "$MCP_REPO" && ${pkgs.jujutsu}/bin/jj git init --git-repo=.
          ${pkgs.jujutsu}/bin/jj git fetch
        else
          echo "⚠️  $MCP_REPO exists but is not a valid repository"
        fi

        # Install dependencies if package.json exists
        if [[ -f "$MCP_REPO/package.json" ]]; then
          echo "📦 Installing MCP server dependencies..."
          cd "$MCP_REPO" && ${pkgs.bun}/bin/bun install
        fi

        # Register MCP server globally with Claude Code
        echo "🔧 Registering MCP server globally with Claude Code..."
        ${pkgs.claude-code}/bin/claude mcp add --scope user --transport stdio run-typescript-skills bun run "$MCP_REPO/src/mcp-bun.ts"
      '';
    in
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${
        pkgs.lib.makeBinPath [
          pkgs.bun
          pkgs.git
          pkgs.openssh
          pkgs.jujutsu
          pkgs.claude-code
        ]
      }:$PATH"
      $DRY_RUN_CMD ${setupScript}
    '';

  # Activation script to clone Doom Emacs configuration and install Doom using jj
  home.activation.setupDoomEmacs =
    let
      setupScript = pkgs.writeShellScript "setup-doom-emacs" ''
        set -euo pipefail

        DOOM_CONFIG_DIR="$HOME/.doom.d"
        DOOM_EMACS_DIR="$HOME/.emacs.d"

        # Setup Doom Emacs configuration
        if [[ ! -d "$DOOM_CONFIG_DIR" ]]; then
          echo "📥 Cloning Doom Emacs configuration with jj..."
          ${pkgs.jujutsu}/bin/jj git clone git@github.com:zgagnon/doom-emacs.git "$DOOM_CONFIG_DIR"
        elif [[ -d "$DOOM_CONFIG_DIR/.jj" ]]; then
          echo "🔄 Updating Doom Emacs configuration with jj..."
          cd "$DOOM_CONFIG_DIR" && ${pkgs.jujutsu}/bin/jj git fetch
        elif [[ -d "$DOOM_CONFIG_DIR/.git" ]]; then
          echo "🔄 Converting existing git repo to jj..."
          cd "$DOOM_CONFIG_DIR" && ${pkgs.jujutsu}/bin/jj git init --git-repo=.
          ${pkgs.jujutsu}/bin/jj git fetch
        else
          echo "⚠️  $DOOM_CONFIG_DIR exists but is not a valid repository"
        fi

        # Setup Doom Emacs itself
        if [[ ! -d "$DOOM_EMACS_DIR" ]]; then
          echo "📥 Installing Doom Emacs with jj..."
          ${pkgs.jujutsu}/bin/jj git clone git@github.com:doomemacs/doomemacs.git "$DOOM_EMACS_DIR"
          echo "🔨 Installing Doom Emacs..."
          "$DOOM_EMACS_DIR/bin/doom" install --no-env
        else
          echo "🔄 Doom Emacs already installed, syncing configuration..."
          "$DOOM_EMACS_DIR/bin/doom" sync
        fi
      '';
    in
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${
        pkgs.lib.makeBinPath [
          pkgs.emacs
          pkgs.git
          pkgs.openssh
          pkgs.jujutsu
        ]
      }:$PATH"
      $DRY_RUN_CMD ${setupScript}
    '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
