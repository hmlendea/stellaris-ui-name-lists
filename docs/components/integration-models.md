# Integration Models

## External Integrations

### StellarisNameListGenerator

**Type**: External CLI binary (C#/.NET)

**Repository**: hmlendea/stellaris-name-list-generator

**Integration Pattern**: Downloaded binary executed as subprocess

**Interface**:

```bash
StellarisNameListGenerator \
    --input <merged_xml_path> \
    --output <name_lists_output_dir> \
    --localisation <localisation_output_dir> \
    --mod-name <mod_display_name> \
    --mod-version <mod_version>
```

**Inputs**:
- Merged XML containing one or more `<NameList>` elements
- Output directory paths
- Mod metadata (name, version)

**Outputs**:
- `common/name_lists/*.txt` — Stellaris name list definitions
- `localisation/english/*.yml` — Localisation strings

**Version Management**:
- Pinned version in `scripts/update-builder.sh` (`BUILDER_VERSION`)
- Cached in `.builder/` directory
- Downloaded from GitHub Releases on demand

**Failure Modes**:
- Binary not found → `update-builder.sh` downloads it
- Invalid input XML → Non-zero exit, error to stderr
- Output directory permissions → Non-zero exit
- Version incompatibility → May produce invalid output

**Testing**:
- Integration tested via full `build.sh` execution
- No unit tests for the binary itself (external dependency)

---

### GitHub Actions (CI/CD)

**Type**: Hosted CI/CD platform

**Workflows**:

#### `build.yml` (Continuous Integration)

**Trigger**: Push/PR to `master`

**Jobs**:
1. **validate** — Runs `validate-data.sh`
2. **build** — Runs `build.sh`, uploads artefacts

**Environment**:
- Ubuntu latest
- Bash, curl, wget, unzip pre-installed
- No .NET SDK required (binary cached)

**Artefacts**:
- `ui-name-lists.zip` — Built mod package

#### `steam-workshop.yml` (Steam Workshop Deployment)

**Trigger**: Tag push (`v*.*.*`)

**Jobs**:
1. **release** — Downloads release asset, uploads to Steam Workshop

**Secrets Required**:
- `STEAM_USERNAME`
- `STEAM_PASSWORD`
- `STEAM_2FA_SEED`

**Action**: `hmlendea/steam-workshop-update@v1.0.0`

**Inputs**:
- `appid` — Steam App ID (281990 for Stellaris)
- `itemid` — Workshop item ID
- `path` — Mod directory path
- `changenote` — Markdown changelog with release link

#### `nexus-mods.yml` (Nexus Mods Deployment)

**Trigger**: Tag push (`v*.*.*`) or manual dispatch

**Jobs**:
1. **release** — Downloads release asset, uploads to Nexus Mods

**Secrets Required**:
- `NEXUSMODS_API_KEY`

**Action**: `Nexus-Mods/upload-action@v1.0.0-beta.10`

**Inputs**:
- `file_id` — Nexus Mods file ID
- `filename` — Archive filename
- `display_name` — Display name
- `version` — Release version
- `description` — Changelog link
- `category` — `main`
- `archive_existing_version` — `true`
- `update_mod_version` — `true`

---

### GitHub Releases

**Type**: Artefact hosting

**Usage**:
- Release assets uploaded by `build.yml` (via `actions/upload-release-asset` or manual)
- Downloaded by deployment workflows (`steam-workshop.yml`, `nexus-mods.yml`)
- Asset naming: `ui-name-lists_{version}.zip`

**Integration**:
- `build.yml` creates release on tag push (or manual)
- Deployment workflows use `wget` to download from `github.com/.../releases/download/{tag}/...`

---

### Stellaris Game (Target Platform)

**Type**: Game mod consumer

**Integration Contract**:
- Mod directory structure:
  ```
  ui-name-lists/
  ├── descriptor.mod
  ├── thumbnail.png
  ├── common/name_lists/*.txt
  └── localisation/english/*.yml
  ```
- `descriptor.mod` must declare `supported_version="v4.3.*"`
- Name list IDs must be unique across all loaded mods
- Localisation keys must follow `ui_name_*` prefix convention

**Compatibility**:
- Tested against Stellaris v4.3.x
- Major version upgrades (v4.x → v5.x) likely require mod updates
- No runtime API — purely data-driven

---

## Internal Integrations

### Scripts ↔ Name Lists

**Pattern**: File-based (XML)

**Scripts read from**: `name-lists/**/*.xml`

**Scripts write to**: `build/`, `out/`

**Validation**: `validate-data.sh` reads all XML; `build.sh` reads composition variable paths

### Scripts ↔ Paths Configuration

**Pattern**: Sourced shell script

**File**: `scripts/common/paths.sh`

**Usage**:
```bash
source "$SCRIPTS_DIR/common/paths.sh"
# Uses: REPO_DIR, SCRIPTS_DIR, BUILD_DIR, OUTPUT_DIR, MOD_BUILDER_DIRECTORY, CACHE_DIR
```

### Build ↔ Output

**Pattern**: Directory-based

**Build writes to**: `out/ui-name-lists/`

**Consumers**:
- Steam Workshop upload action
- Nexus Mods upload action
- Manual Paradox Mods upload
- End users (manual installation)

---

## Data Flow Summary

```
name-lists/**/*.xml
       │
       ▼
validate-data.sh (structural + URL validation)
       │
       ▼
build.sh:merge() ──────────────────► build/merged_*.xml
       │                                    │
       │                                    ▼
       │                          StellarisNameListGenerator
       │                                    │
       │                    ┌───────────────┴───────────────┐
       │                    ▼                               ▼
       │          common/name_lists/*.txt           localisation/english/*.yml
       │                    │                               │
       │                    └───────────────┬───────────────┘
       │                                    ▼
       │                          build.sh:add_localisation()
       │                                    │
       ▼                                    ▼
generate_mod_descriptor()          ui_names_l_english.yml
       │
       ▼
create_release_archives() ──────► release/ui-name-lists_{version}.zip
       │
       ├──► GitHub Release (asset)
       ├──► Steam Workshop (via steam-workshop.yml)
       └──► Nexus Mods (via nexus-mods.yml)
```

---

## Version Compatibility Matrix

| Component | Version | Compatibility Policy |
|-----------|---------|---------------------|
| Stellaris | v4.3.* | Patch wildcard; major version breaks |
| StellarisNameListGenerator | v1.2.3 | Pinned; update via `update-builder.sh` |
| GitHub Actions | ubuntu-latest | Rolling; pin if breaking changes |
| steam-workshop-update | v1.0.0 | Semantic versioning |
| Nexus-Mods/upload-action | v1.0.0-beta.10 | Beta; monitor for stable release |

---

## Adding New Integrations

1. **New external binary**: Add download logic to `update-builder.sh` or new script; cache in `.builder/`
2. **New deployment channel**: Create new workflow in `.github/workflows/` following existing patterns
3. **New validation rule**: Add grep pattern to `validate-data.sh`
4. **New output format**: Modify `build.sh` packaging; ensure Stellaris compatibility