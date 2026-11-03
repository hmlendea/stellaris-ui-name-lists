# API Usage Examples

> **Note**: This project has no public API. This document provides usage examples for the *data contracts* and *CLI interfaces* that constitute the system's integration surface.

## XML Name List Definition

### Minimal Valid Name List

```xml
<NameList>
    <Name>my_custom_list</Name>
    <DisplayName>My Custom Names</DisplayName>
    <SpeciesClass>HUMANOID</SpeciesClass>
    <Url>https://example.com/source</Url>
    <NameGroup>
        <Name>default</Name>
        <Chance>100</Chance>
        <Value>Name One</Value>
        <Value>Name Two</Value>
        <Value>Name Three</Value>
    </NameGroup>
</NameList>
```

### Multiple Name Groups with Weights

```xml
<NameList>
    <Name>weighted_example</Name>
    <DisplayName>Weighted Names</DisplayName>
    <SpeciesClass>MAMMALIAN</SpeciesClass>
    <Url>https://example.com/source</Url>
    <NameGroup>
        <Name>common</Name>
        <Chance>80</Chance>
        <Value>Common Name 1</Value>
        <Value>Common Name 2</Value>
    </NameGroup>
    <NameGroup>
        <Name>rare</Name>
        <Chance>20</Chance>
        <Value>Rare Name 1</Value>
        <Value>Rare Name 2</Value>
    </NameGroup>
</NameList>
```

### Real-World Culture Example (African)

```xml
<NameList>
    <Name>african_yoruba</Name>
    <DisplayName>Yoruba Names</DisplayName>
    <SpeciesClass>HUMANOID</SpeciesClass>
    <Url>https://en.wikipedia.org/wiki/Yoruba_name</Url>
    <NameGroup>
        <Name>male</Name>
        <Chance>50</Chance>
        <Value>Adebayo</Value>
        <Value>Chinedu</Value>
        <Value>Olumide</Value>
    </NameGroup>
    <NameGroup>
        <Name>female</Name>
        <Chance>50</Chance>
        <Value>Abimbola</Value>
        <Value>Chinwe</Value>
        <Value>Olufunke</Value>
    </NameGroup>
</NameList>
```

### Media Universe Example (Elder Scrolls)

```xml
<NameList>
    <Name>elderscrolls_altmer</Name>
    <DisplayName>Altmer (High Elf)</DisplayName>
    <SpeciesClass>HUMANOID</SpeciesClass>
    <Url>https://en.uesp.net/wiki/Lore:Altmer</Url>
    <NameGroup>
        <Name>male</Name>
        <Chance>50</Chance>
        <Value>Aicantar</Value>
        <Value>Calcelmo</Value>
        <Value>Ondolemar</Value>
    </NameGroup>
    <NameGroup>
        <Name>female</Name>
        <Chance>50</Chance>
        <Value>Elenwen</Value>
        <Value>Niranye</Value>
        <Value>Taarie</Value>
    </NameGroup>
</NameList>
```

## Build Commands

### Full Build

```bash
./scripts/build.sh
```

### Clean Build

```bash
rm -rf build/ out/ release/
./scripts/build.sh
```

### Validation Only

```bash
./scripts/validate-data.sh
```

### Verbose Validation

```bash
./scripts/validate-data.sh --verbose
```

### Force Cache Refresh

```bash
./scripts/validate-data.sh --no-cache
```

### Update Generator Binary

```bash
./scripts/update-builder.sh --force
```

### Specific Version

```bash
./scripts/update-builder.sh --version v1.3.0
```

## Generator Direct Usage

### Basic Invocation

```bash
.builder/StellarisNameListGenerator \
    --input build/merged_african_names.xml \
    --output /tmp/test_name_lists \
    --localisation /tmp/test_loc \
    --mod-name "Test Mod" \
    --mod-version "1.0.0"
```

### With Custom Paths

```bash
.builder/StellarisNameListGenerator \
    --input /path/to/merged.xml \
    --output /path/to/output/name_lists \
    --localisation /path/to/output/localisation \
    --mod-name "My Mod" \
    --mod-version "2.0.0"
```

## CI/CD Workflows

### Trigger Build (Push to Master)

```bash
git push origin master
# Triggers .github/workflows/build.yml
```

### Trigger Build (Pull Request)

```bash
git push origin feature-branch
# Open PR → triggers build.yml
```

### Trigger Release (Tag Push)

```bash
git tag -a v1.2.4 -m "Release v1.2.4"
git push origin v1.2.4
# Triggers steam-workshop.yml + nexus-mods.yml
```

### Manual Nexus Deploy

```bash
# Via GitHub Actions UI:
# Actions → Nexus Mods Deploy → Run workflow
# Input: version = v1.2.4
```

## Output Inspection

### Check Generated Name Lists

