# Repository Structure

## Source Tree Layout

```
stellaris-ui-name-lists/
├── .builder/                          # Cached StellarisNameListGenerator binary
├── .cache/                            # URL validation cache
├── .github/
│   └── workflows/
│       ├── build.yml                  # CI: validate and build
│       ├── nexus-mods.yml             # Deploy to Nexus Mods
│       └── steam-workshop.yml         # Deploy to Steam Workshop
├── build/                             # Transient build output (generated)
├── name-lists/                        # Source XML name list definitions
│   ├── generated/                     # Generated source lists (external generators)
│   │   ├── fng/                       # Fantasy Name Generator outputs
│   │   ├── letsmakeagame/             # Let's Make A Game outputs
│   │   └── ung/                       # Universal Name Generator outputs
│   ├── media/                         # Media franchise-inspired name lists
│   │   ├── alien/                     # Alien franchise
│   │   ├── aow/                       # Age of Wonders
│   │   ├── borderlands/               # Borderlands
│   │   ├── civbe/                     # Civilization: Beyond Earth
│   │   ├── dc/                        # DC Comics
│   │   ├── dishonored/                # Dishonored
│   │   ├── dnd/                       # Dungeons & Dragons
│   │   ├── doctor-who/                # Doctor Who
│   │   ├── dune/                      # Dune
│   │   ├── elderscrolls/              # The Elder Scrolls
│   │   ├── firefly/                   # Firefly
│   │   ├── foundation/                # Foundation
│   │   ├── galactik-football/         # Galactik Football
│   │   ├── galciv/                    # Galactic Civilizations
│   │   ├── gta/                       # Grand Theft Auto
│   │   ├── halo/                      # Halo
│   │   ├── mass-effect/               # Mass Effect
│   │   ├── middle-earth/              # Middle-earth
│   │   ├── marvel/                    # Marvel
│   │   ├── narivia/                   # Narivia
│   │   ├── pandora/                   # Pandora
│   │   ├── paxnova/                   # Pax Nova
│   │   ├── runescape/                 # RuneScape
│   │   ├── sose/                      # Sins of a Solar Empire
│   │   ├── space-trilogy/             # Space Trilogy
│   │   ├── star-trek/                 # Star Trek
│   │   ├── starcraft/                 # StarCraft
│   │   ├── starwars/                  # Star Wars
│   │   ├── stellaris/                 # Stellaris (original content)
│   │   ├── vorkosigan/                # Vorkosigan Saga
│   │   ├── warcraft/                  # Warcraft
│   │   ├── warhammer/                 # Warhammer (Fantasy & 40k)
│   │   ├── witcher/                   # The Witcher
│   │   ├── ypp/                       # YPP
│   │   └── other/                     # Other media sources
│   ├── real/                          # Real-world culture name lists
│   │   ├── african/                   # African cultures
│   │   ├── american/                  # American cultures
│   │   ├── asian/                     # Asian cultures
│   │   ├── austronesian/              # Austronesian cultures
│   │   ├── baltic/                    # Baltic cultures
│   │   ├── celtic/                    # Celtic cultures
│   │   ├── common/                    # Common/shared definitions
│   │   ├── english/                   # English-speaking cultures
│   │   ├── germanic/                  # Germanic cultures
│   │   ├── hellenic/                  # Hellenic/Greek cultures
│   │   ├── indian/                    # Indian cultures
│   │   ├── iranian/                   # Iranian cultures
│   │   ├── romance/                   # Romance language cultures
│   │   ├── semitic/                   # Semitic cultures
│   │   ├── slavic/                    # Slavic cultures
│   │   ├── turkic/                    # Turkic cultures
│   │   └── [individual culture files] # e.g., afghan.xml, armenian.xml
│   └── ui/                            # UI-facing list definitions
│       ├── art1.xml                   # Arthropoid species
│       ├── avi1.xml                   # Avian species 1
│       ├── avi2.xml                   # Avian species 2
│       ├── fun1.xml                   # Fungoid species
│       ├── hum1.xml                   # Humanoid species 1
│       ├── hum2.xml                   # Humanoid species 2
│       ├── hum3.xml                   # Humanoid species 3
│       ├── hum4.xml                   # Humanoid species 4
│       ├── human/                     # Human-specific UI lists
│       ├── human_extra.xml            # Extra human names
│       ├── human_zextended.xml        # Extended human names
│       ├── mam1.xml                   # Mammalian species 1
│       ├── mam2.xml                   # Mammalian species 2
│       ├── mam3.xml                   # Mammalian species 3
│       ├── mol1.xml                   # Molluscoid species 1
│       ├── mol2.xml                   # Molluscoid species 2
│       ├── pla1.xml                   # Plantoid species 1
│       ├── pla2.xml                   # Plantoid species 2
│       ├── rep1.xml                   # Reptilian species 1
│       ├── rep2.xml                   # Reptilian species 2
│       ├── rep3.xml                   # Reptilian species 3
│       └── rep4.xml                   # Reptilian species 4
├── out/                               # Final mod output (generated)
│   └── ui-name-lists/                 # Stellaris mod directory structure
│       ├── common/
│       │   └── name_lists/            # Generated name list files
│       ├── localisation/
│       │   └── english/
│       │       └── ui_names_l_english.yml  # Localisation strings
│       ├── descriptor.mod             # Mod descriptor (internal)
│       └── thumbnail.png              # Mod thumbnail
├── scripts/                           # Build, validation, and automation
│   ├── build.sh                       # Principal build orchestrator
│   ├── validate-data.sh               # XML structure and URL validation
│   ├── update-builder.sh              # StellarisNameListGenerator dependency management
│   └── common/
│       └── paths.sh                   # Shared path configuration
├── thumbnail.png                      # Mod thumbnail (source)
├── ARCHITECTURE.md                    # System architecture documentation
├── CODE_OF_CONDUCT.md                 # Code of conduct
├── CONTRIBUTING.md                    # Contribution guidelines
├── LICENSE                            # GNU GPL v3.0
├── PRIVACY.md                         # Privacy policy
├── README.md                          # Project overview
├── SECURITY.md                        # Security policy
└── docs/                              # Generated documentation
    ├── INDEX.md                       # Documentation index
    ├── architecture.md                # High-level architecture
    ├── repository-overview.md         # This file
    ├── repository-structure.md        # Source tree layout
    └── ...                            # Other documentation files
```

