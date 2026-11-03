# Build and Deployment

## Build Pipeline

### Local Build

```bash
# Prerequisites: bash, curl, wget, unzip
# No .NET SDK required (binary cached)

# Clean build
rm -rf build/ out/ .builder/ .cache/
./scripts/build.sh

# Output: out/ui-name-lists/ (Stellaris mod directory)
```

### CI Build (GitHub Actions)

**Workflow**: `.github/workflows/build.yml`

**Triggers**:
- Push to `master`
- Pull requests to `master`

**Jobs**:
1. **validate** — Runs `validate-data.sh`
2. **build** — Runs `build.sh`, uploads artefact

**Environment**: `ubuntu-latest`

**Artefacts**:
- `ui-name-lists.zip` — Built mod package

### Build Steps Detail

| Step | Script | Description |
|------|--------|-------------|
| 1 | `update-builder.sh` | Download/cache StellarisNameListGenerator |
| 2 | `validate-data.sh` | Structural + URL validation |
| 3 | `build.sh` (loop) | Merge → Generate → Localise per composition |
| 4 | `generate_mod_descriptor` | Create `descriptor.mod` |
| 5 | `create_release_archives` | Zip `out/ui-name-lists/` |

### Build Configuration

**File**: `scripts/build.sh` (top of file)

```bash
MOD_ID="ui_name_lists"
MOD_NAME="Universum Infinitum: Name Lists"
STELLARIS_VERSION="v4.3.*"
VERSION="${GITHUB_REF_NAME:-dev}"
```

**File**: `scripts/update-builder.sh`

```bash
BUILDER_VERSION="v1.2.3"
```

**File**: `scripts/common/paths.sh`

```bash
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS_DIR="$REPO_DIR/scripts"
BUILD_DIR="$REPO_DIR/build"
OUTPUT_DIR="$REPO_DIR/out/ui-name-lists"
MOD_BUILDER_DIRECTORY="$REPO_DIR/.builder"
CACHE_DIR="$REPO_DIR/.cache"
```

## Deployment Channels

### 1. Steam Workshop

**Workflow**: `.github/workflows/steam-workshop.yml`

**Trigger**: Tag push (`v*.*.*`)

**Process**:
1. Download release asset from GitHub Releases
2. Unzip to `release/`
3. Upload via `hmlendea/steam-workshop-update@v1.0.0`

**Required Secrets**:
- `STEAM_USERNAME`
- `STEAM_PASSWORD`
- `STEAM_2FA_SEED`

**Configuration** (in workflow):
```yaml
appid: 281990          # Stellaris App ID
itemid: <WORKSHOP_ID>  # Workshop item ID
path: "release/ui-name-lists/"
changelog: "[url=...]Version ${{github.ref_name}}[/url]"
```

### 2. Nexus Mods

**Workflow**: `.github/workflows/nexus-mods.yml`

**Trigger**: Tag push (`v*.*.*`) or manual dispatch

**Process**:
1. Download release asset from GitHub Releases
2. Upload via `Nexus-Mods/upload-action@v1.0.0-beta.10`

**Required Secrets**:
- `NEXUSMODS_API_KEY`

**Configuration** (in workflow):
```yaml
file_id: <NEXUS_FILE_ID>
filename: release.zip
display_name: "ui-name-lists.zip"
version: ${{ env.VERSION }}
description: "Changelog: https://github.com/.../releases/${{env.VERSION}}"
category: main
archive_existing_version: true
update_mod_version: true
```

### 3. Paradox Mods (Manual)

**Process**:
1. Download release asset from GitHub Releases
2. Log in to Paradox Plaza
3. Upload via Mod Manager
4. Fill metadata manually

**No automation** — Paradox Mods has no public API.

### 4. GitHub Releases

**Workflow**: `.github/workflows/build.yml` (on tag push)

