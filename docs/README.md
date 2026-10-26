# nixos-config

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/karafra/nixos-config)

Collection of NixOs configurations for my personal use. This repository is a flake, so you can use it as a flake input
in your own flake.

> [!NOTE]
> To install this configuration on fresh system, you can use the following command:
> ```bash
> curl -fsSL https://karafra.github.io/nixos-config/install.sh | bash
> ```
> Optional environment variables:
> - `FLAKE_VERSION` - pin a FlakeHub version instead of the latest (e.g. `FLAKE_VERSION=0.2.1`).
> - `AGE_KEY_FILE` - path to an existing age key to install for sops.
