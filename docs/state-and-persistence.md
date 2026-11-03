# State and Persistence

## State Management Overview

This project is a **stateless data transformation pipeline**. There is no runtime state, no database, and no persistent service. State exists only as files on disk during and after the build process.

## State Categories

### Source State (Authoritative)

| Location | Content | Mutability | Persistence |
|----------|---------|------------|-------------|
| `name-lists/**/*.xml` | Name list definitions | Via PR | Git (permanent) |
| `scripts/*.sh` | Build automation | Via PR | Git (permanent) |
| `.github/workflows/*.yml` | CI/CD config | Via PR | Git (permanent) |
| `thumbnail.png` | Mod thumbnail | Via PR | Git (permanent) |

### Build State (Transient)

| Location | Content | Lifetime | Regeneration |
|----------|---------|----------|--------------|
| `build/merged_*.xml` | Merged XML per composition | Single build | Each build |
| `out/ui-name-lists/` | Final mod output | Until clean | Each build |
| `release/*.zip` | Distribution archives | Until clean | Each build |

### Cache State (Persistent, Recreatable)

| Location | Content | Lifetime | Invalidation |
|----------|---------|----------|--------------|
| `.builder/StellarisNameListGenerator` | Generator binary | Until version change | Delete dir or version bump |
| `.cache/url_*` | URL validation results | 7 days (TTL) | Delete dir or TTL expiry |

## Persistence Mechanisms

### Git (Primary)

- **All source state** stored in Git repository
- **History** provides full audit trail
- **Branches/PRs** enable collaborative editing
- **Tags** mark releases

### File System (Build Output)

- **Build output** written to `out/` and `release/`
- **Not committed** (in `.gitignore`)
- **Regenerated** on every build
- **Artefacts** uploaded to GitHub Releases

### Cache Directories

```
.builder/
└── StellarisNameListGenerator  # ~50 MB binary

.cache/
├── url_a1b2c3d4...  # Contains "OK" or "FAIL"
├── url_e5f6g7h8...
└── ...
```

**Cache Invalidation**:
- `.builder/`: Delete directory or update `BUILDER_VERSION`
- `.cache/`: Delete directory or wait 7 days

## Data Flow and State Transitions

```
Git (source)
    │
    ▼
validate-data.sh (reads name-lists/, writes .cache/)
    │
    ▼
build.sh (reads name-lists/, .builder/, writes build/, out/, release/)
    │
    ▼
GitHub Release (reads release/, writes release assets)
    │
    ▼
Deployment (reads GitHub Release, writes to Steam/Nexus)
```

## State Consistency

### Validation Ensures

- Source XML well-formed (structural rules)
- Attribution URLs reachable (semantic rules)
- No corrupted source state enters pipeline

### Build Ensures

- Deterministic output from given source + builder version
- Clean build = delete `build/`, `out/`, `release/` first
- Incremental build safe (overwrites output)

### Cache Consistency

- URL cache keyed by SHA256(URL) — collision resistant
- TTL prevents stale results
- Cache miss = network request = fresh result

## Migration Procedures

### Schema Changes (XML)

No formal migration — XML schema is stable. If StellarisNameListGenerator changes:
1. Update `BUILDER_VERSION`
2. Test build
3. Fix any source XML incompatibilities
4. Commit

### Cache Format Changes

Cache format is simple (`OK`/`FAIL` text). If changed:
1. Delete `.cache/`
2. Re-run validation

### Builder Binary Changes

1. Update `BUILDER_VERSION` in `update-builder.sh`
2. Delete `.builder/`
3. Run `./scripts/update-builder.sh`
4. Test build

## Backup and Recovery

### Source State

- **Backup**: Git repository (distributed)
- **Recovery**: `git clone` from any remote

### Build State

- **Backup**: Not needed (regeneratable)
- **Recovery**: `./scripts/build.sh`

### Cache State

- **Backup**: Not needed (regeneratable)
- **Recovery**: Automatic on next build

## Concurrency Considerations

### Local Development

- Single-user: No conflicts
- Multiple terminals: Safe (separate `build/` dirs if needed)

### CI/CD

- **GitHub Actions**: Each run isolated (fresh runner)
- **Concurrent workflows**: Independent (separate workspaces)
- **Cache**: Per-runner (not shared)

### Cache Sharing

- **No shared cache** between runs
- Each runner populates own `.builder/` and `.cache/`
- Acceptable overhead (builder ~10s download, URLs ~1s each)

## Monitoring State Health

### Indicators

| Indicator | Healthy | Degraded |
|-----------|---------|----------|
| Git status | Clean working tree | Uncommitted changes |
| Build output | `out/` exists, >40 name lists | Missing or incomplete |
| Cache hit rate | >80% | <50% (network issues) |
| Builder present | `.builder/StellarisNameListGenerator` exists | Missing (re-download) |

### Checks

```bash
# Source state
git status

# Build state
ls -la out/ui-name-lists/
grep -c "name_list = {" out/ui-name-lists/common/name_lists/00_ui_name_lists.txt

# Cache state
ls .cache/ | wc -l
ls .builder/
```

## Future State Considerations

- [ ] Add build manifest (JSON) with composition metadata
- [ ] Implement incremental build detection (mtime-based)
- [ ] Add output checksums for reproducibility verification
- [ ] Consider shared cache for CI (GitHub Actions cache action)