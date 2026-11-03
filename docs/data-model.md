# Data Model

## Domain Entities

### NameList

The primary domain entity representing a Stellaris name list definition.

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Unique identifier (e.g., `human_extended`, `ui_art1`) |
| `name` | string | Display name shown in Stellaris UI |
| `type` | enum | Species class: `human`, `mammalian`, `reptilian`, `avian`, `arthropoid`, `molluscoid`, `fungoid`, `plantoid`, `lithoid`, `machine` |
| `nameGroups` | NameGroup[] | Ordered collection of name groups |
| `shipNames` | ShipNameGroup[] | Optional ship name definitions |
| `fleetNames` | FleetNameGroup[] | Optional fleet name definitions |
| `planetNames` | PlanetNameGroup[] | Optional planet name definitions |
| `armyNames` | ArmyNameGroup[] | Optional army name definitions |
| `rulerTitles` | RulerTitleGroup[] | Optional ruler title definitions |
| `sourceFiles` | string[] | Source XML files that contributed to this name list |

### NameGroup

A named collection of name values within a NameList.

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Unique identifier within the NameList |
| `name` | string | Display name for the group |
| `type` | enum | Group type: `first`, `last`, `middle`, `prefix`, `suffix`, `ship`, `fleet`, `planet`, `army`, `ruler_title` |
| `values` | Value[] | Collection of name values |
| `weight` | integer | Selection weight (default: 1) |

### Value

An individual name entry within a NameGroup.

| Property | Type | Description |
|----------|------|-------------|
| `text` | string | The actual name string |
| `weight` | integer | Selection weight (default: 1) |
| `gender` | enum? | Optional gender: `male`, `female`, `neutral` |
| `sourceUrl` | string? | Optional attribution URL |

### ShipNameGroup / FleetNameGroup / PlanetNameGroup / ArmyNameGroup / RulerTitleGroup

Specialised NameGroup variants for specific Stellaris entity types. Share the same structure as NameGroup but with fixed `type` values.

## Relationships

```
NameList (1) ──────< (N) NameGroup
NameGroup (1) ────< (N) Value
NameList (1) ────< (N) ShipNameGroup
NameList (1) ────< (N) FleetNameGroup
NameList (1) ────< (N) PlanetNameGroup
NameList (1) ────< (N) ArmyNameGroup
NameList (1) ────< (N) RulerTitleGroup
```

## Persistence

### Source Format (XML)

Name lists are authored as XML files in `name-lists/` following the StellarisNameListGenerator schema:

```xml
<NameList>
  <Name>Human - Extended</Name>
  <Type>human</Type>
  <NameGroup>
    <Name>First Names</Name>
    <Type>first</Type>
    <Values>
      <Value>Alexander</Value>
      <Value>Beatrice</Value>
      <!-- ... -->
    </Values>
  </NameGroup>
  <!-- Additional NameGroups -->
</NameList>
```

### Build-Time Representation

During the build pipeline, XML files are:

1. **Validated** — Structural checks via `validate-data.sh`
2. **Merged** — Multiple source XMLs combined into composite name lists via `build.sh` composition variables (e.g., `AFRICAN_NAMELISTS`, `ARABIC_NAMELISTS`)
3. **Transformed** — Processed by StellarisNameListGenerator to produce Stellaris-compatible output

### Output Format (Stellaris Mod)

The final mod output in `out/ui-name-lists/`:

```
common/name_lists/
  00_ui_name_lists.txt          # Compiled name list definitions
localisation/english/
  ui_names_l_english.yml        # Localisation strings for all names
descriptor.mod                  # Mod metadata
thumbnail.png                   # Mod thumbnail
```

### Localisation Format (YAML)

```yaml
l_english:
  ui_name_list_human_extended: "Human - Extended"
  ui_name_group_first_names: "First Names"
  ui_name_value_alexander: "Alexander"
  # ...
```

## Composition Rules

The `build.sh` script defines composition variables that merge multiple source name lists into final output name lists:

| Composition Variable | Source Categories | Output Name List |
|---------------------|-------------------|------------------|
| `AFRICAN_NAMELISTS` | real/african, media/* | Human - African |
| `ARABIC_NAMELISTS` | real/arabic, media/* | Human - Arabic |
| `ASIAN_NAMELISTS` | real/asian, media/* | Human - Asian |
| `EUROPEAN_NAMELISTS` | real/european, media/* | Human - European |
| `HUMAN_EXTENDED_NAMELISTS` | All human categories | Human - Extended |
| `UI_ART1_NAMELISTS` | ui/art1, generated/* | Arthropoid |
| `UI_AVI1_NAMELISTS` | ui/avi1, generated/* | Avian 1 |
| ... | ... | ... |

Each composition variable is a space-separated list of source XML file paths (relative to `name-lists/`).

## Validation Constraints

Enforced by `validate-data.sh`:

1. **No double tags** — No `<NameList><NameList>` nesting
2. **No empty tags** — No `<Values></Values>` or `<Value></Value>`
3. **Single Characters element** — At most one `<Characters>` per NameList
4. **No Url in Values** — `<Url>` must not appear inside `<Values>`
5. **Name outside NameGroup** — `<Name>` must be direct child of `<NameGroup>`
6. **Well-formed nesting** — Proper XML hierarchy
7. **URL reachability** — All `<Url>` elements must return HTTP 200 (cached)

## Schema Evolution

- **Additive only** — New NameGroups, Values, or optional fields can be added
- **Breaking changes** — Removing or renaming NameGroups/Values used by downstream compositions requires updating `build.sh` composition variables
- **Version compatibility** — Output must remain compatible with Stellaris `v4.3.*`