# Change Guide

> **Audience**: Contributors making changes to the repository

## Contribution Workflow

### 1. Fork and Branch

```bash
git fork https://github.com/hmlendea/stellaris-ui-name-lists
git clone https://github.com/YOUR_USERNAME/stellaris-ui-name-lists
cd stellaris-ui-name-lists
git checkout -b feature/your-change
```

### 2. Make Changes

Follow the relevant guide:
- **New name list**: `components/presentation.md` + `components/host-and-composition.md`
- **Edit name list**: `behaviour/inspect-edit-delete.md`
- **Build pipeline**: `components/host-and-composition.md`
- **Validation rules**: `flows/detail-mutation.md`

### 3. Validate Locally

```bash
# Fast validation
./scripts/validate-data.sh

# Full build test
./scripts/build.sh
```

### 4. Commit with Conventional Messages

```bash
git add .
git commit -m "feat: add new elven name list from Tolkien"
# Types: feat, fix, docs, refactor, test, chore
```

### 5. Push and Open PR

```bash
git push origin feature/your-change
# Open PR on GitHub
```

## Change Categories

### Adding a Name List

| Step | Action | Reference |
|------|--------|-----------|
| 1 | Choose category directory | `components/presentation.md` |
| 2 | Create XML file | `components/presentation.md` |
| 3 | Validate XML | `flows/detail-mutation.md` |
| 4 | Add to composition | `components/host-and-composition.md` |
| 5 | Test build | `operations/quick-start.md` |

### Editing a Name List

| Step | Action | Reference |
|------|--------|-----------|
| 1 | Locate source file | `behaviour/browse-and-search.md` |
| 2 | Modify XML | `components/presentation.md` |
| 3 | Validate | `flows/detail-mutation.md` |
| 4 | Test build | `operations/quick-start.md` |

### Modifying Composition

| Step | Action | Reference |
|------|--------|-----------|
| 1 | Edit `scripts/build.sh` | `components/host-and-composition.md` |
| 2 | Update composition variable | `components/host-and-composition.md` |
| 3 | Test build | `operations/quick-start.md` |

### Updating Generator Version

| Step | Action | Reference |
|------|--------|-----------|
| 1 | Update `BUILDER_VERSION` in `update-builder.sh` | `dependencies.md` |
| 2 | Delete `.builder/` | `state-and-persistence.md` |
| 3 | Run `./scripts/update-builder.sh` | `operations/quick-start.md` |
| 4 | Full build test | `operations/quick-start.md` |

## Code Style

### Shell Scripts

- **Shebang**: `#!/usr/bin/env bash`
- **Strict mode**: `set -euo pipefail`
- **Functions**: lowercase_with_underscores
- **Variables**: UPPER_SNAKE_CASE for globals, lowercase for locals
- **Quoting**: Always quote variables `"$var"`
- **Indentation**: 4 spaces (no tabs)

### XML Files

- **Indentation**: 4 spaces
- **Encoding**: UTF-8
- **Line endings**: LF
- **Attributes**: Double quotes
- **Self-closing**: `<Element />` for empty

### Commit Messages

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New name list, new composition, new feature
- `fix`: Bug fix (validation, build, output)
- `docs`: Documentation only
- `refactor`: Code restructure without behaviour change
- `test`: Test additions (not applicable currently)
- `chore`: Maintenance (versions, CI, tooling)

**Scopes**:
- `name-lists`: Source XML changes
- `build`: Build script changes
- `validate`: Validation changes
- `ci`: CI/CD changes
- `docs`: Documentation changes
- `deps`: Dependency updates

## PR Requirements

### Mandatory Checks

- [ ] `./scripts/validate-data.sh` passes
- [ ] `./scripts/build.sh` completes successfully
- [ ] Output structure verified (`out/ui-name-lists/`)
- [ ] No uncommitted files in `build/`, `out/`, `release/`

### Recommended

- [ ] Test in Stellaris (if name list changes)
- [ ] Update documentation if behaviour changes
- [ ] Add comment for complex composition changes

## Review Checklist

### For Reviewers

- [ ] XML follows schema (`components/presentation.md`)
- [ ] Attribution URL is valid and reachable
- [ ] Composition variable updated correctly
- [ ] No duplicate `Name` identifiers
- [ ] Species class appropriate
- [ ] Build passes
- [ ] Documentation updated if needed

### For Maintainers (Merge)

- [ ] All CI checks pass
- [ ] At least one approval
- [ ] No merge conflicts
- [ ] Version bump if release-worthy

## Release Process

See `build-and-deployment.md` for full release procedure.

### Version Bumping

| Change Type | Version Bump |
|-------------|--------------|
| New name list | PATCH (1.2.3 → 1.2.4) |
| Composition change | PATCH |
| Generator update | PATCH (or MINOR if breaking) |
| Major restructure | MINOR |
| Stellaris version support | MAJOR |

### Tagging

```bash
git tag -a v1.2.4 -m "Release v1.2.4"
git push origin v1.2.4
```

Triggers: Steam Workshop + Nexus Mods deployment

## Rollback

### Revert Commit

```bash
git revert <commit-hash>
git push origin master
```

### Revert Tag (if deployed)

1. Delete GitHub Release
2. Delete tag locally and remote
3. Re-deploy previous version manually if needed

## Getting Help

- **Documentation**: Start with `INDEX.md`
- **Issues**: GitHub Issues for bugs/features
- **Discussions**: GitHub Discussions for questions
- **Maintainer**: @hmlendea