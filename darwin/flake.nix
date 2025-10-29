{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:nix-darwin/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      darwin,
      nixpkgs,
      home-manager,
    }:
    let
      systemConfiguration =
        { pkgs, arch, ... }:
        {

          nix.enable = false;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.allowBroken = true;
          # Enable alternative shell support in nixdarwin.
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;
          users.users.zell = {
            name = "zell";
            home = "/Users/zell";
            shell = pkgs.nushell;
          };
          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;
          system.primaryUser = "zell";

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = arch;
          security.pam.services.sudo_local.touchIdAuth = true;
          system.defaults = {
            dock.autohide = true;
          };
          fonts.packages = with pkgs; [
            nerd-fonts.fira-code
            nerd-fonts.droid-sans-mono
          ];

        };
      homebrew = {
        homebrew = {
          enable = true;

          onActivation = {
            cleanup = "zap";
            autoUpdate = true;
            upgrade = true;
          };

          casks = [
            "google-chrome"
            "notion"
            "discord"
            "arc"
            "orbstack"
            "raycast"
            "slack"
            "logseq"
            "tandem"
            "tuple"
            "soundsource"
            "ghostty"
          ];
        };
      };
      globalPrograms =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.vim
            pkgs.home-manager
          ];
          programs.zsh.enable = true;
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."zell-mo" = darwin.lib.darwinSystem rec {
        system = "aarch64-darwin";
        modules = [
          systemConfiguration
          homebrew
          globalPrograms
        ];
        specialArgs = {
          arch = "aarch64-darwin";
          user = "zell";
          email = "zoe@zgagnon.com";
        };
      };
    };
}
