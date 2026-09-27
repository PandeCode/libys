{ pkgs, self }:

let
  inherit (pkgs) lib;
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (lib.options) mkOption;
  inherit (lib) types;

  nixd.nixos = "(import <nixpkgs/nixos> { }).options";

  nixos =
    (import "${pkgs.path}/nixos/lib/eval-config.nix" {
      system = null;
      modules = [
        self.nixosModules.default
        {
          nixpkgs.hostPlatform = system;
          boot.loader.grub.enable = false;
          fileSystems."/" = {
            device = "none";
            fsType = "tmpfs";
          };
          system.stateVersion = "26.05";

          programs.libys = {
            enable = true;
            profile = "rust";
            defaultEditor = true;
            inherit nixd;
          };
        }
      ];
    }).config;

  # the options home-manager would provide, so the module can be checked
  # without a home-manager input
  home =
    (lib.modules.evalModules {
      specialArgs = { inherit pkgs; };
      modules = [
        self.homeModules.default
        {
          options.home = {
            packages = mkOption {
              type = types.listOf types.package;
              default = [ ];
            };
            sessionVariables = mkOption {
              type = types.attrsOf types.str;
              default = { };
            };
          };
        }
        { programs.libys.enable = true; }
      ];
    }).config;

  inherit (nixos.programs.libys) package;

  editorIn = packages: lib.lists.any (p: p.name == package.name) packages;
in

{
  formatting = self.formatter.${system}.check self;

  modules =
    assert lib.asserts.assertMsg (editorIn nixos.environment.systemPackages)
      "nixos: editor not installed";
    assert lib.asserts.assertMsg (
      nixos.environment.variables.EDITOR == "emacs"
    ) "nixos: EDITOR not set";
    assert lib.asserts.assertMsg (
      package.nixdServer.settings.nixd.options.nixos.expr == nixd.nixos
    ) "nixos: nixd expression not passed to the editor";
    assert lib.asserts.assertMsg
      (lib.strings.hasInfix (builtins.unsafeDiscardStringContext "--add-flags ${package.initDirectory}") package.drvAttrs.buildCommand)
      "nixos: config not passed to emacs";
    assert lib.asserts.assertMsg (
      builtins.length home.home.packages == 2
    ) "home: editor and aspell not installed";
    assert lib.asserts.assertMsg (
      !(home.home.sessionVariables ? EDITOR)
    ) "home: EDITOR set without defaultEditor";
    pkgs.runCommandLocal "libys-modules" { } "touch $out";
}
