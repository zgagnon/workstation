#!/usr/bin/env nu

print "🏠 Switching to canonical workstation..."
cd $env.CANONICAL_WORKSTATION
echo pwd

print "📥 Fetching latest changes..."
jj git fetch

print "🌱 Creating new branch from main..."
jj new main

print "📤 Switching to public workstation..."
cd $env.PUBLIC_WORKSTATION
echo pwd

print "🔄 Syncing workstations..."
rsync -av --delete --exclude='.*' ($env.CANONICAL_WORKSTATION + "/") $env.PUBLIC_WORKSTATION

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



#~/.bin/coder.sh
