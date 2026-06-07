self: let
  inherit (self) inputs;
  inherit (inputs) nixpkgs;
in
  system: let
    pkgs = nixpkgs.legacyPackages.${system};
    escapeShellArg = pkgs.lib.escapeShellArg;

    wrapProgram = pkg: config: let
      mkWrapFlags = {
        envs ? {},
        args ? [],
      }: let
        mkEnvFlag = name: value: [
          "--prefix"
          name
          ":"
          value
        ];

        envFlags = pkgs.lib.flatten (pkgs.lib.mapAttrsToList mkEnvFlag envs);
        argFlags = pkgs.lib.concatMap (arg: ["--add-flags" arg]) args;
      in
        envFlags ++ argFlags;
    in
      pkgs.symlinkJoin {
        name = "${pkg.pname or pkg.name}-wrapped";
        paths = [pkg];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = let
          program = pkg.meta.mainProgram or (pkg.pname or pkg.name);
          flags = mkWrapFlags {
            envs = config.envs or {};
            args = config.args or [];
          };
        in ''
          wrapProgram $out/bin/${program} ${pkgs.lib.escapeShellArgs flags}
        '';
      };

    # emacs = inputs.emacs-overlay.packages.${pkgs.system}.emacs-git;
    emacs = pkgs.emacs-pgtk;

    tools = let
      lldbTools = with pkgs; [
        vscode-extensions.vadimcn.vscode-lldb
        lldb
      ];
    in {
      base = with pkgs; [
        universal-ctags
        ripgrep
        fd
        proselint
        ast-grep
        harper
      ];

      lua = with pkgs; [
        emmylua-ls
        emmylua-check
        emmylua-doc-cli
        stylua
      ];

      fennel = with pkgs; [
        luaPackages.fennel
        fennel-ls
        fnlfmt
      ];

      nix = with pkgs; [
        nixd
        statix
        deadnix
        alejandra
      ];

      shell = with pkgs; [
        bash-language-server
        shfmt
      ];

      python = with pkgs; [
        pyrefly
        ruff
        basedpyright
        black
      ];

      cxx = with pkgs;
        [
          asm-lsp
          ccls
          clang-tools
          neocmakelsp
          cmake-format
          cmake-lint
          gdb
          lldb
        ]
        ++ lldbTools;

      rust = with pkgs;
        [
          cargo
          rust-analyzer
          rustc
        ]
        ++ lldbTools;

      go = with pkgs;
        [
          go
          gopls
          gotools
          go-tools
        ]
        ++ lldbTools;

      web = with pkgs; [
        bun
        vscode-langservers-extracted
        typescript-language-server
        eslint
        tailwindcss-language-server
        emmet-ls
        mermaid-cli
        wasm-language-tools
      ];

      fun = with pkgs;
        [
          sbcl

          matlab-language-server

          haskell-language-server
          cabal-install
          stack
          ghc

          ocaml
          ocamlPackages.ocaml-lsp
          # dune_3
        ]
        ++ lldbTools;
    };

    # profile definitions

    inherit (pkgs.lib) flatten;

    profiles = let
      minimal = flatten [tools.base tools.lua tools.fennel tools.nix tools.shell];
    in {
      inherit minimal;
      python = flatten [minimal tools.python];
      cxx = flatten [minimal tools.cxx];
      rust = flatten [minimal tools.rust];
      go = flatten [minimal tools.go];
      web = flatten [minimal tools.web];
      fun = flatten [minimal tools.fun];
      full = flatten [minimal tools.python tools.cxx tools.rust tools.go tools.web tools.fun];
    };

    # editor builder
    mkEditor = profile: packages: profileEnv:
      wrapProgram ((pkgs.emacsPackagesFor emacs).emacsWithPackages (
        epkgs:
          with epkgs; [
            # (trivialBuild {
            #   pname = "default";
            #   src = pkgs.writeText "default.el" (builtins.readFile ../default.el);
            #   version = "0.1.0";
            #   packageRequires = packages;
            # })

            magit
            evil

            which-key

            consult

            doom-themes

            vterm
          ]
      )) {
        args = ["--init-directory" ./..];
        envs = {
          PATH = pkgs.lib.makeBinPath packages;
        };
      };

    # editor variants
    editors = let
      lldbEnv = [
        "--set"
        "CODELLDB_PATH"
        "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb"
        "--set"
        "LIBLLDB_PATH"
        "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.so"
      ];
      rustEnv = [
        "--set"
        "RUST_SRC_PATH"
        "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}"
      ];
    in {
      full = mkEditor "full" profiles.full (lldbEnv ++ rustEnv);
      minimal = mkEditor "minimal" profiles.minimal [];

      python = mkEditor "python" profiles.python [];

      rust = mkEditor "rust" profiles.rust (lldbEnv ++ rustEnv);
      cxx = mkEditor "cxx" profiles.cxx lldbEnv;
      go = mkEditor "go" profiles.go lldbEnv;
      web = mkEditor "web" profiles.web lldbEnv;
      fun = mkEditor "fun" profiles.fun lldbEnv;
    };
  in {
    default = editors.full;

    inherit
      (editors)
      minimal
      python
      cxx
      rust
      go
      web
      fun
      ;

    cachix = pkgs.buildEnv {
      name = "cachix";
      paths = [editors.full];
    };
  }
