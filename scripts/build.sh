#!/bin/bash

STARTDIR="$(pwd)"
SCRIPTSDIR="${STARTDIR}/scripts"

MOD_ID="ui-name-lists"
MOD_NAME="Universum Infinitum - Name Lists"
STELLARIS_VERSION="3.2.*"

BUILD_DIRECTORY_PATH="${STARTDIR}/build"
OUTPUT_DIRECTORY_PATH="${STARTDIR}/out"
OUTPUT_MOD_DIRECTORY_PATH="${OUTPUT_DIRECTORY_PATH}/${MOD_ID}"
OUTPUT_NAMELISTS_DIRECTORY_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/common/name_lists"
OUTPUT_LOCALISATION_DIRECTORY_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/localisation/english"
OUTPUT_LOCALISATION_FILE_PATH="${OUTPUT_LOCALISATION_DIRECTORY_PATH}/ui_names_l_english.yml"
GENERATOR_EXECUTABLE="${STARTDIR}/stellaris-name-list-generator/StellarisNameListGenerator"

MOD_THUMBNAIL_FILE_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/thumbnail.png"
MOD_DESCRIPTOR_PRIMARY_FILE_PATH="${OUTPUT_DIRECTORY_PATH}/${MOD_ID}.mod"
MOD_DESCRIPTOR_SECONDARY_FILE_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/descriptor.mod"

if [[ $* != *--skip-updates* ]]; then
    "${SCRIPTSDIR}"/update-builder.sh
fi

if [[ $* != *--skip-validation* ]]; then
    echo "Validating the files..."
    VALIDATE_DATA="$(scripts/validate-data.sh | tr '\0' '\n')"
    if [ -n "${VALIDATE_DATA}" ]; then
        echo "Input files validation failed!"
        echo "${VALIDATE_DATA}"
        exit 1
    fi
fi

[ ! -d "${BUILD_DIRECTORY_PATH}" ] && mkdir -p "${BUILD_DIRECTORY_PATH}"
[ ! -d "${OUTPUT_DIRECTORY_PATH}" ] && mkdir -p "${OUTPUT_DIRECTORY_PATH}"
[ ! -d "${OUTPUT_NAMELISTS_DIRECTORY_PATH}" ] && mkdir -p "${OUTPUT_NAMELISTS_DIRECTORY_PATH}"
[ ! -d "${OUTPUT_LOCALISATION_DIRECTORY_PATH}" ] && mkdir -p "${OUTPUT_LOCALISATION_DIRECTORY_PATH}"

printf '\xEF\xBB\xBF' > ${OUTPUT_LOCALISATION_FILE_PATH}
printf "l_english:\n" >> ${OUTPUT_LOCALISATION_FILE_PATH}

function merge {
    OUTPUT_FILE_NAME=$1
    shift 1

    head -2 "./name-lists/$1.xml" > "${OUTPUT_FILE_NAME}"

    for NAME_LIST in "$@"; do
        tail -n +3 "./name-lists/${NAME_LIST}.xml" | head -n -1 >> "${OUTPUT_FILE_NAME}"
        echo " " >> "${OUTPUT_FILE_NAME}"
    done

    tail -1 "./name-lists/$1.xml" >> "${OUTPUT_FILE_NAME}"
}

function add-localisation {
    NAMELIST_ID=$1
    NAMELIST_FILE_PATH="${OUTPUT_NAMELISTS_DIRECTORY_PATH}/${NAMELIST_ID}.txt"

    NAMELIST_NAME=$(sed -n '2{p;q}' ${OUTPUT_NAMELIST_FILE_PATH} | tail -c +5)
    NAMELIST_LEADERS=$(sed -n '3{p;q}' ${OUTPUT_NAMELIST_FILE_PATH} | tail -c +14)
    NAMELIST_SHIPS=$(sed -n '4{p;q}' ${OUTPUT_NAMELIST_FILE_PATH} | tail -c +12)
    NAMELIST_FLEETS=$(sed -n '5{p;q}' ${OUTPUT_NAMELIST_FILE_PATH} | tail -c +13)
    NAMELIST_COLONIES=$(sed -n '6{p;q}' ${OUTPUT_NAMELIST_FILE_PATH} | tail -c +15)

    echo " name_list_${NAMELIST_ID}:0 \"${NAMELIST_NAME}\"" >> ${OUTPUT_LOCALISATION_FILE_PATH}
    echo " name_list_${NAMELIST_ID}_desc:0 \"§YLeaders:§! ${NAMELIST_LEADERS}\n§YShips:§! ${NAMELIST_SHIPS}\n§YFleets:§! ${NAMELIST_FLEETS}\n§YColonies:§! ${NAMELIST_COLONIES}\"" >> ${OUTPUT_LOCALISATION_FILE_PATH}
}

