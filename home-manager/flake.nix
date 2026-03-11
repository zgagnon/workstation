{
  description = "Home Manager configuration of zell";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
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

      homeConfigurations."zell" = import ./machines/work-darwin.nix { inherit sysPkgs home-manager; };
      homeConfigurations."zell-mo" = import ./machines/work-darwin.nix { inherit sysPkgs home-manager; };

      homeConfigurations."coder" = import ./machines/work-coder.nix { inherit sysPkgs home-manager; };
      homeConfigurations."zoe" = import ./machines/home-nixos.nix { inherit sysPkgs home-manager; };
    };
}
