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

## Workflow

1. Develop/fix on `downstream/main`.
2. Cherry-pick relevant commits onto the active `downstream/v*` release branch.
3. When a new upstream tag ships, create a new `downstream/v<tag>` branch from
   that tag and cherry-pick the patch set forward.
4. Contribute fixes upstream when possible to shrink the patch set over time.

## Current focus

- Runtime plugin discovery bypass for proxy-only providers (avoid 28s+ plugin
  load on first message).
- `plugins.enabled: false` respected in runtime provider discovery path.
- Liveness probe resilience for K8s deployments with heavy first-message
  cold-start paths.
