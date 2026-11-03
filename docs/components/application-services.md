# Application Services

## Overview

The application services layer contains the core transformation logic that converts source XML name list definitions into Stellaris-compatible mod output. These services are implemented as bash functions in `scripts/build.sh` and the external StellarisNameListGenerator binary.

## Core Services

### 1. Validation Service (`scripts/validate-data.sh`)

Validates all XML name list definitions before build.

#### Structural Validation

Checks for common XML authoring errors using grep patterns:

| Check | Pattern | Error Message |
|-------|---------|---------------|
| Double tags | `<NameList>.*<NameList>` | "Double NameList tags found" |
| Empty Values | `<Values>\s*</Values>` | "Empty Values element" |
| Empty Value | `<Value>\s*</Value>` | "Empty Value element" |
| Multiple Characters | `<Characters>.*<Characters>` | "Multiple Characters elements" |
| Url in Values | `<Values>.*<Url>` | "Url inside Values" |
| Name outside NameGroup | `</NameGroup>.*<Name>` (not in NameGroup) | "Name outside NameGroup" |
| Malformed nesting | Various | "Malformed XML structure" |

#### Semantic Validation (URL Reachability)

- Extracts all `<Url>` elements from all XML files
- Performs HTTP HEAD request for each unique URL
- Caches results in `.cache/` to avoid redundant requests
- Fails build if any URL returns non-2xx status

#### Usage

```bash
./scripts/validate-data.sh
# Exit code: 0 = success, 1 = validation failure
```

### 2. Merge Service (`build.sh::merge()`)

Combines multiple source XML files into a single composite XML for StellarisNameListGenerator.

#### Input

- Array of source XML file paths (relative to `name-lists/`)

#### Process

1. Creates temporary merged XML file in `build/`
2. Wraps all source `<NameList>` elements in a root `<NameLists>` element
3. Preserves all source attributes and child elements

#### Output

- Merged XML file path for StellarisNameListGenerator consumption

### 3. Generation Service (StellarisNameListGenerator)

External binary that transforms merged XML into Stellaris mod format.

#### Invocation

```bash
"$MOD_BUILDER_DIRECTORY/StellarisNameListGenerator" \
    --input "$merged_xml" \
    --output "$OUTPUT_DIR/common/name_lists" \
    --localisation "$OUTPUT_DIR/localisation/english" \
    --mod-name "$MOD_NAME" \
    --mod-version "$VERSION"
```

#### Responsibilities

- Parses merged XML
- Generates `common/name_lists/*.txt` files (Stellaris format)
- Generates `localisation/english/*.yml` files
- Handles name group weighting, gender, and special types (ship, fleet, planet, army, ruler_title)

#### Version Management

- Downloaded by `scripts/update-builder.sh`
- Cached in `.builder/` by version
- Version pinned in `update-builder.sh` (currently `v1.2.3`)

### 4. Localisation Service (`build.sh::add_localisation()`)

Generates localisation YAML entries for all names in a name list.

#### Input

- Name list ID (e.g., `human_extended`)
- Display name (e.g., `Human - Extended`)

#### Process

1. Reads generated name list output from StellarisNameListGenerator
2. Extracts all name groups and values
3. Generates YAML keys following pattern:
   - `ui_name_list_{id}: "{display_name}"`
   - `ui_name_group_{group_id}: "{group_name}"`
   - `ui_name_value_{sanitized_value}: "{value}"`

#### Output

- Appends to `out/ui-name-lists/localisation/english/ui_names_l_english.yml`

### 5. Mod Descriptor Service (`build.sh::generate_mod_descriptor()`)

Creates the Stellaris mod descriptor file.

#### Output (`out/ui-name-lists/descriptor.mod`)

```ini
name="Universum Infinitum: Name Lists"
supported_version="v4.3.*"
tags={
    "Name List"
}
description="Provides numerous detailed name lists for empire creation..."
picture="thumbnail.png"
```

### 6. Packaging Service (`build.sh::create_release_archives()`)

Creates distribution archives for each deployment channel.

#### Steam Workshop

- Zips `out/ui-name-lists/` directory
- Names: `ui-name-lists_{version}.zip`

#### Nexus Mods

- Same archive as Steam Workshop
- Uploaded via Nexus Mods API

#### Paradox Mods (Manual)

- Same archive structure
- Manual upload via Paradox Plaza

### 7. Dependency Management Service (`scripts/update-builder.sh`)

Manages the StellarisNameListGenerator binary.

#### Process

1. Checks `.builder/` for cached binary matching required version
2. If missing, downloads from GitHub Releases:
   `https://github.com/hmlendea/stellaris-name-list-generator/releases/download/{version}/StellarisNameListGenerator-linux-x64.zip`
3. Extracts to `.builder/`
4. Makes executable

#### Version Pinning

Version defined in `update-builder.sh`:
```bash
BUILDER_VERSION="v1.2.3"
```

## Service Interactions

```
validate-data.sh
       │
       ▼
build.sh:main()
       │
       ├── update-builder.sh ──────► .builder/StellarisNameListGenerator
       │
       ├── merge() ────────────────► build/merged_*.xml
       │                                │
       │                                ▼
       │                    StellarisNameListGenerator
       │                                │
       │                                ├──► common/name_lists/*.txt
       │                                └──► localisation/english/*.yml
       │
       ├── add_localisation() ──────► localisation/english/ui_names_l_english.yml
       │
       ├── generate_mod_descriptor() ─► descriptor.mod
       │
       └── create_release_archives() ──► release/*.zip
```

## Error Handling

| Service | Failure Mode | Recovery |
|---------|--------------|----------|
| Validation | Non-zero exit | Fix source XML, re-run |
| Merge | File not found | Check composition variable paths |
| Generator | Non-zero exit | Check merged XML validity; verify builder version |
| Localisation | Write permission | Check output directory permissions |
| Descriptor | Write permission | Check output directory permissions |
| Packaging | Disk space | Clean build directory |

## Testing Services Locally

```bash
# Validate only
./scripts/validate-data.sh

# Full build
./scripts/build.sh

# Update builder only
./scripts/update-builder.sh

# Clean build artefacts
rm -rf build/ out/ .builder/
./scripts/build.sh
```