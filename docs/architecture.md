# Architecture (Documentation Perspective)

> **Note**: This document complements the root `ARCHITECTURE.md` which contains the canonical architecture specification. This file provides a documentation-centric view focused on how the architecture is represented in the `docs/` structure.

## Documentation Architecture

The `docs/` directory follows a **domain-driven documentation architecture** organised by audience and concern:

```
docs/
├── INDEX.md                          # Master navigation
├── architecture.md                   # This file (docs perspective)
├── repository-overview.md            # What and why
├── repository-structure.md           # File layout
├── data-model.md                     # Domain entities
├── design-decisions.md               # ADRs
├── build-and-deployment.md           # Release process
├── configuration.md                  # Config reference
├── testing.md                        # Test strategy
├── dependencies.md                   # Dependency graph
├── error-handling.md                 # Error taxonomy
├── logging.md                        # Observability
├── security.md                       # Threat model
├── state-and-persistence.md          # State management
├── concurrency-and-scheduling.md     # Execution model
├── integrations.md                   # System boundaries
├── api-reference/
│   └── INDEX.md                      # API reference hub
├── behaviour/
│   ├── browse-and-search.md          # User workflows
│   └── inspect-edit-delete.md        # CRUD operations
├── components/
│   ├── presentation.md               # XML schema & UI
│   ├── host-and-composition.md       # Build orchestration
│   ├── application-services.md       # Core services
│   └── integration-models.md         # Integration contracts
├── flows/
│   ├── startup-and-rendering.md      # Build pipeline
│   ├── calendar-search.md            # Merge & generation
│   └── detail-mutation.md            # Validation & errors
└── operations/
    ├── change-guide.md               # Contribution guide
    ├── documentation-maintenance.md  # Doc upkeep
    ├── troubleshooting.md            # Common issues
    ├── faq.md                        # FAQ
    ├── ambiguities-and-open-questions.md
    ├── quick-start.md                # Newcomer guide
    └── api-usage-examples.md         # Usage examples
```

## Architectural Style in Documentation

### Data Transformation Pipeline (Documented As)

| Layer | Documentation Location |
|-------|------------------------|
| Source Definitions | `components/presentation.md` |
| Validation Gate | `flows/detail-mutation.md` |
| Composition Engine | `components/host-and-composition.md` |
| Transformation | `flows/calendar-search.md` |
| Output Assembly | `components/application-services.md` |
| Deployment | `build-and-deployment.md` |

### Cross-Cutting Concerns (Documented As)

| Concern | Documentation Location |
|---------|------------------------|
| Configuration | `configuration.md` |
| Error Handling | `error-handling.md` |
| Logging | `logging.md` |
| Security | `security.md` |
| Testing | `testing.md` |
| Dependencies | `dependencies.md` |

## Documentation Principles

### 1. Single Source of Truth

- Root `ARCHITECTURE.md` = canonical architecture
- `docs/` = elaborated, audience-specific views
- No duplication of diagrams or specifications

### 2. Audience Segmentation

| Audience | Entry Points |
|----------|--------------|
| New contributor | `operations/quick-start.md` |
| Maintainer | `operations/change-guide.md`, `build-and-deployment.md` |
| Researcher | `data-model.md`, `design-decisions.md` |
| Integrator | `integrations.md`, `api-reference/INDEX.md` |
| Debugger | `troubleshooting.md`, `error-handling.md`, `logging.md` |

### 3. Navigation Hierarchy

```
INDEX.md (master)
├── Root-level (overview, structure, data, decisions)
├── Components (presentation, host, services, integrations)
├── Flows (startup, merge, validation)
├── Behaviour (user workflows)
├── Operations (guides, maintenance, troubleshooting)
└── API Reference (if applicable)
```

## Relationship to Root ARCHITECTURE.md

| Root ARCHITECTURE.md | docs/ Complement |
|----------------------|------------------|
| System Context | `repository-overview.md` |
| Architectural Style | `design-decisions.md` (ADR-001) |
| Runtime Flow | `flows/startup-and-rendering.md` |
| Architectural Areas | `components/*` |
| Data Architecture | `data-model.md` |
| Interfaces | `integrations.md`, `components/integration-models.md` |
| Key Flows | `flows/*` |
| Cross-Cutting | `configuration.md`, `error-handling.md`, `logging.md`, `security.md`, `testing.md`, `dependencies.md` |

## Documentation Maintenance Architecture

### Update Triggers

| Trigger | Affected Docs |
|---------|---------------|
| New name list category | `components/presentation.md`, `repository-structure.md` |
| New composition variable | `components/host-and-composition.md` |
| Validation rule change | `flows/detail-mutation.md`, `error-handling.md` |
| Generator version bump | `dependencies.md`, `build-and-deployment.md` |
| New deployment channel | `integrations.md`, `build-and-deployment.md` |
| CI workflow change | `build-and-deployment.md`, `configuration.md` |

### Review Cadence

- **Per PR**: Affected docs updated in same PR
- **Quarterly**: Full docs audit for drift
- **Per release**: Version-specific notes in `build-and-deployment.md`

## Future Documentation Architecture

- [ ] Add `adr/` directory for formal Architecture Decision Records
- [ ] Generate API reference from source (if API emerges)
- [ ] Add interactive diagrams (Mermaid live editor links)
- [ ] Consider docs-as-code with automated validation