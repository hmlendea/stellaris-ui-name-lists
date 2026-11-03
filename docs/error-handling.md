# Error Handling

## Error Taxonomy

### Validation Errors (V-series)

| Code | Rule | Severity | Recovery |
|------|------|----------|----------|
| V001 | Double NameList tags | Fatal | Fix source XML nesting |
| V002 | Empty Values element | Fatal | Add values or remove group |
| V003 | Empty Value element | Fatal | Add text or remove Value |
| V004 | Multiple Characters elements | Fatal | Keep only one Characters |
| V005 | Url inside Values | Fatal | Move Url to NameList level |
| V006 | Name outside NameGroup | Fatal | Move Name inside NameGroup |
| V007 | Malformed nesting | Fatal | Fix XML hierarchy |
| V008 | Unreachable URL | Fatal | Fix URL or remove Url element |

### Build Errors (B-series)

| Code | Condition | Severity | Recovery |
|------|-----------|----------|----------|
| B001 | Missing source file | Fatal | Fix composition variable path |
| B002 | Merge failure | Fatal | Check source XML well-formedness |
| B003 | Generator non-zero exit | Fatal | Check merged XML; verify builder version |
| B004 | Localisation write failure | Fatal | Check output directory permissions |
| B005 | Descriptor write failure | Fatal | Check output directory permissions |
| B006 | Archive creation failure | Fatal | Check disk space; check zip command |

### Dependency Errors (D-series)

| Code | Condition | Severity | Recovery |
|------|-----------|----------|----------|
| D001 | Builder binary missing | Fatal | Run update-builder.sh |
| D002 | Builder download failure | Fatal | Check network; retry |
| D003 | Builder version mismatch | Warning | Update BUILDER_VERSION |
| D004 | Missing system command | Fatal | Install required package |

### CI/CD Errors (C-series)

| Code | Condition | Severity | Recovery |
|------|-----------|----------|----------|
| C001 | Workflow syntax error | Fatal | Fix YAML |
| C002 | Secret missing | Fatal | Add secret to repository |
| C003 | Upload action failure | Fatal | Retry; check action version |
| C004 | Release asset missing | Fatal | Rebuild; check build.yml |

## Error Handling Patterns

### Fail-Fast (Primary Pattern)

```bash
# In all scripts
set -euo pipefail
# -e: Exit immediately on command failure
# -u: Treat unset variables as error
# -o pipefail: Pipeline fails if any command fails
```

**Rationale**: Prevents cascading errors; surfaces first failure immediately.

### Validation Gate Pattern

```bash
# validate-data.sh
check_rule() {
    if grep -q "$PATTERN" name-lists/; then
        echo "ERROR: Rule violation"
        exit 1
    fi
}

main() {
    check_rule_v001 || exit 1
    check_rule_v002 || exit 1
    # ...
    echo "All validation checks passed"
}
```

**Rationale**: Validation must pass before build proceeds; no partial builds.

### Context Preservation Pattern

```bash
# build.sh
build() {
    local id="$1"
    echo "Building: $id"

    if ! merge "$merged_xml" $sources; then
        echo "FAILED: Merge failed for $id"
        return 1
    fi

    if ! run_generator "$merged_xml"; then
        echo "FAILED: Generation failed for $id"
        return 1
    fi
}
```

**Rationale**: Error messages include composition ID for quick diagnosis.

### Continue-on-Error (Build Loop)

```bash
# build.sh main()
local failed=0
for composition in "${COMPOSITIONS[@]}"; do
    if ! build "$id" "$display_name" "$sources"; then
        failed=1
        # Continue to surface all errors
    fi
done

if [[ $failed -eq 1 ]]; then
    echo "BUILD FAILED: One or more name lists failed"
    exit 1
fi
```

**Rationale**: Surface all failures in one run rather than fixing one at a time.

### Cache-First Pattern (URL Validation)

```bash
# validate-data.sh
check_url() {
    local url="$1"
    local cache_file="$CACHE_DIR/url_$(echo -n "$url" | sha256sum | cut -d' ' -f1)"

    if [[ -f "$cache_file" ]] && [[ $(find "$cache_file" -mtime -7) ]]; then
        cat "$cache_file"  # Cache hit
        return
    fi

    # Cache miss: network request
    if curl -sfI --max-time 10 "$url" >/dev/null; then
        echo "OK" > "$cache_file"
    else
        echo "FAIL" > "$cache_file"
    fi
}
```

**Rationale**: Avoid redundant network calls; prevent CI flakiness from transient network issues.

## Error Messages

### Validation Error Format

```
ERROR: V001 - Double NameList tags found in name-lists/real/african/yoruba.xml:42
```

Components:
- `ERROR` — Severity prefix
- `V001` — Rule code
- Description — What was found
- Location — File and line number

