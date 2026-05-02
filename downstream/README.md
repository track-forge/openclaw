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

- **`downstream/v<version>xp<n>`** (e.g. `downstream/v2026.5.2xp0`) — experimental
  branch cut from a green CI commit on upstream `main` when no official tag is
  available yet. Used to pick up significant upstream changes (e.g. removal of
  runtime dep install machinery) before the next release tag ships.

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

## Patch tracking

See [`PATCHES.md`](PATCHES.md) for the full inventory of downstream patches,
their status, and upstream PR links.

## Workflow

1. Develop/fix on `downstream/main`.
2. Cherry-pick relevant commits onto the active `downstream/v*` release branch.
3. When a new upstream tag ships, create a new `downstream/v<tag>` branch from
   that tag and cherry-pick the patch set forward (use `PATCHES.md` as the checklist).
4. Tag and build: `git tag v<upstream>-tf.<n>` then `./downstream/build-image.sh --tag <tag> --push`.
5. Contribute fixes upstream when possible to shrink the patch set over time.
6. When an upstream PR lands, mark its patch as `upstreamed` in `PATCHES.md` and
   drop it on the next rebase.

## Current focus

- `plugins.bundledMode: "respect-allow"` for K8s deployments — gates runtime
  provider discovery by the allowlist instead of force-loading all bundled
  providers. Upstream PR: [#76085](https://github.com/openclaw/openclaw/pull/76085).
- **`v2026.5.2xp0`**: experimental branch based on upstream `main` at
  `336303e48b` (2026-05-02, CI green). Picks up the upstream refactor that
  removed the runtime pnpm-install machinery entirely — no more EROFS on
  `readOnlyRootFilesystem`, no startup network dependency, no lock contention.
  The `OPENCLAW_SKIP_RUNTIME_DEPS_INSTALL` env var from
  [track-forge/openclaw#4](https://github.com/track-forge/openclaw/issues/4)
  is no longer needed on this base.
