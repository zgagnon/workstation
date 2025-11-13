{
  withBasePath = base-path: paths:
    builtins.map (x: base-path + "${x}") paths;
}
