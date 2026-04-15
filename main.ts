import { App, Plugin, PluginSettingTab, Setting } from "obsidian";
import THEME_CSS from "./styles.css";

// ============================================================================
// SETTINGS INTERFACE
// ============================================================================

interface KotaroismeSettings {
	fontSize: number;
	lineHeight: number;
	letterSpacing: number;
	accentColor: string;
}

const DEFAULT_SETTINGS: KotaroismeSettings = {
	fontSize: 18,
	lineHeight: 1.8,
	letterSpacing: 0.042,
	accentColor: "#D7494C",
};

// ============================================================================
// MAIN PLUGIN CLASS
// ============================================================================

export default class KotaroismePlugin extends Plugin {
	settings: KotaroismeSettings;
	styleEl: HTMLStyleElement;

	async onload() {
		await this.loadSettings();

		// Inject theme CSS
		this.injectThemeStyles();

		// Apply user settings as CSS variables
		this.applySettings();

		// Add settings tab
		this.addSettingTab(new KotaroismeSettingTab(this.app, this));

		console.log("Kotaroisme Theme loaded");
	}

	onunload() {
		// Remove injected styles
		if (this.styleEl) {
			this.styleEl.remove();
		}
		// Remove CSS variables
		document.body.style.removeProperty("--font-text-size");
		document.body.style.removeProperty("--line-height-normal");
		document.body.style.removeProperty("--letter-spacing-body");
		document.body.style.removeProperty("--color-accent");
		document.body.style.removeProperty("--accent-h");
		document.body.style.removeProperty("--accent-s");
		document.body.style.removeProperty("--accent-l");

		console.log("Kotaroisme Theme unloaded");
	}

	async loadSettings() {
		this.settings = Object.assign({}, DEFAULT_SETTINGS, await this.loadData());
	}

	async saveSettings() {
		await this.saveData(this.settings);
		this.applySettings();
	}

	applySettings() {
		// Apply settings as CSS custom properties on body
		document.body.style.setProperty(
			"--font-text-size",
			`${this.settings.fontSize}px`
		);
		document.body.style.setProperty(
			"--line-height-normal",
			`${this.settings.lineHeight}`
		);
		document.body.style.setProperty(
			"--letter-spacing-body",
			`${this.settings.letterSpacing}em`
		);
		document.body.style.setProperty(
			"--color-accent",
			this.settings.accentColor
		);
		
		// Calculate and set HSL values for accent color
		const hsl = this.hexToHSL(this.settings.accentColor);
		document.body.style.setProperty("--accent-h", `${hsl.h}`);
		document.body.style.setProperty("--accent-s", `${hsl.s}%`);
		document.body.style.setProperty("--accent-l", `${hsl.l}%`);
	}

	hexToHSL(hex: string): { h: number; s: number; l: number } {
		// Remove # if present
		hex = hex.replace(/^#/, "");
		
		// Parse hex values
		const r = parseInt(hex.substring(0, 2), 16) / 255;
		const g = parseInt(hex.substring(2, 4), 16) / 255;
		const b = parseInt(hex.substring(4, 6), 16) / 255;

		const max = Math.max(r, g, b);
		const min = Math.min(r, g, b);
		let h = 0;
		let s = 0;
		const l = (max + min) / 2;

		if (max !== min) {
			const d = max - min;
			s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
			
			switch (max) {
				case r:
					h = ((g - b) / d + (g < b ? 6 : 0)) / 6;
					break;
				case g:
					h = ((b - r) / d + 2) / 6;
					break;
				case b:
					h = ((r - g) / d + 4) / 6;
					break;
			}
		}

		return {
			h: Math.round(h * 360),
			s: Math.round(s * 100),
			l: Math.round(l * 100),
		};
	}

	injectThemeStyles() {
		// Create style element for theme CSS
		this.styleEl = document.createElement("style");
		this.styleEl.id = "kotaroisme-theme-styles";
		this.styleEl.textContent = THEME_CSS;
		document.head.appendChild(this.styleEl);
	}
}

// ============================================================================
// SETTINGS TAB
// ============================================================================

class KotaroismeSettingTab extends PluginSettingTab {
	plugin: KotaroismePlugin;

	constructor(app: App, plugin: KotaroismePlugin) {
		super(app, plugin);
		this.plugin = plugin;
	}

