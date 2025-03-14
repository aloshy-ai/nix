# NIX

[![](https://img.shields.io/badge/aloshy.🅰🅸-000000.svg?style=for-the-badge)](https://aloshy.ai)
[![Powered By Nix](https://img.shields.io/badge/NIX-POWERED-5277C3.svg?style=for-the-badge&logo=nixos)](https://nixos.org)
[![Build Status](https://img.shields.io/badge/BUILD-PASSING-success.svg?style=for-the-badge&logo=github)](https://github.com/aloshy-ai/nix/actions)
[![Apple Silicon Ready](https://img.shields.io/badge/APPLE_SILICON-READY-success.svg?style=for-the-badge&logo=apple)](https://github.com/aloshy-ai/nix)
[![License](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Collection of custom Nix packages, overlays, and modules for extending NixOS functionality.

## Getting Started

[![Built with Devbox](https://www.jetify.com/img/devbox/shield_galaxy.svg)](https://www.jetify.com/devbox/docs/contributor-quickstart/)
[![Docker Support](https://img.shields.io/badge/Docker-Enabled-2496ED?logo=docker&logoColor=white)](https://github.com/aloshy-ai/nix)

This project uses [devbox](https://github.com/jetify-com/devbox) to manage its development environment.

Install devbox:
```sh
curl -fsSL https://get.jetpack.io/devbox | bash
```

Start the devbox shell:
```sh 
devbox shell
```

Run a script in the devbox environment:
```sh
devbox run <script>
```
## Scripts
Scripts are custom commands that can be run using this project's environment. This project has the following scripts:

* [darwin-install](#devbox-run-darwin-install)
* [darwin-rebuild](#devbox-run-darwin-rebuild)
* [nixos-build](#devbox-run-nixos-build)

## Environment

```sh
DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
```

## Shell Init Hook
The Shell Init Hook is a script that runs whenever the devbox environment is instantiated. It runs 
on `devbox shell` and on `devbox run`.
```sh

```

## Packages

* [colima@latest](https://www.nixhub.io/packages/colima)
* [docker@latest](https://www.nixhub.io/packages/docker)

## Script Details

### devbox run darwin-install
```sh
curl -fsSL https://darwin.aloshy.ai | sh
```
&ensp;

### devbox run darwin-rebuild
```sh
darwin-rebuild switch --flake ${HOME}/.config/nix-darwin
```
&ensp;

### devbox run nixos-build
```sh
docker build -t ethernix-builder:latest .
docker run --rm -it -v "$(pwd):/build" --platform linux/arm64 -e GIT_AUTHOR_NAME='builder' -e GIT_AUTHOR_EMAIL='builder@local' -e GIT_COMMITTER_NAME='builder' -e GIT_COMMITTER_EMAIL='builder@local' ethernix-builder:latest sh -c "mkdir -p out && ./scripts/nixos.sh && find /nix/store -name 'nixos-image-sd-card-*.img.zst' -exec unzstd -d {} -o out/ethernix.img \; && chown -R $(id -u):$(id -g) out"
echo 'Image built successfully. You can find `ethernix.img` in the `out/` directory.'
```
&ensp;



<!-- gen-readme end -->
