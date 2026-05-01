#!/usr/bin/env bash
# downstream/build-image.sh — Build an OpenClaw container image from a
# downstream branch and push it to a local/private registry.
#
# Uses the upstream multi-stage Dockerfile unchanged. Podman-native.
#
# Usage:
#   ./downstream/build-image.sh                          # defaults
#   ./downstream/build-image.sh --tag v2026.4.29-tf.1    # custom tag
#   ./downstream/build-image.sh --push                   # build + push
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

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)    IMAGE_TAG="$2"; shift 2 ;;
    --push)   PUSH=1; shift ;;
    --repo)   IMAGE_REPO="$2"; shift 2 ;;
    --builder) BUILDER="$2"; shift 2 ;;
    --extensions) EXTENSIONS="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--tag TAG] [--repo REPO] [--push] [--builder podman|docker] [--extensions 'ext1 ext2']"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

FULL_IMAGE="${IMAGE_REPO}:${IMAGE_TAG}"

echo "==> Building OpenClaw downstream image"
echo "    branch:     ${BRANCH}"
echo "    commit:     ${SHORT_SHA}"
echo "    image:      ${FULL_IMAGE}"
echo "    builder:    ${BUILDER}"
if [ -n "$EXTENSIONS" ]; then
  echo "    extensions: ${EXTENSIONS}"
fi
echo ""

BUILD_ARGS=(
  --file "${REPO_ROOT}/Dockerfile"
  --tag "${FULL_IMAGE}"
  --build-arg "OPENCLAW_EXTENSIONS=${EXTENSIONS}"
  --label "org.opencontainers.image.source=https://github.com/track-forge/openclaw"
  --label "org.opencontainers.image.revision=${SHORT_SHA}"
  --label "dev.trackforge.branch=${BRANCH}"
)

"$BUILDER" build "${BUILD_ARGS[@]}" "$REPO_ROOT"

echo ""
echo "==> Built: ${FULL_IMAGE}"

if [ "$PUSH" -eq 1 ]; then
  echo "==> Pushing ${FULL_IMAGE}"
  "$BUILDER" push "${FULL_IMAGE}"
  echo "==> Pushed: ${FULL_IMAGE}"
fi
