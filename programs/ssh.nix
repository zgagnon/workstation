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
    enableDefaultConfig = false;
    extraConfig = ''
      Include ~/.ssh/1Password/config
    '';

    matchBlocks = {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
        extraOptions = {
          IdentityAgent = "\"/Users/zell/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
        };
      };

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