function build {
    NAMELIST_ID=$1 && shift
    NAMELIST_NAME=$1 && shift
    NAMELIST_ISLOCKED=$1 && shift
    NAMELIST_FILE_PATH="${BUILD_DIRECTORY_PATH}/${NAMELIST_ID}.xml"
    OUTPUT_NAMELIST_FILE_PATH="${OUTPUT_NAMELISTS_DIRECTORY_PATH}/${NAMELIST_ID}.txt"

    echo "Building ${NAMELIST_ID}..."

    GENERATOR_EXECUTABLE_WITH_ARGS=${GENERATOR_EXECUTABLE}
    [ "${NAMELIST_ISLOCKED}" == "L" ] && GENERATOR_EXECUTABLE_WITH_ARGS="${GENERATOR_EXECUTABLE} --locked"

    merge ${NAMELIST_FILE_PATH} $@
    ${GENERATOR_EXECUTABLE_WITH_ARGS} -i "${NAMELIST_FILE_PATH}" -o "${OUTPUT_NAMELIST_FILE_PATH}" -n "${NAMELIST_NAME}"
    add-localisation ${NAMELIST_ID}
}

function generate-mod-descriptor {
    FILE_PATH=$1

    echo "name=\"${MOD_NAME}\"" > ${FILE_PATH}
    echo "path=\"mod/${MOD_ID}\"" >> ${FILE_PATH}
    echo "tags={" >> ${FILE_PATH}
    echo "  \"Species\"" >> ${FILE_PATH}
    echo "}" >> ${FILE_PATH}
    echo "supported_version=\"${STELLARIS_VERSION}\"" >> ${FILE_PATH}
}

build "ui_extra_humans_african"         "Human - African"           "L" \
    real/algerian real/angolan real/congolese real/ethiopian real/french_ivory real/kabyle real/malian real/mauritanian \
    real/nigerian real/senegalese real/shona real/somali real/swahili real/tswana real/tunisian real/yoruba real/zambian \
    real/zulu real/african real/common/african \
    media/other/human/african media/other/human/shona media/other/human/somali media/other/human/swahili media/other/human/tswana \
    media/other/human/xhosa media/other/human/zulu
build "ui_extra_humans_american_north"  "Human - American NA"       "L" \
    real/american real/canadian \
    real/common/english \
    media/other/human/american media/other/human/canadian \
    media/other/human/english_int
build "ui_extra_humans_american_usa"    "Human - American USA"      "L" \
    real/american \
    real/common/english \
    media/other/human/american \
    media/other/human/english_int
build "ui_extra_humans_arabic"          "Human - Arabic"            "L" \
    real/egyptian real/jordanian real/syrian \
    real/arabic \
    media/other/human/arabic media/runescape/human_kharidian
build "ui_extra_humans_asian"           "Human - Asian"             "L" \
    real/chinese real/japanese real/korean real/mongol real/taiwanese real/tibetan real/vietnamese \
    real/common/asian \
    media/other/human/chinese media/other/human/japanese media/other/human/korean media/other/human/tibetan media/other/human/vietnamese
build "ui_extra_humans_austronesian"    "Human - Austronesian"      "L" \
    real/filipino real/hawaiian real/indonesian real/kiribatian real/malaysian real/maori real/polynesian \
    real/austronesian \
    media/other/human/filipino media/other/human/indonesian media/other/human/malaysian media/other/human/maori
build "ui_extra_humans_british"         "Human - British"           "L" \
    real/english real/scottish real/welsh \
    real/common/british real/common/english \
    media/other/human/british media/other/human/english media/other/human/scottish \
    media/other/human/english_int
