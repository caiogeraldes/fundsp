{
  description = "A Nix-flake-based C/C++ development environment";

  inputs.nixpkgs.url =
    "https://flakehub.com/f/NixOS/nixpkgs/0"; # stable Nixpkgs

  outputs = { self, ... }@inputs:

    let
      supportedSystems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f:
        inputs.nixpkgs.lib.genAttrs supportedSystems
        (system: f { pkgs = import inputs.nixpkgs { inherit system; }; });
    in {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = with pkgs;
          mkShell rec {
            buildInputs = [
              pkg-config
              wayland
              fontconfig
              alsa-lib
              libxkbcommon
              # OpenGL
              libGLU
              libGL
              glew
            ];

            shellHook = ''
              export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${
                builtins.toString (pkgs.lib.makeLibraryPath buildInputs)
              }";
            '';
          };

        PKG_CONFIG_PATH = "${pkgs.alsa-lib}/lib/pkgconfig";

      });
    };
}
