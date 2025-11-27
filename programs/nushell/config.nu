source ($nu.home-path + "/.bin/prompt") 
alias homeswitch = nu ($nu.home-path + "/.bin/homeswitch")
alias good_morning = nu ($nu.home-path + "/.bin/good_morning")

# Override TERM when connecting via Ghostty to coder machine to fix terminfo issues
if  ($env.user? == "coder") {
  $env.COLORTERM = "truecolor"
}

def try-out [try: string, ...args:string] {
    nix run $"nixpkgs#($try)" -- $"($args)"
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
  try { source ~/.secrets.nu } catch { print "Warning: Failed to load ~/.secrets.nu" }
}

$env.HOME_MANAGER_CONFIG = $"($nu.home-path)/config/home-manager/"
$env.DOOMDIR = $"($nu.home-path)/.doom.d/"
$env.config = ($env.config | upsert edit_mode 'vi')
$env.PATH = ($env.PATH | split row (char esep) |
  append ($nu.home-path + '/.emacs.d/bin') |
  append ($nu.home-path + '/.npm-global/bin'))
