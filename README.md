# Kotaroisme Theme Plugin

A refined, typography-focused theme plugin for Obsidian with built-in customization settings.

![Obsidian](https://img.shields.io/badge/Obsidian-v1.0.0+-7C3AED?logo=obsidian&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

## Philosophy

Kotaroisme is designed with intentional typography choices:

- **Readable body text** with generous line height and letter spacing
- **Clear heading hierarchy** with a consistent scale
- **Customizable accent color** throughout the interface
- **Darcula-inspired syntax highlighting** for code blocks
- **Light and dark theme support**

## Screenshots

<!-- TODO: Add screenshots here -->
<!-- ![Light Theme](screenshots/light.png) -->
<!-- ![Dark Theme](screenshots/dark.png) -->
<!-- ![Settings](screenshots/settings.png) -->

## Features

- Standalone plugin with built-in settings UI
- No dependency on Style Settings plugin
- Real-time preview when changing settings
- Mobile-friendly design
- Clean, minimal interface

## Settings

| Setting | Description | Range | Default |
|---------|-------------|-------|---------|
| Base Font Size | Body text size | 14-24px | 18px |
| Line Height | Line height multiplier | 1.4-2.2 | 1.8 |
| Letter Spacing | Character spacing | 0-0.1em | 0.042em |
| Accent Color | Primary theme color | Color picker | #D7494C |

---

## Installation

### Method 1: Community Plugins (Recommended)

1. Open Obsidian Settings
2. Go to **Community Plugins** and disable **Safe Mode**
3. Click **Browse** and search for "Kotaroisme"
4. Click **Install**, then **Enable**

### Method 2: Automatic Install Script

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/USERNAME/kotaroisme-theme/main/install.sh | bash
```

With specific vault path:

```bash
curl -fsSL https://raw.githubusercontent.com/USERNAME/kotaroisme-theme/main/install.sh | bash -s -- "/path/to/your/vault"
```

**Windows (PowerShell):**

```powershell
# Download files
$repo = "USERNAME/kotaroisme-theme"
$release = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest"
$version = $release.tag_name

# Set your vault path
$vaultPath = "$env:USERPROFILE\Documents\Obsidian\YourVault"
$pluginDir = "$vaultPath\.obsidian\plugins\kotaroisme-theme"

# Create directory and download
New-Item -ItemType Directory -Force -Path $pluginDir
Invoke-WebRequest "https://github.com/$repo/releases/download/$version/main.js" -OutFile "$pluginDir\main.js"
Invoke-WebRequest "https://github.com/$repo/releases/download/$version/manifest.json" -OutFile "$pluginDir\manifest.json"

Write-Host "Installed! Restart Obsidian and enable the plugin."
```

### Method 3: Manual Installation

1. Go to the [Releases](https://github.com/USERNAME/kotaroisme-theme/releases) page
2. Download `main.js` and `manifest.json` from the latest release
3. Create folder: `<your-vault>/.obsidian/plugins/kotaroisme-theme/`
4. Copy the downloaded files into that folder
5. Restart Obsidian
6. Go to **Settings → Community Plugins**
7. Enable **Kotaroisme Theme**

### Method 4: BRAT (Beta Reviewers Auto-update Tool)

If you have [BRAT](https://github.com/TfTHacker/obsidian42-brat) installed:

1. Open Command Palette (Ctrl/Cmd + P)
2. Run "BRAT: Add a beta plugin for testing"
3. Enter: `USERNAME/kotaroisme-theme`
4. Enable the plugin in Community Plugins

---

## Configuration

After installation:

1. Go to **Settings → Kotaroisme Theme**
2. Adjust typography settings using the sliders
3. Pick your accent color using the color picker
4. Changes apply in real-time

---

## Building from Source

### Prerequisites

- [Node.js](https://nodejs.org/) v16 or higher
- npm or yarn

### Steps

```bash
# Clone the repository
git clone https://github.com/USERNAME/kotaroisme-theme.git
cd kotaroisme-theme

# Install dependencies
npm install

# Build for production
npm run build

# Or watch for development
npm run dev
```

### Project Structure

```
kotaroisme-theme/
├── main.ts           # Plugin source code
├── main.js           # Compiled output (after build)
├── manifest.json     # Plugin metadata
├── package.json      # Dependencies
├── tsconfig.json     # TypeScript config
├── esbuild.config.mjs # Build config
├── versions.json     # Version compatibility
├── install.sh        # Auto-installer script
└── README.md         # This file
```

---

## Updating

### Automatic (Community Plugins)

Obsidian will notify you when updates are available.

### Manual

Re-run the install script or download new release files.

---

## Uninstalling

1. Go to **Settings → Community Plugins**
2. Find **Kotaroisme Theme** and click **Uninstall**

Or manually delete the folder:
```
<your-vault>/.obsidian/plugins/kotaroisme-theme/
```

---

## Compatibility

- Obsidian v1.0.0 or higher
- Desktop (Windows, macOS, Linux)
- Mobile (iOS, Android)

---

## Troubleshooting

### Plugin not appearing

1. Make sure files are in the correct location: `<vault>/.obsidian/plugins/kotaroisme-theme/`
2. Check that both `main.js` and `manifest.json` exist
3. Restart Obsidian completely
4. Disable Safe Mode in Community Plugins settings

### Settings not saving

1. Check write permissions on the vault folder
2. Try disabling and re-enabling the plugin

### Styles not applying

1. Disable other themes that might conflict
2. Try reloading Obsidian (Ctrl/Cmd + R)

---

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

## Acknowledgments

- [Obsidian](https://obsidian.md/) for the amazing knowledge base app
- Darcula color scheme for syntax highlighting inspiration
- The Obsidian community for feedback and support

---

## Support

- 🐛 [Report a bug](https://github.com/USERNAME/kotaroisme-theme/issues)
- 💡 [Request a feature](https://github.com/USERNAME/kotaroisme-theme/issues)
- ⭐ Star this repo if you find it useful!
