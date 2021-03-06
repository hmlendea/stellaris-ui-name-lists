#!/bin/bash

MOD_ID="ui-name-lists"
MOD_NAME="Universum Infinitum - Name Lists"
STELLARIS_VERSION="3.0.*"

BUILD_DIRECTORY_PATH="./build"
OUTPUT_DIRECTORY_PATH="./out"
OUTPUT_MOD_DIRECTORY_PATH="${OUTPUT_DIRECTORY_PATH}/${MOD_ID}"
OUTPUT_NAMELISTS_DIRECTORY_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/common/name_lists"
OUTPUT_LOCALISATION_DIRECTORY_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/localisation/english"
OUTPUT_LOCALISATION_FILE_PATH="${OUTPUT_LOCALISATION_DIRECTORY_PATH}/ui_names_l_english.yml"
GENERATOR_EXECUTABLE="dotnet ../stellaris-name-list-generator/bin/Debug/net5.0/StellarisNameListGenerator.dll"

MOD_THUMBNAIL_FILE_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/thumbnail.png"
MOD_DESCRIPTOR_PRIMARY_FILE_PATH="${OUTPUT_DIRECTORY_PATH}/${MOD_ID}.mod"
MOD_DESCRIPTOR_SECONDARY_FILE_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/descriptor.mod"

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
    human/algerian human/angolan human/congolese human/ethiopian human/malian human/mauritanian \
    human/nigerian human/senegalese human/somali human/swahili human/tunisian human/zambian human/zulu human/african
build "ui_extra_humans_arabic"          "Human - Arabic"            "L" human/arabic
build "ui_extra_humans_asian"           "Human - Asian"             "L" \
    human/chinese human/japanese human/korean human/mongol human/taiwanese human/tibetan human/vietnamese human/common_asian
build "ui_extra_humans_austronesian"    "Human - Austronesian"      "L" \
    human/filipino human/hawaiian human/indonesian human/kiribatian human/malaysian human/maori human/polynesian human/austronesian
build "ui_extra_humans_british"         "Human - British"           "L" \
    human/english human/scottish human/welsh human/common_british human/common_english
build "ui_extra_humans_celtic"          "Human - Celtic"            "L" human/icenic human/irish human/scottish human/welsh human/celtic
build "ui_extra_humans_chinese"         "Human - Chinese"           "L" human/chinese human/taiwanese human/common_asian
build "ui_extra_humans_english"         "Human - English"           "L" \
    human/american human/australian human/canadian human/english human/zealandian human/common_british human/common_english
build "ui_extra_humans_franco-iberian"  "Human - Franco-Iberian"    "L" \
    human/basque human/catalan human/french human/portuguese human/spanish human/common_iberian human/common_portuguese human/common_spanish
build "ui_extra_humans_french"          "Human - French"            "L" human/french
build "ui_extra_humans_german"          "Human - German"            "L" human/austrian human/german human/swiss human/common_german
build "ui_extra_humans_germanic"        "Human - Germanic"          "L" \
    human/austrian human/danish human/dutch human/german human/icelandic human/norwegian human/swedish \
    human/swiss human/germanic human/common_german human/common_norse
build "ui_extra_humans_hellenic"        "Human - Hellenic"          "L" human/cypriote human/greek human/common_hellenic
build "ui_extra_humans_hindi"           "Human - Hindi"             "L" \
    human/indian human/nepali human/pakistani human/tamil human/hindi
build "ui_extra_humans_iberian"         "Human - Iberian"           "L" \
    human/basque human/catalan human/portuguese human/spanish human/common_iberian human/common_portuguese human/common_spanish
build "ui_extra_humans_italian"         "Human - Italian"           "L" human/italian
build "ui_extra_humans_japanese"        "Human - Japanese"          "L" human/japanese
build "ui_extra_humans_latino"          "Human - Latino"            "L" \
    human/argentinian human/brazilian human/colombian human/cuban human/ecuadorian human/guatemalan human/mexican human/spanish human/venezuelan \
    human/common_spanish_americano human/common_portuguese human/common_spanish
build "ui_extra_humans_norse"           "Human - Norse"             "L" \
    human/danish human/icelandic human/norwegian human/swedish human/common_norse
build "ui_extra_humans_portuguese"      "Human - Portuguese EU"     "L" human/portuguese human/common_iberian human/common_portuguese
build "ui_extra_humans_portuguese_int"  "Human - Portuguese INT"    "L" \
    human/angolan human/brazilian human/portuguese human/common_iberian human/common_portuguese
build "ui_extra_humans_romanian"        "Human - Romanian"          "L" human/romanian
build "ui_extra_humans_romance"         "Human - Romance"           "L" \
    human/argentinian human/brazilian human/catalan human/colombian human/cuban human/ecuadorian human/french human/guatemalan \
    human/italian human/mexican human/portuguese human/roman human/romanian human/spanish human/venezuelan \
    human/common_iberian human/common_portuguese human/common_spanish_americano human/common_spanish
build "ui_extra_humans_russian"         "Human - Russian"           "L" human/russian
build "ui_extra_humans_slavic"          "Human - Slavic"            "L" \
    human/belarusian human/bosnian human/bulgarian human/croatian human/czech human/polish human/russian human/serbian human/slovakian \
    human/slovenian human/ukrainian human/common_slavic_yugoslavic human/common_slavic
build "ui_extra_humans_spqr_extended"   "Human - Roman"             "L" human/roman human/human3
build "ui_extra_humans_turkic"          "Human - Turkic"            "L" human/turkish human/turkmen
build "ui_extra_humans_yugoslavic"      "Human - Yugoslavic"        "L" \
    human/bosnian human/croatian human/serbian human/slovenian human/common_slavic_yugoslavic human/common_slavic
