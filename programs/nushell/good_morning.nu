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
    let $commit_summary = (jj diff --git --no-pager | claude --print "CRITICAL INSTRUCTIONS:
1. Write ONLY the actual commit message - DO NOT write meta-commentary
2. DO NOT write: 'I'll create...', 'Looking at the diff...', 'This commit will...', 'Based on the changes...'
3. Your entire output IS the commit message itself - nothing else
4. DO NOT describe your process of writing the message
5. Start directly with the imperative verb describing the change

RULES (from cbea.ms/git-commit):
- Subject: ≤50 chars ideal (72 hard max), imperative mood, capitalized, no period
- Test: 'If applied, this commit will [your subject]' must read correctly
- Body: blank line after subject, wrap at 72 chars, explain WHAT and WHY (not HOW)
- Focus on the actual code changes shown in the diff

BAD EXAMPLES (meta-commentary - NEVER do this):
❌ 'I'll create a git commit message following the rules...'
❌ 'Looking at the diff, I can see configuration changes...'
❌ 'This commit will update the dependencies...'
❌ 'Based on the changes, I suggest...'

GOOD EXAMPLE (actual commit message):
✓ Update home-manager dependencies

Updates flake dependencies to latest versions to incorporate
security patches and compatibility fixes for the build system.

Now write ONLY the commit message for these changes:")

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
