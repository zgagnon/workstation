{pkgs}:
let
  beadsSrc = pkgs.fetchFromGitHub {
        owner = "zgagnon";
        repo = "beads";
        rev = "main";
        sha256 = "sha256-Yww6ke7YM8eY9RSD4jSQJ9rt3Ioo5pUWe1wb+jN2rng=";
      };in

   pkgs.callPackage "${beadsSrc}/default.nix" { self = beadsSrc; }
