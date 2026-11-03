# Troubleshooting

> **Audience**: Developers encountering build, validation, or deployment issues

## Quick Diagnosis

| Symptom | Likely Cause | First Check |
|---------|--------------|-------------|
| `validate-data.sh` fails | XML syntax error | Run with `--verbose` |
| URL validation fails | Dead attribution link | Check URL in browser |
| `build.sh` fails early | Missing dependency | Run `./scripts/update-builder.sh` |
| Generator crashes | Invalid merged XML | Check `build/merged_*.xml` |
| Output missing name lists | Composition variable empty | Check `scripts/build.sh` |
| Steam deploy fails | Auth secrets wrong | Verify GitHub secrets |
| Nexus deploy fails | API key invalid | Regenerate API key |

## Validation Issues

### Structural Validation Failures

**Error**: `V001: Double opening/closing tags found`

```bash
# Find the file
grep -rn "<NameList><NameList>" name-lists/
grep -rn "</NameList></NameList>" name-lists/

# Fix: Remove duplicate tag
```

**Error**: `V002: Empty tags found`

```bash
# Find empty tags
grep -rn "<Value></Value>" name-lists/
grep -rn "<Name></Name>" name-lists/

# Fix: Add content or remove tag
```

**Error**: `V003: Multiple Characters elements`

```bash
# Check for nested NameGroup
grep -B5 -A5 "Characters" name-lists/**/*.xml

# Fix: Ensure single NameGroup per NameList
```

**Error**: `V004: Url in Values`

```bash
# Find URLs in Value elements
grep -rn "<Value>http" name-lists/

# Fix: Move URL to <Url> element
```

**Error**: `V005: Name outside NameGroup`

```bash
# Find Name not in NameGroup
grep -B10 "<Name>" name-lists/**/*.xml | grep -v "NameGroup"

# Fix: Wrap in NameGroup
```

**Error**: `V006: Malformed nesting`

```bash
# Check XML well-formedness
xmllint --noout name-lists/**/*.xml 2>&1 | grep -v "^$"

# Fix: Correct nesting
```

**Error**: `V007: Missing required elements`

```bash
# Check each NameList has all required
for f in name-lists/**/*.xml; do
    echo "=== $f ==="
    grep -c "<Name>" "$f"
    grep -c "<DisplayName>" "$f"
    grep -c "<SpeciesClass>" "$f"
    grep -c "<Url>" "$f"
    grep -c "<NameGroup>" "$f"
done
```

### URL Validation Failures

**Error**: `URL validation failed for: https://example.com`

```bash
# Test manually
curl -sfI --max-time 10 "https://example.com"

# Common causes:
# - 404: Page moved → update URL
# - 403: Blocked → find alternative source
# - Timeout: Slow server → may pass on retry
# - DNS: Domain expired → find new source

# Clear cache and retry
rm .cache/url_*
./scripts/validate-data.sh --no-cache
```

**Cache Issues**

```bash
# Stale cache
rm -rf .cache/
./scripts/validate-data.sh

# Corrupted cache entry
rm .cache/url_<hash>
./scripts/validate-data.sh
```

## Build Issues

### Generator Not Found

```bash
# Error: StellarisNameListGenerator not found
./scripts/update-builder.sh

# If version mismatch
./scripts/update-builder.sh --force
```

### Generator Crashes

```bash
# Run generator manually for debugging
.builder/StellarisNameListGenerator \
    --input build/merged_african_names.xml \
    --output /tmp/test_out \
    --localisation /tmp/test_loc \
    --mod-name "Test" \
    --mod-version "1.0.0"

# Check input XML
xmllint --noout build/merged_african_names.xml
```

### Composition Variable Empty

```bash
# Check variable definition in build.sh
grep "AFRICAN_NAMELISTS=" scripts/build.sh

# Should be like:
AFRICAN_NAMELISTS="name-lists/real/african.xml name-lists/generated/african_extra.xml"

# Verify files exist
ls $AFRICAN_NAMELISTS
```

### Permission Denied

