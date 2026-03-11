source ($nu.home-dir + "/.bin/prompt") 
alias homeswitch = nu ($nu.home-dir + "/.bin/homeswitch")
alias good_morning = nu ($nu.home-dir + "/.bin/good_morning")
alias anki = nix run nixpkgs#anki

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

$env.HOME_MANAGER_CONFIG = $"($nu.home-dir)/config/home-manager/"
$env.DOOMDIR = $"($nu.home-dir)/.doom.d/"
$env.config = ($env.config | upsert edit_mode 'vi')

# Keep LS_COLORS enabled for file extension coloring
$env.config = ($env.config | upsert ls.use_ls_colors true)

# Color configuration for light mode readability
$env.config = ($env.config | upsert color_config {
    separator: "#767676"
    leading_trailing_space_bg: { attr: "n" }
    header: { fg: "#107c10" attr: "b" }
    empty: "#0078d4"
    bool: {|| if $in { "#107c10" } else { "#d13438" } }
    int: "#0078d4"
    filesize: {|e|
        if $e == 0b {
            "#767676"
        } else if $e < 1mb {
            "#0078d4"
        } else { "#ff479c" }
    }
    duration: "#0078d4"
    date: {|| (date now) - $in |
        if $in < 1hr {
            { fg: "#d13438" attr: "b" }
        } else if $in < 6hr {
            "#d13438"
        } else if $in < 1day {
            "#f97316"
        } else if $in < 3day {
            "#107c10"
        } else if $in < 1wk {
            { fg: "#107c10" attr: "b" }
        } else if $in < 6wk {
            "#0078d4"
        } else if $in < 52wk {
            "#00539b"
        } else { "#767676" }
    }
    range: "#0078d4"
    float: "#0078d4"
    string: "#767676"
    nothing: "#767676"
    binary: "#767676"
    cellpath: "#767676"
    row_index: { fg: "#107c10" attr: "b" }
    record: "#767676"
    list: "#767676"
    block: "#767676"
    hints: "#4d4d4d"
    search_result: { fg: "#d13438" bg: "#767676" }
    shape_and: { fg: "#ff479c" attr: "b" }
    shape_binary: { fg: "#ff479c" attr: "b" }
    shape_block: { fg: "#0078d4" attr: "b" }
    shape_bool: "#107c10"
    shape_closure: { fg: "#107c10" attr: "b" }
    shape_custom: "#107c10"
    shape_datetime: { fg: "#0078d4" attr: "b" }
    shape_directory: "#0078d4"
    shape_external: "#0078d4"
    shape_externalarg: { fg: "#107c10" attr: "b" }
    shape_filepath: "#0078d4"
    shape_flag: { fg: "#0078d4" attr: "b" }
    shape_float: { fg: "#ff479c" attr: "b" }
    shape_garbage: { fg: "#FFFFFF" bg: "#d13438" attr: "b" }
    shape_globpattern: { fg: "#0078d4" attr: "b" }
    shape_int: { fg: "#ff479c" attr: "b" }
    shape_internalcall: { fg: "#0078d4" attr: "b" }
    shape_list: { fg: "#0078d4" attr: "b" }
    shape_literal: "#0078d4"
    shape_match_pattern: "#107c10"
    shape_matching_brackets: { attr: "u" }
    shape_nothing: "#107c10"
    shape_operator: "#f97316"
    shape_or: { fg: "#ff479c" attr: "b" }
    shape_pipe: { fg: "#ff479c" attr: "b" }
    shape_range: { fg: "#f97316" attr: "b" }
    shape_record: { fg: "#0078d4" attr: "b" }
    shape_redirection: { fg: "#ff479c" attr: "b" }
    shape_signature: { fg: "#107c10" attr: "b" }
    shape_string: "#107c10"
    shape_string_interpolation: { fg: "#0078d4" attr: "b" }
    shape_table: { fg: "#0078d4" attr: "b" }
    shape_variable: "#ff479c"
    shape_vardecl: "#ff479c"
})

# LS_COLORS for light mode readability
# Format: file_type=color_code
# Color codes: 30-37 (foreground), 90-97 (bright), 38;5;N (256 color), 38;2;R;G;B (RGB)
$env.LS_COLORS = "rs=0:di=38;2;0;120;212:ln=38;2;0;120;212:mh=00:pi=40;33:so=38;2;255;71;156:do=38;2;255;71;156:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=38;2;16;124;16:*.el=38;2;16;124;16:*.lisp=38;2;16;124;16:*.py=38;2;16;124;16:*.js=38;2;16;124;16:*.ts=38;2;16;124;16:*.rs=38;2;16;124;16:*.go=38;2;16;124;16:*.c=38;2;16;124;16:*.cpp=38;2;16;124;16:*.java=38;2;16;124;16:*.sh=38;2;209;52;56:*.bash=38;2;209;52;56:*.zsh=38;2;209;52;56:*.nu=38;2;209;52;56:*.json=38;2;249;115;22:*.yaml=38;2;249;115;22:*.yml=38;2;249;115;22:*.toml=38;2;249;115;22:*.md=38;2;0;83;155:*.txt=38;2;0;83;155:*.zip=38;2;255;71;156:*.tar=38;2;255;71;156:*.gz=38;2;255;71;156"
$env.PATH = ($env.PATH | split row (char esep) |
  append ($nu.home-dir + '/.local/bin') |
  append ($nu.home-dir + '/.emacs.d/bin') |
  append ($nu.home-dir + '/.npm-global/bin'))
