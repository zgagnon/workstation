#!/usr/bin/env nu

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

# Run homeswitch directly
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

if ($env.HOME_MANAGER_CONFIG? | is-empty) {
    print "❌ HOME_MANAGER_CONFIG environment variable not set!"
    exit 1
}

print "🏗️  Building your shiny new home with home-manager..."
# Run home-manager switch
^home-manager switch --flake $env.HOME_MANAGER_CONFIG --show-trace

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