build "ui_extra_humans_celtic"          "Human - Celtic"            "L" \
    real/breton real/cornish real/icenic real/irish real/scottish real/welsh \
    real/celtic real/common/celtic \
    media/other/human/celtic media/other/human/irish media/other/human/scottish
build "ui_extra_humans_chinese"         "Human - Chinese"           "L" \
    real/chinese real/taiwanese \
    real/common/asian \
    media/other/human/chinese
build "ui_extra_humans_english"         "Human - English"           "L" \
    real/american real/australian real/canadian real/english real/zealandian \
    real/common/british real/common/english \
    media/other/human/american media/other/human/australian media/other/human/british media/other/human/canadian media/other/human/english \
    media/other/human/english_int
build "ui_extra_humans_european"        "Human - European"          "L" \
    real/austrian real/belarusian real/basque real/bosnian real/breton real/bulgarian real/catalan real/celtic real/cornish real/croatian \
    real/cypriote real/czech real/danish real/dutch real/english real/estonian real/finnish real/french real/german real/germanic real/greek \
    real/hungarian real/icelandic real/icenic real/italian real/irish real/latvian real/lithuanian real/norwegian real/polish real/portuguese \
    real/roman real/romanian real/russian real/scottish real/serbian real/slovakian real/slovenian real/spanish real/swedish real/swiss \
    real/ukrainian real/welsh \
    \
    real/common/british real/common/celtic real/common/english real/common/european real/common/german \
    real/common/hellenic real/common/iberian media/other/human/italian real/common/norse real/common/portuguese real/common/slavic real/common/spanish \
    real/common/yugoslavic real/common/_ \
    \
    media/aow/dvar media/elderscrolls/atmoran media/elderscrolls/nord \
    media/runescape/human_asgarnian media/runescape/human_kandarin media/runescape/human_misthalinian media/runescape/human \
    media/other/human/austrian media/other/human/basque media/other/human/belarusian media/other/human/british media/other/human/catalan media/other/human/celtic \
    media/other/human/czech media/other/human/danish media/other/human/english media/other/human/french media/other/human/german media/other/human/hellenic \
    media/other/human/icelandic media/other/human/irish media/other/human/latin media/other/human/norse media/other/human/norwegian media/other/human/polish \
    media/other/human/portuguese media/other/human/romanian media/other/human/russian media/other/human/scottish media/other/human/slavic media/other/human/spanish \
    media/other/human/swedish media/other/human/swiss media/other/human/ukrainian \
    media/other/human/english_int
build "ui_extra_humans_franco-iberian"  "Human - Franco-Iberian"    "L" \
    real/basque real/catalan real/french real/portuguese real/spanish real/common/iberian real/common/portuguese \
    real/common/spanish real/common/european \
    media/other/human/basque media/other/human/catalan media/other/human/french media/other/human/portuguese media/other/human/spanish
build "ui_extra_humans_french"          "Human - French EU"         "L" \
    real/french \
    real/common/european \
    media/other/human/french
build "ui_extra_humans_french_int"      "Human - French INT"        "L" \
    real/french real/french_ivory \
    media/other/human/french
build "ui_extra_humans_german"          "Human - German"            "L" \
    real/austrian real/german real/swiss \
    real/common/european real/common/german \
    media/other/human/austrian media/other/human/german media/other/human/swiss
build "ui_extra_humans_germanic"        "Human - Germanic"          "L" \
    real/austrian real/danish real/dutch real/german real/icelandic real/norwegian real/swedish real/swiss \
    real/germanic real/common/european real/common/german real/common/norse \
    media/elderscrolls/atmoran media/elderscrolls/nord \
    media/other/human/austrian media/other/human/danish media/other/human/german media/other/human/icelandic media/other/human/norse media/other/human/norwegian \
    media/other/human/swedish media/other/human/swiss
build "ui_extra_humans_hellenic"        "Human - Hellenic"          "L" \
    real/cypriote real/greek \
    real/common/european real/common/hellenic \
    media/other/human/hellenic
