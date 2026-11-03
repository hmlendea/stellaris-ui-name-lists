# Design Decisions

## Architectural Style: Data Transformation Pipeline

**Decision**: Implement the system as a linear data transformation pipeline with an integrated validation gate.

**Rationale**:
- The core operation is transforming XML source definitions into Stellaris mod format
- Pipeline stages (validate → merge → generate → package) map naturally to shell script functions
- Fail-fast validation prevents wasting time on downstream generation with bad input
- Shell scripts provide zero-dependency orchestration suitable for CI environments

**Alternatives Considered**:
- **Make-based build** — Rejected: overkill for linear pipeline; shell functions are simpler
- **Python orchestration** — Rejected: adds runtime dependency; bash is universally available
- **C# application** — Rejected: would duplicate StellarisNameListGenerator functionality

## External Dependency: StellarisNameListGenerator Binary

**Decision**: Consume StellarisNameListGenerator as a downloaded binary rather than building from source or using a NuGet package.

**Rationale**:
- StellarisNameListGenerator is a separate project (hmlendea/stellaris-name-list-generator) with its own release cycle
- Binary download via GitHub Releases is simple, versioned, and cacheable
- Avoids requiring .NET SDK in the build environment (only runtime needed)
- The generator is a black box — we only need its CLI interface

**Alternatives Considered**:
- **Git submodule + build** — Rejected: adds build complexity and .NET SDK requirement
- **NuGet package** — Rejected: not published as NuGet; would require private feed
- **Docker image** — Rejected: overkill for a single CLI tool

## Validation Strategy: Structural + Semantic

**Decision**: Implement two-layer validation in `validate-data.sh`:
1. **Structural** — grep-based pattern matching for XML well-formedness rules
2. **Semantic** — HTTP HEAD requests for all `<Url>` elements with caching

**Rationale**:
- Structural rules catch common authoring errors (empty tags, double nesting, misplaced elements)
- URL validation ensures attribution links remain valid (critical for licensing compliance)
- Caching (`.cache/`) prevents redundant network calls and CI flakiness
- grep patterns are fast and require no XML parser dependency

**Alternatives Considered**:
- **XSD schema validation** — Rejected: schema not available; grep patterns cover known issues
- **Full XML parser (xmllint)** — Rejected: not universally installed; grep is portable
- **No URL validation** — Rejected: broken attribution links violate source licenses

## Composition Model: Declarative Variable Lists

**Decision**: Define name list compositions as bash variables in `build.sh` (e.g., `AFRICAN_NAMELISTS="real/african/... media/..."`).

**Rationale**:
- Explicit, readable composition definitions in the build script itself
- Easy to audit which sources contribute to which output name list
- Shell variable expansion integrates naturally with the merge function
- No separate configuration file format to parse

**Alternatives Considered**:
- **YAML/JSON composition config** — Rejected: adds parser dependency; bash variables are sufficient
- **Directory-based convention** — Rejected: less explicit; harder to handle cross-category merges
- **C# composition logic** — Rejected: would require embedding logic in StellarisNameListGenerator

## Species Classification: Stellaris-Native Types

**Decision**: Use Stellaris species class types directly (`human`, `mammalian`, `reptilian`, `avian`, `arthropoid`, `molluscoid`, `fungoid`, `plantoid`, `lithoid`, `machine`).

**Rationale**:
- Direct mapping to Stellaris game mechanics — no translation layer needed
- UI name lists in `name-lists/ui/` are organised by these exact types
- Contributors familiar with Stellaris can immediately understand the structure

**Alternatives Considered**:
- **Custom taxonomy** — Rejected: would require mapping layer; adds complexity
- **Flat list** — Rejected: loses species-class semantics used by Stellaris

## Source Organisation: Category-Based Directory Structure

**Decision**: Organise source XML files into four top-level categories: `generated/`, `media/`, `real/`, `ui/`.

