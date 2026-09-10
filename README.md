[![Donate](https://img.shields.io/badge/-%E2%99%A5%20Donate-%23ff69b4)](https://hmlendea.go.ro/funding)
[![Latest Release](https://img.shields.io/github/v/release/hmlendea/stellaris-ui-name-lists)](https://github.com/hmlendea/stellaris-ui-name-lists/releases/latest)
[![Build Status](https://github.com/hmlendea/stellaris-ui-name-lists/actions/workflows/build.yml/badge.svg)](https://github.com/hmlendea/stellaris-ui-name-lists/actions/workflows/build.yml)
[![License](https://img.shields.io/github/license/hmlendea/stellaris-ui-name-lists)](https://github.com/hmlendea/stellaris-ui-name-lists/blob/master/LICENSE)

# Universum Infinitum: Name Lists

A Stellaris modification that provides numerous detailed name lists, including the extensive Human - Extended variant with names inspired by historical and fictional sources.

## 📑 Table of Contents

- [Capabilities](#capabilities)
- [Use Cases](#use-cases)
- [Usage](#usage)
- [Installation](#installation)
  - [Manual Installation](#manual-installation)
- [Compatibility](#compatibility)
- [Development](#development)
  - [Requirements](#requirements)
  - [Setup](#setup)
  - [Build](#build)
  - [Test](#test)
  - [Continuous Integration](#continuous-integration)
- [Project Structure](#project-structure)
  - [Directories](#directories)
- [Contributing](#contributing)
- [Related Projects](#related-projects)
- [Project Engagement](#project-engagement)
- [License](#license)

## ✨ Capabilities

- Adds numerous additional name lists for empire creation.
- Provides a large Human - Extended name list with broad linguistic coverage.
- Combines sources inspired by both genuine world cultures and established fictional universes.

## 🎯 Use Cases

- **Human Civilisations:** Use expanded human naming options for culturally diverse empires.
- **Fiction-Inspired Species:** Select species-oriented lists derived from recognised science-fiction and fantasy settings.
- **Role-Playing Campaigns:** Align leader, vessel, fleet, and colony names with a chosen cultural style.

## 🚀 Usage

After installation, activate the mod in the Stellaris launcher, then select one of the provided name lists during empire creation.

## 📦 Installation

[![Obtain it from Steam Workshop](https://raw.githubusercontent.com/hmlendea/readme-assets/master/badges/stores/steam-workshop.png)](https://steamcommunity.com/sharedfiles/filedetails/?id=1912242707)
[![Obtain it from Nexus Mods](https://raw.githubusercontent.com/hmlendea/readme-assets/master/badges/stores/nexus.png)](https://www.nexusmods.com/stellaris/mods/73)
[![Obtain it from Paradox Mods](https://raw.githubusercontent.com/hmlendea/readme-assets/master/badges/stores/paradox-mods.png)](https://mods.paradoxplaza.com/mods/25409/Any)
[![Obtain it from GitHub](https://raw.githubusercontent.com/hmlendea/readme-assets/master/badges/stores/github.png)](https://github.com/hmlendea/stellaris-ui-name-lists/releases)

### Manual Installation

1. Download the latest release archive from the [releases page](https://github.com/hmlendea/stellaris-ui-name-lists/releases).
2. Extract the archive into your Stellaris mod directory.

## 🧩 Compatibility

| Component | Supported Versions | Notes |
|-----------|--------------------|-------|
| Stellaris | `v4.3.*` | The generated mod descriptor sets `supported_version="v4.3.*"`. |
| Operating systems | Linux, macOS, Windows | The mod is data-oriented and designed to operate wherever Stellaris is supported. |

## 🛠️ Development

### Requirements

- `bash`
- `curl`
- `wget`
- `unzip`
- Internet access for downloading the name-list generator dependency

### Setup

```bash
git clone https://github.com/hmlendea/stellaris-ui-name-lists.git
cd stellaris-ui-name-lists
bash scripts/update-builder.sh
```

### Build

```bash
bash scripts/build.sh
```

### Test

```bash
bash scripts/validate-data.sh
```

### Continuous Integration

The principal CI workflow validates input files and then builds with cached dependencies.

```bash
bash scripts/validate-data.sh
bash scripts/build.sh --skip-validation --skip-updates
```

## 🗂️ Project Structure

The repository organises raw source name-list data, generated inputs, UI-focused lists, and automation scripts.

### Directories

| Directory | Purpose |
|-----------|---------|
| `name-lists/generated/` | Generated source lists imported from external generators. |
| `name-lists/media/` | Name lists inspired by media franchises and settings. |
| `name-lists/real/` | Name lists derived from genuine language and culture groups. |
| `name-lists/ui/` | Final UI-facing list definitions consumed by the build process. |
| `scripts/` | Build, validation, and builder-update automation scripts. |

## 🤝 Contributing

You are welcome to submit any suggestion, feedback, or modification to this project.

When doing so, please:
- Maintain cross-platform compatibility
- Submit focused pull requests that conform to the existing code style
- Maintain your branch synchronised with `master`
- Revise the documentation when functionality changes
- Properly test all modifications, including edge cases and error conditions
- Raise a new [issue](https://github.com/hmlendea/stellaris-ui-name-lists/issues) for problems or suggestions

## 🔗 Related Projects

- [stellaris-ui-character-traits](https://github.com/hmlendea/stellaris-ui-character-traits): Additional character trait content for Stellaris.
- [stellaris-ui-deposit-blockers](https://github.com/hmlendea/stellaris-ui-deposit-blockers): Expanded planetary deposit blocker content.
- [stellaris-ui-flags](https://github.com/hmlendea/stellaris-ui-flags): Extended flag options for empires.
- [stellaris-ui-galaxy-sizes](https://github.com/hmlendea/stellaris-ui-galaxy-sizes): Additional galaxy-size configurations.
- [stellaris-ui-planet-modifiers](https://github.com/hmlendea/stellaris-ui-planet-modifiers): Expanded planetary modifier content.
- [stellaris-ui-prescripted-countries](https://github.com/hmlendea/stellaris-ui-prescripted-countries): Additional pre-scripted country definitions.
- [stellaris-ui-species-names](https://github.com/hmlendea/stellaris-ui-species-names): Additional species naming content.
- [stellaris-ui-species-traits](https://github.com/hmlendea/stellaris-ui-species-traits): Expanded species trait content.
- [stellaris-ui-star-names](https://github.com/hmlendea/stellaris-ui-star-names): Expanded stellar naming content.

## 💝 Project Engagement

Discovered a problem or have a suggestion? [Open an issue](https://github.com/hmlendea/stellaris-ui-name-lists/issues)!

If you find this project useful, consider [funding it](https://hmlendea.go.ro/funding) or starring ⭐️ it on GitHub, or giving it a thumbs up and adding it as a favourite on the [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=1912242707)!

[![Donate](https://raw.githubusercontent.com/hmlendea/readme-assets/master/donate_generic.png)](https://hmlendea.go.ro/funding)

## 📄 License

This project is being distributed under the `GNU General Public License v3.0`.
See [LICENSE](./LICENSE) for further information.