build "ui_extra_humans_hindi"           "Human - Hindi"             "L" \
    real/bengal real/indian real/nepali real/tamil real/urdu real/hindi \
    media/other/human/hindi media/other/human/indian media/other/human/sanskrit media/other/human/tamil media/other/human/urdu
build "ui_extra_humans_iberian"         "Human - Iberian"           "L" \
    real/basque real/catalan real/portuguese real/spanish \
    real/common/european real/common/iberian real/common/portuguese \
    real/common/spanish \
    media/other/human/basque media/other/human/catalan media/other/human/portuguese media/other/human/spanish
build "ui_extra_humans_italian"         "Human - Italian"           "L" \
    real/italian \
    real/common/european \
    media/other/human/italian
build "ui_extra_humans_japanese"        "Human - Japanese"          "L" \
    real/japanese \
    media/other/human/japanese
build "ui_extra_humans_latino"          "Human - Latino"            "L" \
    real/argentinian real/brazilian real/colombian real/cuban real/ecuadorian real/guatemalan real/mexican real/nahuatl \
    real/venezuelan real/common/spanish_americano real/common/portuguese real/common/spanish \
    media/other/human/mexican media/other/human/portuguese media/other/human/spanish media/other/human/venezuelan
build "ui_extra_humans_norse"           "Human - Norse"             "L" \
    real/danish real/icelandic real/norwegian real/swedish \
    real/common/norse \
    media/elderscrolls/atmoran media/elderscrolls/nord \
    media/other/human/danish media/other/human/icelandic media/other/human/norse media/other/human/norwegian media/other/human/swedish
build "ui_extra_humans_portuguese"      "Human - Portuguese EU"     "L" \
    real/portuguese \
    real/common/european real/common/iberian real/common/portuguese \
    media/other/human/portuguese
build "ui_extra_humans_portuguese_int"  "Human - Portuguese INT"    "L" \
    real/angolan real/brazilian real/portuguese \
    real/common/iberian real/common/portuguese \
    media/other/human/portuguese
build "ui_extra_humans_romanian"        "Human - Romanian"          "L" \
    real/romanian \
    real/common/european \
    media/other/human/romanian
build "ui_extra_humans_romance"         "Human - Romance"           "L" \
    real/argentinian real/brazilian real/catalan real/colombian real/cuban real/ecuadorian real/french real/french_ivory real/guatemalan \
    real/italian real/mexican real/portuguese real/roman real/romanian real/spanish real/venezuelan \
    real/common/iberian real/common/portuguese real/common/spanish_americano real/common/spanish \
    media/other/human/catalan media/other/human/french media/other/human/italian media/other/human/latin media/other/human/portuguese \
    media/other/human/romanian media/other/human/spanish media/other/human/venezuelan
build "ui_extra_humans_russian"         "Human - Russian"           "L" \
    real/russian \
    real/common/slavic \
    media/aow/dvar media/other/human/russian media/other/human/slavic
build "ui_extra_humans_slavic"          "Human - Slavic"            "L" \
    real/belarusian real/bosnian real/bulgarian real/croatian real/czech real/polish real/russian real/serbian real/slovakian \
    real/slovenian real/ukrainian real/common/slavic real/common/yugoslavic \
    media/aow/dvar \
    media/other/human/belarusian media/other/human/croatian media/other/human/czech media/other/human/polish media/other/human/russian \
    media/other/human/slavic media/other/human/ukrainian
build "ui_extra_humans_spqr_extended"   "Human - Roman"             "L" \
    real/roman \
    real/common/european \
    real/human3 media/other/human/latin
build "ui_extra_humans_turkic"          "Human - Turkic"            "L" \
    real/turkish real/turkmen real/uyghur \
    real/common/turkic \
    media/other/human/turkish
build "ui_extra_humans_yugoslavic"      "Human - Yugoslavic"        "L" \
    real/bosnian real/croatian real/serbian real/slovenian \
    real/common/european real/common/slavic real/common/yugoslavic \
    media/other/human/croatian media/other/human/slavic
