# Security Policy

This project is a Stellaris modification consisting exclusively of static name list definitions. It contains no executable code, network connectivity, telemetry, analytics, or external integrations. The security policy addresses the integrity of the distributed name list data and the build pipeline that produces it.

## 📑 Table of Contents

- [Supported Versions](#supported-versions)
- [Reporting a Vulnerability](#reporting-a-vulnerability)
- [Scope](#scope)
- [Disclosure Policy](#disclosure-policy)
- [Recognition](#recognition)

## 🛡️ Supported Versions

Use this table to indicate which project versions currently receive security maintenance.

| Version | Distribution Channel | Supported |
|---------|--------------------|-----------|
| Latest version | Steam Workshop | ✅ |
| Latest version | Nexus Mods | ✅ |
| Latest version | Paradox Mods | ✅ |
| Latest version | GitHub Releases | ✅ |
| Latest version | Unofficial third-party distribution channels | ❌ |
| Preceding versions | Any distribution channel | ❌ |

## 🚨 Reporting a Vulnerability

Please do not disclose suspected vulnerabilities publicly before maintainers have had an opportunity to validate and remediate them.

To report a vulnerability:
- [GitHub Security Advisories](https://github.com/hmlendea/stellaris-ui-name-lists/security/advisories)
- Contact the maintainers directly

## 📌 Scope

The subsequent report categories are in scope for this repository:
- Malicious or corrupted name list data introduced during the build process
- Supply-chain compromise of the external name-list generator dependency
- Unauthorised modification of release artefacts on distribution channels

The subsequent categories are out of scope unless explicitly stated to the contrary:
- Vulnerabilities in the Stellaris game engine or launcher
- Vulnerabilities in Steam Workshop, Nexus Mods, Paradox Mods, or GitHub infrastructure
- Issues arising from unofficial forks or modified distributions

## 📢 Disclosure Policy

This project follows coordinated disclosure:
1. Vulnerabilities are investigated privately.
2. A remediation plan is prepared and validated.
3. Public disclosure is published after a fix, mitigation, or agreed risk decision is available.
4. Credit is attributed in accordance with reporter preference and project policy.

## 🙏 Recognition

We appreciate responsible disclosure. Reporters who desire public attribution may be acknowledged in release notes, advisories, or a dedicated acknowledgements section.