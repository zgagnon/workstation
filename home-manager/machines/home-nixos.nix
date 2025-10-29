{ sysPkgs, home-manager }:
let
  paths = import ../../nix-library/paths.nix;
in
home-manager.lib.homeManagerConfiguration rec {
  pkgs = sysPkgs "x86_64-linux";

  # Specify your home configuration modules here, for example,
  # the path to your home.nix.
  modules = paths.withBasePath ./.. [
    "/home.nix"
    "./../programs/atuin.nix"
    "./../programs/carapace.nix"
    "./../programs/git.nix"
    "./../programs/jj.nix"
    "./../programs/direnv.nix"
    "./../programs/nushell.nix"
    "./../programs/raycast.nix"
    "./../programs/starship.nix"
    "./../programs/zsh.nix"
  ];

  # Optionally use extraSpecialArgs
  # to pass through arguments to home.nix
  extraSpecialArgs = {
    inherit home-manager;
    arch = "x86_64-linux";
    user = "zoe";
    home = "/home/zoe/";
    email = "zoe@zgagnon.com";
    home-config = "/home/zoe/workstation/home-manager/";
    uniquePkgs = with pkgs; [
      emacs
    ];
  };
}
