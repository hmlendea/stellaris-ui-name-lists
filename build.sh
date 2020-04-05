#!/bin/bash

MOD_ID="ui-name-lists"
MOD_NAME="Universum Infinitum - Name Lists"
STELLARIS_VERSION="2.6.*"

BUILD_DIRECTORY_PATH="./build"
OUTPUT_DIRECTORY_PATH="./out"
OUTPUT_MOD_DIRECTORY_PATH="${OUTPUT_DIRECTORY_PATH}/${MOD_ID}"
OUTPUT_NAMELISTS_DIRECTORY_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/common/name_lists"
OUTPUT_LOCALISATION_DIRECTORY_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/localisation/english"
OUTPUT_LOCALISATION_FILE_PATH="${OUTPUT_LOCALISATION_DIRECTORY_PATH}/ui_names_l_english.yml"
GENERATOR_EXECUTABLE="dotnet /home/horatiu/Downloads/stellaris-name-list-generator/bin/Debug/netcoreapp3.1/StellarisNameListGenerator.dll"

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

build "ui_extra_humans_african"         "Human - African"       "L" human/african
build "ui_extra_humans_arabic"          "Human - Arabic"        "L" human/arabic
build "ui_extra_humans_asian"           "Human - Asian"         "L" human/asian
build "ui_extra_humans_austronesian"    "Human - Austronesian"  "L" human/austronesian
build "ui_extra_humans_celtic"          "Human - Celtic"        "L" human/celtic
build "ui_extra_humans_english"         "Human - English"       "L" human/english
build "ui_extra_humans_french"          "Human - French"        "L" human/french
build "ui_extra_humans_germanic"        "Human - Germanic"      "L" human/germanic
build "ui_extra_humans_hellenic"        "Human - Hellenic"      "L" human/hellenic
build "ui_extra_humans_hindi"           "Human - Hindi"         "L" human/hindi
build "ui_extra_humans_latino"          "Human - Latino"        "L" human/portuguese human/spanish
build "ui_extra_humans_romanian"        "Human - Romanian"      "L" human/romanian
build "ui_extra_humans_romance"         "Human - Romance"       "L" human/catalan human/french human/italian human/portuguese human/roman human/romanian human/spanish
build "ui_extra_humans_slavic"          "Human - Slavic"        "L" human/slavic
build "ui_extra_humans_spqr_extended"   "Human - Roman"         "L" human/roman human/human3
build "ui_extra_humans_turkic"          "Human - Turkic"        "L" human/turkic
build "ui_extra_humans_extended"        "Human - Extended"      "L" \
      human/african human/arabic human/asian human/austronesian human/baltic human/catalan human/celtic human/english \
      human/french human/germanic human/hebrew human/hellenic human/hindi human/hungarian human/italian human/persian \
      human/portuguese human/roman human/romanian human/slavic human/spanish human/turkic human/common \
      starcraft/human starwars/human galciv/human sose/human runescape/human other-media/human \
      human/human1 human/human2 human/human3 human/zextended

build "ui_dnd_kobold" "D&D - Kobold" "L" dnd/kobold

build "ui_elderscrolls_altmer"      "ElderScrolls - Altmer"     "R" elderscrolls/altmer
build "ui_elderscrolls_argonian"    "ElderScrolls - Argonian"   "R" elderscrolls/argonian
build "ui_elderscrolls_khajiit"     "ElderScrolls - Khajiit"    "R" elderscrolls/khajiit
build "ui_elderscrolls_orc"         "ElderScrolls - Orc"        "R" elderscrolls/orc
build "ui_elderscrolls_spriggan"    "ElderScrolls - Spriggan"   "R" elderscrolls/spriggan

build "ui_narivia_rodah" "Narivia - Rodah" "R" narivia/rodah

build "ui_runescape_human" "RuneScape - Human" "L" runescape/human

build "ui_starcraft_human" "StarCraft - Human"      "L" starcraft/human
build "ui_starcraft_protoss" "StarCraft - Protoss"  "R" starcraft/protoss

build "ui_starwars_human" "StarWars - Human" "L" starwars/human

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
