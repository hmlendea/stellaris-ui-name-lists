# API Reference

> **Note**: This project is a **data-only Stellaris mod** with no public API, no HTTP endpoints, no library interface, and no programmatic extension points. This document serves as a reference for the *data contracts* and *CLI interfaces* that constitute the system's integration surface.

## Data Contracts

### XML Name List Schema

The primary data contract is the XML schema for name list definitions in `name-lists/**/*.xml`.

#### Root Element: `<NameList>`

```xml
<NameList>
    <Name>internal_identifier</Name>
    <DisplayName>Human Readable Name</DisplayName>
    <SpeciesClass>HUMANOID</SpeciesClass>
    <Url>https://attribution.example.com</Url>
    <NameGroup>
        <Name>group_name</Name>
        <Chance>100</Chance>
        <Value>Name Value 1</Value>
        <Value>Name Value 2</Value>
    </NameGroup>
</NameList>
```

#### Element Reference

| Element | Required | Cardinality | Description |
|---------|----------|-------------|-------------|
| `Name` | Yes | 1 | Internal identifier (snake_case, unique) |
| `DisplayName` | Yes | 1 | Human-readable name for UI |
| `SpeciesClass` | Yes | 1 | Stellaris species class (HUMANOID, FUNGUS, etc.) |
| `Url` | Yes | 1 | Attribution URL (must be reachable) |
| `NameGroup` | Yes | 1+ | Group of names with shared chance |
| `NameGroup/Name` | Yes | 1 | Group identifier |
| `NameGroup/Chance` | Yes | 1 | Weight (integer, relative) |
| `NameGroup/Value` | Yes | 1+ | Individual name strings |

#### Species Class Values

| Class | Description |
|-------|-------------|
| `HUMANOID` | Human-like species |
| `FUNGUS` | Fungal species |
| `MAMMALIAN` | Mammalian species |
| `REPTILIAN` | Reptilian species |
| `AVIAN` | Bird-like species |
| `ARTHROPOID` | Insectoid species |
| `MOLLUSCOID` | Mollusc-like species |
| `PLANTOID` | Plant-like species |
| `LITHOID` | Rock-like species |
| `MACHINE` | Mechanical species |
| `TOXOID` | Toxic species |

#### Validation Rules

See `flows/detail-mutation.md` for complete validation rule set (V001-V007).

### Generated Output Contracts

#### Name List Definition (`common/name_lists/*.txt`)

```txt
name_list = {
    key = "internal_identifier"
    name = "Display Name"
    species_class = "HUMANOID"
    used_for = {
        country = yes
        fleet = yes
        planet = yes
        leader = yes
        ship = yes
        army = yes
    }
    name = {
        "Name Value 1"
        "Name Value 2"
    }
}
```

#### Localisation (`localisation/english/*.yml`)

```yml
l_english:
 internal_identifier: "Display Name"
 internal_identifier_desc: "Description from Url or generated"
```

### Mod Descriptor Contract (`descriptor.mod`)

```ini
name="Universum Infinitum: Name Lists"
description="Adds 50+ curated name lists..."
version="1.2.3"
supported_version="v4.3.*"
tags={"Content", "Localisation"}
picture="thumbnail.png"
```

## CLI Interfaces

### Build Script (`scripts/build.sh`)

```bash
./scripts/build.sh [options]

Options:
  --clean          Clean build directories before building
  --validate-only  Run validation only, skip generation
  --help           Show help
```

**Exit Codes**:
- `0` = Success
- `1` = Validation failed
- `2` = Build failed
- `3` = Dependency missing

### Validation Script (`scripts/validate-data.sh`)

```bash
./scripts/validate-data.sh [options]

Options:
  --no-cache       Skip URL cache, force fresh checks
  --verbose        Verbose output
  --help           Show help
```

**Exit Codes**:
- `0` = All valid
- `1` = Structural validation failed
- `2` = URL validation failed

### Update Builder (`scripts/update-builder.sh`)

```bash
./scripts/update-builder.sh [options]

Options:
  --version VERSION  Override BUILDER_VERSION
  --force            Force re-download
  --help             Show help
```

### StellarisNameListGenerator (External)

```bash
StellarisNameListGenerator \
    --input <merged_xml_file> \
    --output <name_lists_output_dir> \
    --localisation <loc_output_dir> \
    --mod-name <mod_name> \
    --mod-version <mod_version>
```

**Exit Codes**:
- `0` = Success
- `1` = Invalid arguments
- `2` = Input file error
- `3` = Output error
- `4` = Processing error

## CI/CD Interfaces

### Workflow Dispatch Inputs

#### `nexus-mods.yml`

```yaml
workflow_dispatch:
  inputs:
    version:
      description: "Version to deploy (e.g., v1.2.3)"
      required: true
      type: string
```

### Workflow Outputs

#### `build.yml`

```yaml
outputs:
  version: ${{ steps.version.outputs.version }}
  artefact: ${{ steps.upload.outputs.artefact-url }}
```

## File Format Specifications

### URL Cache Format (`.cache/url_<sha256>`)

```
OK
```
or
```
FAIL
```

Single line, no newline required.

### Builder Version File (`.builder/VERSION`)

```
v1.2.3
```

Single line version string.

## Integration Points Summary

| Interface | Type | Consumer | Producer |
|-----------|------|----------|----------|
| XML Schema | Data | Generator, Validator | Contributors |
| Merged XML | Data | Generator | Build script |
| Generator CLI | Process | Build script | Generator binary |
| Name list TXT | Data | Stellaris | Generator |
| Localisation YML | Data | Stellaris | Generator |
| Mod descriptor | Data | Stellaris, Steam, Nexus | Build script |
| Release ZIP | Archive | Steam, Nexus, Users | Build script |
| GitHub Actions | Platform | Workflows | GitHub |

## Versioning

| Contract | Versioning |
|----------|------------|
| XML Schema | Implicit (Stellaris version) |
| Generator CLI | Semantic (pinned) |
| Output formats | Tied to Stellaris version |
| Mod descriptor | Semantic (mod version) |
| CI workflows | GitHub Actions versions |

## Deprecation Policy

- **XML Schema**: Never deprecated (Stellaris compatibility)
- **Generator CLI**: Pinned version; update tested before bump
- **Output formats**: Updated with Stellaris major version
- **Workflows**: Updated with GitHub Actions deprecations