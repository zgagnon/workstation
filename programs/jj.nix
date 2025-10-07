{
  ...
}:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "zoe@zgagnon.com";
        name = "Zoe Gagnon";
      };
      revset-aliases = {
        "thisofftrunk()" = "trunk()..@ | (..trunk() ~ ..@) | latest(..trunk() & ..@)";
        "allofftrunk()" = "trunk()..@";
        "accordion()" =
          "@ | bases | bookmarks | curbookmark::@ | @::nextbookmark | downstream(@, bookmarksandheads)";
        "bases" = "trunk()";
        "downstream(x,y)" = "(x::y) & y";
        "bookmarks" = "downstream(trunk(), bookmarks()) & mine()";
        "bookmarksandheads" = "bookmarks | (heads(trunk()::) & mine())";
        "curbookmark" = "latest(bookmarks::@- & bookmarks)";
        "nextbookmark" = "roots(@:: & bookmarksandheads)";
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
        "closest_pushable(to)" =
          "heads(::to & mutable() & ~description(exact:\" \") & (~empty() | merges()))";

      };
      aliases = {
        heads = [
          "log"
          "-r"
          "visible_heads()"
          "--no-pager"
        ];
        save = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          "jj squash --into $@"
          ""
        ];
      };
      ui = {
        editor = "emacs -nw";
        default-command = [
          "log"
          "--no-pager"
        ];
      };
    };
  };
}