build "ui_extra_humans_extended"        "Human - Extended"          "L" \
    human/afghan human/african human/algerian human/american human/angolan human/arabic human/argentinian \
    human/armenian human/australian human/austrian human/austronesian human/belarusian \
    human/bosnian human/basque human/brazilian human/bulgarian human/canadian human/catalan \
    human/celtic human/chinese human/colombian human/congolese human/croatian human/cuban \
    human/cypriote human/czech human/danish human/dutch human/ecuadorian human/english \
    human/estonian human/ethiopian human/filipino human/french human/german human/germanic \
    human/greek human/greenlandic human/guatemalan human/hawaiian human/hebrew human/hindi \
    human/hungarian human/icelandic human/icenic human/indian human/indonesian human/italian human/irish \
    human/japanese human/kiribatian human/korean human/latvian human/lithuanian human/malaysian human/malian \
    human/maori human/mauritanian human/mexican human/mongol human/nepali human/nigerian \
    human/norwegian human/pakistani human/persian human/polish human/polynesian human/portuguese \
    human/roman human/romanian human/russian human/scottish human/senegalese human/serbian human/slovakian \
    human/slovenian human/somali human/spanish human/swahili human/swedish human/swiss human/taiwanese human/tamil \
    human/tibetan human/tunisian human/turkish human/turkmen human/ukrainian human/venezuelan \
    human/vietnamese human/welsh human/zambian human/zealandian human/zulu \
    \
    human/common_asian human/common_british human/common_english human/common_german human/common_hellenic \
    human/common_iberian human/common_norse human/common_portuguese human/common_slavic_yugoslavic human/common_slavic \
    human/common_spanish_americano human/common_spanish human/common \
    \
    starcraft/human starwars/human galciv/human sose/human runescape/human other-media/human \
    \
    human/human1 human/human2 human/human3 ui/human_extra human/zextended

build "ui_aow_dvar"  "AoW:P - Dvar" "L"    aow/dvar
build "ui_aow_kirko" "AoW:P - Kir'Ko" "L"  aow/kirko

build "ui_dnd_kobold" "D&D - Kobold" "L" dnd/kobold

build "ui_elderscrolls_altmer"      "ElderScrolls - Altmer"     "R" elderscrolls/altmer
build "ui_elderscrolls_argonian"    "ElderScrolls - Argonian"   "R" elderscrolls/argonian
build "ui_elderscrolls_dremora"     "ElderScrolls - Dremora"    "R" elderscrolls/dremora
build "ui_elderscrolls_khajiit"     "ElderScrolls - Khajiit"    "R" elderscrolls/khajiit
build "ui_elderscrolls_orc"         "ElderScrolls - Orc"        "R" elderscrolls/orc
build "ui_elderscrolls_spriggan"    "ElderScrolls - Spriggan"   "R" elderscrolls/spriggan

build "ui_narivia_rodah" "Narivia - Rodah" "R" narivia/rodah

build "ui_runescape_human" "RuneScape - Human" "L" runescape/human

build "ui_starcraft_human" "StarCraft - Human"      "L" starcraft/human
build "ui_starcraft_protoss" "StarCraft - Protoss"  "R" starcraft/protoss

build "ui_starwars_human" "StarWars - Human" "L" starwars/human

build "ui_catfolk"  "Catfolk"   "R" aow/tigran elderscrolls/khajiit
build "ui_demon"    "Demon"     "R" aow/draconian divinity/demon elderscrolls/dremora
build "ui_dwarven"  "Dwarven"   "R" aow/dwarven divinity/dwarven
build "ui_elven"    "Elven"     "R" aow/elven divinity/elven elderscrolls/altmer elderscrolls/ayleid
build "ui_goblin"   "Goblin"    "R" aow/goblin divinity/goblin elderscrolls/goblin runescape/goblin
build "ui_lizard"   "Lizard"    "R" divinity/lizard elderscrolls/argonian
build "ui_orc"      "Orc"       "R" aow/orc elderscrolls/orc

build "ui_extra_art1" "Extra - Arthropoid 1"    "R" ui/art1
build "ui_extra_avi1" "Extra - Avian 1"         "R" ui/avi1
build "ui_extra_avi2" "Extra - Avian 2"         "R" ui/avi2
build "ui_extra_fun1" "Extra - Fungoid 1"       "R" ui/fun1
build "ui_extra_hum1" "Extra - Humanoid 1"      "R" ui/hum1
build "ui_extra_hum2" "Extra - Humanoid 2"      "R" ui/hum2
build "ui_extra_mam1" "Extra - Mammalian 1"     "R" ui/mam1
build "ui_extra_mam2" "Extra - Mammalian 2"     "R" ui/mam2
build "ui_extra_mol1" "Extra - Molluscoid 1"    "R" ui/mol1
build "ui_extra_mol2" "Extra - Molluscoid 2"    "R" ui/mol2
build "ui_extra_pla1" "Extra - Plantoid 1"      "R" ui/pla1
build "ui_extra_rep1" "Extra - Reptillian 1"    "R" ui/rep1
build "ui_extra_rep2" "Extra - Reptillian 2"    "R" ui/rep2
build "ui_extra_rep3" "Extra - Reptillian 3"    "R" ui/rep3

generate-mod-descriptor ${MOD_DESCRIPTOR_PRIMARY_FILE_PATH}
generate-mod-descriptor ${MOD_DESCRIPTOR_SECONDARY_FILE_PATH}

cp thumbnail.png ${MOD_THUMBNAIL_FILE_PATH}
