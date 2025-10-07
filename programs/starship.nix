{
  lib,
  ...
}:
{

  programs.starship = {
    enable = false;
    # enableNushellIntegration = true;
    settings = {
      format = lib.concatStrings [
        "$shell"
        "$directory"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_metrics"
        "$git_status"
        "$fill"
        "$dotnet"
        "$elixir"
        "$haskell"
        "$nix_shell"
        "$direnv"
        "$line_break"
        "$status"
        "$sudo"
        "$character"
      ];

      shell = {
        disabled = false;
        style = "red bold";
      };

      right_format = lib.concatStrings [
        "$cmd_duration"
      ];

      direnv = {
        disabled = false;
        symbol = "direnv ";
        allowed_msg = "[ok]";
        not_allowed_msg = "[blocked]";
        loaded_msg = "[loaded]";
        unloaded_msg = "[unloaded]";
      };

      git_metrics = {
        added_style = "bold blue";
        format = "[+$added]($added_style)/[-$deleted]($deleted_style) ";
      };

      cmd_duration = {
        min_time = 0;
        show_milliseconds = true;
        show_notifications = true;
      };

      character = {
        success_symbol = "❯";
        error_symbol = "❯";
      };
    };
  };
}
