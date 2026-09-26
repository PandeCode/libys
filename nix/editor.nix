# builds libys: emacs with my packages and the tools of one profile from
# nixbuilds' toolsets
{ pkgs, wrapProgram }:

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
      # emacs writes caches here, so it has to be a writable directory
      initDirectory ? "~/libys",
    }:
    wrapProgram pkgs withPackages {
      name = "emacs";
      args = [
        "--init-directory"
        initDirectory
      ];
      envs = {
        prefix.PATH = lib.strings.makeBinPath pkgs.toolsets.profiles.${profile};
        set = profileEnv.${profile} or { };
      };
    };
in

lib.customisation.makeOverridable mkEditor { }