**Rationale**:
- Clear semantic separation: procedural vs. authored, real vs. fictional
- Matches how contributors think about name list sources
- Enables category-level composition in `build.sh` (e.g., "all real human cultures")
- Scales to hundreds of files without flat directory chaos

**Alternatives Considered**:
- **Single flat directory** — Rejected: unmanageable at scale
- **By species class** — Rejected: crosses category boundaries (e.g., human names from both real and media)
- **By contributor** — Rejected: not a stable classification

## CI/CD: GitHub Actions with Multi-Channel Deployment

**Decision**: Use GitHub Actions for CI (build.yml) and separate deployment workflows for Steam Workshop (steam-workshop.yml) and Nexus Mods (nexus-mods.yml), triggered on version tags.

**Rationale**:
- Native GitHub integration — no external CI service needed
- Tag-based deployment aligns with semantic versioning
- Separate workflows allow independent failure/retry per channel
- Steam Workshop and Nexus Mods have different authentication and packaging requirements

**Alternatives Considered**:
- **Single workflow with matrix** — Rejected: different secrets, different actions, different failure modes
- **Manual deployment scripts** — Rejected: error-prone; automation ensures consistency
- **Paradox Mods API** — Rejected: no public API available at time of implementation

## Version Compatibility: Explicit Stellaris Version Targeting

**Decision**: Hard-code supported Stellaris version in mod descriptor (`supported_version="v4.3.*"`).

**Rationale**:
- Stellaris mods must declare compatibility explicitly
- Patch-level wildcard (`*`) allows minor updates without mod updates
- Major version changes (v4.x → v5.x) typically break mod compatibility
- Single version target simplifies testing

**Alternatives Considered**:
- **Multiple version descriptors** — Rejected: Stellaris only reads one descriptor.mod
- **Dynamic version detection** — Rejected: not possible at build time; runtime detection not supported

## Caching Strategy: Explicit Cache Directories

**Decision**: Use `.builder/` for binary cache and `.cache/` for URL validation cache, both committed to `.gitignore`.

**Rationale**:
- `.builder/` avoids re-downloading StellarisNameListGenerator on every build
- `.cache/` prevents redundant HTTP requests during validation (especially in CI)
- Explicit directories make cache invalidation obvious (delete directory)
- Not committed — regenerated on demand

**Alternatives Considered**:
- **System package manager** — Rejected: StellarisNameListGenerator not in distro repos
- **Git LFS for binary** — Rejected: binary updates frequently; LFS adds complexity
- **No caching** — Rejected: slow CI; flaky network dependencies

## Error Handling: Fail-Fast with Descriptive Messages

**Decision**: `validate-data.sh` exits with non-zero code on first error; `build.sh` uses `set -euo pipefail`.

**Rationale**:
- Fail-fast prevents cascading errors and wasted compute
- Descriptive error messages (file, line, rule) enable quick fixes
- `set -euo pipefail` catches unset variables and pipeline failures
- CI fails fast, reducing feedback loop time

**Alternatives Considered**:
- **Collect all errors then report** — Rejected: more complex implementation; first error usually blocks others
- **Warnings instead of errors** — Rejected: validation rules are correctness requirements, not style suggestions

## Licensing: GPL-3.0 for Code, Source Attribution for Names

**Decision**: Repository code under GPL-3.0; name list sources require attribution via `<Url>` elements.

**Rationale**:
- GPL-3.0 ensures derivative works remain open source
- Name lists derived from real-world cultures are factual (not copyrightable) but attribution is ethical
- Name lists from media franchises are transformative use; attribution acknowledges source
- `<Url>` validation enforces attribution compliance

**Alternatives Considered**:
- **MIT/BSD** — Rejected: less protective of downstream openness
- **No licence** — Rejected: defaults to all-rights-reserved; blocks collaboration
- **CC-BY for names** — Rejected: mixed licence model adds complexity; GPL covers code adequately