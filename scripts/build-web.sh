#!/usr/bin/env sh
set -eux

# ------------------------------------------------------
# Build Flutter Web in Release Mode with Source Maps
# and upload to Sentry (if configured)
# ------------------------------------------------------
# Expected environment variables:
#   FOLDER             -> Folder name for PR deployment
#   GITHUB_REPOSITORY  -> GitHub repo (provided by CI)
#   SENTRY_AUTH_TOKEN  -> Secret token to upload sourcemaps (optional)
#   SENTRY_ORG         -> Sentry organization name (optional)
#   SENTRY_PROJECT     -> Sentry project name (optional)
# ------------------------------------------------------

echo "=== 🧱 Building Flutter Web (Release + Source Maps) ==="

BASE_HREF="/${GITHUB_REPOSITORY##*/}/${FOLDER}/"
BUILD_DIR="build/web"

# Step 1️⃣: Clean before build (optional, helps cache correctness)
flutter clean

# Step 2️⃣: Build Flutter Web with source maps enabled
flutter build web \
  --release \
  --source-maps \
  --base-href "$BASE_HREF"

echo "✅ Flutter web build completed."
echo "📂 Output directory: $BUILD_DIR"

# Step 3️⃣: Improve JS source maps (fix mapping for Sentry)
if command -v sentry-cli >/dev/null 2>&1; then
  echo "🧩 Injecting Sentry debug identifiers into JS files..."
  sentry-cli sourcemaps inject "$BUILD_DIR"
  echo "✅ Injected Sentry debug identifiers successfully."
else
  echo "⚠️ sentry-cli not found, skipping injection step."
fi

# Step 4️⃣: Upload source maps to Sentry (only if env vars available)
if [ -n "${SENTRY_AUTH_TOKEN:-}" ] && [ -n "${SENTRY_ORG:-}" ] && [ -n "${SENTRY_PROJECT:-}" ]; then
  echo "📤 Uploading source maps to Sentry..."
  SENTRY_RELEASE="local-${GITHUB_REPOSITORY##*/}-${FOLDER}-$(git rev-parse --short HEAD)"

  # Create release
  sentry-cli releases new "$SENTRY_RELEASE"

  # Upload sourcemaps (Flutter Web layout)
  sentry-cli releases files "$SENTRY_RELEASE" upload-sourcemaps "$BUILD_DIR" \
    --rewrite --ignore-missing --url-prefix "~/"

  # Associate commits & finalize
  sentry-cli releases set-commits "$SENTRY_RELEASE" --auto --ignore-missing
  sentry-cli releases finalize "$SENTRY_RELEASE" --ignore-missing

  echo "✅ Source maps uploaded successfully to Sentry."
  echo "🔹 Sentry release: $SENTRY_RELEASE"
else
  echo "⚠️ Skipping Sentry upload (missing SENTRY_AUTH_TOKEN, ORG, or PROJECT)."
fi

echo "🎉 Build script finished successfully."