```bash
# Generator not executable
chmod +x .builder/StellarisNameListGenerator

# Output directory permissions
mkdir -p out/ui-name-lists/common/name_lists
mkdir -p out/ui-name-lists/localisation/english
```

### Disk Space

```bash
# Check space
df -h .

# Clean transient directories
rm -rf build/ out/ release/
```

## Deployment Issues

### Steam Workshop

| Error | Resolution |
|-------|------------|
| `Authentication failed` | Check `STEAM_USERNAME`, `STEAM_PASSWORD`, `STEAM_2FA_SEED` |
| `Item not found` | Verify `itemid` in workflow matches workshop item |
| `File too large` | Check ZIP size < 1GB (Steam limit) |
| `Rate limited` | Wait and retry; don't spam deployments |

### Nexus Mods

| Error | Resolution |
|-------|------------|
| `Invalid API key` | Regenerate at Nexus Mods account settings |
| `File ID not found` | Verify `file_id` in workflow |
| `Version format` | Use semantic version (v1.2.3) |
| `Category invalid` | Use valid category (main, optional, etc.) |

### GitHub Release

| Error | Resolution |
|-------|------------|
| `Asset upload failed` | Check workflow permissions; file size < 2GB |
| `Tag already exists` | Delete tag locally and remote, re-push |
| `Release not created` | Check `softprops/action-gh-release` version |

## CI/CD Issues

### Workflow Stuck

```bash
# Check GitHub Actions status
# - Runner queue full? Wait.
# - Concurrency cancelling? Check concurrency group.
# - Timeout? Default 6 hours.
```

### Secrets Not Available

```bash
# Secrets only available in:
# - Same repository (not forks)
# - Protected branches (for environment secrets)
# - Not in PR from fork (security)

# Test: Add debug step (remove after)
# - name: Debug secrets
#   run: echo "STEAM_USERNAME=${{ secrets.STEAM_USERNAME }}"
```

### Action Version Deprecated

```bash
# Update pinned version in workflow
# Old: uses: actions/checkout@v3
# New: uses: actions/checkout@v7

# Check: https://github.com/actions/checkout/releases
```

## Stellaris Compatibility Issues

### Mod Not Loading

```bash
# Check descriptor.mod
cat out/ui-name-lists/descriptor.mod

# Verify:
# - supported_version matches game version
# - name matches folder name
# - no syntax errors
```

### Name Lists Not Appearing

```bash
# Check generated output
grep "name_list = {" out/ui-name-lists/common/name_lists/00_ui_name_lists.txt

# Verify species_class matches empire species
# Check localisation keys exist
grep "l_english:" out/ui-name-lists/localisation/english/*.yml
```

### Game Crashes on Mod Enable

```bash
# Check Stellaris log
# ~/.local/share/Paradox Interactive/Stellaris/logs/error.log

# Common causes:
# - Duplicate name_list keys
# - Invalid species_class value
# - Malformed localisation (missing quotes)
# - Encoding issues (must be UTF-8)
```

## Debugging Techniques

### Verbose Build

```bash
# Enable debug in build.sh temporarily
set -x  # At top of build.sh after shebang
./scripts/build.sh
set +x
```

### Inspect Intermediate Files

```bash
# Merged XML
cat build/merged_african_names.xml | head -100

# Generator output
ls -la out/ui-name-lists/common/name_lists/
ls -la out/ui-name-lists/localisation/english/
```

### Dry Run Validation

```bash
# Check what would be validated
./scripts/validate-data.sh --verbose 2>&1 | head -50
```

### Binary Search for Breaking Change

```bash
# If build broke after commit X
git bisect start
git bisect bad HEAD
git bisect good <last-known-good>
# Run build.sh at each step
git bisect reset
```

## Getting Help

1. **Check this guide** for matching symptom
2. **Search GitHub Issues** for similar problems
3. **Open new Issue** with:
   - Error message (full)
   - Steps to reproduce
   - `./scripts/validate-data.sh --verbose` output
   - `./scripts/build.sh` output (last 50 lines)
   - OS and tool versions
4. **Tag maintainer** @hmlendea