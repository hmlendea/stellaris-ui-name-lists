# Logging

## Logging Framework

This project uses **structured console output** via bash `echo` statements. There is no external logging library or framework.

## Log Levels

| Level | Prefix | Use Case |
|-------|--------|----------|
| INFO | (none) | Normal progress, build steps |
| SUCCESS | `SUCCESS:` | Completed composition |
| WARNING | `WARNING:` | Non-fatal issues (rare) |
| ERROR | `ERROR:` / `FAILED:` | Fatal errors, validation failures |
| DEBUG | `DEBUG:` | Verbose output (opt-in via `bash -x`) |

## Structured Fields

Log lines follow consistent patterns for parseability:

```
Building: human_extended
SUCCESS: Human - Extended
FAILED: Merge failed for human_arabic
  Missing source: name-lists/real/arabic/missing.xml
ERROR: V001 - Double NameList tags found in name-lists/real/african/yoruba.xml:42
```

### Field Conventions

| Field | Format | Example |
|-------|--------|---------|
| Composition ID | `human_extended` | Lowercase, underscores |
| Display Name | `Human - Extended` | Title case, spaces |
| File Path | `name-lists/real/african/yoruba.xml` | Relative to repo root |
| Line Number | `:42` | Suffix on file path |
| Rule Code | `V001` | Validation rule identifier |

## Output Streams

| Stream | Content |
|--------|---------|
| stdout | Normal progress, success messages |
| stderr | Errors, warnings, validation failures |

**CI Capture**: GitHub Actions captures both streams; failures appear in job log.

## Correlation

No distributed tracing or correlation IDs. Each build is a single linear process.

### Build Identification

- **Local**: No ID (terminal session)
- **CI**: GitHub Actions run ID + commit SHA
- **Release**: Git tag (`v1.2.3`)

## Sinks

| Sink | Configuration | Retention |
|------|---------------|-----------|
| Console (stdout/stderr) | Default | Session only |
| GitHub Actions log | Automatic | 90 days (default) |
| Release artefact log | Manual upload on failure | Until release deleted |

## Log Samples

### Successful Build

```
Building: human_african
SUCCESS: Human - African
Building: human_arabic
SUCCESS: Human - Arabic
Building: human_extended
SUCCESS: Human - Extended
...
Generating mod descriptor
Creating release archive
Build complete
```

### Validation Failure

```
ERROR: V001 - Double NameList tags found in name-lists/real/african/yoruba.xml:42
```

### Build Failure

```
Building: human_extended
FAILED: Merge failed for human_extended
  Missing source: name-lists/real/african/new_culture.xml
Building: human_arabic
SUCCESS: Human - Arabic
BUILD FAILED: One or more name lists failed
```

### URL Validation

```
Checking URL: https://en.wikipedia.org/wiki/Yoruba_name
  OK (cached)
Checking URL: https://example.com/broken
  FAIL
ERROR: V008 - Unreachable URL: https://example.com/broken
```

## Debug Logging

Enable verbose execution trace:

```bash
bash -x ./scripts/build.sh 2>&1 | tee debug.log
```

Output includes every command with expanded variables.

## Log Redaction

No sensitive data is logged:
- No secrets (API keys, passwords)
- No personal data
- URLs are public attribution links

## Performance Logging

No automatic timing. CI job duration serves as build time metric.

### Manual Timing

```bash
time ./scripts/build.sh
# real    2m45.321s
# user    1m12.456s
# sys     0m23.789s
```

## Log Analysis

### Common Queries

```bash
# Count successful compositions
grep -c "SUCCESS:" build.log

# Count failures
grep -c "FAILED:" build.log

# List failed compositions
grep "FAILED:" build.log | sed 's/.*for //'

# Validation errors
grep "ERROR: V" build.log
```

### CI Log Access

```bash
# Via GitHub CLI
gh run view <run-id> --log

# Via API
curl -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/owner/repo/actions/runs/<run-id>/logs"
```

## Future Improvements

- [ ] Add timestamps to log lines
- [ ] Add build duration summary
- [ ] Structured JSON output option for CI parsing
- [ ] Log aggregation for historical trend analysis