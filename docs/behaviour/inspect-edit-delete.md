# Inspect, Edit, and Delete Behaviour

## Overview

This document describes how contributors inspect, edit, and delete name list definitions in the repository, and how maintainers manage the build pipeline.

## Inspecting Name List Definitions

### View Source XML

```bash
# View a specific name list
cat name-lists/real/african/yoruba.xml

# View all name lists in a category
cat name-lists/media/starwars/*.xml

# View UI-facing list
cat name-lists/ui/hum1.xml
```

### View Composition

```bash
# Show all composition variables
grep "_NAMELISTS=" scripts/build.sh

# Show sources for a specific composition
grep "HUMAN_EXTENDED_NAMELISTS=" scripts/build.sh
```

### View Generated Output

```bash
# After running ./scripts/build.sh

# Name list definitions (Clausewitz format)
cat out/ui-name-lists/common/name_lists/00_ui_name_lists.txt

# Localisation strings
cat out/ui-name-lists/localisation/english/ui_names_l_english.yml

# Mod descriptor
cat out/ui-name-lists/descriptor.mod
```

### Validate Specific File

```bash
# Validate all (required before commit)
./scripts/validate-data.sh

# Quick structural check on single file
grep -n "<NameList>\|<NameGroup>\|<Values>" name-lists/real/african/yoruba.xml
```

## Editing Name List Definitions

### Adding a New Name List

#### 1. Choose Category

| Content Type | Target Directory |
|--------------|------------------|
| Real-world culture | `name-lists/real/<region>/<culture>.xml` |
| Media franchise | `name-lists/media/<franchise>/<name>.xml` |
| Generated source | `name-lists/generated/<generator>/<name>.xml` |
| UI-facing species list | `name-lists/ui/<species>_<variant>.xml` |

#### 2. Create XML File

Follow the schema in `docs/components/presentation.md`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<NameList>
  <Name>Yoruba</Name>
  <Type>human</Type>
  <Url>https://en.wikipedia.org/wiki/Yoruba_name</Url>
  <NameGroup>
    <Name>First Names</Name>
    <Type>first</Type>
    <Values>
      <Value>Adebayo</Value>
      <Value>Folake</Value>
      <Value>Olumide</Value>
    </Values>
  </NameGroup>
  <NameGroup>
    <Name>Last Names</Name>
    <Type>last</Type>
    <Values>
      <Value>Adeyemi</Value>
      <Value>Okafor</Value>
      <Value>Babalola</Value>
    </Values>
  </NameGroup>
</NameList>
```

#### 3. Validate

```bash
./scripts/validate-data.sh
# Must pass with exit code 0
```

#### 4. Add to Composition

Edit `scripts/build.sh`:

```bash
# Find the appropriate composition variable
AFRICAN_NAMELISTS="real/african/yoruba.xml real/african/zulu.xml ..."

# Add your new file
AFRICAN_NAMELISTS="real/african/yoruba.xml real/african/zulu.xml real/african/new_culture.xml ..."
```

#### 5. Test Build

```bash
./scripts/build.sh
# Verify output in out/ui-name-lists/
```

### Editing an Existing Name List

#### 1. Locate File

```bash
find name-lists/ -name "*yoruba*"
# name-lists/real/african/yoruba.xml
```

#### 2. Modify XML

```bash
# Edit with your preferred editor
vim name-lists/real/african/yoruba.xml
```

#### 3. Validate

```bash
./scripts/validate-data.sh
```

#### 4. Test Build

```bash
./scripts/build.sh
```

### Editing Composition Variables

#### 1. Open build.sh

```bash
vim scripts/build.sh
```

#### 2. Modify Variable

```bash
# Before
HUMAN_EXTENDED_NAMELISTS="real/african/yoruba.xml real/african/zulu.xml media/starwars/human.xml"

# After (add new source)
HUMAN_EXTENDED_NAMELISTS="real/african/yoruba.xml real/african/zulu.xml media/starwars/human.xml real/african/new_culture.xml"
```

#### 3. Test

```bash
./scripts/validate-data.sh && ./scripts/build.sh
```

## Deleting Name List Definitions

### Remove Source File

```bash
# Delete the XML file
rm name-lists/real/african/yoruba.xml

# Remove from composition variable in build.sh
# Edit AFRICAN_NAMELISTS to remove the path
```

### Remove Entire Composition

```bash
# 1. Remove composition variable from build.sh
# 2. Remove build() call from main()
# 3. Delete associated source files (if not used elsewhere)
```

### Clean Build Artefacts

```bash
# After deletions, clean and rebuild
rm -rf build/ out/
./scripts/build.sh
```

## Modifying Build Pipeline

### Adding Validation Rule

Edit `scripts/validate-data.sh`:

```bash
# Add new check function
check_new_rule() {
    local pattern="<NewPattern>"
    if grep -r "$pattern" name-lists/; then
        echo "ERROR: New rule violation"
        return 1
    fi
}

# Add to main()
main() {
    # ... existing checks ...
    check_new_rule || exit 1
}
```

### Modifying Merge Logic

Edit `scripts/build.sh` `merge()` function:

```bash
merge() {
    local output="$1"
    shift
    local inputs=("$@")

    echo '<NameLists>' > "$output"
    for input in "${inputs[@]}"; do
        # Custom logic here
        awk '/<NameList>/,/<\/NameList>/' "name-lists/$input" >> "$output"
    done
    echo '</NameLists>' >> "$output"
}
```

### Changing Generator Version

Edit `scripts/update-builder.sh`:

```bash
BUILDER_VERSION="v1.2.4"  # Update version

# Clear cache to force re-download
rm -rf .builder/
./scripts/update-builder.sh
```

### Adding Deployment Channel

1. Create new workflow in `.github/workflows/`
2. Follow patterns in `steam-workshop.yml` and `nexus-mods.yml`
3. Add required secrets to GitHub repository settings
4. Test with manual workflow dispatch

## Common Editing Patterns

### Bulk Add Names to Existing List

```bash
# Use sed to add values
sed -i '/<Values>/a\      <Value>NewName1</Value>\n      <Value>NewName2</Value>' name-lists/real/african/yoruba.xml
```

### Rename Name List (Changes In-Game Display Name)

```xml
<!-- In source XML -->
<Name>New Display Name</Name>
```

Note: This changes the localisation key. Update composition variable if needed.

### Change Species Type

```xml
<!-- In source XML -->
<Type>mammalian</Type>  <!-- Was: human -->
```

Must also move file to appropriate UI composition or create new one.

### Add Attribution URL

```xml
<Url>https://example.com/source</Url>
```

Must be reachable (validated by `validate-data.sh`).

## Safety Checks Before Commit

```bash
# 1. Validate all
./scripts/validate-data.sh

# 2. Full build
./scripts/build.sh

# 3. Check output structure
ls -la out/ui-name-lists/
ls -la out/ui-name-lists/common/name_lists/
ls -la out/ui-name-lists/localisation/english/

# 4. Verify no regressions (compare name list count)
grep -c "name_list = {" out/ui-name-lists/common/name_lists/00_ui_name_lists.txt
```

## Rollback Procedures

### Revert Single File

```bash
git checkout HEAD -- name-lists/real/african/yoruba.xml
```

### Revert Composition Change

```bash
git checkout HEAD -- scripts/build.sh
```

### Revert Entire Build

```bash
git checkout HEAD -- scripts/ name-lists/
rm -rf build/ out/ .builder/ .cache/
./scripts/build.sh
```