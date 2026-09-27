# libys

## Run

```bash
nix run github:pandecode/libys
nix run github:pandecode/libys#minimal
nix run github:pandecode/libys#python
nix run github:pandecode/libys#cxx
nix run github:pandecode/libys#rust
nix run github:pandecode/libys#zig
nix run github:pandecode/libys#go
nix run github:pandecode/libys#web
nix run github:pandecode/libys#fun
nix run github:pandecode/libys#full
```

The config comes with the package. Emacs writes its caches, backups and
auto-saves to `~/.local/share/libys`. To try a change, run `nix run .` in
a clone.

## Module

NixOS (`nixosModules.default`) or home-manager (`homeModules.default`):

```nix
{
  imports = [ inputs.libys.nixosModules.default ];

  programs.libys = {
    enable = true;
    profile = "rust"; # minimal python cxx rust zig go web fun full
    defaultEditor = true;
    # optional, for nixd option completion
    nixd.nixos = ''(builtins.getFlake "/home/me/dotnix").nixosConfigurations.laptop.options'';
  };
}
```

## Binary Cache

Add to your `flake.nix`:

```nix
{
  nixConfig = {
    extra-substituters = [ "https://charon.cachix.org" ];
    extra-trusted-public-keys = [
      "charon.cachix.org-1:epdetEs1ll8oi8DT8OG2jEA4whj3FDbqgPFvapEPbY8="
    ];
  };
}
```

## TODO

- [ ] https://github.com/magit/magit
- [ ] https://github.com/minad/org-modern
- [ ] https://github.com/justinbarclay/parinfer-rust-mode
- [ ] https://github.com/NixOS/nix-mode
- [ ] https://github.com/joaotavora/yasnippet https://github.com/AndreaCrotti/yasnippet-snippets
- [ ] https://github.com/tinted-theming/base16-emacs

### zig

- [ ] https://codeberg.org/ziglang/zig-mode

### haskell

- [ ] https://haskell.github.io/haskell-mode/manual/latest/
- [ ] https://github.com/jyp/dante
- [ ] ? https://github.com/matthewbauer/nix-haskell-mode
