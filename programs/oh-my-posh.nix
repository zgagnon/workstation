{
  ...
}:
{
  programs.oh-my-posh = {
    enable = true;
    enableNushellIntegration = true;
    
    # Custom powerline-style configuration with direnv status
    settings = {
      version = 2;
      final_space = true;
      blocks = [
        {
          type = "prompt";
          alignment = "left";
          segments = [
            {
              type = "shell";
              style = "powerline";
              powerline_symbol = "";
              foreground = "#ffffff";
              background = "#ff479c";
            }
            {
              type = "path";
              style = "powerline";
              powerline_symbol = "";
              foreground = "#ffffff";
              background = "#61afef";
              properties = {
                style = "folder";
              };
            }
            {
              type = "git";
              style = "powerline";
              powerline_symbol = "";
              foreground = "#193549";
              background = "#95ffa4";
            }
            {
              type = "command";
              style = "powerline";
              powerline_symbol = "";
              foreground = "#ffffff";
              background = "#f97316";
              properties = {
                command = "direnv status | grep -q 'Found RC' && echo '🔒 direnv' || echo '🔓'";
                shell = "bash";
              };
            }
          ];
        }
      ];
    };
  };
}