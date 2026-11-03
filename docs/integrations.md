# Integrations

## External System Integrations

### 1. Stellaris Game (Target Platform)

**Integration Type**: Data consumer

**Contract**:
- Mod directory structure in `out/ui-name-lists/`
- `descriptor.mod` with `supported_version="v4.3.*"`
- Name list definitions in `common/name_lists/*.txt`
- Localisation in `localisation/english/*.yml`

**Compatibility**:
- Tested: Stellaris v4.3.x
- Breaking changes expected on major version (v5.x)
- No runtime API — purely data-driven

**Validation**: Manual load test in game

### 2. StellarisNameListGenerator (Transformation Engine)

**Integration Type**: External CLI binary

**Repository**: hmlendea/stellaris-name-list-generator

**Interface**:
```bash
StellarisNameListGenerator \
    --input <merged_xml> \
    --output <name_lists_dir> \
    --localisation <loc_dir> \
    --mod-name <name> \
    --mod-version <version>
```

**Version Management**:
- Pinned: `BUILDER_VERSION="v1.2.3"` in `update-builder.sh`
- Downloaded from GitHub Releases
- Cached in `.builder/`

**Failure Modes**:
- Invalid input XML → Non-zero exit
- Output permission denied → Non-zero exit
- Version incompatibility → Invalid output

### 3. GitHub Actions (CI/CD Platform)

**Integration Type**: Hosted automation

**Workflows**:
| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `build.yml` | Push/PR to master | Validate + Build |
| `steam-workshop.yml` | Tag push | Deploy to Steam |
| `nexus-mods.yml` | Tag push / manual | Deploy to Nexus |

**Permissions**:
- `GITHUB_TOKEN`: Read/write repository (default)
- Secrets: Deployment credentials only

**Artefacts**:
- Build uploads `ui-name-lists.zip` as artefact
- Release workflow attaches to GitHub Release

### 4. GitHub Releases (Artefact Hosting)

**Integration Type**: File hosting

**Usage**:
- Build workflow creates release on tag
- Asset: `ui-name-lists_v*.zip`
- Deployment workflows download via `wget`

**URL Pattern**:
```
https://github.com/hmlendea/stellaris-ui-name-lists/releases/download/v1.2.3/ui-name-lists_v1.2.3.zip
```

### 5. Steam Workshop (Distribution)

**Integration Type**: Game mod platform

**Action**: `hmlendea/steam-workshop-update@v1.0.0`

**Configuration**:
```yaml
appid: 281990          # Stellaris
itemid: <WORKSHOP_ID>  # Workshop item ID
path: "release/ui-name-lists/"
changelog: "[url=...]Version v1.2.3[/url]"
```

**Authentication**:
- `STEAM_USERNAME`
- `STEAM_PASSWORD`
- `STEAM_2FA_SEED`

**Process**:
1. Download release asset
2. Unzip to `release/`
3. Upload via Steam API

### 6. Nexus Mods (Distribution)

**Integration Type**: Mod hosting platform

**Action**: `Nexus-Mods/upload-action@v1.0.0-beta.10`

**Configuration**:
```yaml
file_id: <NEXUS_FILE_ID>
filename: release.zip
display_name: "ui-name-lists.zip"
version: ${{ env.VERSION }}
description: "Changelog: https://github.com/.../releases/v1.2.3"
category: main
archive_existing_version: true
update_mod_version: true
```

**Authentication**:
- `NEXUSMODS_API_KEY`

### 7. Paradox Mods (Distribution)

**Integration Type**: Official mod platform

**Status**: Manual only (no public API)

**Process**:
1. Download release asset
2. Log in to Paradox Plaza
3. Upload via Mod Manager
4. Fill metadata manually

## Internal Integrations

### Scripts ↔ Name Lists

**Pattern**: File-based (XML)

```
scripts/validate-data.sh ──────► reads name-lists/**/*.xml
scripts/build.sh:merge() ──────► reads name-lists/**/*.xml
```

### Scripts ↔ Paths Config

**Pattern**: Sourced shell script

```
scripts/common/paths.sh ──────► sourced by all scripts
```

### Build ↔ Output

**Pattern**: Directory-based

```
build.sh ──────► writes out/ui-name-lists/
Steam/Nexus actions ──────► reads release/*.zip
```

## Integration Health Checks

### Pre-Build

```bash
# Verify generator binary
test -x .builder/StellarisNameListGenerator

# Verify source directory
test -d name-lists/
```

### Post-Build

```bash
# Verify output structure
test -f out/ui-name-lists/descriptor.mod
test -d out/ui-name-lists/common/name_lists
test -d out/ui-name-lists/localisation/english

# Verify name list count
COUNT=$(grep -c "name_list = {" out/ui-name-lists/common/name_lists/00_ui_name_lists.txt)
test $COUNT -gt 40
```

### Deployment

```bash
# Steam: Check workshop page version
# Nexus: Check file version
# GitHub: Check release exists with asset
```

## Integration Version Matrix

| Integration | Version | Update Policy |
|-------------|---------|---------------|
| Stellaris | v4.3.* | Major version = breaking |
| StellarisNameListGenerator | v1.2.3 | Test before update |
| GitHub Actions | ubuntu-latest | Pin if breaking |
| steam-workshop-update | v1.0.0 | Semantic versioning |
| Nexus-Mods/upload-action | v1.0.0-beta.10 | Monitor for stable |

## Adding New Integrations

### New Distribution Channel

1. Create workflow in `.github/workflows/`
2. Follow existing patterns
3. Add required secrets
4. Test with manual dispatch

### New Validation Source

1. Add check to `validate-data.sh`
2. Or create new validation script
3. Call from `build.sh` before generation

### New Transformation Step

1. Add function to `build.sh`
2. Insert in pipeline after merge, before generator
3. Ensure deterministic output

## Integration Testing

### Local Integration Test

```bash
# Full pipeline
./scripts/build.sh

# Verify Stellaris compatibility
cp -r out/ui-name-lists/ ~/.local/share/Paradox\ Interactive/Stellaris/mod/ui-name-lists-test
# Launch Stellaris, enable mod, verify
```

### CI Integration Test

Automatic via `build.yml`:
- Validation pass
- Build pass
- Output structure verification
- Artefact upload

### Deployment Integration Test

Triggered on tag push:
- Steam Workshop upload
- Nexus Mods upload
- GitHub Release creation

## Troubleshooting Integrations

| Integration | Common Issue | Resolution |
|-------------|--------------|------------|
| Generator | Version mismatch | Update `BUILDER_VERSION` |
| Steam | Auth failure | Check secrets; verify 2FA seed |
| Nexus | API key invalid | Regenerate API key |
| GitHub Release | Asset missing | Check build.yml upload step |
| Stellaris | Mod not loading | Check descriptor.mod version |