build "ui_extra_humans_extended"        "Human - *Extended*"          "L" \
    real/afghan real/african real/algerian real/american real/angolan real/arabic real/argentinian real/armenian real/australian real/austrian real/austronesian \
    real/belarusian real/basque real/bosnian real/bengal real/brazilian real/breton real/bulgarian real/canadian real/catalan real/celtic real/chinese real/colombian \
    real/congolese real/cornish real/croatian real/cuban real/cypriote real/czech real/danish real/dutch real/ecuadorian real/egyptian real/english real/estonian \
    real/ethiopian real/filipino real/finnish real/french real/french_ivory real/german real/germanic real/greek real/greenlandic real/guatemalan real/hawaiian \
    real/hebrew real/hindi real/hungarian real/icelandic real/icenic real/indian real/indonesian real/iranian real/italian real/irish real/japanese real/jordanian \
    real/kabyle real/kazakh real/kiribatian real/korean real/latvian real/lithuanian real/malaysian real/malian real/maori real/mauritanian real/mexican real/mongol \
    real/nahuatl real/nepali real/nigerian real/norwegian real/persian real/polish real/polynesian real/portuguese real/roman real/romanian real/russian real/scottish \
    real/senegalese real/serbian real/shona real/slovakian real/slovenian real/somali real/spanish real/swahili real/swedish real/swiss real/syrian real/taiwanese \
    real/tajik real/tamil real/tibetan real/tswana real/tunisian real/turkish real/turkmen real/ukrainian real/urdu real/uyghur real/venezuelan real/vietnamese \
    real/welsh real/yoruba real/zambian real/zealandian real/zulu \
    \
    real/common/african real/common/asian real/common/british real/common/celtic real/common/english real/common/european real/common/german real/common/hellenic \
    real/common/iberian real/common/norse real/common/portuguese real/common/slavic real/common/spanish_americano real/common/spanish real/common/turkic \
    real/common/yugoslavic real/common/_ \
    \
    media/aow/dvar media/elderscrolls/atmoran media/elderscrolls/human media/elderscrolls/nord \
    media/galciv/human media/sose/human media/starcraft/human media/starwars/human \
    media/runescape/human_asgarnian media/runescape/human_kandarin media/runescape/human_kharidian media/runescape/human_menaphite media/runescape/human_misthalinian \
    media/runescape/human \
    media/other/human/african media/other/human/american media/other/human/arabic media/other/human/armenian media/other/human/australian media/other/human/austrian \
    media/other/human/basque media/other/human/belarusian media/other/human/british media/other/human/canadian media/other/human/catalan media/other/human/celtic \
    media/other/human/chinese media/other/human/croatian media/other/human/czech media/other/human/danish media/other/human/english media/other/human/english_int \
    media/other/human/filipino media/other/human/french media/other/human/german media/other/human/hebrew media/other/human/hellenic media/other/human/hindi \
    media/other/human/icelandic media/other/human/indian media/other/human/indonesian media/other/human/irish media/other/human/italian media/other/human/japanese \
    media/other/human/korean media/other/human/latin media/other/human/malaysian media/other/human/maori media/other/human/mexican media/other/human/mongol \
    media/other/human/norse media/other/human/norwegian media/other/human/polish media/other/human/portuguese media/other/human/romanian media/other/human/russian \
    media/other/human/shona media/other/human/slavic media/other/human/spanish media/other/human/sanskrit media/other/human/scottish media/other/human/somali \
    media/other/human/swahili media/other/human/swedish media/other/human/swiss media/other/human/tamil media/other/human/tibetan media/other/human/tswana \
    media/other/human/turkish media/other/human/ukrainian media/other/human/urdu media/other/human/venezuelan media/other/human/vietnamese media/other/human/xhosa \
    media/other/human/zulu media/other/human/_ \
    \
    real/human1 real/human2 real/human3 ui/human_extra real/zextended

build "ui_aow_dvar"  "AoW:P - Dvar"     "L" media/aow/dvar
build "ui_aow_kirko" "AoW:P - Kir'Ko"   "L" media/aow/kirko

build "ui_dnd_kobold" "D&D - Kobold" "L" media/dnd/kobold

