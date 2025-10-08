{

  home-config,
  ...
}:
{
  programs.nushell = {
    enable = true;
    extraConfig = ''
            # Custom powerline-style prompt
            def create_left_prompt [] {
              let path_segment = if (($env.PWD | str starts-with $nu.home-path) == true) {
                $env.PWD | str replace $nu.home-path "~"
              } else { $env.PWD }

              let vcs_info = (do {
                # Check if we're in a jj repository first
                let jj_check = (do -i { jj status } | complete)
                if $jj_check.exit_code == 0 {
                  # We're in a jj repo
                  let jj_status = ($jj_check.stdout | str trim)
                  let branch = (do -i { jj log -r '@' --no-graph -T 'parents.map(|p| if(p.bookmarks(), p.bookmarks().join(" ") ++ " " ++ p.change_id().shortest(), p.change_id().shortest())).join(", ")' } | complete | get stdout | str trim)
                  let has_changes = ($jj_status | str contains "Working copy changes:")

                  if ($branch | is-empty) {
                    if $has_changes { " (jj*)" } else { " (jj)" }
                  } else {
                    if $has_changes { " (" + $branch + "*)" } else { " (" + $branch + ")" }
                  }
                } else {
                  # Fall back to git
                  let branch = (do -i { git branch --show-current } | complete | get stdout | str trim)
                  if ($branch | is-empty) {
                    ""
                  } else {
                    let status = (do -i { git status --porcelain } | complete | get stdout | lines | length)
                    if $status > 0 {
                      " (" + $branch + "*)"
                    } else {
                      " (" + $branch + ")"
                    }
                  }
                }
              })

              let direnv_info = (do -i {
                # Check if direnv is currently active
                let direnv_dir = ($env.DIRENV_DIR? | default "")
                let direnv_file = ($env.DIRENV_FILE? | default "")

                if ($direnv_dir | str length) == 0 {
                  # No direnv active
                  ""
                } else {
                  # Parse direnv status to check if allowed
                  let direnv_status = (direnv status | complete | get stdout)
                  let is_allowed = ($direnv_status | str contains "Found RC allowed 1")
                  let is_blocked = ($direnv_status | str contains "Found RC allowed 0")

                  if $is_blocked {
                    " 🔒"
                  } else if $is_allowed {
                    # Check if it's nix-direnv
                    let in_nix_shell = ($env.IN_NIX_SHELL? | default "") == "impure"
                    let path_has_nix = ($env.PATH | str contains "/nix/store/")

                    # Check for flake usage
                    let has_flake = if ($direnv_file | path exists) {
                      (open $direnv_file | str contains "use flake")
                    } else { false }

                    if $in_nix_shell and $path_has_nix {
                      if $has_flake {
                        " ❄️"
                      } else {
                        " 🟢"
                      }
                    } else {
                      " 🔓"
                    }
                  } else {
                    " 🔒"
                  }
                }
              })

              let os_icon = if ($nu.os-info.name == "macos") { "🍎" } else if ($nu.os-info.name == "linux") { "🐧" } else { "nu" }
              [
                (ansi { fg: "#ff479c" })
                $os_icon
                (ansi reset)
                (ansi { fg: "#61afef" })
                " "
                $path_segment
                (ansi reset)
                (ansi { fg: "#95ffa4" })
                $vcs_info
                (ansi reset)
                (ansi { fg: "#f97316" })
                $direnv_info
                (ansi reset)
                " "
              ] | str join
            }

            def create_right_prompt [] {
              # Show last command duration if > 100ms
              let duration = ($env.CMD_DURATION_MS? | default "0" | into int)
              if $duration > 100 {
                $"(ansi { fg: "#888888" })($duration)ms(ansi reset)"
              } else {
                ""
              }
            }

            $env.PROMPT_COMMAND = {|| (create_left_prompt) + (char newline) }
            $env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }
            $env.PROMPT_INDICATOR = "❯ "
            $env.PROMPT_INDICATOR_VI_INSERT = "❯ "
            $env.PROMPT_INDICATOR_VI_NORMAL = "❮ "
            $env.PROMPT_INDICATOR_VI_REPLACE = "🔄 "
            $env.PROMPT_MULTILINE_INDICATOR = "::: "

            $env.config = ($env.config | upsert edit_mode 'vi')
            $env.PATH = ($env.PATH | split row (char esep) |
              append ($nu.home-path + '/.emacs.d/bin') |
              append ($nu.home-path + '/.npm-global/bin'))
            $env.HOME_MANAGER_CONFIG = "${home-config}"

            alias darwinswitch = sudo darwin-rebuild switch --flake /Users/zell/git/mo/workstations/home/zgagnon#zell-mo

            def homeswitch [] {
              print "🔍 Hunting for coder secrets in SSH config..."
              let ssh_config_path = ($env.HOME + "/.ssh/config")
              # Extract coder section from SSH config
              let coder_section = (
                if ($ssh_config_path | path exists) {
                  open $ssh_config_path | str replace -a '\r\n' '\n' |
                  parse-coder-section
                } else { "" }
              )

              if ($coder_section | str length) > 0 {
                print "✨ Found coder magic! Safely tucking it away..."
              } else {
                print "🤷 No coder config found, moving on..."
              }

              print "🗑️  Yeeting the old SSH config symlink into the void..."
              # Remove SSH config symlink if it exists (don't expand - we want the symlink, not the target)
              if ($ssh_config_path | path exists) {
                rm $ssh_config_path
              }

              print "🏗️  Building your shiny new home with home-manager..."
              # Run home-manager switch
              ^home-manager switch --flake ${home-config}

              print "🔧 Making the new SSH config less stubborn (removing read-only)..."
              # Copy the read-only nix config to make it writable and add coder section back
              if ($coder_section | str length) > 0 {
                cp $ssh_config_path ($ssh_config_path + ".tmp")
                rm $ssh_config_path
                mv ($ssh_config_path + ".tmp") $ssh_config_path
                chmod 644 $ssh_config_path
                print "🪄 Sprinkling the coder magic back in..."
                $coder_section | save --append $ssh_config_path
                print "✅ Coder config restored! You can still reach the mothership 🚀"
              }

              print "🔄 Config updated! Run 'source $nu.config-path' to reload, or restart your shell"
              print "📋 Reload command copied to clipboard!"
              print "🎉 Homeswitch complete! Welcome to your freshly renovated digital home! 🏠"
            }

            def parse-coder-section [] {
              let content = $in
              let start_marker = "# ------------START-CODER-----------"
              let end_marker = "# ------------END-CODER------------"

              if ($content | str contains $start_marker) and ($content | str contains $end_marker) {
                let lines = ($content | lines)
                let start_idx = ($lines | enumerate | where item == $start_marker | get index.0)
                let end_idx = ($lines | enumerate | where item == $end_marker | get index.0)

                $lines | skip $start_idx | take ($end_idx - $start_idx + 1) | str join "\n" | $in + "\n"
              } else {
                ""
              }
            }

            # Override TERM when connecting via Ghostty to coder machine to fix terminfo issues
            if  ($env.user? == "coder") {
              $env.COLORTERM = "truecolor"
            }

            def edit [file?: string] {
                emacs -nw
            }

            def vm [] {
              ~/.bin/coder.sh
            }

            jj util completion nushell | save -f completions-jj.nu


            if ("~/.ai.env.toml" | path expand | path exists) {
            print "Loading AI env vars...";
            open ~/.ai.env.toml | load-env; }

            if ("~/.secrets.nu" | path expand | path exists) {
            source ~/.secrets.nu; }
    '';
  };
}
