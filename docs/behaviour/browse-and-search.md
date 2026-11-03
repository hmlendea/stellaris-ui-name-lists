# Browse and Search Behaviour

## Overview

This document describes how end users (Stellaris players) browse and select name lists in the game, and how contributors discover and select name list definitions in the repository.

## In-Game Name List Selection (End User)

### Empire Creation Flow

1. **Open Empire Creation** — Player starts new game or creates custom empire
2. **Select Species Class** — Choose from: Human, Mammalian, Reptilian, Avian, Arthropoid, Molluscoid, Fungoid, Plantoid, Lithoid, Machine
3. **Open Name List Dropdown** — UI shows available name lists for selected species class
4. **Browse Name Lists** — Lists displayed with display names (e.g., "Human - Extended", "Human - African", "Mammalian 1")
5. **Select Name List** — Player chooses one name list for the empire
6. **Preview Names** — Optional: game shows sample names from selected list
7. **Confirm** — Empire created with selected name list

### Name Lists by Species Class

| Species Class | Available Name Lists (Examples) |
|---------------|----------------------------------|
| Human | Human - Extended, Human - African, Human - Arabic, Human - Asian, Human - European, Human - Norse, Human - Roman (SPQR), Human - Star Wars, Human - StarCraft, Human - RuneScape, Human - Elder Scrolls, Human - Warhammer 40k, Human - Witcher, Human - Dune, Human - Foundation, Human - Mass Effect, Human - Halo, Human - Dishonored, Human - Cyberpunk, Human - Fallout, Human - Metro, Human - S.T.A.L.K.E.R., Human - Vampire, Human - Zombie, Human - Extra, Human - ZExtended |
| Mammalian | Mammalian 1, Mammalian 2, Mammalian 3, Extra Mammalian 1, Extra Mammalian 2, Extra Mammalian 3 |
| Reptilian | Reptilian 1, Reptilian 2, Reptilian 3, Reptilian 4, Extra Reptilian 1-4, Lizard, Fantasy Spider, FNG Lizardfolk, Goblin, Orc, Narivia Rodah |
| Avian | Avian 1, Avian 2, Extra Avian 1, Extra Avian 2, GalCiv Yor |
| Arthropoid | Arthropoid 1, Extra Arthropoid 1 |
| Molluscoid | Molluscoid 1, Molluscoid 2, Extra Molluscoid 1, Extra Molluscoid 2 |
| Fungoid | Fungoid 1, Extra Fungoid 1 |
| Plantoid | Plantoid 1, Plantoid 2, Extra Plantoid 1, Extra Plantoid 2 |
| Lithoid | (Uses base game lists) |
| Machine | (Uses base game lists) |

### Search and Filter (In-Game)

- **No built-in search** — Stellaris UI shows all lists for species class in dropdown
- **Naming convention** — Lists prefixed by species class for grouping
- **Extended variants** — "Extended", "Extra", "ZExtended" suffixes indicate larger lists

## Repository Name List Discovery (Contributor)

### Finding Name Lists by Category

#### Real-World Cultures

```
name-lists/real/
├── african/           # Browse by region
├── american/          # North/South America
├── asian/             # East/Southeast Asia
├── austronesian/      # Pacific/Indian Ocean
├── baltic/            # Baltic states
├── celtic/            # Celtic nations
├── english/           # Anglosphere
├── germanic/          # Germanic Europe
├── hellenic/          # Greece/Cyprus
├── indian/            # South Asia
├── iranian/           # Iran/Central Asia
├── romance/           # Romance languages
├── semitic/           # Middle East/North Africa
├── slavic/            # Eastern Europe
├── turkic/            # Central Asia/Turkey
└── *.xml              # Individual cultures (afghan.xml, armenian.xml, etc.)
```

#### Media Franchises