	display(): void {
		const { containerEl } = this;

		containerEl.empty();

		// Header
		containerEl.createEl("h1", { text: "Kotaroisme Theme" });
		containerEl.createEl("p", {
			text: "A refined, typography-focused theme. Earnest, reflective, purpose-driven.",
			cls: "setting-item-description",
		});

		containerEl.createEl("h2", { text: "Typography Settings" });

		// Font Size Setting
		new Setting(containerEl)
			.setName("Base Font Size")
			.setDesc("The base font size for body text (in pixels)")
			.addSlider((slider) =>
				slider
					.setLimits(14, 24, 1)
					.setValue(this.plugin.settings.fontSize)
					.setDynamicTooltip()
					.onChange(async (value) => {
						this.plugin.settings.fontSize = value;
						await this.plugin.saveSettings();
					})
			)
			.addExtraButton((button) =>
				button
					.setIcon("reset")
					.setTooltip("Reset to default (18px)")
					.onClick(async () => {
						this.plugin.settings.fontSize = DEFAULT_SETTINGS.fontSize;
						await this.plugin.saveSettings();
						this.display(); // Refresh UI
					})
			);

		// Line Height Setting
		new Setting(containerEl)
			.setName("Line Height")
			.setDesc("The line height multiplier for comfortable reading")
			.addSlider((slider) =>
				slider
					.setLimits(1.4, 2.2, 0.1)
					.setValue(this.plugin.settings.lineHeight)
					.setDynamicTooltip()
					.onChange(async (value) => {
						this.plugin.settings.lineHeight = value;
						await this.plugin.saveSettings();
					})
			)
			.addExtraButton((button) =>
				button
					.setIcon("reset")
					.setTooltip("Reset to default (1.8)")
					.onClick(async () => {
						this.plugin.settings.lineHeight = DEFAULT_SETTINGS.lineHeight;
						await this.plugin.saveSettings();
						this.display();
					})
			);

		// Letter Spacing Setting
		new Setting(containerEl)
			.setName("Letter Spacing")
			.setDesc("The spacing between characters (in em units)")
			.addSlider((slider) =>
				slider
					.setLimits(0, 0.1, 0.002)
					.setValue(this.plugin.settings.letterSpacing)
					.setDynamicTooltip()
					.onChange(async (value) => {
						this.plugin.settings.letterSpacing = value;
						await this.plugin.saveSettings();
					})
			)
			.addExtraButton((button) =>
				button
					.setIcon("reset")
					.setTooltip("Reset to default (0.042em)")
					.onClick(async () => {
						this.plugin.settings.letterSpacing = DEFAULT_SETTINGS.letterSpacing;
						await this.plugin.saveSettings();
						this.display();
					})
			);

		// Appearance Section
		containerEl.createEl("h2", { text: "Appearance" });

		// Accent Color Setting
		new Setting(containerEl)
			.setName("Accent Color")
			.setDesc("The primary accent color used throughout the theme")
			.addColorPicker((picker) =>
				picker
					.setValue(this.plugin.settings.accentColor)
					.onChange(async (value) => {
						this.plugin.settings.accentColor = value;
						await this.plugin.saveSettings();
					})
			)
			.addExtraButton((button) =>
				button
					.setIcon("reset")
					.setTooltip("Reset to default (#D7494C)")
					.onClick(async () => {
						this.plugin.settings.accentColor = DEFAULT_SETTINGS.accentColor;
						await this.plugin.saveSettings();
						this.display();
					})
			);

		// Reset All Button
		containerEl.createEl("h2", { text: "Actions" });

		new Setting(containerEl)
			.setName("Reset All Settings")
			.setDesc("Restore all typography settings to their default values")
			.addButton((button) =>
				button
					.setButtonText("Reset All")
					.setWarning()
					.onClick(async () => {
						this.plugin.settings = Object.assign({}, DEFAULT_SETTINGS);
						await this.plugin.saveSettings();
						this.display();
					})
			);

		// Info Section
		containerEl.createEl("h2", { text: "About" });
		containerEl.createEl("p", {
			text: "Kotaroisme is designed with intentional typography choices: readable body text, clear heading hierarchy, and a signature accent color (#D7494C).",
			cls: "setting-item-description",
		});
	}
}

