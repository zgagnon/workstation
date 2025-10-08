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
      action-validator
      bat
      beam27Packages.elixir-ls
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
      nil
      nixfmt-rfc-style
      nodePackages.js-beautify
      nodePackages.typescript-language-server
      nodejs
      obsidian
      pandoc
      pgadmin4-desktopmode
      ripgrep
      rlama
      sc-im
      shellcheck
      shfmt
      stgit
      stylelint
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

  programs.git = {
    enable = true;
    extraConfig = {
      core.excludesfile = "~/.gitignore_global";
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
    editor = "emacs -nw"; # or your preferred editor
    fzfCommand = "fzf";
  };

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
