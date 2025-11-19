{
  lib,
  pkgs,
  email,
  ...
}:
let
  aliases = import ./aliases.nix;
in
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "zgagnon";
      user.email = email;
      core.excludesfile = "~/.gitignore_global";
      aliases = aliases;
      gpg = {
        format = "ssh";
      };
      "gpg \"ssh\"" = lib.mkIf pkgs.stdenv.isDarwin {
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
      core = {
        hooksPath = "bin/githooks";
        fsmonitor = "true";
        filemode = "true";
        editor = "vi";
      };
      mergetool."idea" = {
        cmd = ''
          idea merge \
                          \"$(cd \"$(dirname \"$LOCAL\")\" && pwd)/$(basename \"$LOCAL\")\" \
                          \"$(cd \"$(dirname \"$REMOTE\")\" && pwd)/$(basename \"$REMOTE\")\" \
                          \"$(cd \"$(dirname \"$BASE\")\" && pwd)/$(basename \"$BASE\")\" \
                          \"$(cd \"$(dirname \"$MERGED\")\" && pwd)/$(basename \"$MERGED\")\" \
        '';
      };
      push.autoSetupRemote = false;
      rerere = {
        enabled = true;
      };
      column.branch = "auto";
      maintenance.strategy = "incremental";
    };
    lfs = {
      enable = true;
    };

    # Global ignore patterns - affects both git and jj
    ignores = [
      "completions-jj.nu"
      # Add other global ignores here if needed
      ".DS_Store" # macOS
      "Thumbs.db" # Windows
      "*.swp" # Vim swap files
      "*.swo" # Vim swap files
      "*~" # Backup files
    ];

    #    signing = {
    #      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBw43UgKpS9/bxfyP9y8R0enylSCNdVc5OgPKB64IJGC";
    #      signByDefault = true;
    #    };
  };
}
