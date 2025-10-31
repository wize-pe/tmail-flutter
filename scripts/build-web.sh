#!/usr/bin/env sh
set -eux

# ------------------------------------------------------
# Build Flutter Web in Release Mode with Source Maps
# and (optional) upload to Sentry
# ------------------------------------------------------
# Expected environment variables:
#   FOLDER             -> Folder name for PR deployment
#   GITHUB_REPOSITORY  -> GitHub repo (provided by CI)
#   SENTRY_AUTH_TOKEN  -> Secret token to upload sourcemaps (optional)
#   SENTRY_ORG         -> Sentry organization name (optional)
#   SENTRY_PROJECT     -> Sentry project name (optional)
# ------------------------------------------------------

echo "=== Building Flutter Web (Release + Source Maps) ==="
BASE_HREF="/${GITHUB_REPOSITORY##*/}/${FOLDER}/"

# Step 1️⃣: Build web with source maps enabled
flutter build web \
  --release \
  --source-maps \
  --base-href "$BASE_HREF"

echo "✅ Flutter web build completed."

# Step 2️⃣: Upload source maps to Sentry if credentials are available
if [ -n "${SENTRY_AUTH_TOKEN:-}" ] && [ -n "${SENTRY_ORG:-}" ] && [ -n "${SENTRY_PROJECT:-}" ]; then
  echo "📤 Uploading source maps to Sentry..."
  flutter pub run sentry_dart_plugin
  echo "✅ Source maps uploaded successfully."
else
  echo "⚠️ Skipping Sentry upload (missing SENTRY_AUTH_TOKEN, ORG, or PROJECT)."
fi

echo "✅ Build script finished."
