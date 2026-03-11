{
  ...
}:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    initContent = builtins.concatStringsSep "\n" [
      "if [ -e $HOME/.profile ]; then . $HOME/.profile; fi"
      "export NIXPKGS_ALLOW_UNFREE=1"
      "export DOOMDIR=\"$HOME/.doom.d\""
      ''eval "$(fasd --init auto)"''
      "alias g=git"
      "alias v='f -e vim'"
      "alias ls='ls -lahG'"
      "alias el='eza -labh --git --git-repos'"
      "alias history='fc -l 1'"
      "alias ms='mob start'"
      "alias vim=nvim"

      "alias clean-branches='git for-each-ref --format=\"%(refname:short)\" refs/heads | grep -v main | xargs -L1 git branch -D'"
      "alias clean-branches-remote='git for-each-ref --format=\"%(refname:short)\" refs/remotes | grep -v origin/main | xargs -L1 git branch -D --remote'"
      ''export PATH="$PATH:$HOME/darwin-flake/switcher:$HOME/.npm-global/bin"''
      ''export AUTO_ENABLE_FLAKES=true''
      ''eval "$(/opt/homebrew/bin/brew shellenv)"''
      "export EDITOR=nvim"
    ];
    history = {
      ignoreSpace = true;
      ignoreDups = true;
      save = 100000;
      size = 100000;
    };
  };
}
