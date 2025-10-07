{ ... }:
let
  homeAssistant = {
    hostname = "192.168.68.64";
    user = "root";
    port = 22;
    extraOptions = {
      MACs = "umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com";
      IdentityAgent = "\"/Users/zell/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";

    };
    identitiesOnly = true;
  };
in
{

  programs.ssh = {
    enable = true; # Global SSH settings
    extraConfig = ''
      Include ~/.ssh/1Password/config

      # Use 1Password SSH agent
      IdentityAgent "/Users/zell/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';

    matchBlocks = {
      "home-assistant" = homeAssistant;
      "hass" = homeAssistant;

      "github.com" = {
        extraOptions = {
          IdentityAgent = "~/.1password/agent.sock";
        };
      };
    };
  };
}
