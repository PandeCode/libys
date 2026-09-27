inputs:

let
  inherit (inputs)
    nixbuilds
    nixpkgs
    nixutils
    self
    ;

  # gdb and lldb in the toolsets only build on linux
  forAllPkgs =
    fn:
    nixutils.lib.forSystems [ "x86_64-linux" "aarch64-linux" ] (
      system:
      fn (
        import nixpkgs {
          inherit system;
          overlays = [ nixbuilds.overlays.default ];
        }
      )
    );

  profiles = [
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
in

{
  packages = forAllPkgs (
    pkgs:
    let
      editor = import ../nix/editor.nix {
        inherit pkgs;
        inherit (nixutils.lib) wrapProgram;
        src = self;
      };
    in
    nixpkgs.lib.attrsets.genAttrs profiles (profile: editor.override { inherit profile; })
    // {
      default = editor;
    }
  );

  nixosModules.default = import ../nix/module.nix {
    inherit self;
    class = "nixos";
  };

  homeModules.default = import ../nix/module.nix {
    inherit self;
    class = "homeManager";
  };

  checks = forAllPkgs (pkgs: import ./checks.nix { inherit pkgs self; });

  formatter = forAllPkgs (pkgs: pkgs.treefmt.withConfig nixutils.lib.treefmtModule);

  devShells = forAllPkgs (pkgs: {
    default = pkgs.mkShellNoCC {
      packages = [
        self.formatter.${pkgs.stdenv.hostPlatform.system}
        self.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  });
}
