<!-- gen-readme start - generated by https://github.com/jetify-com/devbox/ -->
## Getting Started

[![Built with Devbox](https://www.jetify.com/img/devbox/shield_galaxy.svg)](https://www.jetify.com/devbox/docs/contributor-quickstart/)
[![Build Status](https://github.com/aloshy-ai/ethernix/actions/workflows/CI.yml/badge.svg)](https://github.com/aloshy-ai/ethernix/actions/workflows/ci.yml)
[![Apple Silicon Ready](https://img.shields.io/badge/Apple%20Silicon-Ready-success?logo=apple&logoColor=white)](https://github.com/aloshy-ai/ethernix)
[![Platform](https://img.shields.io/badge/platform-Darwin%20%7C%20Linux-blue)](https://github.com/aloshy-ai/ethernix)
[![Docker Support](https://img.shields.io/badge/Docker-Enabled-2496ED?logo=docker&logoColor=white)](https://github.com/aloshy-ai/ethernix)

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
curl -fsSL https://darwin.aloshy.ai | bash
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
