# Host and Composition

## Build Orchestration

The build pipeline is orchestrated by `scripts/build.sh`, which serves as the composition root. It defines how hundreds of source XML files are merged into approximately 50 final name lists.

### Entry Point

```bash
#!/usr/bin/env bash
# scripts/build.sh

set -euo pipefail

# Configuration
MOD_ID="ui_name_lists"
MOD_NAME="Universum Infinitum: Name Lists"
STELLARIS_VERSION="v4.3.*"
```

### Composition Variables

The script defines composition variables as space-separated lists of source XML paths. Each variable maps to one output name list.

#### Human Name Lists

| Variable | Output | Sources |
|----------|--------|---------|
| `AFRICAN_NAMELISTS` | `human_african` | `real/african/*`, `media/*` |
| `ARABIC_NAMELISTS` | `human_arabic` | `real/arabic/*`, `media/*` |
| `ASIAN_NAMELISTS` | `human_asian` | `real/asian/*`, `media/*` |
| `AUSTRO_NAMELISTS` | `human_austronesian` | `real/austronesian/*`, `media/*` |
| `BALTIC_NAMELISTS` | `human_baltic` | `real/baltic/*`, `media/*` |
| `CELTIC_NAMELISTS` | `human_celtic` | `real/celtic/*`, `media/*` |
| `ENGLISH_NAMELISTS` | `human_english` | `real/english/*`, `media/*` |
| `EUROPEAN_NAMELISTS` | `human_european` | `real/european/*`, `media/*` |
| `GERMANIC_NAMELISTS` | `human_germanic` | `real/germanic/*`, `media/*` |
| `HELLENIC_NAMELISTS` | `human_hellenic` | `real/hellenic/*`, `media/*` |
| `HINDI_NAMELISTS` | `human_hindi` | `real/indian/*`, `media/*` |
| `IBERIAN_NAMELISTS` | `human_iberian` | `real/romance/iberian/*`, `media/*` |
| `INDIAN_NAMELISTS` | `human_indian` | `real/indian/*`, `media/*` |
| `IRANIAN_NAMELISTS` | `human_iranian` | `real/iranian/*`, `media/*` |
| `LATINO_NAMELISTS` | `human_latino` | `real/american/latino/*`, `media/*` |
| `NORSE_NAMELISTS` | `human_norse` | `real/germanic/norse/*`, `media/*` |
| `ROMANCE_NAMELISTS` | `human_romance` | `real/romance/*`, `media/*` |
| `ROMANIAN_NAMELISTS` | `human_romanian` | `real/romance/romanian/*`, `media/*` |
| `RUSSIAN_NAMELISTS` | `human_russian` | `real/slavic/russian/*`, `media/*` |
| `SLAVIC_NAMELISTS` | `human_slavic` | `real/slavic/*`, `media/*` |
| `TURKIC_NAMELISTS` | `human_turkic` | `real/turkic/*`, `media/*` |
| `YUGOSLAVIC_NAMELISTS` | `human_yugoslavic` | `real/slavic/yugoslavic/*`, `media/*` |

#### Extended Human Name Lists

| Variable | Output | Sources |
|----------|--------|---------|
| `HUMAN_EXTENDED_NAMELISTS` | `human_extended` | All human categories above |
| `HUMAN_EXTRA_NAMELISTS` | `human_extra` | `ui/human_extra.xml`, `ui/human/*` |
| `HUMAN_ZEXTENDED_NAMELISTS` | `human_zextended` | `ui/human_zextended.xml` |

#### Species UI Name Lists

