# Security

## Security Model

This project is a **data-only Stellaris mod** with no runtime code execution, no network services, and no user data processing. The security model focuses on supply chain integrity and build pipeline safety.

## Threat Model

### Assets

| Asset | Sensitivity | Threats |
|-------|-------------|---------|
| Source name lists | Low (public) | Tampering, malicious content |
| Build pipeline | Medium | Supply chain compromise |
| Release artefacts | Medium | Tampering, malware injection |
| Deployment secrets | High | Theft, misuse |
| StellarisNameListGenerator binary | Medium | Supply chain compromise |

### Threat Actors

| Actor | Capability | Motivation |
|-------|------------|------------|
| External contributor | PR submission | Malicious name list content |
| Compromised CI runner | Build execution | Artefact tampering |
| Compromised dependency | Binary replacement | Supply chain attack |
| Secret leakage | Credential access | Unauthorized deployment |

## Security Controls

### Source Code Integrity

- **Branch protection**: `master` requires PR review and CI pass
- **Signed commits**: Recommended for maintainers
- **Code review**: All changes require review before merge

### Dependency Integrity

#### StellarisNameListGenerator

- **Pinned version**: `BUILDER_VERSION="v1.2.3"` in `update-builder.sh`
- **Verified source**: Built from hmlendea/stellaris-name-list-generator (same author)
- **Checksum verification**: Not currently implemented (TODO)
- **Cache isolation**: `.builder/` not committed; regenerated on demand

#### GitHub Actions

- **Pinned versions**: All actions pinned to specific versions (e.g., `actions/checkout@v7`)
- **Minimal permissions**: Workflows use default `GITHUB_TOKEN` with read/write scope
- **Secret isolation**: Deployment secrets only in deployment workflows

### Build Pipeline Security

#### Validation Gate

```bash
# validate-data.sh prevents:
# - Malformed XML that could exploit parser
# - Unreachable URLs (broken attribution)
# - Structural anomalies
```

#### Fail-Fast Execution

```bash
set -euo pipefail  # Prevents silent failures
```

#### No Arbitrary Code Execution

- Build scripts only process XML data
- No `eval`, no dynamic code generation
- Generator is external binary with fixed interface

### Secret Management

| Secret | Scope | Rotation |
|--------|-------|----------|
| `STEAM_USERNAME` | steam-workshop.yml | Manual |
| `STEAM_PASSWORD` | steam-workshop.yml | Manual |
| `STEAM_2FA_SEED` | steam-workshop.yml | Manual |
| `NEXUSMODS_API_KEY` | nexus-mods.yml | Manual |

**Storage**: GitHub Actions encrypted secrets (AES-256 at rest)

**Access**: Only deployment workflows; not accessible to PR builds

### Release Integrity

- **Artefact provenance**: Built in CI, uploaded as workflow artefact
- **Release creation**: `softprops/action-gh-release@v1` from CI
- **Deployment**: Separate workflows download from GitHub Releases
- **Checksums**: Not currently published (TODO)

## Vulnerability Management

### Known Vulnerabilities

| Component | CVE | Status | Mitigation |
|-----------|-----|--------|------------|
| bash | Various | Monitor | Ubuntu runner updates |
| curl | Various | Monitor | Ubuntu runner updates |
| GitHub Actions | Various | Monitor | Pin versions; update on advisory |

### Scanning

No automated vulnerability scanning. Manual review on:
- Dependency updates
- Security advisories
- CI runner updates

### Response Procedure

1. **Identify** affected component
2. **Assess** impact on build pipeline
3. **Update** version pin or workaround
4. **Test** in PR
5. **Deploy** fix

## Compliance

### Licensing

- **Code**: GPL-3.0 (see LICENSE)
- **Name lists**: Attribution via `<Url>` elements
- **Generator**: MIT (separate repository)

### Data Handling

- **No personal data** collected or processed
- **No telemetry** or analytics
- **Attribution URLs** are public references only

## Security Checklist for Contributors

- [ ] No executable code in XML files
- [ ] Attribution URLs are HTTPS and reputable
- [ ] No external entity references in XML
- [ ] PR passes validation and build
- [ ] No secrets in source code

## Security Checklist for Maintainers

- [ ] Review PRs for malicious content
- [ ] Verify dependency updates from trusted sources
- [ ] Rotate deployment secrets periodically
- [ ] Monitor GitHub Security Advisories
- [ ] Pin action versions; avoid `@main` or `@latest`

## Incident Response

### Compromised Build

1. Revoke affected deployment secrets
2. Delete compromised release artefacts
3. Rebuild from known-good commit
4. Re-deploy with new secrets

### Compromised Dependency

1. Pin to last known-good version
2. Investigate upstream
3. Update when fixed
4. Rebuild and re-deploy

### Secret Leakage

1. Rotate leaked secret immediately
2. Audit recent deployments
3. Review access logs
4. Update secret in GitHub Settings

## Future Improvements

- [ ] Add checksum verification for StellarisNameListGenerator
- [ ] Publish release artefact checksums
- [ ] Add dependabot for action updates
- [ ] Implement SBOM generation
- [ ] Add provenance attestation (SLSA)