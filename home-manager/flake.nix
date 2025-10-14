{
  description = "Home Manager configuration of zell";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      emacs-overlay,
      ...
    }:
    let
      sysPkgs =
        system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [
            emacs-overlay.overlays.default
            (final: prev: {
              # Import custom packages
              fasder = final.callPackage ./../packages/fasder.nix { };
            })
          ];
        };
    in
    {
      devShells.x64_64-linux.default = (sysPkgs "x86_64-linux").mkShell {
        buildInputs = [ home-manager.packages.x64_64-linux.home-manager ];
      };

      homeConfigurations."zell" = home-manager.lib.homeManagerConfiguration rec {
        pkgs = sysPkgs "aarch64-darwin";

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./../programs/aerospace.nix
          ./../programs/atuin.nix
          ./../programs/carapace.nix
          ./../programs/direnv.nix
          ./../programs/git.nix
          ./../programs/oneP.nix
          ./../programs/jj.nix
          ./../programs/nushell.nix
          ./../programs/raycast.nix
          ./../programs/ssh.nix
          ./../programs/starship.nix
          ./../programs/zoxide.nix
          ./../programs/zsh.nix
          ./home.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
          inherit home-manager;
          arch = "aarch64-darwin";
          user = "zell";
          home = "/Users/zell";
          email = "zoe@zgagnon.com";
          home-config = "/Users/zell/git/mo/workstations/home/zgagnon/home-manager";
          uniquePkgs = with pkgs; [
            cachix
            direnv
            emacs
            anki-bin
          ];
        };
      };

      homeConfigurations."coder" = home-manager.lib.homeManagerConfiguration rec {
        pkgs = sysPkgs "x86_64-linux";

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home.nix
          ./../programs/atuin.nix
          ./../programs/carapace.nix
          ./../programs/git.nix
          ./../programs/jj.nix
          ./../programs/direnv.nix
          ./../programs/nushell.nix
          ./../programs/raycast.nix
          ./../programs/starship.nix
          ./../programs/zsh.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
          inherit home-manager;
          arch = "x86_64-linux";
          user = "coder";
          home = "/home/coder";
          email = "zoe@zgagnon.com";
          home-config = "/home/coder/workspace/workstations/home/zgagnon/home-manager";
          uniquePkgs = with pkgs; [
            emacs
          ];
        };
      };
    };
}
