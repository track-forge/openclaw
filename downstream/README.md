# track-forge/openclaw downstream

Lightweight fork of [openclaw/openclaw](https://github.com/openclaw/openclaw) for
K8s deployment customizations that upstream doesn't support yet.

## Branch strategy

- **`downstream/main`** — rolling branch based on upstream `main`. All
  downstream patches land here first. Cherry-pick candidates for upstream PRs
  are identified from this branch.

- **`downstream/v<version>`** (e.g. `downstream/v2026.4.29`) — release branch
  pinned to an upstream tag. Carries only the cherry-picked patches from
  `downstream/main` that apply to that release. This is what we build and deploy.

## Versioning

Images and git tags use the format `v<upstream>-tf.<patch>`:

    v2026.4.29-tf.1   — first track-forge patch on upstream v2026.4.29
    v2026.4.29-tf.2   — second patch
    v2026.5.10-tf.1   — first patch on a newer upstream tag

`-tf` stands for track-forge. The patch number increments with each
downstream release on that upstream base. Reset to `.1` when rebasing
onto a new upstream tag.

Tag the release branch when cutting an image:

    git tag v2026.4.29-tf.1
    git push track-forge v2026.4.29-tf.1

## Building images

    git checkout downstream/v2026.4.29
    ./downstream/build-image.sh --tag v2026.4.29-tf.1 --push

See `build-image.sh --help` for options. Defaults to podman and the
local registry at `stimsonmt.tail549b77.ts.net:5000/openclaw`.

## Workflow

1. Develop/fix on `downstream/main`.
2. Cherry-pick relevant commits onto the active `downstream/v*` release branch.
3. When a new upstream tag ships, create a new `downstream/v<tag>` branch from
   that tag and cherry-pick the patch set forward.
4. Tag and build: `git tag v<upstream>-tf.<n>` then `./downstream/build-image.sh --tag <tag> --push`.
5. Contribute fixes upstream when possible to shrink the patch set over time.

## Current focus

- Runtime plugin discovery bypass for proxy-only providers (avoid 28s+ plugin
  load on first message).
- `plugins.enabled: false` respected in runtime provider discovery path.
- Liveness probe resilience for K8s deployments with heavy first-message
  cold-start paths.
