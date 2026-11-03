# Concurrency and Scheduling

## Concurrency Model

This project uses **sequential execution** with no explicit concurrency primitives. All operations run in a single bash process.

## Execution Model

### Build Pipeline (Sequential)

```
main()
  ├── update-builder.sh (sequential)
  ├── validate-data.sh (sequential)
  ├── for each composition (sequential loop)
  │     ├── merge() (sequential)
  │     ├── StellarisNameListGenerator (sequential, external process)
  │     └── add_localisation() (sequential)
  ├── generate_mod_descriptor() (sequential)
  └── create_release_archives() (sequential)
```

### No Parallelism

- **No background jobs** (`&`)
- **No GNU parallel**
- **No subprocess pooling**
- **Single-threaded** by design

**Rationale**:
- Simplicity — easier to debug and reason about
- Determinism — same output every run
- Resource constraints — CI runners have limited cores
- Generator is CPU-intensive; parallel runs would contend

## Scheduling

### Build Trigger Schedule

| Trigger | Schedule | Workflow |
|---------|----------|----------|
| Push to master | Immediate | build.yml |
| Pull request | Immediate | build.yml |
| Tag push (v*.*.*) | Immediate | steam-workshop.yml, nexus-mods.yml |
| Manual dispatch | On demand | nexus-mods.yml |
| Scheduled | None configured | — |

### No Cron Jobs

- No scheduled builds
- No nightly validation
- No dependency update checks

## Resource Management

### Process Limits

| Resource | Limit | Notes |
|----------|-------|-------|
| CPU | 1 core | Single-threaded |
| Memory | ~100 MB | Generator + bash |
| Disk | ~500 MB | Build output + cache |
| Network | ~10 MB | Builder download + URL checks |
| File descriptors | Default | No explicit limits |

### Generator Resource Usage

StellarisNameListGenerator (external process):
- **CPU**: High during generation (~30-60s per composition)
- **Memory**: ~50-100 MB
- **Disk I/O**: Reads merged XML, writes output files

## Locking and Synchronisation

### No Explicit Locks

- **No flock**, no mutex, no semaphores
- **Single process** — no contention possible
- **Cache directories** — per-runner isolation in CI

### Cache Concurrency

- **Local**: Single user, no conflict
- **CI**: Each runner has own `.builder/` and `.cache/`
- **No shared cache** between concurrent workflow runs

## Async Operations

### None in Build Scripts

All operations are synchronous:
- `curl` with `--max-time` (blocking)
- `wget` (blocking)
- `unzip` (blocking)
- Generator execution (blocking)

### CI Async

GitHub Actions runs workflows asynchronously:
- Multiple workflow runs can execute concurrently
- Each run isolated in own runner
- No shared state between runs

## Timeout Handling

### Network Timeouts

```bash
# URL validation
curl -sfI --max-time 10 "$url"

# Builder download
wget --timeout=30 "$BUILDER_URL"
```

### No Build Timeout

- Build runs to completion
- CI has default 6-hour timeout (GitHub Actions)
- Typical build: 3-5 minutes

## Scaling Considerations

### Current Scale

- ~50 name list compositions
- ~200 source XML files
- ~50,000 total name values
- Build time: ~3-5 minutes CI, ~30s local incremental

### Scaling Bottlenecks

| Bottleneck | Current | Mitigation |
|------------|---------|------------|
| Generator CPU | Sequential | Could parallelise compositions |
| URL validation | Sequential + cache | Cache hits mitigate |
| Disk I/O | Sequential | SSD runners help |

### Potential Parallelisation

If build time becomes problematic:

```bash
# Parallel composition builds (conceptual)
for composition in "${COMPOSITIONS[@]}"; do
    build "$id" "$display_name" "$sources" &
done
wait
```

**Challenges**:
- Generator writes to shared `out/` directory (conflicts)
- Would need per-composition output dirs + merge step
- Localisation file append conflicts
- Complexity not justified at current scale

## Scheduling in CI

### Workflow Concurrency

```yaml
# build.yml
concurrency:
  group: build-${{ github.ref }}
  cancel-in-progress: true
```

- Cancels previous run on same ref
- Prevents queue buildup on rapid pushes

### Deployment Concurrency

```yaml
# steam-workshop.yml, nexus-mods.yml
concurrency:
  group: deploy-${{ github.ref }}
  cancel-in-progress: false
```

- Deployments not cancelled (idempotent)
- Tag pushes are immutable

## Future Considerations

- [ ] Add build timeout safeguard
- [ ] Consider GitHub Actions cache for `.builder/` and `.cache/`
- [ ] Evaluate parallel composition builds if scale increases
- [ ] Add resource monitoring (CPU, memory, disk) to CI