```
name-lists/media/
├── elderscrolls/      # Altmer, Argonian, Dremora, Khajiit, Orc, Spriggan
├── starwars/          # Human, Twi'lek, etc.
├── starcraft/         # Terran, Protoss, Zerg
├── warhammer/         # 40k Imperium, Chaos, Eldar, Orks
├── witcher/           # Human, Elf, Dwarf, Monster
├── dune/              # Fremen, Noble Houses
├── mass-effect/       # Human, Asari, Turian, etc.
├── halo/              # UNSC, Covenant
├── star-trek/         # Federation, Klingon, Romulan
├── dnd/               # Human, Elf, Dwarf, Halfling, etc.
├── runescape/         # Human, Elf, Dwarf, etc.
└── ...                # 30+ franchises
```

#### Generated Sources

```
name-lists/generated/
├── fng/               # Fantasy Name Generator
├── letsmakeagame/     # Let's Make A Game
└── ung/               # Universal Name Generator
```

#### UI-Facing Lists

```
name-lists/ui/
├── hum1.xml - hum4.xml           # Humanoid variants
├── human_extra.xml               # Additional human names
├── human_zextended.xml           # Extended human names
├── human/                        # Human sub-lists
├── mam1.xml - mam3.xml           # Mammalian variants
├── rep1.xml - rep4.xml           # Reptilian variants
├── avi1.xml - avi2.xml           # Avian variants
├── art1.xml                      # Arthropoid
├── fun1.xml                      # Fungoid
├── mol1.xml - mol2.xml           # Molluscoid
├── pla1.xml - pla2.xml           # Plantoid
└── extra_*.xml                   # Extra variants for each class
```

### Searching in Repository

#### By File Name (GitHub/Git)

```bash
# Find all human-related name lists
find name-lists/ -name "*human*" -o -name "*Human*"

# Find all elven name lists
find name-lists/ -name "*elf*" -o -name "*Elf*" -o -name "*altmer*" -o -name "*Altmer*"

# Find all orc name lists
find name-lists/ -name "*orc*" -o -name "*Orc*"
```

#### By Content (grep)

```bash
# Find name lists containing specific name
grep -r "Alexander" name-lists/

# Find name lists of specific type
grep -r "<Type>human</Type>" name-lists/

# Find name lists with specific group
grep -r "<Name>First Names</Name>" name-lists/
```

#### By Composition (build.sh)

```bash
# View all composition variables
grep "_NAMELISTS=" scripts/build.sh

# View sources for specific composition
grep "HUMAN_EXTENDED_NAMELISTS=" scripts/build.sh
```

### Selecting Name Lists for Composition

#### Adding to Existing Composition

1. Identify target composition variable in `build.sh` (e.g., `AFRICAN_NAMELISTS`)
2. Add source XML path to the variable
3. Ensure source file exists in `name-lists/`
4. Run `./scripts/validate-data.sh` to validate
5. Run `./scripts/build.sh` to test

#### Creating New Composition

1. Create source XML in appropriate `name-lists/` subdirectory
2. Add new composition variable in `build.sh`
3. Add `build()` call in `main()` function
4. Test with `./scripts/build.sh`

### Previewing Name List Content

#### View Source XML

```bash
cat name-lists/real/african/yoruba.xml
```

#### View Generated Output (after build)

```bash
# Name list definition
cat out/ui-name-lists/common/name_lists/00_ui_name_lists.txt | grep -A 50 "human_extended"

# Localisation
grep "human_extended" out/ui-name-lists/localisation/english/ui_names_l_english.yml
```

#### In-Game Preview

1. Build mod: `./scripts/build.sh`
2. Copy to Stellaris mod directory
3. Launch Stellaris, create empire, select name list

## Navigation Aids

### For End Users

- **Mod description** — Lists major name list categories on Steam/Nexus/Paradox pages
- **In-game tooltips** — Hover shows species class compatibility
- **Naming convention** — "Human - [Culture]" for human lists; "[Class] [Number]" for others

### For Contributors

- **README.md** — Project overview and structure
- **docs/repository-structure.md** — Detailed source tree
- **docs/components/presentation.md** — XML schema and categories
- **docs/components/host-and-composition.md** — Composition variables
- **build.sh** — Single source of truth for all compositions