{
  pkgs,
  lib,
  config,
  ...
}:
let
  homeDir = "/Users/zell/";
in
{
  home = {
    file.".1password/agent.sock" = lib.mkIf pkgs.stdenv.isDarwin {
      source = config.lib.file.mkOutOfStoreSymlink "${homeDir}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    };

    sessionVariables = {
      SSH_AUTH_SOCK = "${homeDir}/.1password/agent.sock";
    };
  };
}
