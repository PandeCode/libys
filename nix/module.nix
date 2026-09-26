# the same module for nixos and home-manager; `class` picks where packages
# and variables go
{ self, class }:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types;

  cfg = config.programs.libys;

  editor = self.packages.${pkgs.stdenv.hostPlatform.system}.default;

  packages = [
    cfg.package
    (pkgs.aspellWithDicts (
      dicts: with dicts; [
        en
        en-computers
        en-science
        es
      ]
    ))
  ];
in

{
  options.programs.libys = {
    enable = mkEnableOption "libys, my emacs";

    profile = mkOption {
      type = types.enum [
        "minimal"
        "python"
        "cxx"
        "rust"
        "zig"
        "go"
        "web"
        "fun"
        "full"
      ];
      default = "full";
      description = "Which language tools come with the editor.";
    };

    initDirectory = mkOption {
      type = types.str;
      default = "~/libys";
      description = ''
        A clone of libys. Emacs loads the config from here and writes its
        caches here, so it has to be writable.
      '';
    };

    package = mkOption {
      type = types.package;
      default = editor.override { inherit (cfg) profile initDirectory; };
      defaultText = lib.literalExpression "libys built from profile and initDirectory";
      description = "The editor package.";
    };

    defaultEditor = mkEnableOption "libys as EDITOR";
  };

  config = mkIf cfg.enable (mkMerge [
    (lib.optionalAttrs (class == "nixos") {
      environment.systemPackages = packages;
      environment.variables.EDITOR = mkIf cfg.defaultEditor "emacs";
    })

    (lib.optionalAttrs (class == "homeManager") {
      home.packages = packages;
      home.sessionVariables.EDITOR = mkIf cfg.defaultEditor "emacs";
    })
  ]);
}