## Module Organisation

### Name Lists (`name-lists/`)

The `name-lists/` directory is the authoritative source for all name list definitions. It is organised into four top-level categories:

| Category | Path | Purpose |
|----------|------|---------|
| **Generated** | `name-lists/generated/` | Name lists produced by external generators (FNG, Let's Make A Game, UNG) |
| **Media** | `name-lists/media/` | Name lists derived from recognised science-fiction and fantasy intellectual properties |
| **Real** | `name-lists/real/` | Name lists derived from real-world cultures, languages, and historical naming conventions |
| **UI** | `name-lists/ui/` | Procedurally-generated or thematic name lists for Stellaris species and factions |

Each XML file contains one or more `<NameList>` definitions conforming to the StellarisNameListGenerator schema.

### Scripts (`scripts/`)

| Script | Responsibility |
|--------|----------------|
| `build.sh` | Principal build orchestrator; drives the entire pipeline |
| `validate-data.sh` | Structural and semantic validation of all XML definitions |
| `update-builder.sh` | Downloads or caches the StellarisNameListGenerator binary |
| `common/paths.sh` | Shared configuration and path definitions |

### Build Output (`build/`, `out/`)

- `build/` — Transient intermediate files during build (merged XML inputs)
- `out/ui-name-lists/` — Final Stellaris mod directory structure ready for release

### CI/CD (`.github/workflows/`)

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `build.yml` | Push/PR to `master` | Validate and build |
| `steam-workshop.yml` | Tag push (`v*.*.*`) | Deploy to Steam Workshop |
| `nexus-mods.yml` | Tag push (`v*.*.*`) / manual | Deploy to Nexus Mods |

## File Naming Conventions

- **XML name lists**: kebab-case with descriptive names (`ui_extra_humans_african.xml`, `media_starcraft_protoss.xml`)
- **Scripts**: kebab-case with `.sh` extension (`build.sh`, `validate-data.sh`)
- **Workflows**: kebab-case with `.yml` extension (`build.yml`, `steam-workshop.yml`)
- **Documentation**: kebab-case with `.md` extension (`repository-structure.md`, `build-and-deployment.md`)

## Directory Purpose Summary

| Directory | Mutable? | Regenerated? | Description |
|-----------|----------|--------------|-------------|
| `name-lists/` | Yes (PRs) | No | Authoritative source definitions |
| `scripts/` | Yes (PRs) | No | Build automation logic |
| `.builder/` | No | Yes (cached) | External binary dependency |
| `.cache/` | No | Yes (cached) | URL validation cache |
| `build/` | No | Yes (each build) | Transient intermediate files |
| `out/` | No | Yes (each build) | Final mod output |
| `docs/` | Yes (PRs) | No | Generated documentation |