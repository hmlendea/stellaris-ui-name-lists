# Quick Start

> **Audience**: New contributors, evaluators, first-time builders

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| bash | 4.0+ | System package manager |
| curl | 7.0+ | System package manager |
| wget | 1.20+ | System package manager |
| unzip | 6.0+ | System package manager |
| git | 2.0+ | System package manager |

**OS**: Linux (tested), macOS (should work), Windows (WSL2 recommended)

## 1. Clone Repository

```bash
git clone https://github.com/hmlendea/stellaris-ui-name-lists.git
cd stellaris-ui-name-lists
```

## 2. Run Full Build

```bash
./scripts/build.sh
```

**Expected output** (abbreviated):
```
[INFO] Updating builder...
[INFO] Builder v1.2.3 already present
[INFO] Validating data...
[INFO] Structural validation passed
[INFO] URL validation passed (42/42 OK)
[INFO] Building name lists...
[INFO] Merged: african_names (12 sources)
[INFO] Generated: african_names
...
[INFO] Build complete: out/ui-name-lists/
```

## 3. Verify Output

```bash
# Check mod structure
ls out/ui-name-lists/
# descriptor.mod  common/  localisation/  thumbnail.png

# Count name lists
grep -c "name_list = {" out/ui-name-lists/common/name_lists/00_ui_name_lists.txt
# Should be 40+
```

## 4. Test in Stellaris (Optional)

```bash
# Copy to Stellaris mod directory
cp -r out/ui-name-lists/ ~/.local/share/Paradox\ Interactive/Stellaris/mod/ui-name-lists-test

# Launch Stellaris, enable "Universum Infinitum: Name Lists" in mod launcher
# Create new empire → verify name lists appear in species selection
```

## 5. Run Validation Only

```bash
./scripts/validate-data.sh
```

## 6. Update Generator Binary

```bash
./scripts/update-builder.sh --force
```

## Common Tasks

### Add a New Name List

1. Choose category: `name-lists/real/`, `media/`, `generated/`, or `ui/`
2. Create XML file following schema (see `components/presentation.md`)
3. Add to composition in `scripts/build.sh` (see `components/host-and-composition.md`)
4. Run `./scripts/validate-data.sh`
5. Run `./scripts/build.sh`

### Fix Validation Error

```bash
# Verbose validation
./scripts/validate-data.sh --verbose

# Check specific file
grep -n "pattern" name-lists/real/your_file.xml
```

### Clean Build

```bash
rm -rf build/ out/ release/ .builder/ .cache/
./scripts/build.sh
```

## Directory Structure After Build

```
stellaris-ui-name-lists/
├── name-lists/          # Source (git-tracked)
├── scripts/             # Build automation (git-tracked)
├── build/               # Merged XML (transient)
├── out/
│   └── ui-name-lists/   # Final mod (transient)
├── release/             # Distribution ZIP (transient)
├── .builder/            # Generator binary (cache)
└── .cache/              # URL validation cache
```

## Next Steps

- Read `operations/change-guide.md` for contribution workflow
- Read `components/presentation.md` for XML schema
- Read `components/host-and-composition.md` for composition model
- Read `build-and-deployment.md` for release process