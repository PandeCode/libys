# builds libys: emacs with my packages, this config and the tools of one
# profile from nixbuilds' toolsets
{
  pkgs,
  wrapProgram,
  src,
}:

let
  inherit (pkgs) lib;

  emacs = pkgs.emacs-pgtk;

  lldb = pkgs.vscode-extensions.vadimcn.vscode-lldb;

  lldbEnv = {
    CODELLDB_PATH = "${lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
    LIBLLDB_PATH = "${lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.so";
  };

  rustEnv = {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };

  # extra environment per profile, on top of the profile's tools
  profileEnv = {
    # keep-sorted start
    cxx = lldbEnv;
    full = lldbEnv // rustEnv;
    fun = lldbEnv;
    go = lldbEnv;
    rust = lldbEnv // rustEnv;
    web = lldbEnv;
    zig = lldbEnv;
    # keep-sorted end
  };

  withPackages = (pkgs.emacsPackagesFor emacs).emacsWithPackages (
    epkgs: with epkgs; [
      base16-theme

      magit
      vterm

      vertico
      mini-frame
      marginalia

      evil
      general
      which-key

      lsp-bridge
      markdown-mode
      yasnippet

      nix-mode

      parinfer-rust-mode

      zig-mode
      rust-mode

      dante

      ledger-mode
    ]
  );

  mkEditor =
    {
      # one of the profiles in nixbuilds' toolsets
      profile ? "full",
      # nix expressions nixd evaluates for option completion
      nixd ? { },
    }:
    let
      # lsp-bridge reads <server>.json from lsp-bridge-user-langserver-dir
      nixdServer = {
        name = "nixd";
        languageId = "nix";
        command = [ "nixd" ];
        settings.nixd = {
          nixpkgs.expr = "import ${pkgs.path} { }";
          options = lib.attrsets.mapAttrs (_: expr: { inherit expr; }) nixd;
        };
      };

      langservers = pkgs.writeTextFile {
        name = "libys-langservers";
        destination = "/nixd.json";
        text = builtins.toJSON nixdServer;
      };

      # the config stays in the store; what emacs writes goes to
      # ~/.local/share/libys, like NVIM_APPNAME does for hermes
      initDirectory = pkgs.linkFarm "libys-init" {
        "early-init.el" = pkgs.writeText "early-init.el" ''
          (setq libys-directory "${src}/")
          (setq libys-nix-profile "${profile}")
          (setq libys-nix-langserver-dir "${langservers}")

          (setq user-emacs-directory
                (expand-file-name "libys/" (or (getenv "XDG_DATA_HOME") "~/.local/share")))
          (setq auto-save-list-file-prefix
                (expand-file-name "auto-save-list/.saves-" user-emacs-directory))
          (startup-redirect-eln-cache (expand-file-name "eln-cache/" user-emacs-directory))

          (load (expand-file-name "early-init.el" libys-directory) nil t t)
        '';

        "init.el" = pkgs.writeText "init.el" ''
          (load (expand-file-name "init.el" libys-directory) nil t t)
        '';
      };
    in
    (wrapProgram pkgs withPackages {
      name = "emacs";
      args = [
        "--init-directory"
        "${initDirectory}"
      ];
      envs = {
        prefix.PATH = lib.strings.makeBinPath pkgs.toolsets.profiles.${profile};
        set = profileEnv.${profile} or { };
      };
    }).overrideAttrs
      (old: {
        passthru = old.passthru or { } // {
          inherit initDirectory nixdServer;
        };
      });
in

lib.customisation.makeOverridable mkEditor { }
