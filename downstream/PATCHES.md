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

| Patch                                                     | Branches         | Status     | Upstream                                                  |
| --------------------------------------------------------- | ---------------- | ---------- | --------------------------------------------------------- |
| downstream fork README and branch strategy                | main, v2026.4.29 | active     | n/a (docs-only, not upstreamed)                           |
| downstream container image build script                   | main, v2026.4.29 | active     | n/a (scripts-only, not upstreamed)                        |
| track-forge versioning convention docs                    | main, v2026.4.29 | active     | n/a (docs-only, not upstreamed)                           |
| downstream overlay Dockerfile (baked plugin runtime deps) | main, v2026.4.29 | active     | n/a (tooling-only, not upstreamed)                        |
| `plugins.bundledMode: "respect-allow"` backport           | v2026.4.29       | upstreamed | [#76085](https://github.com/openclaw/openclaw/pull/76085) |

## Retired patches

| Patch                                                            | Retired date | Reason                                                                                                                                                                                                                                                                                                              |
| ---------------------------------------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `downstream.skipRuntimePluginDiscovery` config + 5 guard commits | 2026-05-02   | Replaced by upstream `plugins.bundledMode: "respect-allow"` ([#76085](https://github.com/openclaw/openclaw/pull/76085), closes [#75575](https://github.com/openclaw/openclaw/issues/75575)). Operator config migrates from `downstream.skipRuntimePluginDiscovery: true` to `plugins.bundledMode: "respect-allow"`. |

## Maintenance checklist

When rebasing onto a new upstream tag:

1. Check this file for `upstreamed` patches — drop them if the new tag includes the upstream PR.
2. Cherry-pick remaining `active` patches onto the new release branch.
3. Update the **Branches** column.
4. If adding a new downstream patch, add it to the Active table with an upstream issue link if one exists.
