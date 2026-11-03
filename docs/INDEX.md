# Documentation Index

## Repository Summary

Universum Infinitum: Name Lists is a Stellaris modification that provides numerous detailed name lists for empire creation. The project implements a data transformation pipeline that validates, merges, and generates Stellaris-compatible name list modifications from XML source definitions. The system curates thousands of names across real-world cultures, fictional universes, and procedurally-generated species, with verification that all input conforms to expected XML structure before generating the mod output.

## Root Document Map

- [ARCHITECTURE.md](../ARCHITECTURE.md) — System architecture, components, data flows, and cross-cutting concerns
- [SECURITY.md](../SECURITY.md) — Security model, threats, and mitigations
- [ROADMAP.md](../ROADMAP.md) — Project roadmap and planned features
- [PRIVACY.md](../PRIVACY.md) — Privacy and data handling policy
- [LICENSE](../LICENSE) — GNU General Public License v3.0
- [CONTRIBUTING.md](../CONTRIBUTING.md) — Contribution guidelines
- [CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md) — Code of conduct

## Documentation Catalogue

### Architecture & Design

| Document | Description |
|----------|-------------|
| [architecture.md](./architecture.md) | High-level architecture complementing root ARCHITECTURE.md |
| [repository-overview.md](./repository-overview.md) | Repository purpose, scope, and entry points |
| [repository-structure.md](./repository-structure.md) | Source tree layout and module organisation |
| [design-decisions.md](./design-decisions.md) | Key architectural and design choices with rationale |
| [data-model.md](./data-model.md) | Domain entities, relationships, and persistence |
| [state-and-persistence.md](./state-and-persistence.md) | State management, stores, caches, migrations |
| [concurrency-and-scheduling.md](./concurrency-and-scheduling.md) | Threading, async, schedulers, locks |

### Components & Flows

| Document | Description |
|----------|-------------|
| [components/presentation.md](./components/presentation.md) | Presentation layer: XML name list definitions and UI-facing lists |
| [components/host-and-composition.md](./components/host-and-composition.md) | Build orchestration and pipeline composition |
| [components/application-services.md](./components/application-services.md) | Core transformation services: validation, merging, generation |
| [components/integration-models.md](./components/integration-models.md) | External integrations: StellarisNameListGenerator, CI/CD |
| [integrations.md](./integrations.md) | External system integrations |
| [flows/startup-and-rendering.md](./flows/startup-and-rendering.md) | Build pipeline execution flow |
| [flows/calendar-search.md](./flows/calendar-search.md) | Name list merging and localisation generation flow |
| [flows/detail-mutation.md](./flows/detail-mutation.md) | Validation and error handling flow |

### Behaviours

| Document | Description |
|----------|-------------|
| [behaviour/browse-and-search.md](./behaviour/browse-and-search.md) | Browsing and selecting name lists in Stellaris |
| [behaviour/inspect-edit-delete.md](./behaviour/inspect-edit-delete.md) | Contributing and modifying name list definitions |

### Operations

| Document | Description |
|----------|-------------|
| [build-and-deployment.md](./build-and-deployment.md) | Build pipeline, deployment, and environments |
| [configuration.md](./configuration.md) | Configuration schema, sources, and precedence |
| [testing.md](./testing.md) | Test strategy, organisation, and coverage |
| [dependencies.md](./dependencies.md) | External and internal dependencies |
| [error-handling.md](./error-handling.md) | Error taxonomy, handling patterns, and recovery |
| [logging.md](./logging.md) | Logging framework, levels, structured fields, correlation, sinks |
| [security.md](./security.md) | Security model complementing root SECURITY.md |
| [state-and-persistence.md](./state-and-persistence.md) | State management, stores, caches, migrations |
| [concurrency-and-scheduling.md](./concurrency-and-scheduling.md) | Threading, async, schedulers, locks |
| [integrations.md](./integrations.md) | External system integrations |
| [change-guide.md](./change-guide.md) | How to modify common areas safely |
| [documentation-maintenance.md](./documentation-maintenance.md) | How to keep docs current, ownership |
| [troubleshooting.md](./troubleshooting.md) | Common issues and solutions |
| [faq.md](./faq.md) | Frequently asked questions |
| [ambiguities-and-open-questions.md](./ambiguities-and-open-questions.md) | Unresolved items, TODOs, known gaps |
| [quick-start.md](./quick-start.md) | Getting started guide for newcomers |
| [api-usage-examples.md](./api-usage-examples.md) | Example requests/responses for API usage |

### Reference

| Document | Description |
|----------|-------------|
| [api-reference/INDEX.md](./api-reference/INDEX.md) | API reference index and endpoint summary |

## Navigation Aids

- **Start here** (newcomers): [quick-start.md](./quick-start.md) → [repository-overview.md](./repository-overview.md) → [architecture.md](./architecture.md)
- **Deep dive** (component owners): [components/](./components/) → [data-model.md](./data-model.md) → [design-decisions.md](./design-decisions.md)
- **Flows** (debuggers): [flows/](./flows/) → [error-handling.md](./error-handling.md) → [troubleshooting.md](./troubleshooting.md)

## Maintenance Metadata

- Last reviewed: 2026-11-03
- Owner: hmlendea
- Coverage status: Initial generation — comprehensive review pending