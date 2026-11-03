# Dependencies

## External Dependencies

### Runtime Dependencies

| Dependency | Version | Purpose | Source |
|------------|---------|---------|--------|
| StellarisNameListGenerator | v1.2.3 | Core name list transformation | GitHub Releases (hmlendea/stellaris-name-list-generator) |
| Stellaris Game | v4.3.* | Target platform | Paradox Interactive |

### Build-Time Dependencies (System)

| Dependency | Version | Purpose | Installation |
|------------|---------|---------|--------------|
| bash | 4.0+ | Script execution | System package manager |
| curl | 7.60+ | HTTP requests (URL validation, downloads) | System package manager |
| wget | 1.20+ | File downloads (builder, release assets) | System package manager |
| unzip | 6.0+ | Extract builder binary, release archives | System package manager |
| grep | 3.0+ | Pattern matching (validation, merge) | System package manager |
| awk | 4.0+ | Text processing (merge, extraction) | System package manager |
| sed | 4.0+ | Stream editing (merge, sanitisation) | System package manager |
| sha256sum | 8.0+ | Cache key generation | System package manager (coreutils) |
| find | 4.0+ | File discovery (cache cleanup) | System package manager (findutils) |

### CI/CD Dependencies (GitHub Actions)

| Action | Version | Purpose |
|--------|---------|---------|
| actions/checkout | v7 | Repository checkout |
| actions/upload-artifact | v4 | Build artefact upload |
| softprops/action-gh-release | v1 | GitHub Release creation |
| hmlendea/steam-workshop-update | v1.0.0 | Steam Workshop deployment |
| Nexus-Mods/upload-action | v1.0.0-beta.10 | Nexus Mods deployment |

## Internal Dependencies

### Script Dependencies

```
scripts/build.sh
├── scripts/common/paths.sh (sourced)
├── scripts/update-builder.sh (executed)
├── scripts/validate-data.sh (executed)
└── .builder/StellarisNameListGenerator (executed)

scripts/validate-data.sh
├── scripts/common/paths.sh (sourced)
└── .cache/ (read/write)

scripts/update-builder.sh
├── scripts/common/paths.sh (sourced)
└── .builder/ (read/write)
```

### Data Dependencies

| Consumer | Dependency | Type |
|----------|------------|------|
| build.sh | name-lists/**/*.xml | Source data |
| validate-data.sh | name-lists/**/*.xml | Source data |
| StellarisNameListGenerator | build/merged_*.xml | Intermediate data |
| add_localisation() | out/ui-name-lists/common/name_lists/*.txt | Generated data |
| Steam/Nexus upload | release/ui-name-lists_*.zip | Release artefact |

## Dependency Management

### StellarisNameListGenerator

**Management**: `scripts/update-builder.sh`

```bash
BUILDER_VERSION="v1.2.3"
# Downloads from:
# https://github.com/hmlendea/stellaris-name-list-generator/releases/download/v1.2.3/StellarisNameListGenerator-linux-x64.zip
```

**Cache**: `.builder/StellarisNameListGenerator`

**Update Procedure**:
1. Check GitHub Releases for new version
2. Update `BUILDER_VERSION` in `update-builder.sh`
3. Delete `.builder/` directory
4. Run `./scripts/update-builder.sh`
5. Test with `./scripts/build.sh`
6. Commit changes

### System Dependencies

**Verification** (in build.sh):
```bash
for cmd in curl wget unzip grep awk sed sha256sum find; do
    command -v "$cmd" >/dev/null || { echo "Missing: $cmd"; exit 1; }
done
```

**Ubuntu/Debian**:
```bash
sudo apt update && sudo apt install -y bash curl wget unzip grep gawk sed coreutils findutils
```

**Arch Linux**:
```bash
sudo pacman -S bash curl wget unzip grep gawk sed coreutils findutils
```

**Fedora/RHEL**:
```bash
sudo dnf install bash curl wget unzip grep gawk sed coreutils findutils
```

### GitHub Actions Dependencies

**Pinned Versions** (in workflow files):
```yaml
uses: actions/checkout@v7
uses: actions/upload-artifact@v4
uses: softprops/action-gh-release@v1
uses: hmlendea/steam-workshop-update@v1.0.0
uses: Nexus-Mods/upload-action@v1.0.0-beta.10
```

**Update Procedure**:
1. Check action repositories for new versions
2. Update version pins in workflow files
3. Test in PR
4. Merge

## Compatibility Matrix

| Component | Compatible Versions | Notes |
|-----------|---------------------|-------|
| Stellaris | v4.3.* | Patch wildcard; major version breaks |
| StellarisNameListGenerator | v1.2.x | Semantic versioning; test on update |
| bash | 4.0+ | Uses `set -euo pipefail`, arrays |
| GitHub Actions | ubuntu-latest | Rolling; pin if breaking |
| Steam Workshop API | Current | Via hmlendea/steam-workshop-update |
| Nexus Mods API | Current | Via Nexus-Mods/upload-action |

## Vulnerability Management

### Supply Chain

- **StellarisNameListGenerator**: Built from source in separate repo; binary downloaded from GitHub Releases
- **GitHub Actions**: Pinned to specific versions; review on update
- **System packages**: Managed by CI runner OS (ubuntu-latest)

### Scanning

No automated vulnerability scanning configured. Manual review on dependency updates.

### Update Policy

| Dependency | Update Trigger | Process |
|------------|----------------|---------|
| StellarisNameListGenerator | New release | Test locally, update version pin |
| GitHub Actions | Security advisory or feature | Update pin, test in PR |
| System packages | CI runner update | Automatic via ubuntu-latest |
| Stellaris version | New major release | Update `STELLARIS_VERSION`, test compatibility |

## Dependency Graph

```
┌─────────────────────────────────────────────────────────────┐
│                      Build Pipeline                         │
├─────────────────────────────────────────────────────────────┤
│  scripts/build.sh                                           │
│  ├── source: scripts/common/paths.sh                        │
│  ├── exec: scripts/update-builder.sh                        │
│  │   └── download: GitHub Releases (StellarisNameListGen)  │
│  ├── exec: scripts/validate-data.sh                         │
│  │   ├── read: name-lists/**/*.xml                          │
│  │   ├── network: HTTP HEAD (URL validation)                │
│  │   └── cache: .cache/                                     │
│  ├── loop: for each composition                             │
│  │   ├── merge() → build/merged_*.xml                       │
│  │   ├── exec: .builder/StellarisNameListGenerator         │
│  │   │   ├── read: build/merged_*.xml                       │
│  │   │   └── write: out/ui-name-lists/                      │
│  │   └── add_localisation() → localisation/english/        │
│  ├── generate_mod_descriptor() → descriptor.mod             │
│  └── create_release_archives() → release/*.zip              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Deployment                               │
├─────────────────────────────────────────────────────────────┤
│  GitHub Release ← release/*.zip                             │
│  Steam Workshop ← release/*.zip (via action)                │
│  Nexus Mods ← release/*.zip (via action)                    │
└─────────────────────────────────────────────────────────────┘
```

## Lockfile Equivalent

No formal lockfile. Version pins in:

- `scripts/update-builder.sh` → `BUILDER_VERSION`
- `.github/workflows/*.yml` → action versions
- `scripts/build.sh` → `STELLARIS_VERSION`

To reproduce exact build:
1. Check out specific commit
2. All versions pinned in source
3. Run `./scripts/build.sh`