**Process**:
1. Build creates `release/ui-name-lists_{version}.zip`
2. `softprops/action-gh-release@v1` creates release
3. Asset attached automatically

## Release Procedure

### Automated (Tag Push)

```bash
# 1. Ensure master is up to date
git checkout master
git pull

# 2. Create and push tag
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin v1.2.3

# 3. GitHub Actions triggers:
#    - build.yml → creates release + artefact
#    - steam-workshop.yml → deploys to Steam
#    - nexus-mods.yml → deploys to Nexus
```

### Manual Release Creation

```bash
# 1. Build locally
./scripts/build.sh

# 2. Create release archive
cd out/ui-name-lists/..
zip -r ../release/ui-name-lists_v1.2.3.zip ui-name-lists/

# 3. Create GitHub release manually
#    - Tag: v1.2.3
#    - Title: Universum Infinitum: Name Lists v1.2.3
#    - Attach: release/ui-name-lists_v1.2.3.zip
#    - Generate release notes

# 4. Trigger deployment workflows manually (if needed)
gh workflow run steam-workshop.yml -f tag=v1.2.3
gh workflow run nexus-mods.yml -f tag=v1.2.3
```

## Versioning

### Scheme

**Semantic Versioning**: `MAJOR.MINOR.PATCH`

| Component | When to Increment |
|-----------|-------------------|
| MAJOR | Breaking Stellaris compatibility (v4.x → v5.x) |
| MINOR | New name lists, significant additions |
| PATCH | Bug fixes, small corrections, validation updates |

### Version Sources

| Context | Version Source |
|---------|----------------|
| Local build | `dev` |
| CI build (PR) | `pr-<number>` |
| CI build (master) | `master-<sha>` |
| Tagged release | Git tag (`v1.2.3`) |

### Mod Descriptor Version

The `descriptor.mod` uses `supported_version="v4.3.*"` (Stellaris version), not mod version. Mod version is in release metadata only.

## Environment Matrix

| Environment | Purpose | Trigger | Artefacts |
|-------------|---------|---------|-----------|
| Local | Development | Manual | `out/ui-name-lists/` |
| CI (PR) | Validation | PR to master | None (validation only) |
| CI (master) | Integration | Push to master | `ui-name-lists.zip` |
| Release | Distribution | Tag push | `ui-name-lists_v*.zip` |
| Steam | Player install | Tag push | Workshop item update |
| Nexus | Player install | Tag push | Nexus Mods file update |
| Paradox | Player install | Manual | Mod portal update |

## Rollback Procedures

### Failed Deployment

```bash
# Steam Workshop: Re-upload previous version
gh workflow run steam-workshop.yml -f tag=v1.2.2

# Nexus Mods: Re-upload previous version
gh workflow run nexus-mods.yml -f tag=v1.2.2

# GitHub Release: Delete release, re-create
gh release delete v1.2.3
git tag -d v1.2.3
git push origin :refs/tags/v1.2.3
# Re-tag and push
```

### Bad Build on Master

```bash
# Revert commit
git revert <bad-commit>
git push origin master

# Or reset (force push - coordinate with team)
git reset --hard <good-commit>
git push --force origin master
```

## Monitoring and Verification

### Build Health

- **CI Status**: GitHub Actions badge in README
- **Build Duration**: ~3-5 minutes
- **Success Rate**: Target >95%

### Deployment Verification

| Channel | Verification |
|---------|--------------|
| Steam Workshop | Check workshop page version matches tag |
| Nexus Mods | Check file version matches tag |
| GitHub Releases | Check release exists with asset |
| Paradox Mods | Manual verification |

### Post-Release Checklist

- [ ] GitHub Release created with correct tag
- [ ] Release asset attached and downloadable
- [ ] Steam Workshop updated (check changelog)
- [ ] Nexus Mods updated (check version)
- [ ] Paradox Mods updated (manual)
- [ ] Changelog published (GitHub release notes)
- [ ] No regression in name list count