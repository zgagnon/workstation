{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkOption
    mkEnableOption
    types
    mkIf
    mkAfter
    mkOrder
    getExe
    ;
  cfg = config.programs.fasder;

  # Generate shell aliases
  aliases = {
    j = "${getExe cfg.package} -d -e cd";
    v = "${getExe cfg.package} -f -e ${cfg.editor}";
    a = "${getExe cfg.package}";
    d = "${getExe cfg.package} -d";
    f = "${getExe cfg.package} -f";
  };

  # Nushell integration functions
  nushellIntegration = ''
    # Fasder integration for Nushell

    # External command declaration
    extern "fasder" [
        query?: string              # Search query
        --directories(-d)           # Directories only  
        --files(-f)                 # Files only
        --list(-l)                  # List only, omit rankings
        --exec(-e): string          # Execute command against best match
        --reverse(-R)               # Reverse sort (useful for fzf)
        --scores(-s)                # Show rank scores
        --help(-h)                  # Show help
        --version(-v)               # Show version
        --init: string              # Initialize fasder
        --add: string               # Add path to database
    ]

    # Jump to directory
    def --env z [...query: string] {
        let result = (${getExe cfg.package} -d ...$query | str trim)
        if ($result | is-empty) {
            print $"No directory found for: ($query | str join ' ')"
        } else {
            cd $result
        }
    }

    # Jump to directory with interactive selection
    def --env zf [...query: string] {
        let dirs = (${getExe cfg.package} -d -l ...$query)
        if ($dirs | is-empty) {
            print $"No directories found for: ($query | str join ' ')"
        } else {
            let selected = ($dirs | ${cfg.fzfCommand} --height=40% --reverse)
            if not ($selected | is-empty) {
                cd $selected
            }
        }
    }

    # Open file in editor
    def v [...query: string] {
        let result = (${getExe cfg.package} -f ...$query | str trim)
        if ($result | is-empty) {
            print $"No file found for: ($query | str join ' ')"
        } else {
            ^${cfg.editor} $result
        }
    }

    # Open file with interactive selection
    def vf [...query: string] {
        let files = (${getExe cfg.package} -f -l ...$query)
        if ($files | is-empty) {
            print $"No files found for: ($query | str join ' ')"
        } else {
            let selected = ($files | ${cfg.fzfCommand} --height=40% --reverse)
            if not ($selected | is-empty) {
                ^${cfg.editor} $selected
            }
        }
    }

    # Additional aliases
    def a [...query: string] { ${getExe cfg.package} ...$query }      # All (files and directories)
    def d [...query: string] { ${getExe cfg.package} -d ...$query }   # Directories only  
    def f [...query: string] { ${getExe cfg.package} -f ...$query }   # Files only
  '';

  # File tracking wrapper functions
  nushellFileTracking = ''
    # File tracking wrappers for editors
    # These add opened files to the fasder database automatically

    # Backup original commands for fallback access
    alias vi-orig = ^vi
    alias vim-orig = ^vim
    alias nvim-orig = ^nvim

    # Enhanced vi wrapper with fasder tracking
    def vi [...args: string] {
        # Track existing files before opening
        for arg in $args {
            if not ($arg | str starts-with "-") and not ($arg | str starts-with "+") {
                try {
                    let resolved = ($arg | path expand)
                    if ($resolved | path exists) and ($resolved | path type) == "file" {
                        ^${getExe cfg.package} --add $resolved
                    }
                } catch {
                    # Silently ignore path resolution errors
                }
            }
        }
        
        # Call original vi with all arguments
        ^vi ...$args
    }

    # Enhanced vim wrapper
    def vim [...args: string] {
        # Track existing files before opening
        for arg in $args {
            if not ($arg | str starts-with "-") and not ($arg | str starts-with "+") {
                try {
                    let resolved = ($arg | path expand)
                    if ($resolved | path exists) and ($resolved | path type) == "file" {
                        ^${getExe cfg.package} --add $resolved
                    }
                } catch {
                    # Silently ignore path resolution errors
                }
            }
        }
        
        # Call original vim with all arguments
        ^vim ...$args
    }

    # Enhanced nvim wrapper
    def nvim [...args: string] {
        # Track existing files before opening
        for arg in $args {
            if not ($arg | str starts-with "-") and not ($arg | str starts-with "+") {
                try {
                    let resolved = ($arg | path expand)
                    if ($resolved | path exists) and ($resolved | path type) == "file" {
                        ^${getExe cfg.package} --add $resolved
                    }
                } catch {
                    # Silently ignore path resolution errors
                }
            }
        }
        
        # Call original nvim with all arguments
        ^nvim ...$args
    }

    # Note: Cannot wrap nushell's built-in 'edit' command as it cannot be redefined
    # Users can manually add files to fasder database if needed:
    # fasder --add /path/to/file
  '';

  # Tracking hooks for nushell
  nushellHooks = ''
    # Fasder tracking hooks - work around direnv overwriting hooks by modifying them after direnv sets up
    $env.config = ($env.config | upsert hooks.pre_execution (
        $env.config.hooks.pre_execution?
        | default []
        | append {||
            # Track current directory
            ${getExe cfg.package} --add $env.PWD
        }
    ))
    
    $env.config = ($env.config | upsert hooks.env_change.PWD (
        $env.config.hooks.env_change.PWD?
        | default []
        | append {|before, after|
            # Track directory changes
            ${getExe cfg.package} --add $after
        }
    ))
  '';

in
{
  meta.maintainers = [ ];

  options.programs.beads= {
    enable = mkEnableOption "Beads, a memory upgrade for you coding agent";

    package = lib.mkPackageOption pkgs "beads" { };

    enabeClaudeIntegratoin = mkOption {
      type = types.bool;
      default = true;
      description = ''Whether to add Claude-code configuration'';'};
    };

    initOptions = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "auto"
        "aliases"
      ];
      description = ''
        Options to pass to fasder init command.
        Common options: auto, aliases, bash-hook, zsh-hook
      '';
    };

    enableBashIntegration = lib.hm.shell.mkBashIntegrationOption {
      inherit config;
    };

    enableZshIntegration = lib.hm.shell.mkZshIntegrationOption {
      inherit config;
    };

    enableFishIntegration = lib.hm.shell.mkFishIntegrationOption {
      inherit config;
    };

    enableNushellIntegration = lib.hm.shell.mkNushellIntegrationOption {
      inherit config;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ] ++ lib.optional cfg.enableInteractiveSelection pkgs.fzf;

    # Bash integration
    programs.bash = mkIf cfg.enableBashIntegration {
      initExtra = mkOrder 2000 ''
        # Fasder initialization
        eval "$(${getExe cfg.package} --init ${
          lib.concatStringsSep " " (cfg.initOptions ++ lib.optional cfg.enableTracking "bash-hook")
        })"

        ${lib.optionalString cfg.enableAliases ''
          # Fasder aliases
          alias j='${aliases.j}'
          alias v='${aliases.v}'
          alias a='${aliases.a}'
          alias d='${aliases.d}'
          alias f='${aliases.f}'
        ''}

        ${lib.optionalString cfg.enableInteractiveSelection ''
          # Interactive selection functions
          jf() {
            local dir
            dir=$(${getExe cfg.package} -d -l "$@" | ${cfg.fzfCommand} --height=40% --reverse) && cd "$dir"
          }

          vf() {
            local file
            file=$(${getExe cfg.package} -f -l "$@" | ${cfg.fzfCommand} --height=40% --reverse) && ${cfg.editor} "$file"
          }
        ''}
      '';
    };

    # Zsh integration
    programs.zsh = mkIf cfg.enableZshIntegration {
      initContent = mkOrder 2000 ''
        # Fasder initialization
        eval "$(${getExe cfg.package} --init ${
          lib.concatStringsSep " " (cfg.initOptions ++ lib.optional cfg.enableTracking "zsh-hook")
        })"

        ${lib.optionalString cfg.enableAliases ''
          # Fasder aliases
          alias j='${aliases.j}'
          alias z='${aliases.j}'
          alias v='${aliases.v}'
          alias a='${aliases.a}'
          alias d='${aliases.d}'
          alias f='${aliases.f}'
        ''}

        ${lib.optionalString cfg.enableInteractiveSelection ''
          # Interactive selection functions
          jf() {
            local dir
            dir=$(${getExe cfg.package} -d -l "$@" | ${cfg.fzfCommand} --height=40% --reverse) && cd "$dir"
          }

          vf() {
            local file
            file=$(${getExe cfg.package} -f -l "$@" | ${cfg.fzfCommand} --height=40% --reverse) && ${cfg.editor} "$file"
          }
        ''}
      '';
    };

    # Fish integration
    programs.fish = mkIf cfg.enableFishIntegration {
      interactiveShellInit = ''
        # Fasder initialization
        ${getExe cfg.package} --init ${
          lib.concatStringsSep " " (cfg.initOptions ++ lib.optional cfg.enableTracking "fish-hook")
        } | source

        ${lib.optionalString cfg.enableAliases ''
          # Fasder aliases
          alias j '${aliases.j}'
          alias v '${aliases.v}'
          alias a '${aliases.a}'
          alias d '${aliases.d}'
          alias f '${aliases.f}'
        ''}

        ${lib.optionalString cfg.enableInteractiveSelection ''
          # Interactive selection functions
          function jf
              set -l dir (${getExe cfg.package} -d -l $argv | ${cfg.fzfCommand} --height=40% --reverse)
              and cd "$dir"
          end

          function vf
              set -l file (${getExe cfg.package} -f -l $argv | ${cfg.fzfCommand} --height=40% --reverse)
              and ${cfg.editor} "$file"
          end
        ''}
      '';
    };

    # Nushell integration (custom implementation since fasder doesn't support nushell natively)
    programs.nushell = mkIf cfg.enableNushellIntegration {
      extraConfig = mkOrder 9999 ''
        ${nushellIntegration}

        ${lib.optionalString cfg.enableTracking nushellHooks}

        ${lib.optionalString cfg.enableFileTracking nushellFileTracking}
      '';
    };

    # Environment variables
    home.sessionVariables = {
      # Set default editor if not already set
      EDITOR = lib.mkDefault (lib.removePrefix "\${EDITOR:-" (lib.removeSuffix "}" cfg.editor));
    };
  };
}
