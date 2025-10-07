{
  co = "checkout";
  st = "status";
  ci = "commit -v";
  parts = "add -p";
  lg =
    "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
  lgp =
    "log --pretty=format:'%C(yellow)%h%Creset - %s %C(auto)%d - %C(green)%ad - %C(blue)%an <%C(green)%ae%C(blue)>' --graph --date=local";
  lgf =
    "log --pretty=format:'%C(yellow)%h %C(green)%ad %C(red)%an%Creset %s %C(auto)%d' --graph --date=local --stat";
  pr = "pull --rebase --autostash";
  rum = "rebase main@{u}";
  bl = "branch --list";
  ba = "branch --all";
  pf = "push --force-with-lease";
  pop = "reset HEAD^";
  update = "ci --amend --no-edit";
  edit = "ci --amend";
  cp = "cherry-pick";
  dfc = "diff --cached";
  rpo = "remote prune origin";
  sl = "stash list";
  sll = "stash-list";
  slll = "stash-list --full";
  ss = "stash save";
  sa = "!sh -c 'git stash apply stash@{$1}' -";
  sd = "!sh -c 'git stash drop stash@{$1}' -";
}
