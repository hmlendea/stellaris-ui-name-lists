# Testing

## Test Strategy

This project is a data transformation pipeline with no traditional unit-testable code. Testing focuses on:

1. **Validation correctness** — Structural and semantic validation rules
2. **Build integrity** — Pipeline produces valid Stellaris mod output
3. **Data quality** — Name lists are well-formed, attributed, and diverse
4. **Compatibility** — Output loads in target Stellaris version

## Test Organisation

### Validation Tests (Automated)

**Location**: `scripts/validate-data.sh` (self-testing via exit codes)

| Test | Method | Success Criteria |
|------|--------|------------------|
| Structural rules V001-V007 | grep patterns | Exit code 0 |
| URL reachability | curl HEAD + cache | All URLs return 2xx |
| No regressions | Compare name list count | Count ≥ expected minimum |

**Execution**:
```bash
./scripts/validate-data.sh
# Exit 0 = pass, Exit 1 = fail
```

### Build Tests (Automated)

**Location**: `.github/workflows/build.yml`

| Test | Method | Success Criteria |
|------|--------|------------------|
| Clean build | `./scripts/build.sh` | Exit code 0 |
| Output structure | Directory/file checks | All required paths exist |
| Name list count | grep on output | ≥ 40 name lists |
| Descriptor validity | Parse descriptor.mod | Required fields present |

**Execution**: Automatic on push/PR to master.

### Integration Tests (Manual)

| Test | Method | Frequency |
|------|--------|-----------|
| Stellaris load test | Copy to mod dir, launch game | Per release |
| Name list selection | Create empire, verify names | Per release |
| Localisation display | Check in-game text | Per release |
| Multi-mod compatibility | Enable with other mods | Per major release |

## Coverage

### Validation Coverage

| Rule | Covered | Notes |
|------|---------|-------|
| V001 Double tags | ✅ | grep pattern |
| V002 Empty Values | ✅ | grep pattern |
| V003 Empty Value | ✅ | grep pattern |
| V004 Multiple Characters | ✅ | grep pattern |
| V005 Url in Values | ✅ | grep pattern |
| V006 Name outside NameGroup | ✅ | Complex grep |
| V007 Malformed nesting | ✅ | Multiple patterns |
| URL reachability | ✅ | curl + cache |

### Build Coverage

| Aspect | Covered | Notes |
|--------|---------|-------|
| All compositions build | ✅ | 50+ name lists |
| Merge correctness | ✅ | Generator validates |
| Localisation completeness | ✅ | add_localisation() |
| Descriptor generation | ✅ | generate_mod_descriptor() |
| Archive creation | ✅ | create_release_archives() |

### Data Quality Coverage

| Aspect | Covered | Method |
|--------|---------|--------|
| Attribution URLs | ✅ | validate-data.sh |
| No duplicate values | ✅ | Generator deduplicates |
| Species type validity | ✅ | Generator validates |
| Required groups present | ⚠️ | Manual review |

## Test Data

### Test Fixtures

No dedicated test fixtures. The `name-lists/` directory serves as both source and test data.

### Synthetic Test Cases

For validation rule verification:

```bash
# Test V001 (double tags)
echo '<NameList><NameList></NameList></NameList>' | ./scripts/validate-data.sh
# Should fail

# Test V002 (empty Values)
echo '<NameList><NameGroup><Values></Values></NameGroup></NameList>' | ./scripts/validate-data.sh
# Should fail
```

## Running Tests

### Local Validation Only

```bash
./scripts/validate-data.sh
```

### Local Full Build Test

```bash
rm -rf build/ out/ .builder/ .cache/
./scripts/build.sh
# Verify output
ls -la out/ui-name-lists/
```

### CI Simulation

```bash
# Mimic CI environment
export GITHUB_REF_NAME="v1.2.3-test"
./scripts/validate-data.sh && ./scripts/build.sh
```

### Stellaris Integration Test

```bash
# 1. Build
./scripts/build.sh

# 2. Install to Stellaris mod directory
MOD_DIR="$HOME/.local/share/Paradox Interactive/Stellaris/mod"
cp -r out/ui-name-lists/ "$MOD_DIR/ui-name-lists-test"

# 3. Create descriptor.mod in mod dir (Stellaris reads from there)
cp out/ui-name-lists/descriptor.mod "$MOD_DIR/ui-name-lists-test/"

# 4. Launch Stellaris, enable mod, create empire
# 5. Verify name lists appear and function
```

## Continuous Integration

### GitHub Actions (`.github/workflows/build.yml`)

```yaml
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - name: Validate
        run: ./scripts/validate-data.sh

  build:
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - name: Build
        run: ./scripts/build.sh
      - name: Verify output
        run: |
          test -f out/ui-name-lists/descriptor.mod
          test -d out/ui-name-lists/common/name_lists
          test -d out/ui-name-lists/localisation/english
          COUNT=$(grep -c "name_list = {" out/ui-name-lists/common/name_lists/00_ui_name_lists.txt)
          test $COUNT -gt 40
      - uses: actions/upload-artifact@v4
        with:
          name: ui-name-lists
          path: release/ui-name-lists_*.zip
```

### Deployment Workflows

- `steam-workshop.yml` — Tests Steam upload on tag
- `nexus-mods.yml` — Tests Nexus upload on tag

## Test Maintenance

### Adding Validation Rules

1. Add check function to `validate-data.sh`
2. Add to `main()` execution chain
3. Test with known-good and known-bad XML
4. Document in `docs/flows/detail-mutation.md`

### Adding Build Verification

1. Add check to `build.sh` after relevant step
2. Or add to CI workflow `Verify output` step
3. Ensure failure exits non-zero

### Updating Expected Counts

When adding name lists, update minimum count in CI:

```yaml
# In build.yml
COUNT=$(grep -c "name_list = {" ...)
test $COUNT -gt 50  # Update from 40
```

## Known Test Gaps

| Gap | Impact | Mitigation |
|-----|--------|------------|
| No unit tests for merge() | Logic errors possible | Manual review of merged XML |
| No generator output validation | Invalid Stellaris format | Integration test in game |
| No localisation completeness check | Missing translations | Manual spot-check |
| No performance benchmarks | Regressions undetected | CI duration monitoring |
| No cross-mod compatibility test | Conflicts possible | Manual testing per release |

## Future Improvements

- [ ] Add schema validation for generated output
- [ ] Implement localisation completeness check
- [ ] Add performance benchmark tracking
- [ ] Create automated Stellaris load test (headless)
- [ ] Add name list diversity metrics (unique names per list)