```bash
# List all generated name list files
ls out/ui-name-lists/common/name_lists/

# View main name list file
cat out/ui-name-lists/common/name_lists/00_ui_name_lists.txt

# Count name lists
grep -c "name_list = {" out/ui-name-lists/common/name_lists/00_ui_name_lists.txt
```

### Check Localisation

```bash
# View localisation files
ls out/ui-name-lists/localisation/english/

# View specific localisation
cat out/ui-name-lists/localisation/english/ui_name_lists_l_english.yml

# Search for specific key
grep "african_yoruba" out/ui-name-lists/localisation/english/*.yml
```

### Check Mod Descriptor

```bash
cat out/ui-name-lists/descriptor.mod
```

### Verify Release Artefact

```bash
# List release directory
ls release/

# Inspect ZIP contents
unzip -l release/ui-name-lists_v1.2.3.zip
```

## Validation Debugging

### Check Specific File

```bash
# Validate single XML file
xmllint --noout name-lists/real/african.xml

# Check for specific patterns
grep -n "<Value>" name-lists/real/african.xml
grep -n "<Url>" name-lists/real/african.xml
```

### URL Validation Debug

```bash
# Test single URL
curl -sfI --max-time 10 "https://en.wikipedia.org/wiki/Yoruba_name"

# Check cache
cat .cache/url_*

# Clear cache
rm -rf .cache/
```

## Composition Examples

### Adding to Existing Composition (in build.sh)

```bash
# Find existing variable
AFRICAN_NAMELISTS="name-lists/real/african.xml name-lists/generated/african_extra.xml"

# Add new source
AFRICAN_NAMELISTS="name-lists/real/african.xml name-lists/generated/african_extra.xml name-lists/real/african_yoruba.xml"

# Build will automatically include it
```

### Creating New Composition (in build.sh)

```bash
# Define new variable
MY_CUSTOM_NAMELISTS="name-lists/real/my_custom.xml name-lists/media/my_media.xml"

# Add to build calls
build "my_custom" "My Custom Names" "$MY_CUSTOM_NAMELISTS"
```

## Error Handling Examples

### Validation Failure

```bash
$ ./scripts/validate-data.sh
[ERROR] V002: Empty tags found in name-lists/real/african.xml
[ERROR] Validation failed
```

### Build Failure

```bash
$ ./scripts/build.sh
[INFO] Building: african_names
[ERROR] Generator failed with exit code 2
[ERROR] Build failed
```

### Fix and Retry

```bash
# Fix the XML
vim name-lists/real/african.xml

# Re-validate
./scripts/validate-data.sh

# Rebuild
./scripts/build.sh
```

## Stellaris Integration

### Install Mod for Testing

```bash
# Linux
cp -r out/ui-name-lists/ ~/.local/share/Paradox\ Interactive/Stellaris/mod/ui-name-lists-test

# macOS
cp -r out/ui-name-lists/ ~/Library/Application\ Support/Paradox\ Interactive/Stellaris/mod/ui-name-lists-test

# Windows (WSL2)
cp -r out/ui-name-lists/ /mnt/c/Users/<USER>/Documents/Paradox\ Interactive/Stellaris/mod/ui-name-lists-test
```

### Enable in Launcher

1. Launch Stellaris
2. Open "Mods" tab
3. Enable "Universum Infinitum: Name Lists"
4. Click "Play"

### Verify In-Game

1. Start new game
2. Create custom empire
3. Select species class matching name list
4. Verify name list appears in naming dropdowns

## Common Patterns

### Pattern: Add Real-World Culture

```bash
# 1. Create XML
cat > name-lists/real/new_culture.xml << 'EOF'
<NameList>
    <Name>new_culture</Name>
    <DisplayName>New Culture Names</DisplayName>
    <SpeciesClass>HUMANOID</SpeciesClass>
    <Url>https://example.com/source</Url>
    <NameGroup>
        <Name>default</Name>
        <Chance>100</Chance>
        <Value>Name 1</Value>
        <Value>Name 2</Value>
    </NameGroup>
</NameList>
EOF

# 2. Validate
./scripts/validate-data.sh

# 3. Add to composition in build.sh
# Edit scripts/build.sh, add to appropriate variable

# 4. Build
./scripts/build.sh
```

### Pattern: Add Media Universe

```bash
# 1. Create XML in name-lists/media/
# 2. Use appropriate SpeciesClass
# 3. Add to composition variable in build.sh
# 4. Validate and build
```

### Pattern: Debug Generator Output

```bash
# 1. Run generator manually with test input
.builder/StellarisNameListGenerator \
    --input build/merged_my_list.xml \
    --output /tmp/debug_out \
    --localisation /tmp/debug_loc \
    --mod-name "Debug" \
    --mod-version "1.0.0"

# 2. Inspect output
cat /tmp/debug_out/00_ui_name_lists.txt
cat /tmp/debug_loc/*.yml
```

### Pattern: Clean Everything

```bash
# Nuclear option
rm -rf build/ out/ release/ .builder/ .cache/
./scripts/build.sh
```