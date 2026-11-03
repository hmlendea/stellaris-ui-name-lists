# Ambiguities and Open Questions

> **Purpose**: Document known ambiguities, unresolved questions, and areas requiring clarification. Prevents future agents from re-deriving or making inconsistent assumptions.

## Ambiguities (Known, Unresolved)

### A1: Species Class Semantics

**Question**: What is the exact in-game behaviour difference between species classes for name list selection?

**Context**: `SpeciesClass` in XML maps to `species_class` in output. Stellaris uses this to filter name lists by empire species class.

**Current Assumption**: Direct 1:1 mapping; no transformation.

**Impact**: If Stellaris applies additional filtering (e.g., HUMANOID includes MAMMALIAN), composition may be redundant.

**Resolution Needed**: Test in-game with multi-class empire.

### A2: Name Group Chance Interpretation

**Question**: Is `Chance` relative weight or absolute probability?

**Context**: `<Chance>100</Chance>` in NameGroup. Generator output uses `chance = { ... }` blocks.

**Current Assumption**: Relative weight (normalized across groups in same list).

**Impact**: If absolute, compositions with multiple groups may behave unexpectedly.

**Resolution Needed**: Inspect generator output for multi-group lists; compare with in-game behaviour.

### A3: Localisation Key Generation

**Question**: How does generator derive localisation keys from `Name`?

**Context**: Output YML has keys like `internal_identifier`. Generator transforms `Name` somehow.

**Current Assumption**: Direct use of `Name` value (snake_case preserved).

**Impact**: If transformation occurs (e.g., prefixing), localisation may mismatch.

**Resolution Needed**: Compare input `Name` with output YML keys for sample lists.

### A4: URL Validation Scope

**Question**: Should URL validation check HTTP status only, or content type?

**Context**: `validate-data.sh` uses `curl -sfI` (HEAD request, status check only).

**Current Assumption**: Status 200-399 = valid.

**Impact**: URLs returning 200 with error page (soft 404) pass validation.

**Resolution Needed**: Decide if content-type check needed; implement if so.

### A5: Composition Variable Naming

**Question**: Why do some composition variables use plural (`AFRICAN_NAMELISTS`) and others singular?

**Context**: `scripts/build.sh` has mixed naming.

**Current Assumption**: Historical inconsistency; no semantic difference.

**Impact**: Confusion when adding new compositions.

**Resolution Needed**: Standardise (recommend plural) in cleanup PR.

### A6: Generated Name Lists Provenance

**Question**: What generator produced `name-lists/generated/*.xml`?

**Context**: Directory contains procedurally generated name lists. Source generator not documented.

**Current Assumption**: External tool, one-time generation, committed as static data.

**Impact**: Cannot regenerate if lost; provenance unclear for licensing.

**Resolution Needed**: Document generator source or mark as "static, do not regenerate".

### A7: UI Name Lists vs Real/Media

**Question**: What distinguishes `ui/` from `generated/`?

**Context**: Both contain non-real-world, non-media name lists.

**Current Assumption**: `ui/` = thematic (demon, goblin, lizard); `generated/` = procedurally generated.

**Impact**: Ambiguous categorisation for new lists.

**Resolution Needed**: Define clear criteria in `components/presentation.md`.

### A8: Mod Descriptor Version Source

**Question**: Where does `version="1.2.3"` in `descriptor.mod` come from?

**Context**: `generate_mod_descriptor()` writes version. Source unclear (hardcoded? git tag? env var?).

**Current Assumption**: Hardcoded in `build.sh` or derived from git.

**Impact**: Version drift between releases if manual.

**Resolution Needed**: Trace `generate_mod_descriptor()` implementation; document source.

### A9: Steam Workshop Item ID

**Question**: What is the actual Workshop item ID?

**Context**: `steam-workshop.yml` references `<WORKSHOP_ID>` placeholder in docs.

**Current Assumption**: Real ID exists in workflow file (redacted in docs).

