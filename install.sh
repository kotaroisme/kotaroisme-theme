#!/bin/bash

# ============================================================================
# Kotaroisme Theme Installer for Obsidian
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kotaroisme/kotaroisme-theme/main/install.sh | bash -s -- "/path/to/vault"
#
# Or download and run:
#   chmod +x install.sh
#   ./install.sh "/path/to/vault"
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GitHub repository info
REPO="kotaroisme/kotaroisme-theme"
PLUGIN_ID="kotaroisme-theme"

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════╗"
echo "║     Kotaroisme Theme Installer            ║"
echo "║     A refined, typography-focused theme   ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================================
# STEP 1: Get vault path
# ============================================================================

VAULT_PATH="$1"

# If no argument, try to detect or ask
if [ -z "$VAULT_PATH" ]; then
    echo -e "${YELLOW}No vault path provided.${NC}"
    echo ""

    # Try common locations
    COMMON_PATHS=(
        "$HOME/Documents/Obsidian"
        "$HOME/Obsidian"
        "$HOME/obsidian"
        "$HOME/Documents/obsidian"
    )

    FOUND_VAULTS=()
    for path in "${COMMON_PATHS[@]}"; do
        if [ -d "$path" ]; then
            # Find .obsidian folders
            while IFS= read -r -d '' vault; do
                FOUND_VAULTS+=("$(dirname "$vault")")
            done < <(find "$path" -maxdepth 2 -name ".obsidian" -type d -print0 2>/dev/null)
        fi
    done

    if [ ${#FOUND_VAULTS[@]} -gt 0 ]; then
        echo -e "${GREEN}Found vault(s):${NC}"
        for i in "${!FOUND_VAULTS[@]}"; do
            echo "  [$((i+1))] ${FOUND_VAULTS[$i]}"
        done
        echo ""
        read -p "Select vault number (or enter custom path): " selection

        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#FOUND_VAULTS[@]} ]; then
            VAULT_PATH="${FOUND_VAULTS[$((selection-1))]}"
        else
            VAULT_PATH="$selection"
        fi
    else
        read -p "Enter your Obsidian vault path: " VAULT_PATH
    fi
fi

# Expand ~ to home directory
VAULT_PATH="${VAULT_PATH/#\~/$HOME}"

# Validate vault path
if [ ! -d "$VAULT_PATH" ]; then
    echo -e "${RED}Error: Vault path does not exist: $VAULT_PATH${NC}"
    exit 1
fi

if [ ! -d "$VAULT_PATH/.obsidian" ]; then
    echo -e "${RED}Error: Not a valid Obsidian vault (no .obsidian folder): $VAULT_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Vault found: $VAULT_PATH${NC}"

# ============================================================================
# STEP 2: Create plugin directory
# ============================================================================

PLUGIN_DIR="$VAULT_PATH/.obsidian/plugins/$PLUGIN_ID"

if [ -d "$PLUGIN_DIR" ]; then
    echo -e "${YELLOW}Plugin already installed. Updating...${NC}"
else
    echo "Creating plugin directory..."
    mkdir -p "$PLUGIN_DIR"
fi

# ============================================================================
# STEP 3: Fetch latest release info from GitHub
# ============================================================================

echo "Fetching latest release..."

RELEASE_API="https://api.github.com/repos/$REPO/releases/latest"

# Get release info
RELEASE_INFO=$(curl -fsSL "$RELEASE_API" 2>/dev/null) || {
    echo -e "${RED}Error: Could not fetch release info from GitHub${NC}"
    echo "Make sure the repository exists and has releases: https://github.com/$REPO/releases"
    exit 1
}

# Parse version
VERSION=$(echo "$RELEASE_INFO" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$VERSION" ]; then
    echo -e "${RED}Error: Could not determine latest version${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Latest version: $VERSION${NC}"

# ============================================================================
# STEP 4: Download plugin files
# ============================================================================

echo "Downloading plugin files..."

BASE_URL="https://github.com/$REPO/releases/download/$VERSION"

# Download main.js
echo "  → main.js"
curl -fsSL "$BASE_URL/main.js" -o "$PLUGIN_DIR/main.js" || {
    echo -e "${RED}Error: Failed to download main.js${NC}"
    exit 1
}

# Download manifest.json
echo "  → manifest.json"
curl -fsSL "$BASE_URL/manifest.json" -o "$PLUGIN_DIR/manifest.json" || {
    echo -e "${RED}Error: Failed to download manifest.json${NC}"
    exit 1
}

# Download styles.css if exists (optional)
echo "  → styles.css (optional)"
curl -fsSL "$BASE_URL/styles.css" -o "$PLUGIN_DIR/styles.css" 2>/dev/null || true

echo -e "${GREEN}✓ Download complete${NC}"

# ============================================================================
# STEP 5: Enable plugin (optional)
# ============================================================================

COMMUNITY_PLUGINS_FILE="$VAULT_PATH/.obsidian/community-plugins.json"

if [ -f "$COMMUNITY_PLUGINS_FILE" ]; then
    # Check if plugin already in list
    if grep -q "\"$PLUGIN_ID\"" "$COMMUNITY_PLUGINS_FILE"; then
        echo -e "${GREEN}✓ Plugin already enabled${NC}"
    else
        # Add plugin to enabled list
        # This is a simple append - works for most cases
        sed -i.bak 's/\]$/,"'"$PLUGIN_ID"'"]/' "$COMMUNITY_PLUGINS_FILE" 2>/dev/null || {
            echo -e "${YELLOW}Note: Could not auto-enable plugin. Please enable manually in Obsidian.${NC}"
        }
        rm -f "$COMMUNITY_PLUGINS_FILE.bak" 2>/dev/null
        echo -e "${GREEN}✓ Plugin enabled${NC}"
    fi
else
    # Create community-plugins.json
    echo "[\"$PLUGIN_ID\"]" > "$COMMUNITY_PLUGINS_FILE"
    echo -e "${GREEN}✓ Plugin enabled${NC}"
fi

# ============================================================================
# DONE
# ============================================================================

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Installation Complete!                ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
echo ""
echo "Installed to: $PLUGIN_DIR"
echo "Version: $VERSION"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Restart Obsidian (or reload without restart: Ctrl/Cmd + R)"
echo "  2. Go to Settings → Community Plugins"
echo "  3. Enable 'Kotaroisme Theme' if not already enabled"
echo "  4. Customize in Settings → Kotaroisme Theme"
echo ""