### Build Error Format

```
FAILED: Merge failed for human_extended
  Missing source: name-lists/real/african/yoruba.xml
```

Components:
- `FAILED` — Severity prefix
- Operation — What failed (merge, generate, localise)
- Composition ID — Which name list
- Detail — Specific cause

### Generator Error Format

```
Generator failed for build/merged_human_extended.xml
  [Generator stderr output]
```

Components:
- Context — Which merged file
- Generator stderr — Raw error from StellarisNameListGenerator

## Recovery Procedures

### Validation Failures

| Error | Recovery Steps |
|-------|----------------|
| V001-V007 | Fix source XML in `name-lists/`; re-run `validate-data.sh` |
| V008 (URL) | Verify URL in browser; update or remove `<Url>`; clear `.cache/` |

### Build Failures

| Error | Recovery Steps |
|-------|----------------|
| B001 (missing file) | Check composition variable; verify file exists |
| B002 (merge) | Validate source XML; check for malformed nesting |
| B003 (generator) | Check merged XML manually; verify builder version |
| B004-B005 (write) | `chmod -R u+w out/`; check disk space |
| B006 (archive) | Check disk space; verify zip installed |

### Dependency Failures

| Error | Recovery Steps |
|-------|----------------|
| D001 (builder missing) | Run `./scripts/update-builder.sh` |
| D002 (download fail) | Check network; retry; manual download |
| D003 (version mismatch) | Update `BUILDER_VERSION`; clear `.builder/` |
| D004 (missing command) | Install system package |

### CI/CD Failures

| Error | Recovery Steps |
|-------|----------------|
| C001 (syntax) | Fix YAML; validate locally |
| C002 (secret) | Add secret in repository Settings → Secrets |
| C003 (upload) | Retry workflow; check action version |
| C004 (asset) | Check build.yml; rebuild |

## Error Boundaries

### Script Boundaries

| Boundary | Behaviour |
|----------|-----------|
| `validate-data.sh` | Exits 1 on first validation failure |
| `update-builder.sh` | Exits 1 on download failure |
| `build.sh` | Continues through compositions; exits 1 if any failed |
| CI workflow | Fails job on any non-zero exit |

### Data Boundaries

| Boundary | Behaviour |
|----------|-----------|
| Source XML | Read-only; errors reported, never modified |
| Merged XML | Intermediate; regenerated each build |
| Output directory | Overwritten each build; safe to delete |
| Cache directories | Append-only; safe to delete |

## Monitoring and Alerting

### CI Status

- **GitHub Actions badge** in README shows build status
- **Workflow runs** visible in GitHub UI
- **Failure notifications** via GitHub (if configured)

### Build Duration

- **Normal**: ~3-5 minutes (CI), ~30 seconds (local incremental)
- **Degraded**: >10 minutes indicates network or generator issues
- **Monitoring**: GitHub Actions job duration metric

### URL Validation

- **Cache hit rate**: `ls .cache/ | wc -l` vs unique URLs
- **Failure rate**: Count FAIL files in `.cache/`
- **Monitoring**: Manual review of validation output

## Debugging Techniques

### Enable Verbose Output

```bash
# Add -x to shebang or run with bash -x
bash -x ./scripts/build.sh 2>&1 | tee build-debug.log
```

### Inspect Intermediate Files

```bash
# Merged XML
cat build/merged_human_extended.xml

# Generator output (before localisation)
cat out/ui-name-lists/common/name_lists/00_ui_name_lists.txt

# Cache state
ls -la .cache/
cat .cache/url_*
```

### Isolate Single Composition

```bash
# Edit build.sh temporarily: comment out all but one build() call
# Or run merge manually:
./scripts/build.sh  # Fails at specific composition
# Check build/merged_<id>.xml for the failing composition
```

### Test Generator Directly

```bash
.builder/StellarisNameListGenerator \
    --input build/merged_human_extended.xml \
    --output /tmp/test-output/common/name_lists \
    --localisation /tmp/test-output/localisation/english \
    --mod-name "Test" \
    --mod-version "test"
```

## Error Prevention

### Pre-Commit Checks

```bash
# Run validation before committing
./scripts/validate-data.sh

# Run full build before pushing
./scripts/build.sh
```

### CI Gates

- **PR gate**: `build.yml` runs on all PRs; merge blocked on failure
- **Master gate**: `build.yml` runs on all pushes to master
- **Release gate**: Deployment workflows only trigger on valid tags

### Code Review Checklist

- [ ] XML follows schema (see `docs/components/presentation.md`)
- [ ] Attribution URLs present and reachable
- [ ] Composition variables updated if new sources added
- [ ] No duplicate name list IDs
- [ ] Species type matches target composition