**Impact**: Documentation incomplete without real ID.

**Resolution Needed**: Verify workflow file; document real ID or confirm placeholder.

### A10: Nexus File ID

**Question**: What is the actual Nexus Mods file ID?

**Context**: `nexus-mods.yml` references `<NEXUS_FILE_ID>` placeholder in docs.

**Current Assumption**: Real ID exists in workflow file (redacted in docs).

**Impact**: Documentation incomplete without real ID.

**Resolution Needed**: Verify workflow file; document real ID or confirm placeholder.

## Open Questions (Unanswered, Potentially Resolvable)

### Q1: Generator Output Format Details

**Question**: What exact format does StellarisNameListGenerator produce for `chance` blocks?

**Approach**: Inspect `out/ui-name-lists/common/name_lists/00_ui_name_lists.txt` after build.

**Status**: Not yet inspected.

### Q2: Localisation Description Generation

**Question**: Does generator create `_desc` localisation entries? From what source?

**Approach**: Inspect `out/ui-name-lists/localisation/english/*.yml` after build.

**Status**: Not yet inspected.

### Q3: Merge Algorithm Details

**Question**: How does `merge()` combine multiple XML files? Concatenation? Deduplication? Conflict resolution?

**Approach**: Read `merge()` function in `scripts/build.sh` carefully.

**Status**: Partially understood (concatenation assumed); needs verification.

### Q4: Validation Rule Completeness

**Question**: Are V001-V007 exhaustive? What other structural issues could occur?

**Approach**: Review `validate-data.sh` grep patterns; compare with XML schema possibilities.

**Status**: Documented rules verified; completeness unknown.

### Q5: CI Cache Strategy

**Question**: Should `.builder/` and `.cache/` be cached in GitHub Actions?

**Approach**: Evaluate build time with/without cache; implement if beneficial.

**Status**: Not evaluated.

### Q6: Parallel Build Feasibility

**Question**: Can compositions build in parallel without conflicts?

**Approach**: Analyze generator output paths; test parallel execution.

**Status**: Not evaluated; see `concurrency-and-scheduling.md`.

### Q7: Stellaris v5 Compatibility

**Question**: What changes in v5 would break this mod?

**Approach**: Monitor Paradox patch notes; test when v5 releases.

**Status**: Not applicable yet (v4.3 current).

### Q8: Name List Deduplication

**Question**: Are duplicate names across source files deduplicated in merge?

**Approach**: Test with known duplicate; inspect output.

**Status**: Unknown.

### Q9: Encoding Handling

**Question**: How are non-ASCII characters (accents, CJK, Cyrillic) handled through pipeline?

**Approach**: Test with sample non-ASCII names; verify output encoding.

**Status**: Assumed UTF-8 throughout; not verified.

### Q10: Generator Version Compatibility

**Question**: Which generator versions are compatible with which XML schema versions?

**Approach**: Test multiple generator versions against current sources.

**Status**: Pinned to v1.2.3; compatibility range unknown.

## Resolved Ambiguities (Historical)

| ID | Question | Resolution | Date |
|----|----------|------------|------|
| R1 | Is this a code mod? | No, data-only | Initial exploration |
| R2 | Does build require .NET? | No, binary downloaded | Initial exploration |
| R3 | Are tests automated? | Only validation + build integrity | Initial exploration |
| R4 | Is there runtime state? | No, stateless pipeline | Initial exploration |

## How to Add New Entries

1. **Ambiguity**: Add to "Ambiguities" section with ID (A11, A12, ...), question, context, assumption, impact, resolution needed.
2. **Open Question**: Add to "Open Questions" section with ID (Q11, Q12, ...), question, approach, status.
3. **Resolved**: Move to "Resolved Ambiguities" table with resolution and date.

## Review Cadence

- **Per release**: Review open items; close resolved.
- **Quarterly**: Audit for stale questions.
- **On discovery**: Add new ambiguity immediately.