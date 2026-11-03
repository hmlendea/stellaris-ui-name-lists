# Frequently Asked Questions

> **Audience**: Contributors, users, evaluators

## General

### What is this project?

A Stellaris mod that adds 50+ curated name lists for empire, ship, planet, fleet, leader, and army naming. Sources include real-world cultures, fictional universes, and procedural generators.

### What Stellaris version is supported?

`v4.3.*` (declared in `descriptor.mod`). Major version changes (v5.x) will require updates.

### Is this a code mod or data mod?

**Data-only mod**. No C#, no DLLs, no runtime code. Pure XML → text/yml transformation.

### Who maintains this?

@hmlendea (Horatiu Lendea). See `CODE_OF_CONDUCT.md` for community standards.

## Building

### Do I need .NET / C# to build?

No. The C# generator (`StellarisNameListGenerator`) is downloaded as a pre-built binary. You only need bash, curl, wget, unzip.

### Why does the build download a binary?

The generator is a separate project (hmlendea/stellaris-name-list-generator). Pinning a binary ensures reproducible builds without requiring .NET SDK.

### Can I build on Windows?

Yes, via WSL2. Native Windows (PowerShell/CMD) not supported — scripts use bashisms.

### How long does a build take?

- **Clean**: ~3-5 minutes (CI), ~30-60s (local with cache)
- **Incremental**: ~10-20s (only changed compositions rebuild)

### What is the `.builder/` directory?

Cached `StellarisNameListGenerator` binary. Safe to delete; re-downloaded on next build.

### What is the `.cache/` directory?

URL validation results (7-day TTL). Safe to delete; re-validated on next build.

## Name Lists

### How many name lists are included?

~50 final compositions, each merging 1-20 source XML files. Total ~50,000+ name values.

### Can I add my own name list?

Yes. See `operations/change-guide.md` → "Adding a Name List".

### What categories exist?

| Category | Directory | Examples |
|----------|-----------|----------|
| Real-world | `name-lists/real/` | African, Arabic, Chinese, European |
| Media | `name-lists/media/` | Elder Scrolls, Star Wars, D&D, Warhammer |
| Generated | `name-lists/generated/` | Procedural fantasy, sci-fi |
| UI | `name-lists/ui/` | Thematic (demon, goblin, lizard, etc.) |

### What species classes are supported?

All vanilla classes: HUMANOID, FUNGUS, MAMMALIAN, REPTILIAN, AVIAN, ARTHROPOID, MOLLUSCOID, PLANTOID, LITHOID, MACHINE, TOXOID.

### Why are some name lists "UI" prefixed?

`ui_` prefix = procedural/thematic generators (not real-world or media). E.g., `ui_demon`, `ui_elven`, `ui_fantasy_spider`.

## Validation

### Why does validation check URLs?

Attribution requirement. Every name list must have a reachable `<Url>` for credit/license verification.

### What if a URL dies?

Validation fails. Options:
1. Find new URL for same source
2. Remove name list if no alternative
3. Archive URL via Wayback Machine

### Can I skip URL validation?

```bash
# Not recommended, but for development:
./scripts/validate-data.sh --no-cache  # Still validates, no cache
# To truly skip: comment out URL validation in validate-data.sh
```

### What are the structural validation rules?

See `flows/detail-mutation.md` → V001-V007:
- No duplicate tags
- No empty tags
- Single NameGroup per NameList
- No URLs in Value elements
- Name inside NameGroup
- Well-formed nesting
- All required elements present

## Deployment

### How do I release a new version?

```bash
git tag -a v1.2.4 -m "Release v1.2.4"
git push origin v1.2.4
```

Triggers automated Steam + Nexus deployment.

### Can I deploy manually?

Yes. Download release asset from GitHub, upload to Steam Workshop / Nexus Mods manually.

### What if deployment fails?

Check `build-and-deployment.md` → "Rollback Procedures". Common: secret rotation needed.

### Why two deployment workflows?

- `steam-workshop.yml`: Steam Workshop (requires Steam credentials)
- `nexus-mods.yml`: Nexus Mods (requires API key)
- Separate for security (least privilege) and independent failure

## Contributing

### Do you accept PRs?

Yes. See `CONTRIBUTING.md` and `operations/change-guide.md`.

### What's the review process?

1. CI passes (validation + build)
2. Maintainer review
3. Merge to master
4. Tag for release (optional, per maintainer)

### Can I add a name list from [game/book/movie]?

If:
- Source is publicly attributable (URL)
- License permits reuse (or fair use for names)
- Fits species class
- Not duplicate of existing

Then yes. Add attribution URL.

### Do you need translators?

Localisation is English only. Stellaris handles translation via its own system. Contributions for other languages would be separate mod.

## Technical

### How does the generator work?

Black box. Takes merged XML, outputs Stellaris-format name lists + localisation. See `integrations.md` for interface.

### Can I use the generator separately?

Yes. Download from hmlendea/stellaris-name-list-generator releases. MIT licensed.

### Why bash and not Python/Node?

- Zero dependencies (bash ubiquitous)
- Simple pipeline orchestration
- Easy to read and modify
- CI runners have bash by default

### Is there a test suite?

No automated tests beyond validation + build integrity. See `testing.md` for strategy.

### How do I debug a failing build?

See `operations/troubleshooting.md`.

## Licensing

### What license?

Code: GPL-3.0 (see `LICENSE`).
Name lists: Attribution via `<Url>` (various).
Generator: MIT (separate repo).

### Can I use this in my mod?

Yes, GPL-3.0 applies. Provide attribution, share changes.

### Can I bundle with other mods?

Yes, as dependency or merged. GPL-3.0 requires combined work be GPL-3.0 compatible.

## Support

### Where do I report bugs?

GitHub Issues.

### Where do I ask questions?

GitHub Discussions.

### Is there a Discord?

No. GitHub only.

### Response time?

Best effort. Maintainer is single person with day job.