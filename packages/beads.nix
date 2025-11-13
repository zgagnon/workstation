{pkgs}:
let
  beadsSrc = pkgs.fetchFromGitHub {
        owner = "zgagnon";
        repo = "beads";
        rev = "main";
        sha256 = "
sha256-hWhvXq+xOTktjwsoXZf/gT4/2jIT1wJa4+JQ8CE4SJE=
  ";
      };in

   pkgs.callPackage "${beadsSrc}/default.nix" { self = beadsSrc; }
