{ config, lib, ... }:
{
  programs.direnv = {
    enableNushellIntegration = false; # Disable built-in integration that overwrites hooks
    enableZshIntegration = true;
    enable = true;
  };

  # Custom nushell direnv integration that preserves existing hooks
  programs.nushell = {
    extraConfig = lib.mkAfter ''
      # Direnv integration with proper hook merging
      $env.config = ($env.config | upsert hooks.pre_prompt (
        $env.config.hooks.pre_prompt?
        | default []
        | append {||
          ${lib.getExe config.programs.direnv.package} export json
          | from json --strict
          | default {}
          | items {|key, value|
            let value = do (
              {
                "PATH": {
                  from_string: {|s| $s | split row (char esep) | path expand --no-symlink }
                  to_string: {|v| $v | path expand --no-symlink | str join (char esep) }
                }
              }
              | merge ($env.ENV_CONVERSIONS? | default {})
              | get -o $key
              | get -o from_string
              | if ($in | is-empty) { {|x| $x} } else { $in }
            ) $value
            return [ $key $value ]
          }
          | into record
          | load-env
        }
      ))
    '';
  };
}
