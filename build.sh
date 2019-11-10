#!/bin/bash

MOD_ID="ui-name-lists"
MOD_NAME="Universum Infinitum - Name Lists"
STELLARIS_VERSION="2.5.*"

BUILD_DIRECTORY_PATH="./build"
OUTPUT_DIRECTORY_PATH="./out"
OUTPUT_MOD_DIRECTORY_PATH="${OUTPUT_DIRECTORY_PATH}/${MOD_ID}"
OUTPUT_NAMELISTS_DIRECTORY_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/common/name_lists"
OUTPUT_LOCALISATION_DIRECTORY_PATH="${OUTPUT_MOD_DIRECTORY_PATH}/localisation/english"
OUTPUT_LOCALISATION_FILE_PATH="${OUTPUT_LOCALISATION_DIRECTORY_PATH}/ui_names_l_english.yml"
GENERATOR_EXECUTABLE="dotnet /home/horatiu/Downloads/stellaris-name-list-generator/bin/Debug/netcoreapp2.2/StellarisNameListGenerator.dll"

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
    NAMELIST_FILE_PATH="${BUILD_DIRECTORY_PATH}/${NAMELIST_ID}.xml"
    OUTPUT_NAMELIST_FILE_PATH="${OUTPUT_NAMELISTS_DIRECTORY_PATH}/${NAMELIST_ID}.txt"

    echo "Building ${NAMELIST_ID}..."

    merge ${NAMELIST_FILE_PATH} $@
    ${GENERATOR_EXECUTABLE} -i "${NAMELIST_FILE_PATH}" -o "${OUTPUT_NAMELIST_FILE_PATH}" -n "${NAMELIST_NAME}"
    add-localisation ${NAMELIST_ID}
}

function generate-mod-descriptor {
    FILE_PATH=$1

    echo "name=\"${MOD_NAME}\"" > ${FILE_PATH}
    echo "path=\"mod/${MOD_ID}\"" >> ${FILE_PATH}
    echo "tags={" >> ${FILE_PATH}
    echo "  \"Species\"" >> ${FILE_PATH}
    echo "}" >> ${FILE_PATH}
    echo "picture=\"logo.png\"" >> ${FILE_PATH}
    echo "supported_version=\"${STELLARIS_VERSION}\"" >> ${FILE_PATH}
}

build "ui_extra_humans_asian" "Human - Asian" human/asian
build "ui_extra_humans_germanic" "Human - Germanic" human/germanic
build "ui_extra_humans_latino" "Human - Latino" human/latino
build "ui_extra_humans_slavic" "Human - Slavic" human/slavic
build "ui_extra_humans_spqr_extended" "Human - Roman" human/roman human/human3
build "ui_extra_humans_extended" "Human - Extended" \
      human/african human/arabic human/asian human/baltic human/celtic human/english \
      human/french human/germanic human/hellenic human/hindi human/hungarian human/italian human/latino \
      human/persian human/roman human/romanian human/slavic human/turkic human/common \
      starcraft/human starwars/human runescape/human other-media/human human/human1 human/human2 human/human3 human/zextended

build "ui_dnd_kobold" "D&D - Kobold" dnd/kobold

build "ui_elderscrolls_altmer" "ElderScrolls - Altmer" elderscrolls/altmer
build "ui_elderscrolls_argonian" "ElderScrolls - Argonian" elderscrolls/argonian
build "ui_elderscrolls_khajiit" "ElderScrolls - Khajiit" elderscrolls/khajiit
build "ui_elderscrolls_orc" "ElderScrolls - Orc" elderscrolls/orc
build "ui_elderscrolls_spriggan" "ElderScrolls - Spriggan" elderscrolls/spriggan

build "ui_narivia_rodah" "Narivia - Rodah" narivia/rodah

build "ui_runescape_human" "RuneScape - Human" runescape/human

build "ui_starcraft_human" "StarCraft - Human" starcraft/human
build "ui_starcraft_protoss" "StarCraft - Protoss" starcraft/protoss

build "ui_starwars_human" "StarWars - Human" starwars/human

build "ui_extra_art1" "Extra - Arthropoid 1" ui/art1
build "ui_extra_avi1" "Extra - Avian 1" ui/avi1
build "ui_extra_fun1" "Extra - Fungoid 1" ui/fun1
build "ui_extra_hum1" "Extra - Humanoid 1" ui/hum1
build "ui_extra_mam1" "Extra - Mammalian 1" ui/mam1
build "ui_extra_mam2" "Extra - Mammalian 2" ui/mam2
build "ui_extra_mol1" "Extra - Molluscoid 1" ui/mol1
build "ui_extra_mol2" "Extra - Molluscoid 2" ui/mol2
build "ui_extra_pla1" "Extra - Plantoid 1" ui/pla1
build "ui_extra_rep1" "Extra - Reptillian 1" ui/rep1
build "ui_extra_rep2" "Extra - Reptillian 2" ui/rep2
build "ui_extra_rep3" "Extra - Reptillian 3" ui/rep3

generate-mod-descriptor ${MOD_DESCRIPTOR_PRIMARY_FILE_PATH}
generate-mod-descriptor ${MOD_DESCRIPTOR_SECONDARY_FILE_PATH}
