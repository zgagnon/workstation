def create_left_prompt [] {
  let path_segment = if (($env.PWD | str starts-with $nu.home-path) == true) {
    $env.PWD | str replace $nu.home-path "~"
  } else { $env.PWD }
  
  let jj_check = (do -i { jj status } | complete)
  let jj_info = if $jj_check.exit_code == 0 {
    # We're in a jj repo
    let jj_status = ($jj_check.stdout | str trim)
    let branch = (do -i { jj log -r '@' --no-graph -T 'parents.map(|p| if(p.bookmarks(), p.bookmarks().join(" ") ++ " " ++ p.change_id().shortest(), p.change_id().shortest())).join(", ")' } | complete | get stdout | str trim)
    let has_changes = ($jj_status | str contains "Working copy changes:")

    if ($branch | is-empty) {
      if $has_changes { " (jj*)" } else { " (jj)" }
    } else {
      if $has_changes { " (" + $branch + "*)" } else { " (" + $branch + ")" }
    }
  } else { "" }


  let direnv_info = (do -i {
    # Check if direnv is currently active
    let direnv_dir = ($env.DIRENV_DIR? | default "")
    let direnv_file = ($env.DIRENV_FILE? | default "")

    if ($direnv_dir | str length) == 0 {
      # No direnv active
      return ""
    }

    # Parse direnv status to check if allowed
    let direnv_status = (direnv status | complete | get stdout)
    let is_allowed = ($direnv_status | str contains "Found RC allowed 1")
    let is_blocked = ($direnv_status | str contains "Found RC allowed 0")

    if $is_blocked {
      return " 🔒"
    }

    if $is_allowed {
      # Check if it's nix-direnv
      let in_nix_shell = ($env.IN_NIX_SHELL? | default "") == "impure"
      let path_has_nix = ($env.PATH | str contains "/nix/store/")

      # Check for flake usage
      let has_flake = if ($direnv_file | path exists) {
        (open $direnv_file | str contains "use flake")
      } else { false }

      let nix_info = [$in_nix_shell, $path_has_nix, has_flake]
      match $nix_info {
            [true,true,true] => " ❄️"
            [true,true,false] => " 🟢"
            _ => " 🔓"
      }
    } else {
      " 🔒"
    }
  })


  let os_icon = match $nu.os-info {
      "macos" => "🍎"
      "linux" => "🐧"
      _ => "nu"
  }
  [
    (ansi { fg: "#ff479c" })
    $os_icon
    (ansi reset)
    (ansi { fg: "#61afef" })
    " "
    $path_segment
    (ansi reset)
    (ansi { fg: "#95ffa4" })
    $jj_info
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

$env.PROMPT_COMMAND =  {|| (create_left_prompt) + (char newline)} 
$env.PROMPT_COMMAND_RIGHT = {|| (create_right_prompt)}

$env.PROMPT_INDICATOR_VI_INSERT = "❯ "
$env.PROMPT_INDICATOR_VI_NORMAL = "❮ "
$env.PROMPT_INDICATOR_VI_REPLACE = "🔄 "
$env.PROMPT_MULTILINE_INDICATOR = "::: "
