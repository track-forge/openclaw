# Downstream Patch Inventory

Patches carried by track-forge/openclaw on top of upstream openclaw/openclaw.
Updated each time the patch set changes.

## Format

| Patch | Branches | Status | Upstream |
| ----- | -------- | ------ | -------- |

- **Branches**: which downstream branches carry this patch (`main`, `v2026.4.29`, etc.)
- **Status**: `active` (still needed), `upstreamed` (merged upstream, drop on next rebase), `obsolete` (replaced)
- **Upstream**: link to the upstream PR or issue, if any

## Active patches

| Patch                                      | Branches                                  | Status | Upstream                           |
| ------------------------------------------ | ----------------------------------------- | ------ | ---------------------------------- |
| downstream fork README and branch strategy | main, v2026.4.29, v2026.5.2xp0, v2026.5.6 | active | n/a (docs-only, not upstreamed)    |
| downstream container image build script    | main, v2026.4.29, v2026.5.2xp0, v2026.5.6 | active | n/a (scripts-only, not upstreamed) |
| track-forge versioning convention docs     | main, v2026.4.29, v2026.5.2xp0, v2026.5.6 | active | n/a (docs-only, not upstreamed)    |
| downstream overlay Dockerfile              | main, v2026.4.29, v2026.5.2xp0, v2026.5.6 | active | n/a (tooling-only, not upstreamed) |

## Retired patches

| Patch                                                            | Retired date | Reason                                                                                                                                                                                                                                                                                                                  |
| ---------------------------------------------------------------- | ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `downstream.skipRuntimePluginDiscovery` config + 5 guard commits | 2026-05-02   | Replaced by upstream `plugins.bundledMode: "respect-allow"` ([#76085](https://github.com/openclaw/openclaw/pull/76085), closes [#75575](https://github.com/openclaw/openclaw/issues/75575)). Operator config migrates from `downstream.skipRuntimePluginDiscovery: true` to `plugins.bundledMode: "respect-allow"`.     |
| `plugins.bundledMode: "respect-allow"` backport                  | 2026-05-07   | Superseded by upstream [#77194](https://github.com/openclaw/openclaw/pull/77194) which landed the fix as `plugins.bundledDiscovery: "allowlist"` (default for new installs). Included in `v2026.5.5+`. Operator config migrates from `plugins.bundledMode: "respect-allow"` to `plugins.bundledDiscovery: "allowlist"`. |
| `OPENCLAW_SKIP_RUNTIME_DEPS_INSTALL` env var                     | 2026-05-07   | Never implemented. Upstream refactor [ed8f50f240](https://github.com/openclaw/openclaw/commit/ed8f50f240) removed the runtime pnpm-install machinery entirely. No longer needed on `v2026.5.2+`. See [track-forge/openclaw#4](https://github.com/track-forge/openclaw/issues/4).                                        |

## Maintenance checklist

When rebasing onto a new upstream tag:

1. Check this file for `upstreamed` patches — drop them if the new tag includes the upstream PR.
2. Cherry-pick remaining `active` patches onto the new release branch.
3. Update the **Branches** column.
4. If adding a new downstream patch, add it to the Active table with an upstream issue link if one exists.
