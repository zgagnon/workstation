#!/usr/bin/env nu

print "🏠 Switching to canonical workstation..."
cd $env.CANONICAL_WORKSTATION
print $"📁 Now in: ($env.PWD)"

print "📥 Fetching latest changes..."
jj git fetch

print "🌱 Creating new branch from main..."
let $rebase_result = (jj rebase -d main@origin | complete)
if $rebase_result.exit_code != 0 {
    print "❌ Rebase conflicts detected! Aborting script."
    print "Please resolve conflicts manually and run again."
    exit 1
}

print "❄️ Updating system flake..."
nix flake update
if (jj diff flake.lock --no-pager | str length) > 0 {
    print "🔄 System flake changed, rebuilding Darwin..."
    sudo darwin-rebuild switch --flake .#zell-mo
}

print "🏠 Updating home-manager..."
do {
    cd home-manager
    nix flake update
    if (jj diff flake.lock --no-pager | str length) > 0 {
        print "🔄 Home flake changed, running homeswitch..."
        nu ($env.CANONICAL_WORKSTATION + "/programs/nushell/homeswitch.nu")
    } else {
        print "✅ Home flake unchanged, skipping homeswitch"
    }
}

print "📤 Switching to public workstation..."
cd $env.PUBLIC_WORKSTATION
echo pwd

jj new main
print "🔄 Syncing workstations..."
rsync -av --delete --exclude='.*' ($env.CANONICAL_WORKSTATION + "/") $env.PUBLIC_WORKSTATION

let $diff = jj diff --no-pager
if ($diff | str length) > 0 {
    print "🤖 Generating commit summary..."
    let $commit_summary = (jj show | claude --print "Summarise this jj commit")

    print "📝 Updating commit description..."
    jj describe -m $commit_summary

    print "🏷️  Bookmarking main..."
    jj b m main

    print "🚀 Pushing to remote..."
    jj git push

    print "✨ Creating new working branch..."
    jj new
} else {
    print "No diff in workstations, skipping"
}

~/.bin/coder.sh
