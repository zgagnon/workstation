#!/usr/bin/env nu

# Emacs Bootstrap Script
# This script sets up and configures Emacs for the development environment

# Configuration constants
const EMACS_CONFIG_DIR = "~/.emacs.d"
const DOOM_EMACS_DIR = "~/.doom.d"
const BACKUP_SUFFIX = ".backup"

# Main bootstrap function
def main [] {
    print "🚀 Starting Emacs bootstrap process..."
    
    try {
        check_prerequisites

        setup_doom_emacs
        verify_installation
        
        print "✅ Emacs bootstrap completed successfully!"
    } catch { |err|
        print $"❌ Bootstrap failed: ($err.msg)"
        exit 1
    }
}

# Check if required tools are available
def check_prerequisites [] {
    print "🔍 Checking prerequisites..."
    
    let required_tools = ["git", "emacs"]
    
    for tool in $required_tools {
        if (which $tool | is-empty) {
            error make {
                msg: $"Required tool '($tool)' not found in PATH"
            }
        }
    }
    
    print "✅ All prerequisites satisfied"
}





# Setup Doom Emacs with custom configuration
def setup_doom_emacs [] {
    print "🔥 Setting up Doom Emacs..."
    
    let emacs_dir = ($EMACS_CONFIG_DIR | path expand)
    let doom_config_dir = ($DOOM_EMACS_DIR | path expand)
    let doom_config_repo = "git@github.com:zgagnon/doom-emacs.git"
    
    # Remove existing Emacs directory if it exists
    if ($emacs_dir | path exists) {
        print $"⚠️  Emacs directory already exists at ($emacs_dir), removing..."
        rm -rf $emacs_dir
    }
    
    # Remove existing Doom config if it exists
    if ($doom_config_dir | path exists) {
        print $"⚠️  Doom configuration directory already exists at ($doom_config_dir), removing..."
        rm -rf $doom_config_dir
    }
    
    # Clone Doom Emacs framework
    print $"📥 Cloning Doom Emacs framework to ($emacs_dir)"
    run-external "git" "clone" "--depth" "1" "git@github.com:doomemacs/doomemacs.git" $emacs_dir
    
    # Clone custom Doom configuration
    print $"📥 Cloning custom Doom Emacs configuration to ($doom_config_dir)"
    run-external "git" "clone" $doom_config_repo $doom_config_dir
    
    # Install Doom Emacs with custom configuration
    print "🔧 Installing Doom Emacs..."
    let doom_bin = ($emacs_dir | path join "bin" "doom")
    run-external $doom_bin "install" "--force"
    
    print "✅ Doom Emacs setup complete!"
}



# Verify the installation
def verify_installation [] {
    print "🔍 Verifying installation..."
    
    # Check if Emacs is available
    try {
        let emacs_version = (run-external "emacs" "--version" | lines | first)
        print $"✅ Emacs installed: ($emacs_version)"
    } catch {
        print "❌ Emacs verification failed"
        return
    }
    
    # Check if Doom is available
    let doom_bin = ($EMACS_CONFIG_DIR | path expand | path join "bin" "doom")
    if ($doom_bin | path exists) {
        try {
            let doom_version = (run-external $doom_bin "version" | lines | first)
            print $"✅ Doom Emacs installed: ($doom_version)"
        } catch {
            print "⚠️  Doom Emacs verification failed"
        }
    }
    
    print "🎉 Installation verification complete!"
}

# Utility function to prompt user for confirmation
def confirm [message: string]: any -> bool {
    let response = (input $"($message) (y/N): ")
    ($response | str downcase) in ["y", "yes"]
}

# Utility function to print colored output
def print_status [status: string, message: string] {
    match $status {
        "info" => { print $"ℹ️  ($message)" }
        "success" => { print $"✅ ($message)" }
        "warning" => { print $"⚠️  ($message)" }
        "error" => { print $"❌ ($message)" }
        _ => { print $message }
    }
}

# Clean up function (can be called manually)
def cleanup [] {
    print "🧹 Cleaning up..."
    
    # Remove backup files if user confirms
    if (confirm "Remove backup files?") {
        let backup_files = (ls **/*$BACKUP_SUFFIX | get name)
        for file in $backup_files {
            print $"Removing ($file)"
            rm $file
        }
    }
}

# Help function
def help [] {
    print "Emacs Bootstrap Script"
    print ""
    print "Usage:"
    print "  nu bootstrap.nu          # Run the full bootstrap process"
    print "  nu bootstrap.nu cleanup  # Clean up backup files"
    print "  nu bootstrap.nu help     # Show this help message"
    print ""
    print "This script will:"
    print "  1. Check prerequisites"
    print "  2. Setup Doom Emacs"
    print "  3. Verify installation"
}

# Export main functions for external use
export def "bootstrap main" [] { main }
export def "bootstrap cleanup" [] { cleanup }
export def "bootstrap help" [] { help }

# Run main function if script is executed directly
if ($env.CURRENT_FILE? | default "" | str ends-with "bootstrap.nu") {
    let args = ($env.args? | default [])
    
    match ($args | length) {
        0 => { main }
        1 => {
            match ($args | first) {
                "cleanup" => { cleanup }
                "help" => { help }
                _ => { 
                    print "Unknown command. Use 'help' for usage information."
                    exit 1
                }
            }
        }
        _ => {
            print "Too many arguments. Use 'help' for usage information."
            exit 1
        }
    }
}