| Variable | Output | Sources |
|----------|--------|---------|
| `UI_ART1_NAMELISTS` | `ui_art1` | `ui/art1.xml`, `generated/*` |
| `UI_AVI1_NAMELISTS` | `ui_avi1` | `ui/avi1.xml`, `generated/*` |
| `UI_AVI2_NAMELISTS` | `ui_avi2` | `ui/avi2.xml`, `generated/*` |
| `UI_FUN1_NAMELISTS` | `ui_fun1` | `ui/fun1.xml`, `generated/*` |
| `UI_HUM1_NAMELISTS` | `ui_hum1` | `ui/hum1.xml`, `generated/*` |
| `UI_HUM2_NAMELISTS` | `ui_hum2` | `ui/hum2.xml`, `generated/*` |
| `UI_HUM3_NAMELISTS` | `ui_hum3` | `ui/hum3.xml`, `generated/*` |
| `UI_HUM4_NAMELISTS` | `ui_hum4` | `ui/hum4.xml`, `generated/*` |
| `UI_MAM1_NAMELISTS` | `ui_mam1` | `ui/mam1.xml`, `generated/*` |
| `UI_MAM2_NAMELISTS` | `ui_mam2` | `ui/mam2.xml`, `generated/*` |
| `UI_MAM3_NAMELISTS` | `ui_mam3` | `ui/mam3.xml`, `generated/*` |
| `UI_MOL1_NAMELISTS` | `ui_mol1` | `ui/mol1.xml`, `generated/*` |
| `UI_MOL2_NAMELISTS` | `ui_mol2` | `ui/mol2.xml`, `generated/*` |
| `UI_PLA1_NAMELISTS` | `ui_pla1` | `ui/pla1.xml`, `generated/*` |
| `UI_PLA2_NAMELISTS` | `ui_pla2` | `ui/pla2.xml`, `generated/*` |
| `UI_REP1_NAMELISTS` | `ui_rep1` | `ui/rep1.xml`, `generated/*` |
| `UI_REP2_NAMELISTS` | `ui_rep2` | `ui/rep2.xml`, `generated/*` |
| `UI_REP3_NAMELISTS` | `ui_rep3` | `ui/rep3.xml`, `generated/*` |
| `UI_REP4_NAMELISTS` | `ui_rep4` | `ui/rep4.xml`, `generated/*` |

#### Fantasy/Sci-Fi Species

| Variable | Output | Sources |
|----------|--------|---------|
| `FANTASY_SPIDER_NAMELISTS` | `fantasy_spider` | `ui/fantasy_spider.xml` |
| `FNG_LIZARDFOLK_NAMELISTS` | `fng_lizardfolk` | `ui/fng_lizardfolk.xml` |
| `GALCIV_YOR_NAMELISTS` | `galciv_yor` | `ui/galciv_yor.xml` |
| `GOBLIN_NAMELISTS` | `goblin` | `ui/goblin.xml` |
| `LIZARD_NAMELISTS` | `lizard` | `ui/lizard.xml` |
| `NARIVIA_RODAH_NAMELISTS` | `narivia_rodah` | `ui/narivia_rodah.xml` |
| `ORC_NAMELISTS` | `orc` | `ui/orc.xml` |
| `RUNESCAPE_HUMAN_NAMELISTS` | `runescape_human` | `ui/runescape_human.xml` |
| `STARCRAFT_HUMAN_NAMELISTS` | `starcraft_human` | `ui/starcraft_human.xml` |
| `STARCRAFT_PROTOSS_NAMELISTS` | `starcraft_protoss` | `ui/starcraft_protoss.xml` |
| `STARWARS_HUMAN_NAMELISTS` | `starwars_human` | `ui/starwars_human.xml` |

#### Extra Categories

| Variable | Output | Sources |
|----------|--------|---------|
| `EXTRA_ART1_NAMELISTS` | `extra_art1` | `ui/extra_art1.xml` |
| `EXTRA_AVI1_NAMELISTS` | `extra_avi1` | `ui/extra_avi1.xml` |
| `EXTRA_AVI2_NAMELISTS` | `extra_avi2` | `ui/extra_avi2.xml` |
| `EXTRA_FUN1_NAMELISTS` | `extra_fun1` | `ui/extra_fun1.xml` |
| `EXTRA_HUM1_NAMELISTS` | `extra_hum1` | `ui/extra_hum1.xml` |
| `EXTRA_HUM2_NAMELISTS` | `extra_hum2` | `ui/extra_hum2.xml` |
| `EXTRA_HUM3_NAMELISTS` | `extra_hum3` | `ui/extra_hum3.xml` |
| `EXTRA_HUM4_NAMELISTS` | `extra_hum4` | `ui/extra_hum4.xml` |
| `EXTRA_MAM1_NAMELISTS` | `extra_mam1` | `ui/extra_mam1.xml` |
| `EXTRA_MAM2_NAMELISTS` | `extra_mam2` | `ui/extra_mam2.xml` |
| `EXTRA_MAM3_NAMELISTS` | `extra_mam3` | `ui/extra_mam3.xml` |
| `EXTRA_MOL1_NAMELISTS` | `extra_mol1` | `ui/extra_mol1.xml` |
| `EXTRA_MOL2_NAMELISTS` | `extra_mol2` | `ui/extra_mol2.xml` |
| `EXTRA_PLA1_NAMELISTS` | `extra_pla1` | `ui/extra_pla1.xml` |
| `EXTRA_PLA2_NAMELISTS` | `extra_pla2` | `ui/extra_pla2.xml` |
| `EXTRA_REP1_NAMELISTS` | `extra_rep1` | `ui/extra_rep1.xml` |
| `EXTRA_REP2_NAMELISTS` | `extra_rep2` | `ui/extra_rep2.xml` |
| `EXTRA_REP3_NAMELISTS` | `extra_rep3` | `ui/extra_rep3.xml` |
| `EXTRA_REP4_NAMELISTS` | `extra_rep4` | `ui/extra_rep4.xml` |

