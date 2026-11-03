# Presentation Layer

## Overview

The presentation layer consists of the XML name list definitions that serve as the authoritative source for all name data. These definitions are organised into four categories and are consumed by the build pipeline to generate Stellaris-compatible mod output.

## XML Name List Definitions

### Schema

Each XML file contains one or more `<NameList>` elements conforming to the StellarisNameListGenerator schema:

```xml
<NameList>
  <Name>Display Name</Name>
  <Type>species_class</Type>
  <NameGroup>
    <Name>Group Name</Name>
    <Type>group_type</Type>
    <Values>
      <Value>Name Value</Value>
      <!-- ... -->
    </Values>
  </NameGroup>
  <!-- Additional NameGroups -->
</NameList>
```

### Element Reference

| Element | Required | Description |
|---------|----------|-------------|
| `<NameList>` | Yes | Root element for a name list definition |
| `<Name>` (NameList child) | Yes | Display name shown in Stellaris empire creation |
| `<Type>` | Yes | Species class: `human`, `mammalian`, `reptilian`, `avian`, `arthropoid`, `molluscoid`, `fungoid`, `plantoid`, `lithoid`, `machine` |
| `<NameGroup>` | Yes* | Container for a category of names (*at least one required) |
| `<Name>` (NameGroup child) | Yes | Display name for the group |
| `<Type>` (NameGroup child) | Yes | Group type: `first`, `last`, `middle`, `prefix`, `suffix`, `ship`, `fleet`, `planet`, `army`, `ruler_title` |
| `<Values>` | Yes | Container for name values |
| `<Value>` | Yes* | Individual name string (*at least one required) |
| `<Characters>` | No | Character set definition for procedural generation |
| `<Url>` | No | Attribution URL for the name list source |

### Categories

#### Real-World Cultures (`name-lists/real/`)

Organised by cultural/linguistic region:

```
real/
├── african/           # African cultures (Yoruba, Zulu, Amharic, etc.)
├── american/          # North & South American cultures
├── asian/             # East & Southeast Asian cultures
├── austronesian/      # Austronesian cultures
├── baltic/            # Baltic cultures
├── celtic/            # Celtic cultures
├── common/            # Shared definitions
├── english/           # English-speaking cultures
├── germanic/          # Germanic cultures
├── hellenic/          # Greek/Hellenic cultures
├── indian/            # Indian subcontinent cultures
├── iranian/           # Iranian/Persian cultures
├── romance/           # Romance language cultures
├── semitic/           # Semitic cultures
├── slavic/            # Slavic cultures
├── turkic/            # Turkic cultures
└── *.xml              # Individual culture files (afghan.xml, armenian.xml, etc.)
```

Each culture file typically defines first names, last names, and sometimes middle names or prefixes/suffixes appropriate to that culture.

#### Media Franchises (`name-lists/media/`)

Organised by intellectual property:

```
media/
├── alien/
├── aow/               # Age of Wonders
├── borderlands/
├── civbe/             # Civilization: Beyond Earth
├── dc/                # DC Comics
├── dishonored/
├── dnd/               # Dungeons & Dragons
├── doctor-who/
├── dune/
├── elderscrolls/      # The Elder Scrolls (Altmer, Argonian, Khajiit, etc.)
├── firefly/
├── foundation/
├── galactik-football/
├── galciv/            # Galactic Civilizations
├── gta/               # Grand Theft Auto
├── halo/
├── mass-effect/
├── middle-earth/
├── marvel/
├── narivia/
├── pandora/
├── paxnova/
├── runescape/
├── sose/              # Sins of a Solar Empire
├── space-trilogy/
├── star-trek/
├── starcraft/         # StarCraft (Terran, Protoss, Zerg)
├── starwars/
├── stellaris/         # Original Stellaris content
├── vorkosigan/        # Vorkosigan Saga
├── warcraft/
├── warhammer/         # Warhammer Fantasy & 40k
├── witcher/
├── ypp/
└── other/
```

These name lists draw from character names, place names, and naming conventions within each franchise.

#### Generated Sources (`name-lists/generated/`)

Outputs from external name generators:

```
generated/
├── fng/               # Fantasy Name Generator
├── letsmakeagame/     # Let's Make A Game
└── ung/               # Universal Name Generator
```

These provide procedurally-generated names for species where hand-curated lists are impractical.

#### UI-Facing Lists (`name-lists/ui/`)

Thematic name lists for Stellaris species classes:

```
ui/
├── art1.xml           # Arthropoid
├── avi1.xml           # Avian 1
├── avi2.xml           # Avian 2
├── fun1.xml           # Fungoid
├── hum1.xml           # Humanoid 1
├── hum2.xml           # Humanoid 2
├── hum3.xml           # Humanoid 3
├── hum4.xml           # Humanoid 4
├── human/             # Human-specific sub-lists
├── human_extra.xml    # Extra human names
├── human_zextended.xml # Extended human names
├── mam1.xml           # Mammalian 1
├── mam2.xml           # Mammalian 2
├── mam3.xml           # Mammalian 3
├── mol1.xml           # Molluscoid 1
├── mol2.xml           # Molluscoid 2
├── pla1.xml           # Plantoid 1
├── pla2.xml           # Plantoid 2
├── rep1.xml           # Reptilian 1
├── rep2.xml           # Reptilian 2
├── rep3.xml           # Reptilian 3
└── rep4.xml           # Reptilian 4
```

These define the name lists that appear directly in the Stellaris empire creation UI for each species class.

## UI Name Lists (Output)

The build pipeline produces compiled name list definitions in `out/ui-name-lists/common/name_lists/00_ui_name_lists.txt` that Stellaris reads directly. These are generated by StellarisNameListGenerator from the merged XML sources.

Each output name list corresponds to a composition variable in `build.sh` (e.g., `HUMAN_EXTENDED_NAMELISTS` → `human_extended`).

## Localisation Strings

All display names are externalised into `out/ui-name-lists/localisation/english/ui_names_l_english.yml`:

```yaml
l_english:
  ui_name_list_human_extended: "Human - Extended"
  ui_name_group_first_names: "First Names"
  ui_name_value_alexander: "Alexander"
  # ...
```

This allows translation without modifying the compiled name list definitions.

## Contribution Guidelines for Presentation Layer

1. **Follow the schema** — All XML must pass `validate-data.sh`
2. **Provide attribution** — Include `<Url>` for non-original sources
3. **Use appropriate category** — Place files in `real/`, `media/`, `generated/`, or `ui/`
4. **Maintain cultural sensitivity** — Real-world names should be respectful and accurate
5. **Test locally** — Run `scripts/build.sh` before submitting PRs