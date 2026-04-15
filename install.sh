#!/bin/bash

# ============================================================================
# Kotaroisme Theme Installer for Obsidian
#
# Usage:
#   ./install.sh [OPTIONS] [vault_path]
#
# Options:
#   --version, -v VERSION    Install specific version (e.g. v1.0.0)
#   --list-versions          List all available release versions
#
# Examples:
#   ./install.sh
#   ./install.sh /path/to/vault
#   ./install.sh /path/to/vault --version v1.0.0
#   ./install.sh --version v1.0.0
#   ./install.sh --list-versions
#
# Or via curl:
#   curl -fsSL https://raw.githubusercontent.com/kotaroisme/kotaroisme-theme/main/install.sh | bash -s -- /path/to/vault
#   curl -fsSL https://raw.githubusercontent.com/kotaroisme/kotaroisme-theme/main/install.sh | bash -s -- /path/to/vault --version v1.0.0
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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
# PARSE ARGUMENTS
# ============================================================================

VAULT_PATH=""
TARGET_VERSION=""
LIST_VERSIONS=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --version|-v)
            TARGET_VERSION="$2"
            shift 2
            ;;
        --list-versions)
            LIST_VERSIONS=true
            shift
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Usage: ./install.sh [OPTIONS] [vault_path]"
            echo "       --version, -v VERSION    Install specific version"
            echo "       --list-versions          List all available versions"
            exit 1
            ;;
        *)
            VAULT_PATH="$1"
            shift
            ;;
    esac
done

# ============================================================================
# LIST VERSIONS (if requested)
# ============================================================================

if [ "$LIST_VERSIONS" = true ]; then
    echo "Fetching available versions..."
    RELEASES=$(curl -fsSL "https://api.github.com/repos/$REPO/releases" 2>/dev/null) || {
        echo -e "${RED}Error: Could not fetch releases from GitHub${NC}"
        exit 1
    }

    VERSIONS=$(echo "$RELEASES" | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)

    if [ -z "$VERSIONS" ]; then
        echo -e "${YELLOW}No releases found.${NC}"
        exit 0
    fi

    echo -e "${GREEN}Available versions:${NC}"
    echo "$VERSIONS" | while read -r v; do
        echo "  $v"
    done
    echo ""
    echo "Install a specific version with:"
    echo "  ./install.sh --version <version>"
    exit 0
fi

# ============================================================================
# STEP 1: Resolve version (latest or specific)
# ============================================================================

if [ -n "$TARGET_VERSION" ]; then
    echo -e "${CYAN}Target version: $TARGET_VERSION${NC}"

    # Verify the specified version exists
    CHECK=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/tags/$TARGET_VERSION" 2>/dev/null) || {
        echo -e "${RED}Error: Could not fetch version $TARGET_VERSION from GitHub${NC}"
        exit 1
    }

    VERSION_CHECK=$(echo "$CHECK" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ -z "$VERSION_CHECK" ]; then
        echo -e "${RED}Error: Version '$TARGET_VERSION' not found.${NC}"
        echo "Run './install.sh --list-versions' to see available versions."
        exit 1
    fi

    VERSION="$TARGET_VERSION"
    echo -e "${GREEN}✓ Version found: $VERSION${NC}"
else
    echo "Fetching latest release..."
    RELEASE_INFO=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null) || {
        echo -e "${RED}Error: Could not fetch release info from GitHub${NC}"
        echo "Make sure the repository has releases: https://github.com/$REPO/releases"
        exit 1
    }

    VERSION=$(echo "$RELEASE_INFO" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -z "$VERSION" ]; then
        echo -e "${RED}Error: Could not determine latest version${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ Latest version: $VERSION${NC}"
fi

# ============================================================================
# STEP 2: Get vault path
# ============================================================================

if [ -z "$VAULT_PATH" ]; then
    echo -e "${YELLOW}No vault path provided.${NC}"
    echo ""

    COMMON_PATHS=(
        "$HOME/Documents/Obsidian"
        "$HOME/Obsidian"
        "$HOME/obsidian"
        "$HOME/Documents/obsidian"
    )

    FOUND_VAULTS=()
    for path in "${COMMON_PATHS[@]}"; do
        if [ -d "$path" ]; then
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
# STEP 3: Prepare plugin directory (auto replace if exists)
# ============================================================================

PLUGIN_DIR="$VAULT_PATH/.obsidian/plugins/$PLUGIN_ID"

if [ -d "$PLUGIN_DIR" ]; then
    INSTALLED_VERSION=""
    if [ -f "$PLUGIN_DIR/manifest.json" ]; then
        INSTALLED_VERSION=$(grep -o '"version": *"[^"]*"' "$PLUGIN_DIR/manifest.json" | head -1 | cut -d'"' -f4)
    fi

    if [ -n "$INSTALLED_VERSION" ]; then
        echo -e "${YELLOW}Replacing existing installation (v$INSTALLED_VERSION → $VERSION)...${NC}"
    else
        echo -e "${YELLOW}Replacing existing installation → $VERSION...${NC}"
    fi

    rm -rf "$PLUGIN_DIR"
fi

mkdir -p "$PLUGIN_DIR"

# ============================================================================
# STEP 4: Download plugin files
# ============================================================================

echo "Downloading plugin files ($VERSION)..."

BASE_URL="https://github.com/$REPO/releases/download/$VERSION"

echo "  → main.js"
curl -fsSL "$BASE_URL/main.js" -o "$PLUGIN_DIR/main.js" || {
    echo -e "${RED}Error: Failed to download main.js${NC}"
    echo "Check that release $VERSION has the expected assets: https://github.com/$REPO/releases/tag/$VERSION"
    exit 1
}

echo "  → manifest.json"
curl -fsSL "$BASE_URL/manifest.json" -o "$PLUGIN_DIR/manifest.json" || {
    echo -e "${RED}Error: Failed to download manifest.json${NC}"
    exit 1
}

echo "  → styles.css (optional)"
curl -fsSL "$BASE_URL/styles.css" -o "$PLUGIN_DIR/styles.css" 2>/dev/null || true

echo -e "${GREEN}✓ Download complete${NC}"

# ============================================================================
# STEP 5: Enable plugin
# ============================================================================

COMMUNITY_PLUGINS_FILE="$VAULT_PATH/.obsidian/community-plugins.json"

if [ -f "$COMMUNITY_PLUGINS_FILE" ]; then
    if grep -q "\"$PLUGIN_ID\"" "$COMMUNITY_PLUGINS_FILE"; then
        echo -e "${GREEN}✓ Plugin already enabled${NC}"
    else
        sed -i.bak 's/\]$/,"'"$PLUGIN_ID"'"]/' "$COMMUNITY_PLUGINS_FILE" 2>/dev/null || {
            echo -e "${YELLOW}Note: Could not auto-enable plugin. Please enable manually in Obsidian.${NC}"
        }
        rm -f "$COMMUNITY_PLUGINS_FILE.bak" 2>/dev/null
        echo -e "${GREEN}✓ Plugin enabled${NC}"
    fi
else
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
echo "Installed to : $PLUGIN_DIR"
echo "Version      : $VERSION"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Restart Obsidian (or reload: Ctrl/Cmd + R)"
echo "  2. Go to Settings → Community Plugins"
echo "  3. Enable 'Kotaroisme Theme' if not already enabled"
echo "  4. Customize in Settings → Kotaroisme Theme"
echo ""
