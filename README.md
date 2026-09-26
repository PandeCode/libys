# libys

My emacs config, wrapped with its packages and language tools.

## Run

```bash
git clone https://github.com/PandeCode/libys ~/libys
nix run github:PandeCode/libys          # full
nix run github:PandeCode/libys#minimal  # minimal python cxx rust zig go web fun
```

Emacs loads the config from `~/libys` and writes its caches there.

## Module

NixOS (`nixosModules.default`) or home-manager (`homeModules.default`):

```nix
{
  imports = [ inputs.libys.nixosModules.default ];

  programs.libys = {
    enable = true;
    profile = "rust";
    initDirectory = "~/src/libys"; # default ~/libys
    defaultEditor = true;
  };
}
```
