#!/usr/bin/env bash
# downstream/build-image.sh — Build an OpenClaw container image from a
# downstream branch and push it to a local/private registry.
#
# By default builds a single-stage image from the upstream Dockerfile.
# Pass --overlay to add a second stage via downstream/Dockerfile.downstream
# for any downstream-specific image customizations.
#
# Usage:
#   ./downstream/build-image.sh                          # upstream image only
#   ./downstream/build-image.sh --tag v2026.5.2xp0-tf.1  # custom tag
#   ./downstream/build-image.sh --push                   # build + push
#   ./downstream/build-image.sh --overlay                # add downstream overlay
#   IMAGE_REPO=my.registry/openclaw ./downstream/build-image.sh
#
# Environment:
#   IMAGE_REPO   — registry/repo (default: stimsonmt.tail549b77.ts.net:5000/openclaw)
#   IMAGE_TAG    — image tag (default: downstream-<short-sha>)
#   BUILDER      — container builder command (default: podman)
#   EXTENSIONS   — space-separated openclaw extensions to include (default: none)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

BUILDER="${BUILDER:-podman}"
IMAGE_REPO="${IMAGE_REPO:-stimsonmt.tail549b77.ts.net:5000/openclaw}"
SHORT_SHA="$(git -C "$REPO_ROOT" rev-parse --short=10 HEAD)"
BRANCH="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
IMAGE_TAG="${IMAGE_TAG:-downstream-${SHORT_SHA}}"
EXTENSIONS="${EXTENSIONS:-}"
PUSH=0
OVERLAY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)    IMAGE_TAG="$2"; shift 2 ;;
    --push)   PUSH=1; shift ;;
    --repo)   IMAGE_REPO="$2"; shift 2 ;;
    --builder) BUILDER="$2"; shift 2 ;;
    --extensions) EXTENSIONS="$2"; shift 2 ;;
    --overlay) OVERLAY=1; shift ;;
    -h|--help)
      echo "Usage: $0 [--tag TAG] [--repo REPO] [--push] [--builder podman|docker] [--extensions 'ext1 ext2'] [--overlay]"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

FULL_IMAGE="${IMAGE_REPO}:${IMAGE_TAG}"
BASE_IMAGE="${IMAGE_REPO}:${IMAGE_TAG}-base"

echo "==> Building OpenClaw downstream image"
echo "    branch:     ${BRANCH}"
echo "    commit:     ${SHORT_SHA}"
echo "    image:      ${FULL_IMAGE}"
echo "    builder:    ${BUILDER}"
if [ -n "$EXTENSIONS" ]; then
  echo "    extensions: ${EXTENSIONS}"
fi
if [ "$OVERLAY" -eq 1 ]; then
  echo "    overlay:    enabled (downstream Dockerfile)"
else
  echo "    overlay:    off (default)"
fi
echo ""

# ── Stage 1: Base image (upstream Dockerfile) ──────────────────
if [ "$OVERLAY" -eq 1 ]; then
  STAGE1_TAG="$BASE_IMAGE"
else
  STAGE1_TAG="$FULL_IMAGE"
fi

BUILD_ARGS=(
  --file "${REPO_ROOT}/Dockerfile"
  --tag "${STAGE1_TAG}"
  --build-arg "OPENCLAW_EXTENSIONS=${EXTENSIONS}"
  --label "org.opencontainers.image.source=https://github.com/track-forge/openclaw"
  --label "org.opencontainers.image.revision=${SHORT_SHA}"
  --label "dev.trackforge.branch=${BRANCH}"
)

echo "==> Stage 1: Building base image → ${STAGE1_TAG}"
"$BUILDER" build "${BUILD_ARGS[@]}" "$REPO_ROOT"

# ── Stage 2: Overlay (opt-in downstream customizations) ──────
if [ "$OVERLAY" -eq 1 ]; then
  echo ""
  echo "==> Stage 2: Building overlay (plugin runtime deps) → ${FULL_IMAGE}"
  "$BUILDER" build \
    --file "${SCRIPT_DIR}/Dockerfile.downstream" \
    --tag "${FULL_IMAGE}" \
    --build-arg "BASE_IMAGE=${STAGE1_TAG}" \
    --label "org.opencontainers.image.source=https://github.com/track-forge/openclaw" \
    --label "org.opencontainers.image.revision=${SHORT_SHA}" \
    --label "dev.trackforge.branch=${BRANCH}" \
    --label "dev.trackforge.overlay=plugin-runtime-deps" \
    "$REPO_ROOT"
fi

echo ""
echo "==> Built: ${FULL_IMAGE}"
if [ "$OVERLAY" -eq 1 ]; then
  echo "    base:  ${BASE_IMAGE}"
fi

if [ "$PUSH" -eq 1 ]; then
  echo "==> Pushing ${FULL_IMAGE}"
  "$BUILDER" push "${FULL_IMAGE}"
  echo "==> Pushed: ${FULL_IMAGE}"
fi
