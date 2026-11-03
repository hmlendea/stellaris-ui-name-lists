# Repository Overview

## Purpose

This repository contains the source definitions, build automation, and validation logic for the **Universum Infinitum: Name Lists** Stellaris modification. The mod provides numerous detailed name lists for empire creation, including an extensive Human - Extended variant with names inspired by historical and fictional sources.

## Scope

The repository encompasses:

- **Source name list definitions** — XML files organised by category (real-world cultures, fictional universes, procedurally-generated species)
- **Build and validation scripts** — Bash scripts that orchestrate the transformation pipeline
- **External dependency management** — Automated download and caching of the StellarisNameListGenerator binary
- **CI/CD workflows** — GitHub Actions for validation, building, and multi-channel deployment
- **Distribution artefacts** — Generated mod packages for Steam Workshop, Nexus Mods, and Paradox Mods

## Entry Points

| Entry Point | Type | Description |
|-------------|------|-------------|
| `scripts/build.sh` | Build script | Principal build orchestrator; drives the entire pipeline |
| `scripts/validate-data.sh` | Validation script | Structural and semantic validation of all XML definitions |
| `scripts/update-builder.sh` | Dependency script | Downloads or caches the StellarisNameListGenerator |
| `.github/workflows/build.yml` | CI workflow | Validates and builds on every push and pull request |
| `.github/workflows/steam-workshop.yml` | Deployment workflow | Deploys to Steam Workshop on tagged releases |
| `.github/workflows/nexus-mods.yml` | Deployment workflow | Deploys to Nexus Mods on tagged releases |

## Principal Capabilities

1. **Name List Curation** — Centralised management of thousands of names across diverse sources
2. **Validation Pipeline** — Structural XML validation and URL reachability verification
3. **Transformation** — Merging category-specific name lists and generating localisation strings
4. **Multi-Channel Distribution** — Automated publishing to Steam Workshop, Nexus Mods, and Paradox Mods
5. **Version Compatibility** — Mod descriptor specifies supported Stellaris versions (`v4.3.*`)

## Target Audience

- **Mod Maintainers** — Developers who invoke build scripts locally or via CI
- **Contributors** — Users who submit name list XML definitions via pull requests
- **Stellaris End Users** — Players who consume the generated modification
- **CI/CD Pipeline** — Automated workflows that validate and publish the mod

## System Boundary

The system operates as a data transformation pipeline within a GitHub-hosted repository. External boundaries include:

- **StellarisNameListGenerator** — External binary executable consumed during build
- **Stellaris Mod Format** — Output must conform to Stellaris directory structure
- **CI/CD Distribution** — GitHub Actions workflows for automated publication
- **Version Control** — Git repository as single source of truth