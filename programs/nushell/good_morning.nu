#!/usr/bin/env nu

let MINE = ($env.HOME + "/config")
let WORK = ($env.HOME + "/workspace/workstations/home/zgagnon")

# start update process by cleaning out old nix tarballs
# Clean old entries from Nix tarball cache (keep last 30 days)
print "🧹 Cleaning old Nix tarball cache entries..."
let cache_path = ($env.HOME + "/.cache/nix/tarball-cache")
if ($cache_path | path exists) {
    do --ignore-errors {
        git -C $cache_path gc --prune=30.days.ago --quiet
        print "✅ Tarball cache cleaned (kept entries from last 30 days)"
    }
} else {
    print "✓ No tarball cache to clean"
}

#next -> pull from my own source. This is the system of record
print "🏠 Switching to my workstation..."
cd $MINE
print $"📁 Now in: ($env.PWD)"

print "📥 Fetching latest changes..."
jj git fetch

#Put any local changes back on main
print "🌱 Creating new branch from main..."
let $rebase_result = (jj rebase -d main@origin | complete )
if $rebase_result.exit_code != 0 {
    print "❌ Rebase conflicts detected! Aborting script."
    print "Please resolve conflicts manually and run again."
    exit 1
}
print "❄️ Updating darwin flake..."
do {
    cd ($MINE + "/darwin")
    nix flake update
    if (jj diff flake.lock --no-pager | str length) > 0 {
        print "🔄 Darwin flake changed, rebuilding Darwin..."
        sudo darwin-rebuild switch --flake .#zell-mo
    } else {
        print "✅ Darwin flake unchanged, skipping rebuild"
    }
}

print "🏠 Updating home-manager..."
do {
    cd home-manager
    nix flake update
    if (jj diff flake.lock --no-pager | str length) > 0 {
        print "🔄 Home flake changed, running homeswitch..."
        nu ($MINE + "/programs/nushell/homeswitch.nu")
    } else {
        print "✅ Home flake unchanged, skipping homeswitch"
    }
}

#update work
print "📤 Switching to work workstation..."
cd $WORK
echo pwd

jj new main
print "🔄 Syncing workstations..."
rsync -av --delete --exclude='.*' ($MINE + "/") $WORK

let $diff = jj diff --no-pager
if ($diff | str length) > 0 {
    print "🤖 Generating commit summary..."
    let $commit_summary = (jj show | claude --print "Create a git commit message following these rules:
1. Subject line: max 50 chars (72 hard limit), capitalize first word, no period at end
2. Use imperative mood (e.g., 'Add feature' not 'Added feature')
3. Test: 'If applied, this commit will [your subject]' should read correctly
4. Separate subject from body with blank line
5. Body: wrap at 72 chars, explain WHAT and WHY (not how)
6. Focus on the changes shown in the diff

Format:
<Subject line>

<Body explaining what changed and why>")

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
