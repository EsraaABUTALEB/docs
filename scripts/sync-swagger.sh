#!/bin/bash
# sync-swagger.sh
# Fetches live OpenAPI specs from dev environments and saves them to /openapi/
# Run manually:  bash scripts/sync-swagger.sh
# Or automatically via .github/workflows/sync.yml

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENAPI_DIR="$SCRIPT_DIR/../openapi"

# ─────────────────────────────────────────────────────────────
# Add your service names and their Swagger JSON URLs below.
# Format: ["service-filename"]="https://swagger-url"
# ─────────────────────────────────────────────────────────────
declare -A SERVICES=(
  ["checkout-service"]="https://checkout-service.dev.yourcompany.com/v3/api-docs"
  ["payments-service"]="https://payments-service.dev.yourcompany.com/v3/api-docs"
)

echo "Syncing OpenAPI specs from dev environments..."

for SERVICE in "${!SERVICES[@]}"; do
  URL="${SERVICES[$SERVICE]}"
  OUTPUT="$OPENAPI_DIR/$SERVICE.json"

  echo "  → Fetching $SERVICE from $URL ..."

  HTTP_STATUS=$(curl -sf -o "$OUTPUT" -w "%{http_code}" "$URL" || echo "000")

  if [ "$HTTP_STATUS" != "200" ]; then
    echo "  ✗ ERROR: Could not fetch $SERVICE (HTTP $HTTP_STATUS). Keeping existing file."
    exit 1
  fi

  echo "  ✓ $SERVICE saved to openapi/$SERVICE.json"
done

echo ""
echo "All specs synced successfully."