build "ui_elderscrolls_altmer"      "ElderScrolls - Altmer"     "R" media/elderscrolls/altmer
build "ui_elderscrolls_argonian"    "ElderScrolls - Argonian"   "R" media/elderscrolls/argonian
build "ui_elderscrolls_dremora"     "ElderScrolls - Dremora"    "R" media/elderscrolls/dremora
build "ui_elderscrolls_khajiit"     "ElderScrolls - Khajiit"    "R" media/elderscrolls/khajiit
build "ui_elderscrolls_orc"         "ElderScrolls - Orc"        "R" media/elderscrolls/orc
build "ui_elderscrolls_spriggan"    "ElderScrolls - Spriggan"   "R" media/elderscrolls/spriggan

build "ui_narivia_rodah" "Narivia - Rodah" "R" media/narivia/rodah

build "ui_runescape_human" "RuneScape - Human" "L" \
    media/runescape/human_asgarnian media/runescape/human_kandarin media/runescape/human_kharidian media/runescape/human_menaphite \
    media/runescape/human_misthalinian media/runescape/human

build "ui_starcraft_human"      "StarCraft - Human"     "L" media/starcraft/human
build "ui_starcraft_protoss"    "StarCraft - Protoss"   "R" \
    media/starcraft/protoss/khalai media/starcraft/protoss/nerazim media/starcraft/protoss/purifier media/starcraft/protoss/taldarim \
    media/starcraft/protoss/_

build "ui_starwars_human" "StarWars - Human" "L" media/starwars/human

build "ui_catfolk"          "Fantasy - Catfolk" "R" media/aow/tigran media/elderscrolls/khajiit
build "ui_demon"            "Fantasy - Demon"   "R" media/aow/draconian media/divinity/demon media/elderscrolls/dremora
build "ui_dwarven"          "Fantasy - Dwarven" "R" media/aow/dwarven media/divinity/dwarven
build "ui_elven"            "Fantasy - Elven"   "R" media/aow/elven media/divinity/elven media/elderscrolls/altmer media/elderscrolls/ayleid
build "ui_fantasy_spider"   "Fantasy - Spider"  "R" media/elderscrolls/spider media/middle-earth/spider media/generated/fantasy-name-generators/spiderfolk
build "ui_goblin"           "Fantasy - Goblin"  "R" media/aow/goblin media/divinity/goblin media/elderscrolls/goblin media/runescape/goblin
build "ui_lizard"           "Fantasy - Lizard"  "R" media/divinity/lizard media/elderscrolls/argonian
build "ui_orc"              "Fantasy - Orc"     "R" media/aow/orc media/divinity/orc media/elderscrolls/orc media/middle-earth/orc

build "ui_extra_art1" "Extra - Arthropoid 1"    "R" ui/art1
build "ui_extra_avi1" "Extra - Avian 1"         "R" ui/avi1
build "ui_extra_avi2" "Extra - Avian 2"         "R" ui/avi2
build "ui_extra_fun1" "Extra - Fungoid 1"       "R" ui/fun1
build "ui_extra_hum1" "Extra - Humanoid 1"      "R" ui/hum1
build "ui_extra_hum2" "Extra - Humanoid 2"      "R" ui/hum2
build "ui_extra_hum3" "Extra - Humanoid 3"      "R" ui/hum3
build "ui_extra_mam1" "Extra - Mammalian 1"     "R" ui/mam1
build "ui_extra_mam2" "Extra - Mammalian 2"     "R" ui/mam2
build "ui_extra_mol1" "Extra - Molluscoid 1"    "R" ui/mol1
build "ui_extra_mol2" "Extra - Molluscoid 2"    "R" ui/mol2
build "ui_extra_pla1" "Extra - Plantoid 1"      "R" ui/pla1
build "ui_extra_rep1" "Extra - Reptillian 1"    "R" ui/rep1
build "ui_extra_rep2" "Extra - Reptillian 2"    "R" ui/rep2
build "ui_extra_rep3" "Extra - Reptillian 3"    "R" ui/rep3
build "ui_extra_rep4" "Extra - Reptillian 4"    "R" ui/rep4

generate-mod-descriptor ${MOD_DESCRIPTOR_PRIMARY_FILE_PATH}
generate-mod-descriptor ${MOD_DESCRIPTOR_SECONDARY_FILE_PATH}

cp thumbnail.png ${MOD_THUMBNAIL_FILE_PATH}
