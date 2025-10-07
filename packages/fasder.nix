{ pkgs, lib, ... }:

pkgs.buildGoModule rec {
  pname = "fasder";
  version = "0.1.6";

  src = pkgs.fetchFromGitHub {
    owner = "wyne";
    repo = "fasder";
    rev = "${version}";
    hash = "sha256-8Ux8l2Vk15DZwoOU3tLlX7cNvVv3GXoIIUSx9Z2/n8E="; # Will be filled after first build attempt
  };

  vendorHash = "sha256-UPd9buncfDEsOQryeJD5eWsly7wdxhadM6DlnvDq9H0="; # Will be filled after first build attempt

  # fasder depends on zsh
  nativeBuildInputs = with pkgs; [ zsh ];

  # Skip tests as they require the fasder binary to be installed
  doCheck = false;

  # Build flags for optimization
  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Fast directory and file navigation tool - zoxide for files";
    longDescription = ''
      Fasder lets you access files and directories lightning quick.
      It remembers which files and directories you use most frequently,
      so you can access them in just a few keystrokes.
      A modern reimagining of clvv/fasd with zoxide-style "frecent" access.
    '';
    homepage = "https://github.com/wyne/fasder";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "fasder";
  };
}
