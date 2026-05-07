# agent instructions

This is a nix codebase for setting up an opinionated claude code setup.
At the moment, this is a local repository which does not have an upstream. In the future, this will most likely be pushed to github as a public repository.

## Build instructions

build the project with `nix build`. The build artifact goes into `./result/bin/claude`, which is a shell script wrapping the `claude` binary.
Reading this file will show the wrapped arguments we pass, such as extra binaries in path, cli flags and such.

The project builds an mcp config into the nix store, the path can be found as an argument inside the shell script under `./result/bin`.

## Nix details

The project is purely flakes based, and does not use impure mode.

flake-parts (https://flake.parts/) is used for scaffolding the flake outputs, and the module system of flake-parts is used as well.

### Nix wrapper modules

link: https://birdeehub.github.io/nix-wrapper-modules/

For constructing the built claude setup, nix-wrapper-modules is used to wrap the claude-code package.
nix-wrapper-modules is often referred to as wlib.

setting the output `wrappers.<package>` in a flake will also expose the wrapped package under `packages.<package>`, due to the nix wrappers flake-parts module being imported.

### Nix guidelines

You have nix tools available, use them when you need to search for information.
You can check the implementation for any nix function from noogle, available via the tool.