### Pipeline Functions

#### `merge()`

Merges multiple source XML files into a single composite XML for StellarisNameListGenerator.

```bash
merge() {
    local output_file="$1"
    shift
    local input_files=("$@")

    # Create merged XML with all NameList elements
    # Uses StellarisNameListGenerator's merge capability
}
```

#### `add_localisation()`

Generates localisation YAML from merged name lists.

```bash
add_localisation() {
    local name_list_id="$1"
    local display_name="$2"

    # Extracts all names and generates ui_names_l_english.yml entries
}
```

#### `build()`

Main build function for a single name list composition.

```bash
build() {
    local name_list_id="$1"
    local display_name="$2"
    local composition_var="$3"

    # 1. Merge source XMLs
    # 2. Run StellarisNameListGenerator
    # 3. Generate localisation
    # 4. Copy to output directory
}
```

#### `generate_mod_descriptor()`

Creates `descriptor.mod` with metadata.

```bash
generate_mod_descriptor() {
    cat > "$OUTPUT_DIR/descriptor.mod" <<EOF
name="$MOD_NAME"
supported_version="$STELLARIS_VERSION"
tags={
    "Name List"
}
description="..."
picture="thumbnail.png"
EOF
}
```

### Execution Flow

```bash
main() {
    # 1. Update builder (download StellarisNameListGenerator)
    ./scripts/update-builder.sh

    # 2. Validate all source data
    ./scripts/validate-data.sh

    # 3. Build each name list
    build "human_african" "Human - African" "$AFRICAN_NAMELISTS"
    build "human_arabic" "Human - Arabic" "$ARABIC_NAMELISTS"
    # ... all 50+ name lists

    # 4. Generate mod descriptor
    generate_mod_descriptor

    # 5. Package for distribution
    create_release_archives
}
```

## Path Configuration

Shared paths defined in `scripts/common/paths.sh`:

```bash
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS_DIR="$REPO_DIR/scripts"
BUILD_DIR="$REPO_DIR/build"
OUTPUT_DIR="$REPO_DIR/out/ui-name-lists"
MOD_BUILDER_DIRECTORY="$REPO_DIR/.builder"
CACHE_DIR="$REPO_DIR/.cache"
```

## StellarisNameListGenerator Integration

The external binary is invoked via:

```bash
"$MOD_BUILDER_DIRECTORY/StellarisNameListGenerator" \
    --input "$merged_xml" \
    --output "$OUTPUT_DIR/common/name_lists" \
    --localisation "$OUTPUT_DIR/localisation/english" \
    --mod-name "$MOD_NAME" \
    --mod-version "$VERSION"
```

## Composition Modification Guide

To add a new name list:

1. Create source XML in appropriate `name-lists/` subdirectory
2. Add composition variable in `build.sh` listing source files
3. Add `build` call in `main()` with name list ID, display name, and variable
4. Run `scripts/build.sh` to test
5. Submit PR

To modify an existing composition:

1. Edit the composition variable in `build.sh`
2. Add/remove source file paths
3. Run `scripts/build.sh` to test
4. Submit PR