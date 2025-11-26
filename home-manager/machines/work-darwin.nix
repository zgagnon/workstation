{sysPkgs, home-manager}:
let
paths = import ../../nix-library/paths.nix;
in
home-manager.lib.homeManagerConfiguration rec {
        pkgs = sysPkgs "aarch64-darwin";

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = paths.withBasePath  ./.. [
"./../programs/aerospace.nix"
"./../programs/atuin.nix"
"./../programs/carapace.nix"
"./../programs/direnv.nix"
"./../programs/git.nix"
"./../programs/oneP.nix"
"./../programs/jj.nix"
"./../programs/nushell.nix"
"./../programs/raycast.nix"
"./../programs/ssh.nix"
"./../programs/starship.nix"
"./../programs/zoxide.nix"
"./../programs/zsh.nix"
"/home.nix"
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
          inherit home-manager;
          arch = "aarch64-darwin";
          user = "zell";
          home = "/Users/zell";
          email = "zoe@zgagnon.com";
          home-config = "/Users/zell/config/home-manager";
          uniquePkgs = with pkgs; [
            direnv
            emacs
            anki-bin
          ];
        };
      }
