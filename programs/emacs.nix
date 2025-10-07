{
  user,
  pkgs,
  ...
}:
{
  home-manager.users.${user} = {
    services.emacs = {
      enable = true;
      client = {
        enable = true;
      };
      # Start the server automatically
      startWithUserSession = true;
      socketActivation = {
        enable = true;
      };
      # Try emacs-git or emacs-unstable for latest alpha-background support
      package = pkgs.emacs-git or pkgs.emacs-unstable or pkgs.emacs30;
    };
  };
}