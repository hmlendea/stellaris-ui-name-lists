# Documentation Maintenance

> **Audience**: Maintainers and contributors updating documentation

## Documentation Principles

### 1. Documentation as Code

- Docs live in `docs/` alongside source
- Updated in same PR as code changes
- Reviewed with same rigor as code

### 2. Single Source of Truth

| Topic | Canonical Location | Derived Locations |
|-------|-------------------|-------------------|
| Architecture | `ARCHITECTURE.md` (root) | `docs/architecture.md` |
| XML Schema | `components/presentation.md` | `api-reference/INDEX.md` |
| Composition | `components/host-and-composition.md` | `operations/change-guide.md` |
| Validation | `flows/detail-mutation.md` | `error-handling.md` |
| Build Process | `flows/startup-and-rendering.md` | `build-and-deployment.md` |

### 3. No Duplication

- Link instead of copy
- Use relative links: `[XML Schema](../components/presentation.md)`
- Update canonical; derived updated in same PR

## Maintenance Triggers

### Per PR (Automatic)

| Change | Docs to Update |
|--------|----------------|
| New name list category | `repository-structure.md`, `components/presentation.md` |
| New composition variable | `components/host-and-composition.md` |
| Validation rule added | `flows/detail-mutation.md`, `error-handling.md` |
| Generator version bump | `dependencies.md`, `build-and-deployment.md` |
| New deployment channel | `integrations.md`, `build-and-deployment.md` |
| CI workflow change | `build-and-deployment.md`, `configuration.md` |
| New error code | `error-handling.md` |
| New config option | `configuration.md` |

### Quarterly Audit (Manual)

1. **Link check**: `find docs -name "*.md" -exec grep -l "](http" {} \;` — verify all external links
2. **Drift check**: Compare `docs/` against root `ARCHITECTURE.md`, `README.md`
3. **Completeness**: Verify all INDEX.md catalogue entries exist
4. **Accuracy**: Spot-check 3 random docs against current code

### Per Release

- Update `build-and-deployment.md` with version-specific notes
- Verify `operations/quick-start.md` works for new version
- Update `dependencies.md` version matrix

## Documentation Standards

### File Naming

- kebab-case: `repository-overview.md`
- Descriptive: `change-guide.md` not `contributing.md`
- Consistent with INDEX.md catalogue

### Structure Template

```markdown
# Title

> **Audience**: [who this is for]

## Overview

[2-3 sentences]

## Sections

[Logical grouping with ## headings]

## Cross-References

[Links to related docs]

## Future Considerations

[Known gaps, planned improvements]
```

### Linking Conventions

| Target | Syntax |
|--------|--------|
| Same directory | `[Title](file.md)` |
| Subdirectory | `[Title](subdir/file.md)` |
| Parent directory | `[Title](../file.md)` |
| Root docs | `[Title](../file.md)` |
| Root repo | `[Title](../../file.md)` |
| External | `[Title](https://...)` |

### Code Blocks

```bash
# Bash commands
./scripts/build.sh
```

```xml
<!-- XML examples -->
<NameList>...</NameList>
```

```yaml
# YAML examples
key: value
```

## Tooling

### Link Validation

```bash
# Install markdown-link-check
npm install -g markdown-link-check

# Check all docs
markdown-link-check docs/**/*.md
```

### Spell Check

```bash
# Install cspell
npm install -g cspell

# Check
cspell "docs/**/*.md"
```

### Linting

```bash
# Install markdownlint
npm install -g markdownlint-cli

# Check
markdownlint "docs/**/*.md"
```

## Common Maintenance Tasks

### Adding a New Document

1. Create file in correct directory per INDEX.md
2. Follow structure template
3. Add entry to INDEX.md catalogue
4. Add cross-references from related docs
5. Run link check

### Moving a Document

1. Move file
2. Update all incoming links (grep -r "old-path" docs/)
3. Update INDEX.md
4. Run link check

### Deprecating a Document

1. Add deprecation notice at top
2. Link to replacement
3. Keep for 1 release cycle
4. Then delete and update INDEX.md

## Review Checklist

### For Documentation PRs

- [ ] Follows structure template
- [ ] Audience declared
- [ ] Cross-references use relative links
- [ ] No broken links (markdown-link-check passes)
- [ ] No spelling errors (cspell passes)
- [ ] No lint errors (markdownlint passes)
- [ ] Added to INDEX.md if new
- [ ] Related docs updated

### For Code PRs with Doc Impact

- [ ] Canonical doc updated
- [ ] Derived docs updated (or issue filed)
- [ ] INDEX.md current

## Future Improvements

- [ ] Automate link checking in CI
- [ ] Add spell check to CI
- [ ] Generate API reference from source (if API emerges)
- [ ] Add Mermaid diagram validation
- [ ] Consider docs-as-code with Vale for style