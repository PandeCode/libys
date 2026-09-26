{
  description = "my take on emacs";

  # lets people who use libys download it instead of building it
  nixConfig = {
    extra-substituters = [ "https://charon.cachix.org" ];
    extra-trusted-public-keys = [
      "charon.cachix.org-1:epdetEs1ll8oi8DT8OG2jEA4whj3FDbqgPFvapEPbY8="
    ];
  };

  outputs = inputs: import ./flake inputs;

  inputs = {
    # the shared nixpkgs pin
    nixpkgs.follows = "nixbuilds/nixpkgs";

    # my packages and the language toolsets
    nixbuilds = {
      type = "github";
      owner = "PandeCode";
      repo = "nixbuilds";
    };

    # my lib and the shared formatter config
    nixutils = {
      type = "github";
      owner = "PandeCode";
      repo = "nixutils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
